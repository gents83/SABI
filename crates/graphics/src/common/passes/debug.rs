use std::path::PathBuf;

use crate::{
    BindingData, BindingFlags, BindingInfo, CommandBuffer, ConstantDataRw, DataBuffers,
    DrawCommandType, IndicesBuffer, LightsBuffer, LoadOperation, MaterialsBuffer, MeshFlags,
    MeshesBuffer, MeshletsBuffer, Pass, RenderContext, RenderContextRc, RenderPass,
    RenderPassBeginData, RenderPassData, RenderTarget, RuntimeVerticesBuffer, SamplerType,
    ShaderStage, StoreOperation, TextureId, TextureView, TexturesBuffer, VertexAttributesBuffer,
    NUM_DATA_BUFFER,
};

use inox_core::ContextRc;
use inox_resources::{DataTypeResource, Resource, ResourceTrait};
use inox_uid::{generate_random_uid, INVALID_UID};

pub const DEBUG_PIPELINE: &str = "pipelines/Debug.render_pipeline";
pub const DEBUG_PASS_NAME: &str = "DebugPass";

pub struct DebugPass {
    render_pass: Resource<RenderPass>,
    binding_data: BindingData,
    constant_data: ConstantDataRw,
    meshes: MeshesBuffer,
    meshlets: MeshletsBuffer,
    indices: IndicesBuffer,
    runtime_vertices: RuntimeVerticesBuffer,
    vertices_attributes: VertexAttributesBuffer,
    textures: TexturesBuffer,
    materials: MaterialsBuffer,
    lights: LightsBuffer,
    finalize_texture: TextureId,
    visibility_texture: TextureId,
    depth_texture: TextureId,
    data_buffers: DataBuffers,
}
unsafe impl Send for DebugPass {}
unsafe impl Sync for DebugPass {}

