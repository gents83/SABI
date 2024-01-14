use std::path::PathBuf;

use inox_core::{define_plugin, ContextRc, Plugin, SystemUID, WindowSystem};

use inox_graphics::{
    platform::has_wireframe_support, rendering_system::RenderingSystem,
    update_system::UpdateSystem, BlitPass, ComputeFinalizePass, ComputePathTracingDirectPass,
    ComputePathTracingIndirectPass, ComputeRuntimeVerticesPass, CullingPass, DebugPass, Pass,
    RenderContextRc, RenderPass, Renderer, RendererRw, TextureFormat, TextureUsage,
    VisibilityBufferPass, WireframePass, DEFAULT_HEIGHT, DEFAULT_WIDTH, WIREFRAME_PASS_NAME,
};
use inox_platform::Window;
use inox_resources::ConfigBase;
use inox_scene::{ObjectSystem, ScriptSystem};
use inox_serialize::read_from_file;
use inox_ui::{UIPass, UISystem, UI_PASS_NAME};

use crate::{config::Config, systems::viewer_system::ViewerSystem};

const ADD_CULLING_PASS: bool = true;
const ADD_UI_PASS: bool = true;

enum RenderTargetType {
    Visibility = 0,
    Depth = 1,
    Rays = 2,
    Radiance = 3,
    Binding = 4,
    Finalize = 5,
    DebugData = 6,
}

pub struct Viewer {
    _renderer: RendererRw,
}
define_plugin!(Viewer);

impl Plugin for Viewer {
    fn create(context: &ContextRc) -> Self {
        let window = {
            Window::create(
                "INOX Engine".to_string(),
                0,
                0,
                DEFAULT_WIDTH,
                DEFAULT_HEIGHT,
                PathBuf::from("").as_path(),
                context.message_hub(),
            )
        };

        let context_rc = context.clone();
        let _renderer = Renderer::new(window.handle(), context, move |render_context| {
            Self::create_systems(&context_rc, render_context);
            Self::create_render_targets(render_context, DEFAULT_WIDTH, DEFAULT_HEIGHT);
            Self::create_render_passes(&context_rc, render_context);
        });

        let window_system = WindowSystem::new(window, context);
        context.add_system(inox_core::Phases::PlatformUpdate, window_system, None);

        Viewer { _renderer }
    }

    fn name(&self) -> &str {
        "inox_viewer"
    }

    fn prepare(&mut self, _context: &ContextRc) {}

    fn unprepare(&mut self, context: &ContextRc) {
        context.remove_system(inox_core::Phases::Update, &ViewerSystem::system_id());
        if ADD_UI_PASS {
            context.remove_system(inox_core::Phases::Update, &UISystem::system_id());
        }

        context.remove_system(inox_core::Phases::Update, &ScriptSystem::system_id());
        context.remove_system(inox_core::Phases::Update, &ObjectSystem::system_id());

        context.remove_system(
            inox_core::Phases::PlatformUpdate,
            &WindowSystem::system_id(),
        );
        context.remove_system(inox_core::Phases::Render, &UpdateSystem::system_id());
        context.remove_system(inox_core::Phases::Render, &RenderingSystem::system_id());
    }

    fn load_config(&mut self, context: &ContextRc) {
        let config = Config::default();
        let shared_data = context.shared_data().clone();

        read_from_file(
            config.get_filepath(self.name()).as_path(),
            context.shared_data().serializable_registry(),
            Box::new(move |data: Config| {
                if let Some(ui_pass) =
                    shared_data.match_resource(|r: &RenderPass| r.name() == UI_PASS_NAME)
                {
                    ui_pass.get_mut().set_pipeline(&data.ui_pass_pipeline);
                }
                if let Some(wireframe_pass) =
                    shared_data.match_resource(|r: &RenderPass| r.name() == WIREFRAME_PASS_NAME)
                {
                    wireframe_pass
                        .get_mut()
                        .set_pipeline(&data.wireframe_pass_pipeline);
                }
            }),
        );
    }
}

