use super::*;
use nrg_graphics::*;
use nrg_platform::*;

#[derive(Debug, PartialOrd, PartialEq, Clone, Copy)]
pub enum ButtonEvent {
    None,
    Pressed,
    Released,
}

impl Event for ButtonEvent {}

pub struct Button {
    container_data: ContainerData,
    is_pressed: bool,
}

unsafe impl Send for Button {}
unsafe impl Sync for Button {}

impl ContainerTrait for Button {
    fn get_container_data(&self) -> &ContainerData {
        &self.container_data
    }
    fn get_container_data_mut(&mut self) -> &mut ContainerData {
        &mut self.container_data
    }
}

impl Default for Button {
    fn default() -> Self {
        Self {
            container_data: ContainerData::default(),
            is_pressed: false,
        }
    }
}

impl Button {
    pub fn register_events(gui_events: &mut EventsRw) {
        let mut events = gui_events.write().unwrap();
        events.register_event::<ButtonEvent>();
    }
    pub fn unregister_events(gui_events: &mut EventsRw) {
        let mut events = gui_events.write().unwrap();
        events.unregister_event::<ButtonEvent>();
    }
    pub fn on_state_changed(
        _widget: &mut Widget<Self>,
        events: &mut EventsRw,
        old_state: bool,
        new_state: bool,
    ) {
        let mut events = events.write().unwrap();
        if new_state {
            events.send_event(ButtonEvent::Pressed);
        } else if old_state {
            events.send_event(ButtonEvent::Released);
        }
    }
}

impl WidgetTrait for Button {
    fn init(widget: &mut Widget<Self>, renderer: &mut Renderer) {
        let data = widget.get_data_mut();
        data.graphics.init(renderer, "UI");
    }

    fn update(
        widget: &mut Widget<Self>,
        _parent_data: Option<&WidgetState>,
        _renderer: &mut Renderer,
        events: &mut EventsRw,
        _input_handler: &InputHandler,
    ) {
        Self::fit_to_content(widget);

        let old_state = widget.get().is_pressed;
        let new_state = widget.get_data().state.is_pressed();

        if new_state != old_state {
            Button::on_state_changed(widget, events, old_state, new_state);
            widget.get_mut().is_pressed = new_state;
        }

        let screen = widget.get_screen();
        let data = widget.get_data_mut();
        let pos = screen.convert_from_pixels_into_screen_space(data.state.get_position());
        let size = screen.convert_size_from_pixels(data.state.get_size());
        let mut mesh_data = MeshData::default();
        mesh_data
            .add_quad_default([0.0, 0.0, size.x, size.y].into(), data.state.get_layer())
            .set_vertex_color(data.graphics.get_color());
        mesh_data.translate([pos.x, pos.y, 0.0].into());
        data.graphics.set_mesh_data(mesh_data);
    }

    fn uninit(_widget: &mut Widget<Self>, _renderer: &mut Renderer) {}

    fn get_type(&self) -> &'static str {
        std::any::type_name::<Self>()
    }
}
