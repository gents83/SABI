use crate::{api::backend::BackendDevice, Instance};

pub struct Device {
    inner: BackendDevice,
}

impl std::ops::Deref for Device {
    type Target = BackendDevice;
    fn deref(&self) -> &Self::Target {
        &self.inner
    }
}

impl std::ops::DerefMut for Device {
    fn deref_mut(&mut self) -> &mut Self::Target {
        &mut self.inner
    }
}

impl Device {
    pub fn create(instance: &super::instance::Instance, enable_validation: bool) -> Self {
        Device {
            inner: BackendDevice::new(&*instance, enable_validation),
        }
    }

    pub fn destroy(&mut self) {
        self.inner.delete();
    }

    pub fn begin_frame(&mut self) {
        self.inner.begin_primary_command_buffer();
    }

    pub fn end_frame(&self) {
        self.inner.end_primary_command_buffer();
    }

    pub fn submit(&self) {
        let command_buffer = self.inner.get_primary_command_buffer();
        self.inner.graphics_queue_submit(command_buffer);
    }

    pub fn present(&mut self) -> bool {
        self.inner.present()
    }

    pub fn recreate_swap_chain(&mut self, instance: &mut Instance) {
        let surface = instance.get_surface();
        self.inner
            .recreate_swap_chain(instance.get_physical_device_mut(), surface);
    }
}