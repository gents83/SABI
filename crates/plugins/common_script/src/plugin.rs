use sabi_core::{define_plugin, App, Plugin, SystemId};

#[repr(C)]
#[derive(Default)]
pub struct CommonScriptPlugin {
    updater_id: SystemId,
}
define_plugin!(CommonScriptPlugin);

impl Plugin for CommonScriptPlugin {
    fn name(&self) -> &str {
        "sabi_common_script"
    }
    fn prepare(&mut self, app: &mut App) {
        sabi_nodes::register_nodes(app.get_shared_data());
        crate::logic_nodes::register_nodes(app.get_shared_data());
    }

    fn unprepare(&mut self, app: &mut App) {
        crate::logic_nodes::unregister_nodes(app.get_shared_data());
        sabi_nodes::unregister_nodes(app.get_shared_data());
    }
}