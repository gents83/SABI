use crate::events::*;
use crate::handle::*;
use crate::input::*;

pub const DEFAULT_DPI: f32 = 96.0;

#[derive(Debug, PartialOrd, PartialEq, Clone, Copy)]
pub enum WindowEvent {
    None,
    DpiChanged(f32, f32),
    SizeChanged(u32, u32),
    PosChanged(u32, u32),
    Close,
}

impl Event for WindowEvent {}

pub struct Window {
    handle: Handle,
    x: u32,
    y: u32,
    width: u32,
    height: u32,
    scale_factor: f32,
    events: EventsRw,
    can_continue: bool,
}

unsafe impl Send for Window {}
unsafe impl Sync for Window {}

impl Drop for Window {
    fn drop(&mut self) {
        unregister_events(&mut self.events);
    }
}

impl Window {
    pub fn create(
        title: String,
        x: u32,
        y: u32,
        mut width: u32,
        mut height: u32,
        mut events: EventsRw,
    ) -> Self {
        register_events(&mut events);

        let handle = Window::create_handle(title, x, y, &mut width, &mut height, &mut events);
        Self {
            handle,
            x,
            y,
            width,
            height,
            scale_factor: 1.0,
            events,
            can_continue: true,
        }
    }

    pub fn get_scale_factor(&self) -> f32 {
        self.scale_factor
    }

    pub fn get_x(&self) -> u32 {
        self.x
    }
    pub fn get_y(&self) -> u32 {
        self.y
    }

    pub fn get_width(&self) -> u32 {
        self.width
    }

    pub fn get_heigth(&self) -> u32 {
        self.height
    }

    pub fn get_handle(&self) -> &Handle {
        &self.handle
    }

    pub fn get_events(&self) -> EventsRw {
        self.events.clone()
    }

    pub fn update(&mut self) -> bool {
        self.manage_window_events();
        Window::internal_update(&self.handle, &mut self.events);
        self.can_continue
    }

    fn manage_window_events(&mut self) {
        let events = self.events.read().unwrap();
        let window_events = events.read_events::<WindowEvent>();
        for event in window_events.iter() {
            match event {
                WindowEvent::DpiChanged(x, _y) => {
                    self.scale_factor = x / DEFAULT_DPI;
                }
                WindowEvent::SizeChanged(width, height) => {
                    self.width = *width;
                    self.height = *height;
                }
                WindowEvent::PosChanged(x, y) => {
                    self.x = *x;
                    self.y = *y;
                }
                WindowEvent::Close => {
                    self.can_continue = false;
                }
                WindowEvent::None => {}
            }
        }
    }
}

fn register_events(events: &mut EventsRw) {
    let mut events = events.write().unwrap();
    events.register_event::<WindowEvent>();
    events.register_event::<KeyEvent>();
    events.register_event::<MouseEvent>();
}

fn unregister_events(events: &mut EventsRw) {
    let mut events = events.write().unwrap();
    events.unregister_event::<MouseEvent>();
    events.unregister_event::<KeyEvent>();
    events.unregister_event::<WindowEvent>();
}
