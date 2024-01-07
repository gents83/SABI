use std::path::PathBuf;

use crate::{
    BindingData, BindingFlags, BindingInfo, CommandBuffer, ComputePass, ComputePassData,
    ConstantDataRw, DrawCommandType, MeshFlags, Pass, RadianceDataBuffer, RenderContext,
    ShaderStage, TextureId, TextureView,
};

use inox_core::ContextRc;
use inox_resources::{DataTypeResource, Resource};
use inox_uid::{generate_random_uid, INVALID_UID};

pub const COMPUTE_FINALIZE_PIPELINE: &str = "pipelines/ComputeFinalize.compute_pipeline";
pub const COMPUTE_FINALIZE_NAME: &str = "ComputeFinalizePass";

pub struct ComputeFinalizePass {
    compute_pass: Resource<ComputePass>,
    binding_data: BindingData,
    constant_data: ConstantDataRw,
    radiance_data_buffer: RadianceDataBuffer,
    finalize_texture: TextureId,
    dimensions: (u32, u32),
    visibility_texture: TextureId,
    gbuffer_texture: TextureId,
    radiance_texture: TextureId,
    depth_texture: TextureId,
}
unsafe impl Send for ComputeFinalizePass {}
unsafe impl Sync for ComputeFinalizePass {}

impl Pass for ComputeFinalizePass {
    fn name(&self) -> &str {
        COMPUTE_FINALIZE_NAME
    }
    fn static_name() -> &'static str {
        COMPUTE_FINALIZE_NAME
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
            name: COMPUTE_FINALIZE_NAME.to_string(),
            pipelines: vec![PathBuf::from(COMPUTE_FINALIZE_PIPELINE)],
        };

        Self {
            compute_pass: ComputePass::new_resource(
                context.shared_data(),
                context.message_hub(),
                generate_random_uid(),
                &data,
                None,
            ),
            constant_data: render_context.constant_data.clone(),
            radiance_data_buffer: render_context.render_buffers.radiance_data_buffer.clone(),
            binding_data: BindingData::new(render_context, COMPUTE_FINALIZE_NAME),
            finalize_texture: INVALID_UID,
            dimensions: (0, 0),
            visibility_texture: INVALID_UID,
            gbuffer_texture: INVALID_UID,
            radiance_texture: INVALID_UID,
            depth_texture: INVALID_UID,
        }
    }
    fn init(&mut self, render_context: &RenderContext) {
        inox_profiler::scoped_profile!("finalize_pass::init");

        if self.finalize_texture.is_nil()
            || self.radiance_texture.is_nil()
            || self.radiance_data_buffer.read().unwrap().data().is_empty()
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
                &mut *self.radiance_data_buffer.write().unwrap(),
                Some("Radiance Data Buffer"),
                BindingInfo {
                    group_index: 0,
                    binding_index: 1,
                    stage: ShaderStage::Compute,
                    ..Default::default()
                },
            )
            .add_texture(
                &self.finalize_texture,
                BindingInfo {
                    group_index: 0,
                    binding_index: 2,
                    stage: ShaderStage::Compute,
                    flags: BindingFlags::ReadWrite | BindingFlags::Storage,
                },
            )
            .add_texture(
                &self.visibility_texture,
                BindingInfo {
                    group_index: 0,
                    binding_index: 3,
                    stage: ShaderStage::Compute,
                    ..Default::default()
                },
            )
            .add_texture(
                &self.gbuffer_texture,
                BindingInfo {
                    group_index: 0,
                    binding_index: 4,
                    stage: ShaderStage::Compute,
                    ..Default::default()
                },
            )
            .add_texture(
                &self.radiance_texture,
                BindingInfo {
                    group_index: 0,
                    binding_index: 5,
                    stage: ShaderStage::Compute,
                    flags: BindingFlags::ReadWrite | BindingFlags::Storage,
                },
            )
            .add_texture(
                &self.depth_texture,
                BindingInfo {
                    group_index: 0,
                    binding_index: 6,
                    stage: ShaderStage::Compute,
                    ..Default::default()
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
        if self.finalize_texture.is_nil()
            || self.radiance_texture.is_nil()
            || self.radiance_data_buffer.read().unwrap().data().is_empty()
        {
            return;
        }

        inox_profiler::scoped_profile!("finalize_pass::update");

        let pass = self.compute_pass.get();

        let x_pixels_managed_in_shader = 8;
        let y_pixels_managed_in_shader = 8;
        let x = (x_pixels_managed_in_shader
            * ((self.dimensions.0 + x_pixels_managed_in_shader - 1) / x_pixels_managed_in_shader))
            / x_pixels_managed_in_shader;
        let y = (y_pixels_managed_in_shader
            * ((self.dimensions.1 + y_pixels_managed_in_shader - 1) / y_pixels_managed_in_shader))
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

impl ComputeFinalizePass {
    pub fn set_visibility_texture(&mut self, texture_id: &TextureId) -> &mut Self {
        self.visibility_texture = *texture_id;
        self
    }
    pub fn set_gbuffer_texture(&mut self, texture_id: &TextureId) -> &mut Self {
        self.gbuffer_texture = *texture_id;
        self
    }
    pub fn set_radiance_texture(&mut self, texture_id: &TextureId) -> &mut Self {
        self.radiance_texture = *texture_id;
        self
    }
    pub fn set_depth_texture(&mut self, texture_id: &TextureId) -> &mut Self {
        self.depth_texture = *texture_id;
        self
    }
    pub fn set_finalize_texture(
        &mut self,
        texture_id: &TextureId,
        dimensions: (u32, u32),
    ) -> &mut Self {
        self.finalize_texture = *texture_id;
        self.dimensions = dimensions;
        self
    }
}