impl Viewer {
    fn create_systems(context: &ContextRc, render_context: &RenderContextRc) {
        let render_update_system = UpdateSystem::new(render_context, context);
        let rendering_draw_system = RenderingSystem::new(render_context, context);
        let mut ui_system = if ADD_UI_PASS {
            Some(UISystem::new(context))
        } else {
            None
        };

        let viewer_system = ViewerSystem::new(context, render_context, false);
        let object_system = ObjectSystem::new(context);
        let script_system = ScriptSystem::new(context);

        context.add_system(
            inox_core::Phases::Render,
            render_update_system,
            Some(&[RenderingSystem::system_id()]),
        );
        context.add_system(
            inox_core::Phases::Render,
            rendering_draw_system,
            Some(&[UpdateSystem::system_id()]),
        );

        context.add_system(inox_core::Phases::Update, object_system, None);
        context.add_system(
            inox_core::Phases::Update,
            script_system,
            Some(&[ObjectSystem::system_id()]),
        );

        if let Some(ui_system) = ui_system.take() {
            context.add_system(inox_core::Phases::Update, ui_system, None);
        }
        context.add_system(inox_core::Phases::Update, viewer_system, None);
    }
    fn create_render_targets(render_context: &RenderContextRc, width: u32, height: u32) {
        let half_dims = (width / 2, height / 2);
        let single_sample = 1;
        let multi_sample = 8;
        let usage = TextureUsage::TextureBinding
            | TextureUsage::CopySrc
            | TextureUsage::CopyDst
            | TextureUsage::RenderTarget;

        //Visibility,
        let _visibility = render_context.create_render_target(
            width,
            height,
            TextureFormat::R32Uint,
            usage,
            multi_sample,
        );
        debug_assert!(_visibility == RenderTargetType::Visibility as usize);
        //Depth,
        let _depth = render_context.create_render_target(
            width,
            height,
            TextureFormat::Depth32Float,
            usage,
            multi_sample,
        );
        debug_assert!(_depth == RenderTargetType::Depth as usize);
        //Rays,
        let _rays = render_context.create_render_target(
            half_dims.0,
            half_dims.1,
            TextureFormat::Rgba32Float,
            usage | TextureUsage::StorageBinding,
            single_sample,
        );
        debug_assert!(_rays == RenderTargetType::Rays as usize);
        //Radiance,
        let _radiance = render_context.create_render_target(
            half_dims.0,
            half_dims.1,
            TextureFormat::Rgba32Float,
            usage | TextureUsage::StorageBinding,
            single_sample,
        );
        debug_assert!(_radiance == RenderTargetType::Radiance as usize);
        //Binding,
        let _binding = render_context.create_render_target(
            half_dims.0,
            half_dims.1,
            TextureFormat::Rgba32Float,
            usage | TextureUsage::StorageBinding,
            single_sample,
        );
        debug_assert!(_binding == RenderTargetType::Binding as usize);
        //Finalize,
        let _finalize = render_context.create_render_target(
            width,
            height,
            TextureFormat::Rgba8Unorm,
            usage | TextureUsage::StorageBinding,
            single_sample,
        );
        debug_assert!(_finalize == RenderTargetType::Finalize as usize);
        //Debug,
        let _debug_data = render_context.create_render_target(
            half_dims.0,
            half_dims.1,
            TextureFormat::R32Float,
            usage | TextureUsage::StorageBinding,
            single_sample,
        );
        debug_assert!(_debug_data == RenderTargetType::DebugData as usize);
    }
    fn create_render_passes(context: &ContextRc, render_context: &RenderContextRc) {
        Self::create_compute_runtime_vertices_pass(context, render_context, true);
        Self::create_culling_pass(context, render_context, ADD_CULLING_PASS);

        Self::create_visibility_pass(context, render_context);
        Self::create_compute_pathtracing_direct_pass(context, render_context);
        Self::create_compute_pathtracing_indirect_pass(context, render_context);
        Self::create_compute_finalize_pass(context, render_context);
        Self::create_blit_pass(context, render_context);

        Self::create_debug_pass(context, render_context);
        Self::create_wireframe_pass(context, render_context, has_wireframe_support());
        Self::create_ui_pass(context, render_context, ADD_UI_PASS);
    }
    fn create_compute_runtime_vertices_pass(
        context: &ContextRc,
        render_context: &RenderContextRc,
        is_enabled: bool,
    ) {
        if !is_enabled {
            return;
        }
        let compute_runtime_vertices_pass =
            ComputeRuntimeVerticesPass::create(context, render_context);
        render_context.add_pass(compute_runtime_vertices_pass, is_enabled);
    }
    fn create_culling_pass(
        context: &ContextRc,
        render_context: &RenderContextRc,
        is_enabled: bool,
    ) {
        if !is_enabled {
            return;
        }
        let culling_pass = CullingPass::create(context, render_context);
        render_context.add_pass(culling_pass, is_enabled);
    }
    fn create_visibility_pass(context: &ContextRc, render_context: &RenderContextRc) {
        let visibility_pass = VisibilityBufferPass::create(context, render_context);
        visibility_pass
            .add_render_target(&render_context.render_target(RenderTargetType::Visibility as usize))
            .add_depth_target(&render_context.render_target(RenderTargetType::Depth as usize));
        render_context.add_pass(visibility_pass, true);
    }
    fn create_compute_pathtracing_direct_pass(
        context: &ContextRc,
        render_context: &RenderContextRc,
    ) {
        let mut compute_pathtracing_direct_pass =
            ComputePathTracingDirectPass::create(context, render_context);
        let radiance_texture = render_context.render_target(RenderTargetType::Radiance as usize);
        compute_pathtracing_direct_pass
            .set_rays_texture(&render_context.render_target_id(RenderTargetType::Rays as usize))
            .set_radiance_texture(radiance_texture.id(), radiance_texture.get().dimensions())
            .set_binding_texture(
                &render_context.render_target_id(RenderTargetType::Binding as usize),
            )
            .set_visibility_texture(
                &render_context.render_target_id(RenderTargetType::Visibility as usize),
            )
            .set_depth_texture(&render_context.render_target_id(RenderTargetType::Depth as usize));
        render_context.add_pass(compute_pathtracing_direct_pass, true);
    }
    fn create_compute_pathtracing_indirect_pass(
        context: &ContextRc,
        render_context: &RenderContextRc,
    ) {
        let mut compute_pathtracing_indirect_pass =
            ComputePathTracingIndirectPass::create(context, render_context);
        let radiance_texture = render_context.render_target(RenderTargetType::Radiance as usize);
        compute_pathtracing_indirect_pass
            .set_radiance_texture(radiance_texture.id(), radiance_texture.get().dimensions())
            .set_rays_texture(&render_context.render_target_id(RenderTargetType::Rays as usize))
            .set_binding_texture(
                &render_context.render_target_id(RenderTargetType::Binding as usize),
            )
            .set_debug_data_texture(
                &render_context.render_target_id(RenderTargetType::DebugData as usize),
            );
        render_context.add_pass(compute_pathtracing_indirect_pass, true);
    }
    fn create_compute_finalize_pass(context: &ContextRc, render_context: &RenderContextRc) {
        let mut compute_finalize_pass = ComputeFinalizePass::create(context, render_context);
        let finalize_texture = render_context.render_target(RenderTargetType::Finalize as usize);
        compute_finalize_pass
            .set_finalize_texture(finalize_texture.id(), finalize_texture.get().dimensions())
            .set_binding_texture(
                &render_context.render_target_id(RenderTargetType::Binding as usize),
            )
            .set_radiance_texture(
                &render_context.render_target_id(RenderTargetType::Radiance as usize),
            );
        render_context.add_pass(compute_finalize_pass, true);
    }
    fn create_blit_pass(context: &ContextRc, render_context: &RenderContextRc) {
        let mut blit_pass = BlitPass::create(context, render_context);
        blit_pass.set_source(&render_context.render_target_id(RenderTargetType::Finalize as usize));
        render_context.add_pass(blit_pass, true);
    }
    fn create_debug_pass(context: &ContextRc, render_context: &RenderContextRc) {
        let mut debug_pass = DebugPass::create(context, render_context);
        debug_pass
            .set_finalize_texture(
                &render_context.render_target_id(RenderTargetType::Finalize as usize),
            )
            .set_visibility_texture(
                &render_context.render_target_id(RenderTargetType::Visibility as usize),
            )
            .set_radiance_texture(
                &render_context.render_target_id(RenderTargetType::Radiance as usize),
            )
            .set_depth_texture(&render_context.render_target_id(RenderTargetType::Depth as usize))
            .set_debug_data_texture(
                &render_context.render_target_id(RenderTargetType::DebugData as usize),
            );
        render_context.add_pass(debug_pass, true);
    }
    fn create_wireframe_pass(
        context: &ContextRc,
        render_context: &RenderContextRc,
        is_enabled: bool,
    ) {
        if !is_enabled {
            return;
        }
        let wireframe_pass = WireframePass::create(context, render_context);
        render_context.add_pass(wireframe_pass, is_enabled);
    }
    fn create_ui_pass(context: &ContextRc, render_context: &RenderContextRc, is_enabled: bool) {
        if !is_enabled {
            return;
        }
        let ui_pass = UIPass::create(context, render_context);
        render_context.add_pass(ui_pass, is_enabled);
    }
}
