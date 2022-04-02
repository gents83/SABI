use inox_core::{JobHandlerRw, System};

use inox_math::Vector2;
use inox_messenger::{Listener, MessageHubRc};
use inox_platform::WindowEvent;
use inox_resources::{
    ConfigBase, ConfigEvent, DataTypeResource, ReloadEvent, Resource, ResourceEvent,
    SerializableResource, SerializableResourceEvent, SharedData, SharedDataRc,
};
use inox_serialize::read_from_file;
use inox_uid::generate_random_uid;

use crate::{
    is_shader, Light, Material, Mesh, Pipeline, RenderPass, RendererRw, RendererState, Texture,
    View,
};

use super::config::Config;
pub const RENDERING_UPDATE: &str = "RENDERING_UPDATE";

pub struct UpdateSystem {
    config: Config,
    renderer: RendererRw,
    shared_data: SharedDataRc,
    message_hub: MessageHubRc,
    job_handler: JobHandlerRw,
    listener: Listener,
    render_passes: Vec<Resource<RenderPass>>,
    view: Resource<View>,
}

impl UpdateSystem {
    pub fn new(
        renderer: RendererRw,
        shared_data: &SharedDataRc,
        message_hub: &MessageHubRc,
        job_handler: &JobHandlerRw,
    ) -> Self {
        let listener = Listener::new(message_hub);

        Self {
            view: View::new_resource(shared_data, message_hub, generate_random_uid(), 0),
            config: Config::default(),
            renderer,
            shared_data: shared_data.clone(),
            message_hub: message_hub.clone(),
            job_handler: job_handler.clone(),
            listener,
            render_passes: Vec::new(),
        }
    }

    fn handle_events(&mut self) {
        //REMINDER: message processing order is important - RenderPass must be processed before Texture
        self.listener
            .process_messages(|e: &WindowEvent| {
                if let WindowEvent::SizeChanged(width, height) = e {
                    let mut renderer = self.renderer.write().unwrap();
                    renderer.set_surface_size(*width, *height);
                }
            })
            .process_messages(|e: &ReloadEvent| {
                let ReloadEvent::Reload(path) = e;
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
            })
            .process_messages(|e: &ResourceEvent<RenderPass>| match e {
                ResourceEvent::Changed(id) => {
                    self.renderer.write().unwrap().on_render_pass_changed(id);
                }
                ResourceEvent::Created(r) => {
                    self.renderer
                        .write()
                        .unwrap()
                        .on_render_pass_changed(r.id());
                }
                _ => {}
            })
            .process_messages(|e: &ResourceEvent<Texture>| match e {
                ResourceEvent::Changed(id) => {
                    self.renderer.write().unwrap().on_texture_changed(id);
                }
                ResourceEvent::Created(t) => {
                    self.renderer.write().unwrap().on_texture_changed(t.id());
                }
                _ => {}
            })
            .process_messages(|e: &ResourceEvent<Light>| match e {
                ResourceEvent::Changed(id) => {
                    self.renderer.write().unwrap().on_light_changed(id);
                }
                ResourceEvent::Created(l) => {
                    self.renderer.write().unwrap().on_light_changed(l.id());
                }
                _ => {}
            })
            .process_messages(|e: &ResourceEvent<Material>| match e {
                ResourceEvent::Changed(id) => {
                    self.renderer.write().unwrap().on_material_changed(id);
                }
                ResourceEvent::Created(m) => {
                    self.renderer.write().unwrap().on_material_changed(m.id());
                }
                _ => {}
            })
            .process_messages(|e: &ResourceEvent<Mesh>| {
                if let ResourceEvent::Changed(id) = e {
                    self.renderer.write().unwrap().on_mesh_changed(id);
                }
            })
            .process_messages(|e: &ConfigEvent<Config>| match e {
                ConfigEvent::Loaded(filename, config) => {
                    if filename == self.config.get_filename() {
                        self.config = config.clone();
                        self.render_passes.clear();
                        for render_pass_data in self.config.render_passes.iter() {
                            self.render_passes.push(RenderPass::new_resource(
                                &self.shared_data,
                                &self.message_hub,
                                generate_random_uid(),
                                render_pass_data.clone(),
                            ));
                        }
                    }
                }
            });
    }
}

unsafe impl Send for UpdateSystem {}
unsafe impl Sync for UpdateSystem {}

impl System for UpdateSystem {
    fn read_config(&mut self, plugin_name: &str) {
        self.listener.register::<ConfigEvent<Config>>();
        let message_hub = self.message_hub.clone();
        let filename = self.config.get_filename().to_string();
        read_from_file(
            self.config.get_filepath(plugin_name).as_path(),
            self.shared_data.serializable_registry(),
            Box::new(move |data: Config| {
                message_hub.send_event(ConfigEvent::Loaded(filename.clone(), data));
            }),
        );
    }

    fn should_run_when_not_focused(&self) -> bool {
        false
    }
    fn init(&mut self) {
        self.listener
            .register::<WindowEvent>()
            .register::<SerializableResourceEvent<Pipeline>>()
            .register::<SerializableResourceEvent<Texture>>()
            .register::<ResourceEvent<RenderPass>>()
            .register::<ResourceEvent<Material>>()
            .register::<ResourceEvent<Texture>>()
            .register::<ResourceEvent<Light>>()
            .register::<ResourceEvent<Mesh>>();
    }

    fn run(&mut self) -> bool {
        let state = self.renderer.read().unwrap().state();
        if state != RendererState::Submitted {
            if state == RendererState::Init {
                self.renderer.write().unwrap().check_initialization();
            }
            return true;
        }

        {
            let mut renderer = self.renderer.write().unwrap();
            renderer.change_state(RendererState::Preparing);
        }

        self.handle_events();

        {
            let mut renderer = self.renderer.write().unwrap();

            let resolution = renderer.resolution();
            let screen_size = Vector2::new(resolution.0 as f32, resolution.1 as f32);
            renderer.update_shader_data(
                self.view.get().view(),
                self.view.get().proj(),
                screen_size,
            );

            renderer.send_to_gpu();

            renderer.change_state(RendererState::Prepared);
        }

        true
    }
    fn uninit(&mut self) {
        self.listener
            .unregister::<WindowEvent>()
            .unregister::<SerializableResourceEvent<Pipeline>>()
            .unregister::<SerializableResourceEvent<Texture>>()
            .unregister::<ConfigEvent<Config>>()
            .unregister::<ResourceEvent<Light>>()
            .unregister::<ResourceEvent<Texture>>()
            .unregister::<ResourceEvent<Material>>()
            .unregister::<ResourceEvent<RenderPass>>()
            .unregister::<ResourceEvent<Mesh>>();
    }
}
