use std::path::PathBuf;

use crate::{
    BHVBuffer, BindingData, BindingFlags, BindingInfo, CommandBuffer, ComputePass, ComputePassData,
    ConstantDataRw, CullingResults, DrawCommandType, IndicesBuffer, LightsBuffer, MaterialsBuffer,
    MeshFlags, MeshesBuffer, MeshletsBuffer, OutputPass, Pass, RenderContext,
    RuntimeVerticesBuffer, SamplerType, ShaderStage, Texture, TextureFormat, TextureId,
    TextureUsage, TextureView, TexturesBuffer, VertexAttributesBuffer,
};

use inox_core::ContextRc;
use inox_resources::{DataTypeResource, Handle, Resource};
use inox_uid::{generate_random_uid, INVALID_UID};

pub const COMPUTE_PATHTRACING_DIRECT_PIPELINE: &str =
    "pipelines/ComputePathtracingDirect.compute_pipeline";
pub const COMPUTE_PATHTRACING_DIRECT_NAME: &str = "ComputePathTracingDirectPass";

pub struct ComputePathTracingDirectPass {
    context: ContextRc,
    compute_pass: Resource<ComputePass>,
    binding_data: BindingData,
    constant_data: ConstantDataRw,
    radiance_render_target: Handle<Texture>,
    rays_render_target: Handle<Texture>,
    meshes: MeshesBuffer,
    meshlets: MeshletsBuffer,
    culling_result: CullingResults,
    bhv: BHVBuffer,
    indices: IndicesBuffer,
    runtime_vertices: RuntimeVerticesBuffer,
    vertices_attributes: VertexAttributesBuffer,
    textures: TexturesBuffer,
    materials: MaterialsBuffer,
    lights: LightsBuffer,
    visibility_texture: TextureId,
    depth_texture: TextureId,
}
unsafe impl Send for ComputePathTracingDirectPass {}
unsafe impl Sync for ComputePathTracingDirectPass {}

