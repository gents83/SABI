use std::path::PathBuf;

use crate::{
    BindingData, BindingInfo, LoadOperation, Pass, RenderContext, RenderPass, RenderPassData,
    RenderTarget, ShaderStage, StoreOperation,
};

use inox_core::ContextRc;
use inox_resources::{DataTypeResource, Resource};
use inox_uid::generate_random_uid;

pub const TRANSPARENT_PIPELINE: &str = "pipelines/Transparent.render_pipeline";
pub const TRANSPARENT_PASS_NAME: &str = "TransparentPass";

pub struct TransparentPass {
    render_pass: Resource<RenderPass>,
    binding_data: BindingData,
}
unsafe impl Send for TransparentPass {}
unsafe impl Sync for TransparentPass {}

impl Pass for TransparentPass {
    fn name(&self) -> &str {
        TRANSPARENT_PASS_NAME
    }
    fn static_name() -> &'static str {
        TRANSPARENT_PASS_NAME
    }
    fn create(context: &ContextRc) -> Self
    where
        Self: Sized,
    {
        let data = RenderPassData {
            name: TRANSPARENT_PASS_NAME.to_string(),
            load_color: LoadOperation::Load,
            store_color: StoreOperation::Store,
            load_depth: LoadOperation::Load,
            store_depth: StoreOperation::Store,
            render_target: RenderTarget::Screen,
            pipelines: vec![PathBuf::from(TRANSPARENT_PIPELINE)],
            ..Default::default()
        };
        Self {
            render_pass: RenderPass::new_resource(
                context.shared_data(),
                context.message_hub(),
                generate_random_uid(),
                data,
                None,
            ),
            binding_data: BindingData::default(),
        }
    }
    fn init(&mut self, render_context: &mut RenderContext) {
        let mut pass = self.render_pass.get_mut();
        let render_texture = pass.render_texture_id();
        let depth_texture = pass.depth_texture_id();

        self.binding_data
            .add_uniform_data(
                &render_context.core,
                &render_context.binding_data_buffer,
                &mut render_context.constant_data,
                BindingInfo {
                    group_index: 0,
                    binding_index: 0,
                    stage: ShaderStage::VertexAndFragment,
                    ..Default::default()
                },
            )
            .add_storage_data(
                &render_context.core,
                &render_context.binding_data_buffer,
                &mut render_context.render_buffers.vertices,
                BindingInfo {
                    group_index: 0,
                    binding_index: 1,
                    stage: ShaderStage::VertexAndFragment,
                    read_only: true,
                    ..Default::default()
                },
            )
            .add_textures_data(
                &render_context.texture_handler,
                render_texture,
                depth_texture,
                BindingInfo {
                    group_index: 1,
                    stage: ShaderStage::Fragment,
                    ..Default::default()
                },
            );
        self.binding_data.send_to_gpu(render_context);

        pass.init_pipelines(render_context, &self.binding_data);
    }
    fn update(&mut self, render_context: &RenderContext) {
        let pass = self.render_pass.get();

        let mut encoder = render_context.core.new_encoder();

        let render_pass = pass.begin(render_context, &self.binding_data, &mut encoder);
        pass.draw(render_context, render_pass);

        render_context.core.submit(encoder);
    }
    fn handle_events(&mut self, _render_context: &mut RenderContext) {}
}

impl TransparentPass {
    pub fn render_pass(&self) -> &Resource<RenderPass> {
        &self.render_pass
    }
}
