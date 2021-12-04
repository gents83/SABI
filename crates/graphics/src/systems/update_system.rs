use std::{
    any::TypeId,
    path::PathBuf,
    sync::{
        atomic::{AtomicUsize, Ordering},
        Arc,
    },
    thread,
};

use sabi_core::{JobHandlerRw, System};

use sabi_messenger::{read_messages, MessageChannel, MessengerRw};
use sabi_resources::{
    ConfigBase, DataTypeResource, Resource, SerializableResource, SharedData, SharedDataRc,
    UpdateResourceEvent,
};
use sabi_serialize::{generate_random_uid, read_from_file};

use crate::{
    is_shader, Mesh, MeshId, Pipeline, RenderPass, RenderPassData, RendererRw, RendererState,
    Texture, INVALID_INDEX,
};

use super::config::Config;
pub const RENDERING_UPDATE: &str = "RENDERING_UPDATE";

pub struct UpdateSystem {
    renderer: RendererRw,
    shared_data: SharedDataRc,
    global_messenger: MessengerRw,
    job_handler: JobHandlerRw,
    message_channel: MessageChannel,
    render_passes: Vec<Resource<RenderPass>>,
    pipelines: Vec<Resource<Pipeline>>,
}

impl UpdateSystem {
    pub fn new(
        renderer: RendererRw,
        shared_data: &SharedDataRc,
        global_messenger: &MessengerRw,
        job_handler: &JobHandlerRw,
    ) -> Self {
        let message_channel = MessageChannel::default();
        global_messenger
            .write()
            .unwrap()
            .register_messagebox::<UpdateResourceEvent>(message_channel.get_messagebox());

        crate::register_resource_types(shared_data);
        Self {
            renderer,
            shared_data: shared_data.clone(),
            global_messenger: global_messenger.clone(),
            job_handler: job_handler.clone(),
            message_channel,
            render_passes: Vec::new(),
            pipelines: Vec::new(),
        }
    }

    pub fn load_render_passes(&mut self, render_passes: &[RenderPassData]) -> &mut Self {
        for render_pass_data in render_passes.iter() {
            self.render_passes.push(RenderPass::new_resource(
                &self.shared_data,
                &self.global_messenger,
                generate_random_uid(),
                render_pass_data.clone(),
            ));
        }
        self
    }

    pub fn load_pipelines(&mut self, pipelines: &[PathBuf]) -> &mut Self {
        for pipeline_path in pipelines.iter() {
            let pipeline = Pipeline::create_from_file(
                &self.shared_data,
                &self.global_messenger,
                pipeline_path.as_path(),
                None,
            );
            self.pipelines.push(pipeline);
        }
        self
    }

    fn handle_events(&self) {
        read_messages(self.message_channel.get_listener(), |msg| {
            if msg.type_id() == TypeId::of::<UpdateResourceEvent>() {
                let e = msg.as_any().downcast_ref::<UpdateResourceEvent>().unwrap();
                let path = e.path.as_path();
                if is_shader(path) {
                    SharedData::for_each_resource_mut(&self.shared_data, |_, p: &mut Pipeline| {
                        p.check_shaders_to_reload(path.to_str().unwrap().to_string());
                    });
                } else if Texture::is_matching_extension(path) {
                    SharedData::for_each_resource_mut(&self.shared_data, |_, t: &mut Texture| {
                        if t.path() == path {
                            t.invalidate();
                        }
                    });
                }
            }
        });
    }

    fn create_render_mesh_job(
        renderer: &RendererRw,
        mesh_id: &MeshId,
        mesh: &mut Mesh,
        render_pass_pipeline: Option<&Resource<Pipeline>>,
    ) {
        let renderer = renderer.read().unwrap();
        let device = renderer.device();
        let physical_device = renderer.instance().get_physical_device();
        let mut material_index = INVALID_INDEX;
        if let Some(material) = mesh.material() {
            if material.get().is_initialized() {
                material_index = material.get().uniform_index();
            }
        }
        if let Some(pipeline) = render_pass_pipeline {
            pipeline.get_mut().add_mesh_instance(
                device,
                physical_device,
                mesh_id,
                mesh,
                material_index,
            );
        } else if let Some(material) = mesh.material() {
            if let Some(pipeline) = material.get().pipeline() {
                pipeline.get_mut().add_mesh_instance(
                    device,
                    physical_device,
                    mesh_id,
                    mesh,
                    material_index,
                );
            }
        }
    }
}