impl Pass for ComputePathTracingDirectPass {
    fn name(&self) -> &str {
        COMPUTE_PATHTRACING_DIRECT_NAME
    }
    fn static_name() -> &'static str {
        COMPUTE_PATHTRACING_DIRECT_NAME
    }
    fn is_active(&self, render_context: &RenderContext) -> bool {
        render_context.has_commands(&self.draw_commands_type(), &self.mesh_flags())
    }
    fn mesh_flags(&self) -> MeshFlags {
        MeshFlags::Visible | MeshFlags::Opaque
    }
    fn draw_commands_type(&self) -> DrawCommandType {
        DrawCommandType::PerMeshlet
    }
    fn create(context: &ContextRc, render_context: &RenderContext) -> Self
    where
        Self: Sized,
    {
        let data = ComputePassData {
            name: COMPUTE_PATHTRACING_DIRECT_NAME.to_string(),
            pipelines: vec![PathBuf::from(COMPUTE_PATHTRACING_DIRECT_PIPELINE)],
        };

        Self {
            context: context.clone(),
            compute_pass: ComputePass::new_resource(
                context.shared_data(),
                context.message_hub(),
                generate_random_uid(),
                &data,
                None,
            ),
            constant_data: render_context.constant_data.clone(),
            meshes: render_context.render_buffers.meshes.clone(),
            meshlets: render_context.render_buffers.meshlets.clone(),
            culling_result: render_context.render_buffers.culling_result.clone(),
            bhv: render_context.render_buffers.bhv.clone(),
            indices: render_context.render_buffers.indices.clone(),
            runtime_vertices: render_context.render_buffers.runtime_vertices.clone(),
            vertices_attributes: render_context.render_buffers.vertex_attributes.clone(),
            textures: render_context.render_buffers.textures.clone(),
            materials: render_context.render_buffers.materials.clone(),
            lights: render_context.render_buffers.lights.clone(),
            binding_data: BindingData::new(render_context, COMPUTE_PATHTRACING_DIRECT_NAME),
            radiance_render_target: None,
            rays_render_target: None,
            visibility_texture: INVALID_UID,
            depth_texture: INVALID_UID,
        }
    }
    fn init(&mut self, render_context: &RenderContext) {
        inox_profiler::scoped_profile!("pathtracing_direct_pass::init");

        if self.radiance_render_target.is_none()
            || self.rays_render_target.is_none()
            || self.meshlets.read().unwrap().is_empty()
        {
            return;
        }

        self.binding_data
            .add_uniform_buffer(
                &mut *self.constant_data.write().unwrap(),
                Some("ConstantData"),
                BindingInfo {
                    group_index: 0,
                    binding_index: 0,
                    stage: ShaderStage::Compute,
                    ..Default::default()
                },
            )
            .add_storage_buffer(
                &mut *self.indices.write().unwrap(),
                Some("Indices"),
                BindingInfo {
                    group_index: 0,
                    binding_index: 1,
                    stage: ShaderStage::Compute,
                    flags: BindingFlags::Read | BindingFlags::Index,
                },
            )
            .add_storage_buffer(
                &mut *self.vertices_attributes.write().unwrap(),
                Some("Vertices Attributes"),
                BindingInfo {
                    group_index: 0,
                    binding_index: 2,
                    stage: ShaderStage::Compute,
                    ..Default::default()
                },
            )
            .add_storage_buffer(
                &mut *self.meshes.write().unwrap(),
                Some("Meshes"),
                BindingInfo {
                    group_index: 0,
                    binding_index: 3,
                    stage: ShaderStage::Compute,
                    ..Default::default()
                },
            )
            .add_storage_buffer(
                &mut *self.meshlets.write().unwrap(),
                Some("Meshlets"),
                BindingInfo {
                    group_index: 0,
                    binding_index: 4,
                    stage: ShaderStage::Compute,
                    ..Default::default()
                },
            )
            .add_storage_buffer(
                &mut *self.materials.write().unwrap(),
                Some("Materials"),
                BindingInfo {
                    group_index: 0,
                    binding_index: 5,
                    stage: ShaderStage::Compute,
                    ..Default::default()
                },
            )
            .add_storage_buffer(
                &mut *self.textures.write().unwrap(),
                Some("Textures"),
                BindingInfo {
                    group_index: 0,
                    binding_index: 6,
                    stage: ShaderStage::Compute,
                    ..Default::default()
                },
            )
            .add_storage_buffer(
                &mut *self.lights.write().unwrap(),
                Some("Lights"),
                BindingInfo {
                    group_index: 0,
                    binding_index: 7,
                    stage: ShaderStage::Compute,
                    ..Default::default()
                },
            )
            .add_storage_buffer(
                &mut *self.runtime_vertices.write().unwrap(),
                Some("Runtime Vertices"),
                BindingInfo {
                    group_index: 1,
                    binding_index: 0,
                    stage: ShaderStage::Compute,
                    flags: BindingFlags::Read | BindingFlags::Vertex,
                },
            )
            .add_storage_buffer(
                &mut *self.culling_result.write().unwrap(),
                Some("Culling Results"),
                BindingInfo {
                    group_index: 1,
                    binding_index: 1,
                    stage: ShaderStage::Compute,
                    flags: BindingFlags::Read | BindingFlags::Indirect,
                },
            )
            .add_storage_buffer(
                &mut *self.bhv.write().unwrap(),
                Some("BHV"),
                BindingInfo {
                    group_index: 1,
                    binding_index: 2,
                    stage: ShaderStage::Compute,
                    ..Default::default()
                },
            )
            .add_texture(
                self.radiance_render_target.as_ref().unwrap().id(),
                BindingInfo {
                    group_index: 1,
                    binding_index: 3,
                    stage: ShaderStage::Compute,
                    flags: BindingFlags::ReadWrite | BindingFlags::Storage,
                },
            )
            .add_texture(
                self.rays_render_target.as_ref().unwrap().id(),
                BindingInfo {
                    group_index: 1,
                    binding_index: 4,
                    stage: ShaderStage::Compute,
                    flags: BindingFlags::ReadWrite | BindingFlags::Storage,
                },
            )
            .add_texture(
                &self.visibility_texture,
                BindingInfo {
                    group_index: 1,
                    binding_index: 5,
                    stage: ShaderStage::Compute,
                    ..Default::default()
                },
            )
            .add_texture(
                &self.depth_texture,
                BindingInfo {
                    group_index: 1,
                    binding_index: 6,
                    stage: ShaderStage::Compute,
                    ..Default::default()
                },
            );

        self.binding_data
            .add_default_sampler(
                BindingInfo {
                    group_index: 2,
                    binding_index: 0,
                    stage: ShaderStage::Compute,
                    ..Default::default()
                },
                SamplerType::Unfiltered,
            )
            .add_material_textures(BindingInfo {
                group_index: 2,
                binding_index: 1,
                stage: ShaderStage::Compute,
                ..Default::default()
            });

        let mut pass = self.compute_pass.get_mut();
        pass.init(render_context, &mut self.binding_data);
    }

    fn update(
        &mut self,
        render_context: &RenderContext,
        _surface_view: &TextureView,
        command_buffer: &mut CommandBuffer,
    ) {
        if self.radiance_render_target.is_none() || self.meshlets.read().unwrap().is_empty() {
            return;
        }

        inox_profiler::scoped_profile!("pathtracing_direct_pass::update");

        let pass = self.compute_pass.get();

        let x_pixels_managed_in_shader = 16;
        let y_pixels_managed_in_shader = 16;
        let dimensions = self
            .radiance_render_target
            .as_ref()
            .unwrap()
            .get()
            .dimensions();
        let x = (x_pixels_managed_in_shader
            * ((dimensions.0 + x_pixels_managed_in_shader - 1) / x_pixels_managed_in_shader))
            / x_pixels_managed_in_shader;
        let y = (y_pixels_managed_in_shader
            * ((dimensions.1 + y_pixels_managed_in_shader - 1) / y_pixels_managed_in_shader))
            / y_pixels_managed_in_shader;

        pass.dispatch(
            render_context,
            &mut self.binding_data,
            command_buffer,
            x,
            y,
            1,
        );
    }
}

