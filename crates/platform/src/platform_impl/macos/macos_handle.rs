use raw_window_handle::RawWindowHandle;

use super::super::handle::*;
use core::ffi::c_void;
use core::ptr;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct HandleImpl {
    pub ns_window: *mut c_void,
    pub ns_view: *mut c_void,
}

impl HandleImpl {
    pub fn as_raw_window_handle(&self) -> RawWindowHandle {
        let mut handle = raw_window_handle::AppKitHandle::empty();
        handle.ns_window = *self.ns_window as *mut _;
        handle.ns_view = *self.ns_view as *mut _;
        RawWindowHandle::AppKit(handle)
    }
    pub fn is_valid(&self) -> bool {
        !self.ns_window.is_null()
    }
}

impl Handle for HandleImpl {
    fn is_valid(&self) -> bool {
        self.is_valid()
    }
}
