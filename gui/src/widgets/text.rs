use nrg_events::{implement_undoable_event, Event, EventsRw};
use nrg_graphics::{FontId, MaterialId, MeshData, Renderer, INVALID_ID};
use nrg_math::{Vector2, Vector4};
use nrg_platform::{MouseEvent, MouseState};
use nrg_serialize::{Deserialize, Serialize, Uid};

use crate::{
    implement_widget, InternalWidget, WidgetData, DEFAULT_WIDGET_HEIGHT, DEFAULT_WIDGET_WIDTH,
};

pub const DEFAULT_TEXT_SIZE: [f32; 2] =
    [DEFAULT_WIDGET_WIDTH * 20., DEFAULT_WIDGET_HEIGHT / 4. * 3.];

#[derive(Clone, Copy)]
pub enum TextEvent {
    AddChar(Uid, i32, char),
    RemoveChar(Uid, i32, char),
}
implement_undoable_event!(TextEvent, undo_event, debug_info_event);
fn undo_event(event: &TextEvent) -> TextEvent {
    match event {
        TextEvent::AddChar(widget_id, character_index, character) => {
            TextEvent::RemoveChar(*widget_id, *character_index + 1, *character)
        }
        TextEvent::RemoveChar(widget_id, character_index, character) => {
            TextEvent::AddChar(*widget_id, *character_index - 1, *character)
        }
    }
}
fn debug_info_event(event: &TextEvent) -> String {
    match event {
        TextEvent::AddChar(_widget_id, _character_index, character) => {
            let mut str = String::from("AddChar[");
            str.push(*character);
            str.push(']');
            str
        }
        TextEvent::RemoveChar(_widget_id, _character_index, character) => {
            let mut str = String::from("RemoveChar[");
            str.push(*character);
            str.push(']');
            str
        }
    }
}

#[derive(Serialize, Deserialize)]
#[serde(crate = "nrg_serialize")]
pub struct Text {
    #[serde(skip)]
    font_id: FontId,
    #[serde(skip)]
    material_id: MaterialId,
    text: String,
    #[serde(skip)]
    hover_char_index: i32,
    #[serde(skip)]
    char_width: u32,
    #[serde(skip)]
    is_dirty: bool,
    data: WidgetData,
}
implement_widget!(Text);

impl Default for Text {
    fn default() -> Self {
        Self {
            font_id: INVALID_ID,
            material_id: INVALID_ID,
            text: String::new(),
            hover_char_index: -1,
            char_width: 0,
            is_dirty: true,
            data: WidgetData::default(),
        }
    }
}

impl Text {
    pub fn set_text(&mut self, text: &str) -> &mut Self {
        self.is_dirty = true;
        self.text = String::from(text);
        self
    }

    pub fn get_text(&self) -> &str {
        self.text.as_ref()
    }
    pub fn is_hover_char(&self) -> bool {
        self.hover_char_index >= 0 && self.hover_char_index <= self.text.len() as _
    }
    pub fn get_hover_char(&self) -> i32 {
        self.hover_char_index
    }
    pub fn get_char_pos(&self, index: i32) -> Vector2 {
        let pos = self.get_data().state.get_position();
        if index >= 0 && index < self.text.len() as _ {
            return [pos.x + self.char_width as f32 * (index as f32 + 1.), pos.y].into();
        }
        pos
    }
    pub fn get_char_at(&self, index: i32) -> Option<char> {
        if index >= 0 && index < self.text.len() as _ {
            return Some(self.text.as_bytes()[index as usize] as _);
        }
        None
    }

    fn update_text(&mut self, events_rw: &mut EventsRw) {
        let events = events_rw.read().unwrap();
        if let Some(mut text_events) = events.read_all_events::<TextEvent>() {
            for event in text_events.iter_mut() {
                match event {
                    TextEvent::AddChar(widget_id, char_index, character) => {
                        if *widget_id == self.id() {
                            self.add_char(*char_index, *character);
                        }
                    }
                    TextEvent::RemoveChar(widget_id, char_index, _character) => {
                        if *widget_id == self.id() {
                            self.remove_char(*char_index);
                        }
                    }
                }
            }
        }
        if let Some(mut mouse_events) = events.read_all_events::<MouseEvent>() {
            for event in mouse_events.iter_mut() {
                if event.state == MouseState::Move {
                    let mouse_pos = Vector2::new(event.x as _, event.y as _);
                    let pos = self.get_data().state.get_position();
                    let size = self.get_data().state.get_size();
                    let count = self.text.lines().count();
                    let line_height = size.y / count as f32;
                    for (line_index, t) in self.text.lines().enumerate() {
                        for (i, _c) in t.as_bytes().iter().enumerate() {
                            if mouse_pos.x >= pos.x + self.char_width as f32 * i as f32
                                && mouse_pos.x <= pos.x + self.char_width as f32 * (i as f32 + 1.)
                                && mouse_pos.y >= pos.y + line_height * line_index as f32
                                && mouse_pos.y <= pos.y + size.y + line_height * line_index as f32
                            {
                                self.hover_char_index = 1 + i as i32;
                            }
                        }
                    }
                }
            }
        }
    }