impl OutputPass for ComputePathTracingDirectPass {
    fn render_targets_id(&self) -> Option<Vec<TextureId>> {
        Some(
            [
                *self.radiance_render_target.as_ref().unwrap().id(),
                *self.rays_render_target.as_ref().unwrap().id(),
            ]
            .to_vec(),
        )
    }
    fn depth_target_id(&self) -> Option<TextureId> {
        None
    }
}

impl ComputePathTracingDirectPass {
    pub fn set_visibility_texture(&mut self, texture_id: &TextureId) -> &mut Self {
        self.visibility_texture = *texture_id;
        self
    }
    pub fn set_depth_texture(&mut self, texture_id: &TextureId) -> &mut Self {
        self.depth_texture = *texture_id;
        self
    }
    pub fn add_radiance_render_target_with_resolution(
        &mut self,
        width: u32,
        height: u32,
        render_format: TextureFormat,
    ) -> &mut Self {
        self.radiance_render_target = Some(Texture::create_from_format(
            self.context.shared_data(),
            self.context.message_hub(),
            width,
            height,
            render_format,
            TextureUsage::TextureBinding
                | TextureUsage::CopySrc
                | TextureUsage::CopyDst
                | TextureUsage::RenderAttachment
                | TextureUsage::StorageBinding,
        ));
        self
    }
    pub fn add_ray_render_target_with_resolution(
        &mut self,
        width: u32,
        height: u32,
        render_format: TextureFormat,
    ) -> &mut Self {
        self.rays_render_target = Some(Texture::create_from_format(
            self.context.shared_data(),
            self.context.message_hub(),
            width,
            height,
            render_format,
            TextureUsage::CopySrc | TextureUsage::CopyDst | TextureUsage::StorageBinding,
        ));
        self
    }
}