impl Pass for DebugPass {
    fn name(&self) -> &str {
        DEBUG_PASS_NAME
    }
    fn static_name() -> &'static str {
        DEBUG_PASS_NAME
    }
    fn is_active(&self, _render_context: &RenderContext) -> bool {
        true
    }
    fn mesh_flags(&self) -> MeshFlags {
        MeshFlags::None
    }
    fn draw_commands_type(&self) -> DrawCommandType {
        DrawCommandType::PerMeshlet
    }
    fn create(context: &ContextRc, render_context: &RenderContextRc) -> Self
    where
        Self: Sized,
    {
        inox_profiler::scoped_profile!("debug_pass::create");

        let data = RenderPassData {
            name: DEBUG_PASS_NAME.to_string(),
            load_color: LoadOperation::Load,
            load_depth: LoadOperation::Load,
            store_color: StoreOperation::Store,
            store_depth: StoreOperation::Store,
            render_target: RenderTarget::Screen,
            pipeline: PathBuf::from(DEBUG_PIPELINE),
            ..Default::default()
        };

        Self {
            render_pass: RenderPass::new_resource(
                context.shared_data(),
                context.message_hub(),
                generate_random_uid(),
                &data,
                None,
            ),
            binding_data: BindingData::new(render_context, DEBUG_PASS_NAME),
            constant_data: render_context.global_buffers().constant_data.clone(),
            meshes: render_context.global_buffers().meshes.clone(),
            meshlets: render_context.global_buffers().meshlets.clone(),
            textures: render_context.global_buffers().textures.clone(),
            materials: render_context.global_buffers().materials.clone(),
            lights: render_context.global_buffers().lights.clone(),
            indices: render_context.global_buffers().indices.clone(),
            runtime_vertices: render_context.global_buffers().runtime_vertices.clone(),
            vertices_attributes: render_context.global_buffers().vertex_attributes.clone(),
            finalize_texture: INVALID_UID,
            visibility_texture: INVALID_UID,
            depth_texture: INVALID_UID,
            data_buffers: render_context.global_buffers().data_buffers.clone(),
        }
    }
    fn init(&mut self, render_context: &RenderContext) {
        inox_profiler::scoped_profile!("debug_pass::init");

        if self.indices.read().unwrap().is_empty()
            || self.meshes.read().unwrap().is_empty()
            || self.meshlets.read().unwrap().is_empty()
        {
            return;
        }

        let mut pass = self.render_pass.get_mut();

        self.binding_data
            .add_uniform_buffer(
                &mut *self.constant_data.write().unwrap(),
                Some("ConstantData"),
                BindingInfo {
                    group_index: 0,
                    binding_index: 0,
                    stage: ShaderStage::Fragment,
                    ..Default::default()
                },
            )
            .add_storage_buffer(
                &mut *self.indices.write().unwrap(),
                Some("Indices"),
                BindingInfo {
                    group_index: 0,
                    binding_index: 1,
                    stage: ShaderStage::Fragment,
                    flags: BindingFlags::Read | BindingFlags::Index,
                },
            )
            .add_storage_buffer(
                &mut *self.runtime_vertices.write().unwrap(),
                Some("Runtime Vertices"),
                BindingInfo {
                    group_index: 0,
                    binding_index: 2,
                    stage: ShaderStage::Fragment,
                    ..Default::default()
                },
            )
            .add_storage_buffer(
                &mut *self.vertices_attributes.write().unwrap(),
                Some("Vertices Attributes"),
                BindingInfo {
                    group_index: 0,
                    binding_index: 3,
                    stage: ShaderStage::Fragment,
                    ..Default::default()
                },
            )
            .add_storage_buffer(
                &mut *self.meshes.write().unwrap(),
                Some("Meshes"),
                BindingInfo {
                    group_index: 0,
                    binding_index: 4,
                    stage: ShaderStage::Fragment,
                    ..Default::default()
                },
            )
            .add_storage_buffer(
                &mut *self.meshlets.write().unwrap(),
                Some("Meshlets"),
                BindingInfo {
                    group_index: 0,
                    binding_index: 5,
                    stage: ShaderStage::Fragment,
                    ..Default::default()
                },
            )
            .add_storage_buffer(
                &mut *self.materials.write().unwrap(),
                Some("Materials"),
                BindingInfo {
                    group_index: 1,
                    binding_index: 0,
                    stage: ShaderStage::Fragment,
                    ..Default::default()
                },
            )
            .add_storage_buffer(
                &mut *self.textures.write().unwrap(),
                Some("Textures"),
                BindingInfo {
                    group_index: 1,
                    binding_index: 1,
                    stage: ShaderStage::Fragment,
                    ..Default::default()
                },
            )
            .add_uniform_buffer(
                &mut *self.lights.write().unwrap(),
                Some("Lights"),
                BindingInfo {
                    group_index: 1,
                    binding_index: 2,
                    stage: ShaderStage::Fragment,
                    ..Default::default()
                },
            )
            .add_texture(
                &self.visibility_texture,
                BindingInfo {
                    group_index: 1,
                    binding_index: 3,
                    stage: ShaderStage::Fragment,
                    ..Default::default()
                },
            )
            .add_texture(
                &self.depth_texture,
                BindingInfo {
                    group_index: 1,
                    binding_index: 4,
                    stage: ShaderStage::Fragment,
                    ..Default::default()
                },
            );

        self.binding_data
            .add_default_sampler(
                BindingInfo {
                    group_index: 2,
                    binding_index: 0,
                    stage: ShaderStage::Fragment,
                    ..Default::default()
                },
                SamplerType::Unfiltered,
            )
            .add_material_textures(BindingInfo {
                group_index: 2,
                binding_index: 1,
                stage: ShaderStage::Fragment,
                ..Default::default()
            });

        for i in 0..NUM_DATA_BUFFER {
            self.binding_data.add_storage_buffer(
                &mut *self.data_buffers[i].write().unwrap(),
                Some(format!("DataBuffer_{}", i).as_str()),
                BindingInfo {
                    group_index: 3,
                    binding_index: i,
                    stage: ShaderStage::Fragment,
                    ..Default::default()
                },
            );
        }
        pass.init(render_context, &mut self.binding_data, None, None);
    }
    fn update(
        &mut self,
        render_context: &RenderContext,
        surface_view: &TextureView,
        command_buffer: &mut CommandBuffer,
    ) {
        inox_profiler::scoped_profile!("debug_pass::update");

        let pass = self.render_pass.get();
        let pipeline = pass.pipeline().get();
        if !pipeline.is_initialized() {
            return;
        }
        let buffers = render_context.buffers();
        let render_targets = render_context.texture_handler().render_targets();

        let render_pass_begin_data = RenderPassBeginData {
            render_core_context: &render_context.webgpu,
            buffers: &buffers,
            render_targets: render_targets.as_slice(),
            surface_view,
            command_buffer,
        };
        let mut render_pass = pass.begin(&mut self.binding_data, &pipeline, render_pass_begin_data);
        {
            inox_profiler::gpu_scoped_profile!(
                &mut render_pass,
                &render_context.webgpu.device,
                "debug_pass",
            );
            pass.draw(render_context, render_pass, 0..3, 0..1);
        }
    }
}

impl DebugPass {
    pub fn set_visibility_texture(&mut self, texture_id: &TextureId) -> &mut Self {
        self.visibility_texture = *texture_id;
        self
    }
    pub fn set_depth_texture(&mut self, texture_id: &TextureId) -> &mut Self {
        self.depth_texture = *texture_id;
        self
    }
    pub fn set_finalize_texture(&mut self, texture_id: &TextureId) -> &mut Self {
        self.finalize_texture = *texture_id;
        self
    }
}