    fn add_char(&mut self, index: i32, character: char) {
        let mut new_index = index + 1;
        if new_index > self.text.len() as i32 {
            new_index = self.text.len() as i32;
        }
        if new_index < 0 {
            new_index = 0;
        }
        self.is_dirty = true;
        self.text.insert(new_index as _, character);
    }
    fn remove_char(&mut self, index: i32) -> char {
        if index >= 0 && index < self.text.len() as _ {
            self.is_dirty = true;
            return self.text.remove(index as usize);
        }
        char::default()
    }

    fn update_mesh_from_text(&mut self, renderer: &mut Renderer, drawing_area_in_px: Vector4) {
        let min_size = self.get_data_mut().state.get_size();
        let size: Vector2 = [drawing_area_in_px.z, drawing_area_in_px.w].into();

        let lines_count = self.text.lines().count().max(1);
        let mut max_chars = 1;
        for text in self.text.lines() {
            max_chars = max_chars.max(text.len());
        }

        let char_size = min_size.y / lines_count as f32;
        let mut char_width = char_size;
        let mut char_height = char_size;
        if *self.get_data().state.get_horizontal_alignment() == HorizontalAlignment::Stretch {
            char_width = size.x / max_chars as f32;
        }
        if *self.get_data().state.get_vertical_alignment() == VerticalAlignment::Stretch {
            char_height = size.y / lines_count as f32;
        }

        let new_size: Vector2 = [
            char_width * max_chars as f32,
            char_height * lines_count as f32,
        ]
        .into();

        let font = renderer.get_font(self.font_id).unwrap();

        let mut mesh_data = MeshData::default();
        let mut pos_y = 0.;
        let mut mesh_index = 0;
        let char_width = new_size.y / new_size.x;
        let char_height = 1.;
        for text in self.text.lines() {
            let mut pos_x = 0.;
            for c in text.as_bytes().iter() {
                let id = font.get_glyph_index(*c as _);
                let g = font.get_glyph(id);
                mesh_data.add_quad(
                    Vector4::new(pos_x, pos_y, pos_x + char_width, pos_y + char_height),
                    0.,
                    g.texture_coord,
                    Some(mesh_index),
                );
                mesh_index += 4;
                pos_x += char_width;
            }
            pos_y += char_height;
        }
        self.char_width = char_size as _;
        self.set_size(new_size);

        self.get_data_mut()
            .graphics
            .set_mesh_data(renderer, mesh_data);
    }
}

impl InternalWidget for Text {
    fn widget_init(&mut self, renderer: &mut Renderer) {
        let font_id = renderer.get_default_font_id();
        let material_id = renderer.add_material_from_font_id(font_id);

        self.font_id = font_id;
        self.material_id = material_id;

        self.get_data_mut()
            .graphics
            .link_to_material(renderer, material_id);
        if self.is_initialized() {
            return;
        }

        let size: Vector2 = DEFAULT_TEXT_SIZE.into();
        self.size(size * Screen::get_scale_factor())
            .selectable(false)
            .style(WidgetStyle::DefaultText);
    }

    fn widget_update(&mut self, renderer: &mut Renderer, events_rw: &mut EventsRw) {
        self.update_text(events_rw);
        if self.is_dirty {
            let drawing_area_in_px = self.get_data().state.get_clip_area();
            self.update_mesh_from_text(renderer, drawing_area_in_px);
            self.is_dirty = false;
        }
    }

    fn widget_uninit(&mut self, renderer: &mut Renderer) {
        let data = self.get_data_mut();
        data.graphics.remove_meshes(renderer);
    }
}
