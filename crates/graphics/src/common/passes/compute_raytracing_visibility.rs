use std::{path::PathBuf, sync::atomic::Ordering};

use crate::{
    BHVBuffer, BindingData, BindingFlags, BindingInfo, CommandBuffer, ComputePass, ComputePassData,
    CullingResults, DrawCommandType, IndicesBuffer, MeshFlags, MeshesBuffer,
    MeshesInverseMatrixBuffer, MeshletsBuffer, OutputPass, Pass, RaysBuffer, RenderContext,
    RuntimeVerticesBuffer, ShaderStage, Texture, TextureFormat, TextureId, TextureUsage,
    TextureView,
};

use inox_core::ContextRc;
use inox_resources::{DataTypeResource, Handle, Resource};
use inox_uid::generate_random_uid;

pub const COMPUTE_RAYTRACING_VISIBILITY_PIPELINE: &str =
    "pipelines/ComputeRayTracingVisibility.compute_pipeline";
pub const COMPUTE_RAYTRACING_VISIBILITY_NAME: &str = "ComputeRayTracingVisibilityPass";

pub struct ComputeRayTracingVisibilityPass {
    context: ContextRc,
    compute_pass: Resource<ComputePass>,
    binding_data: BindingData,
    render_target: Handle<Texture>,
    meshes: MeshesBuffer,
    meshes_inverse_matrix: MeshesInverseMatrixBuffer,
    meshlets: MeshletsBuffer,
    culling_result: CullingResults,
    bhv: BHVBuffer,
    indices: IndicesBuffer,
    runtime_vertices: RuntimeVerticesBuffer,
    rays: RaysBuffer,
}
unsafe impl Send for ComputeRayTracingVisibilityPass {}
unsafe impl Sync for ComputeRayTracingVisibilityPass {}

