use std::{
    path::{Path, PathBuf},
    sync::{Arc, RwLock},
};

use inox_core::{
    App, PfnCreatePlugin, PfnDestroyPlugin, PfnPreparePlugin, PfnUnpreparePlugin, System,
};
use inox_graphics::{rendering_system::RenderingSystem, update_system::UpdateSystem, Renderer};

use inox_messenger::MessageHubRc;
use inox_platform::Window;
use inox_log::debug_log;
use inox_resources::SharedDataRc;

use crate::window_system::WindowSystem;

#[derive(Default)]
pub struct Launcher {
    app: Arc<RwLock<App>>,
}

impl Launcher {
    pub fn shared_data(&self) -> SharedDataRc {
        self.app.read().unwrap().get_context().shared_data().clone()
    }
    pub fn message_hub(&self) -> MessageHubRc {
        self.app.read().unwrap().get_context().message_hub().clone()
    }

    pub fn prepare(&self) {
        debug_log!("Preparing launcher");

        let app = &mut self.app.write().unwrap();
        let window = {
            Window::create(
                "SABI".to_string(),
                0,
                0,
                0,
                0,
                PathBuf::from("").as_path(),
                app.get_context().message_hub(),
            )
        };

        let renderer = Renderer::new(window.get_handle(), app.get_context().shared_data(), false);
        let renderer = Arc::new(RwLock::new(renderer));

        let window_system = WindowSystem::new(
            window,
            app.get_context().shared_data(),
            app.get_context().message_hub(),
        );

        let render_update_system = UpdateSystem::new(
            renderer.clone(),
            app.get_context().shared_data(),
            app.get_context().message_hub(),
            app.get_job_handler(),
        );

        let rendering_draw_system = RenderingSystem::new(
            renderer,
            app.get_context().shared_data(),
            app.get_context().message_hub(),
            app.get_job_handler(),
        );

        app.add_system(inox_core::Phases::PlatformUpdate, window_system);
        app.add_system(inox_core::Phases::Render, render_update_system);
        app.add_system(inox_core::Phases::Render, rendering_draw_system);
    }

    pub fn start(&self) {
        let app = &mut self.app.write().unwrap();

        debug_log!("Starting app");

        app.start();
    }

    pub fn add_dynamic_plugin(&self, name: &str, path: &Path) {
        let app = &mut self.app.write().unwrap();
        Self::read_config(app, name);
        app.add_dynamic_plugin(path);
    }

    pub fn add_static_plugin(
        &self,
        name: &str,
        fn_c: PfnCreatePlugin,
        fn_p: PfnPreparePlugin,
        fn_u: PfnUnpreparePlugin,
        fn_d: PfnDestroyPlugin,
    ) {
        let app = &mut self.app.write().unwrap();
        Self::read_config(app, name);

        if let Some(fn_c) = fn_c {
            let mut plugin_holder = unsafe { fn_c() };
            plugin_holder.prepare_fn = fn_p;
            plugin_holder.unprepare_fn = fn_u;
            plugin_holder.destroy_fn = fn_d;
            app.add_static_plugin(plugin_holder);
        }
    }

    fn read_config(app: &mut App, plugin_name: &str) {
        debug_log!("Reading launcher configs");

        app.execute_on_system(|window_system: &mut WindowSystem| {
            window_system.read_config(plugin_name);
        });
        app.execute_on_system(|update_system: &mut UpdateSystem| {
            update_system.read_config(plugin_name);
        });
    }

    pub fn update(&self) -> bool {
        self.app.write().unwrap().run()
    }
}

impl Drop for Launcher {
    fn drop(&mut self) {
        debug_log!("Dropping launcher");
        let app = &mut self.app.write().unwrap();

        app.remove_system(inox_core::Phases::PlatformUpdate, &WindowSystem::id());
        app.remove_system(inox_core::Phases::Render, &UpdateSystem::id());
        app.remove_system(inox_core::Phases::Render, &RenderingSystem::id());
    }
}
