use nrg_core::*;
use std::any::type_name;

use super::rendering_system::*;

const RENDERING_PHASE: &str = "RENDERING_PHASE";

#[repr(C)]
pub struct GfxPlugin {
    system_id: SystemId,
}

impl Default for GfxPlugin {
    fn default() -> Self {
        println!("Created {} plugin", type_name::<Self>().to_string());
        Self {
            system_id: SystemId::default(),
        }
    }
}

impl Drop for GfxPlugin {
    fn drop(&mut self) {
        println!("Destroyed {} plugin", type_name::<Self>().to_string());
    }
}

unsafe impl Send for GfxPlugin {}
unsafe impl Sync for GfxPlugin {}

impl Plugin for GfxPlugin {
    fn prepare<'a>(&mut self, scheduler: &mut Scheduler, shared_data: &mut SharedDataRw) {
        //println!("Prepare {} plugin", type_name::<Self>().to_string());
        let mut update_phase = PhaseWithSystems::new(RENDERING_PHASE);
        let system = RenderingSystem::new(shared_data);

        self.system_id = system.id();

        update_phase.add_system(system);
        scheduler.create_phase(update_phase);
    }

    fn unprepare(&mut self, scheduler: &mut Scheduler) {
        let update_phase: &mut PhaseWithSystems = scheduler.get_phase_mut(RENDERING_PHASE);
        update_phase.remove_system(&self.system_id);
        scheduler.destroy_phase(RENDERING_PHASE);
        //println!("Unprepare {} plugin", type_name::<Self>().to_string());
    }
}