impl Pass for ComputeRayTracingVisibilityPass {
    fn name(&self) -> &str {
        COMPUTE_RAYTRACING_VISIBILITY_NAME
    }
    fn static_name() -> &'static str {
        COMPUTE_RAYTRACING_VISIBILITY_NAME
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
            name: COMPUTE_RAYTRACING_VISIBILITY_NAME.to_string(),
            pipelines: vec![PathBuf::from(COMPUTE_RAYTRACING_VISIBILITY_PIPELINE)],
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
            meshes: render_context.render_buffers.meshes.clone(),
            meshes_inverse_matrix: render_context.render_buffers.meshes_inverse_matrix.clone(),
            meshlets: render_context.render_buffers.meshlets.clone(),
            culling_result: render_context.render_buffers.culling_result.clone(),
            bhv: render_context.render_buffers.bhv.clone(),
            indices: render_context.render_buffers.indices.clone(),
            runtime_vertices: render_context.render_buffers.runtime_vertices.clone(),
            binding_data: BindingData::new(render_context, COMPUTE_RAYTRACING_VISIBILITY_NAME),
            render_target: None,
            rays: render_context.render_buffers.rays.clone(),
        }
    }
    fn init(&mut self, render_context: &RenderContext) {
        inox_profiler::scoped_profile!("raytracing_visibility_pass::init");

        if self.render_target.is_none() || self.meshlets.read().unwrap().is_empty() {
            return;
        }

        let mut tlas_starting_index = render_context.render_buffers.tlas_start_index.load(Ordering::SeqCst);

        self.binding_data
            .add_storage_buffer(
                &mut *self.indices.write().unwrap(),
                Some("Indices"),
                BindingInfo {
                    group_index: 0,
                    binding_index: 0,
                    stage: ShaderStage::Compute,
                    flags: BindingFlags::Read | BindingFlags::Index,
                },
            )
            .add_storage_buffer(
                &mut *self.runtime_vertices.write().unwrap(),
                Some("Runtime Vertices"),
                BindingInfo {
                    group_index: 0,
                    binding_index: 1,
                    stage: ShaderStage::Compute,
                    flags: BindingFlags::Read | BindingFlags::Vertex,
                },
            )
            .add_storage_buffer(
                &mut *self.meshes.write().unwrap(),
                Some("Meshes"),
                BindingInfo {
                    group_index: 0,
                    binding_index: 2,
                    stage: ShaderStage::Compute,
                    ..Default::default()
                },
            )
            .add_storage_buffer(
                &mut *self.meshlets.write().unwrap(),
                Some("Meshlets"),
                BindingInfo {
                    group_index: 0,
                    binding_index: 3,
                    stage: ShaderStage::Compute,
                    ..Default::default()
                },
            )
            .add_storage_buffer(
                &mut *self.culling_result.write().unwrap(),
                Some("Culling Results"),
                BindingInfo {
                    group_index: 0,
                    binding_index: 4,
                    stage: ShaderStage::Compute,
                    flags: BindingFlags::Read | BindingFlags::Indirect,
                },
            )
            .add_storage_buffer(
                &mut *self.bhv.write().unwrap(),
                Some("BHV"),
                BindingInfo {
                    group_index: 0,
                    binding_index: 5,
                    stage: ShaderStage::Compute,
                    ..Default::default()
                },
            )
            .add_storage_buffer(
                &mut *self.meshes_inverse_matrix.write().unwrap(),
                Some("Meshes Inverse Matrix"),
                BindingInfo {
                    group_index: 0,
                    binding_index: 6,
                    stage: ShaderStage::Compute,
                    ..Default::default()
                },
            )
            .add_uniform_buffer(
                &mut tlas_starting_index,
                Some("TLAS index"),
                BindingInfo {
                    group_index: 1,
                    binding_index: 0,
                    stage: ShaderStage::Compute,
                    ..Default::default()
                },
            )
            .add_storage_buffer(
                &mut *self.rays.write().unwrap(),
                Some("Rays"),
                BindingInfo {
                    group_index: 1,
                    binding_index: 1,
                    stage: ShaderStage::Compute,
                    flags: BindingFlags::ReadWrite,
                },
            )
            .add_texture(
                self.render_target.as_ref().unwrap().id(),
                BindingInfo {
                    group_index: 1,
                    binding_index: 2,
                    stage: ShaderStage::Compute,
                    flags: BindingFlags::Write | BindingFlags::Storage,
                },
            );

        let mut pass = self.compute_pass.get_mut();
        pass.init(render_context, &mut self.binding_data);
    }

    fn update(
        &mut self,
        render_context: &RenderContext,
        _surface_view: &TextureView,
        command_buffer: &mut CommandBuffer,
    ) {
        if self.render_target.is_none() || self.meshlets.read().unwrap().is_empty() {
            return;
        }

        inox_profiler::scoped_profile!("raytracing_visibility_pass::update");

        let pass = self.compute_pass.get();

        let x_pixels_managed_in_shader = 16;
        let y_pixels_managed_in_shader = 16;
        let dimensions = self.render_target.as_ref().unwrap().get().dimensions();
        let x = (x_pixels_managed_in_shader * ((dimensions.0 + x_pixels_managed_in_shader - 1) / x_pixels_managed_in_shader))
            / x_pixels_managed_in_shader;
        let y = (y_pixels_managed_in_shader * ((dimensions.1 + y_pixels_managed_in_shader - 1) / y_pixels_managed_in_shader))
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

impl OutputPass for ComputeRayTracingVisibilityPass {
    fn render_targets_id(&self) -> Option<Vec<TextureId>> {
        Some([*self.render_target.as_ref().unwrap().id()].to_vec())
    }
    fn depth_target_id(&self) -> Option<TextureId> {
        None
    }
}

impl ComputeRayTracingVisibilityPass {
    pub fn add_render_target_with_resolution(
        &mut self,
        width: u32,
        height: u32,
        render_format: TextureFormat,
    ) -> &mut Self {
        self.render_target = Some(Texture::create_from_format(
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
}