use std::any::TypeId;

use nrg_math::{Vector2, Vector4};
use nrg_messenger::{implement_message, Message};
use nrg_serialize::{Deserialize, Serialize, Uid, INVALID_UID};

use crate::{
    implement_widget_with_custom_members, CollapsibleItem, InternalWidget, TitleBarEvent,
    WidgetData, WidgetEvent, DEFAULT_WIDGET_HEIGHT, DEFAULT_WIDGET_WIDTH,
};
pub const DEFAULT_TREE_VIEW_SIZE: [f32; 2] =
    [DEFAULT_WIDGET_WIDTH * 10., DEFAULT_WIDGET_HEIGHT * 20.];

#[derive(Clone, Copy)]
pub enum TreeItemEvent {
    Collapsed(Uid),
    Expanded(Uid),
}
implement_message!(TreeItemEvent);

#[derive(Serialize, Deserialize)]
#[serde(crate = "nrg_serialize")]
pub struct TreeView {
    data: WidgetData,
    title_widget: Uid,
    is_collapsed: bool,
    #[serde(skip)]
    is_dirty: bool,
}
implement_widget_with_custom_members!(TreeView {
    title_widget: INVALID_UID,
    is_collapsed: false,
    is_dirty: true
});

impl TreeView {
    pub fn populate_with_folders(parent_widget: &mut dyn Widget, root: &str) {
        if let Ok(dir) = std::fs::read_dir(root) {
            dir.for_each(|entry| {
                if let Ok(dir_entry) = entry {
                    let path = dir_entry.path();
                    if path.is_dir() {
                        let mut has_children = false;
                        if let Ok(dir) = std::fs::read_dir(path.clone()) {
                            dir.for_each(|entry| {
                                if let Ok(dir_entry) = entry {
                                    let path = dir_entry.path();
                                    has_children |= path.is_dir();
                                }
                            });
                        }
                        let mut entry = CollapsibleItem::new(
                            parent_widget.get_shared_data(),
                            parent_widget.get_global_messenger(),
                        );
                        entry
                            .draggable(false)
                            .size(parent_widget.state().get_size())
                            .selectable(has_children)
                            .collapsible(has_children)
                            .horizontal_alignment(HorizontalAlignment::Stretch)
                            .with_text(path.file_name().unwrap().to_str().unwrap())
                            .set_name(path.to_str().unwrap());

                        if has_children {
                            let mut inner_tree = TreeView::new(
                                entry.get_shared_data(),
                                entry.get_global_messenger(),
                            );
                            TreeView::populate_with_folders(
                                &mut inner_tree,
                                path.as_path().to_str().unwrap(),
                            );
                            let mut inner_size = entry.state().get_size();
                            inner_size.x = (inner_size.x
                                - DEFAULT_WIDGET_WIDTH * Screen::get_scale_factor())
                            .max(0.);
                            inner_tree
                                .size(inner_size)
                                .selectable(false)
                                .horizontal_alignment(HorizontalAlignment::Right)
                                .vertical_alignment(VerticalAlignment::Top);
                            entry.add_child(Box::new(inner_tree));
                        }
                        parent_widget.add_child(Box::new(entry));
                    }
                }
            });
        }
    }
}

impl InternalWidget for TreeView {
    fn widget_init(&mut self) {
        self.register_to_listen_event::<WidgetEvent>()
            .register_to_listen_event::<TitleBarEvent>();

        if self.is_initialized() {
            return;
        }

        let size: Vector2 = DEFAULT_TREE_VIEW_SIZE.into();

        self.size(size * Screen::get_scale_factor())
            .fill_type(ContainerFillType::Vertical)
            .vertical_alignment(VerticalAlignment::Top)
            .horizontal_alignment(HorizontalAlignment::Stretch)
            .space_between_elements(1)
            .use_space_before_and_after(true)
            .selectable(false)
            .style(WidgetStyle::DefaultBackground);
    }

    fn widget_update(&mut self, _drawing_area_in_px: Vector4) {}

    fn widget_uninit(&mut self) {
        self.unregister_to_listen_event::<WidgetEvent>()
            .unregister_to_listen_event::<TitleBarEvent>();
    }
    fn widget_process_message(&mut self, msg: &dyn Message) {
        if msg.type_id() == TypeId::of::<TitleBarEvent>() {
            let event = msg.as_any().downcast_ref::<TitleBarEvent>().unwrap();
            match *event {
                TitleBarEvent::Expanded(widget_id) => {
                    if self.node().has_child(widget_id) {
                        self.get_global_dispatcher()
                            .write()
                            .unwrap()
                            .send(WidgetEvent::InvalidateLayout(self.id()).as_boxed())
                            .ok();
                    }
                }
                TitleBarEvent::Collapsed(widget_id) => {
                    if self.node().has_child(widget_id) {
                        self.get_global_dispatcher()
                            .write()
                            .unwrap()
                            .send(WidgetEvent::InvalidateLayout(self.id()).as_boxed())
                            .ok();
                    }
                }
            }
        }
    }
}