impl Drop for UpdateSystem {
    fn drop(&mut self) {
        crate::unregister_resource_types(&self.shared_data);
    }
}

unsafe impl Send for UpdateSystem {}
unsafe impl Sync for UpdateSystem {}

impl System for UpdateSystem {
    fn read_config(&mut self, plugin_name: &str) {
        let mut config = Config::default();
        config = read_from_file(config.get_filepath(plugin_name).as_path());

        self.load_render_passes(&config.render_passes)
            .load_pipelines(&config.pipelines);
    }

    fn should_run_when_not_focused(&self) -> bool {
        false
    }
    fn init(&mut self) {}

    fn run(&mut self) -> bool {
        let state = self.renderer.read().unwrap().state();
        if state != RendererState::Submitted {
            return true;
        }

        self.handle_events();

        let wait_count = Arc::new(AtomicUsize::new(0));

        {
            let mut renderer = self.renderer.write().unwrap();
            if !renderer.device_mut().acquire_image() {
                renderer.recreate();
                return true;
            }
            renderer.change_state(RendererState::Preparing);
            renderer.prepare_frame();
        }

        SharedData::for_each_resource(&self.shared_data, |texture_handle, texture: &Texture| {
            if texture.update_from_gpu() {
                let job_name = format!("Readback texture {:?}", texture_handle.id());
                let renderer = self.renderer.clone();
                let texture = texture_handle.clone();
                let wait_count = wait_count.clone();
                wait_count.fetch_add(1, Ordering::SeqCst);
                self.job_handler.write().unwrap().add_job(
                    &UpdateSystem::id(),
                    job_name.as_str(),
                    move || {
                        let renderer = renderer.read().unwrap();
                        let device = renderer.device();
                        let physical_device = renderer.instance().get_physical_device();
                        let texture_handler = renderer.get_texture_handler();
                        texture.get_mut().capture_image(
                            texture.id(),
                            texture_handler,
                            device,
                            physical_device,
                        );

                        wait_count.fetch_sub(1, Ordering::SeqCst);
                    },
                );
            }
        });

        SharedData::for_each_resource(&self.shared_data, |_, render_pass: &RenderPass| {
            if render_pass.is_initialized() {
                let mesh_category_to_draw = render_pass.mesh_category_to_draw().to_vec();
                SharedData::for_each_resource(&self.shared_data, |mesh_handle, mesh: &Mesh| {
                    let should_render = mesh_category_to_draw
                        .iter()
                        .any(|id| mesh.category_identifier() == id);

                    if !should_render || !mesh.is_visible() || !mesh.is_initialized() {
                        return;
                    }
                    let renderer = self.renderer.clone();
                    let wait_count = wait_count.clone();
                    let mesh_handle = mesh_handle.clone();
                    let pipeline = render_pass.pipeline().clone();

                    let job_name = format!(
                        "Processing mesh {:?} for RenderPass [{:?}",
                        mesh_handle.id(),
                        render_pass.data().name
                    );
                    wait_count.fetch_add(1, Ordering::SeqCst);
                    self.job_handler.write().unwrap().add_job(
                        &UpdateSystem::id(),
                        job_name.as_str(),
                        move || {
                            let mesh_id = *mesh_handle.id();
                            sabi_profiler::scoped_profile!(format!(
                                "create_render_mesh_job[{}]",
                                mesh_id
                            )
                            .as_str());
                            Self::create_render_mesh_job(
                                &renderer,
                                &mesh_id,
                                &mut mesh_handle.get_mut(),
                                pipeline.as_ref(),
                            );
                            wait_count.fetch_sub(1, Ordering::SeqCst);
                        },
                    );
                });
            }
        });

        let renderer = self.renderer.clone();
        let job_name = "EndPreparation";
        self.job_handler
            .write()
            .unwrap()
            .add_job(&UpdateSystem::id(), job_name, move || {
                while wait_count.load(Ordering::SeqCst) > 0 {
                    thread::yield_now();
                }

                let mut r = renderer.write().unwrap();
                r.change_state(RendererState::Prepared);
            });

        true
    }
    fn uninit(&mut self) {}
}