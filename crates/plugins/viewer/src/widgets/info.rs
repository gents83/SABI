use std::sync::atomic::Ordering;

use inox_core::ContextRc;
use inox_graphics::{
    CullingEvent, DrawEvent, Light, LightType, Mesh, MeshFlags, MeshId, RendererRw,
    CONSTANT_DATA_FLAGS_DISPLAY_BASE_COLOR, CONSTANT_DATA_FLAGS_DISPLAY_BITANGENT,
    CONSTANT_DATA_FLAGS_DISPLAY_DEPTH_BUFFER, CONSTANT_DATA_FLAGS_DISPLAY_MESHLETS,
    CONSTANT_DATA_FLAGS_DISPLAY_MESHLETS_BOUNDING_BOX,
    CONSTANT_DATA_FLAGS_DISPLAY_MESHLETS_CONE_AXIS, CONSTANT_DATA_FLAGS_DISPLAY_METALLIC,
    CONSTANT_DATA_FLAGS_DISPLAY_NORMALS, CONSTANT_DATA_FLAGS_DISPLAY_PATHTRACE,
    CONSTANT_DATA_FLAGS_DISPLAY_RADIANCE_BUFFER, CONSTANT_DATA_FLAGS_DISPLAY_ROUGHNESS,
    CONSTANT_DATA_FLAGS_DISPLAY_TANGENT, CONSTANT_DATA_FLAGS_DISPLAY_UV_0,
    CONSTANT_DATA_FLAGS_DISPLAY_UV_1, CONSTANT_DATA_FLAGS_DISPLAY_UV_2,
    CONSTANT_DATA_FLAGS_DISPLAY_UV_3, CONSTANT_DATA_FLAGS_NONE,
};
use inox_math::{
    compute_frustum, Degrees, Frustum, Mat4Ops, MatBase, Matrix4, NewAngle, Quat, VecBase, Vector2,
    Vector3,
};
use inox_messenger::Listener;
use inox_platform::{MouseEvent, MouseState, WindowEvent};
use inox_resources::{DataTypeResourceEvent, HashBuffer, Resource, ResourceEvent};
use inox_scene::{Camera, Object, ObjectId, Scene};
use inox_ui::{implement_widget_data, ComboBox, DragValue, UIWidget, Window};
use inox_uid::INVALID_UID;

use crate::events::{WidgetEvent, WidgetType};

#[derive(Clone)]
struct MeshInfo {
    meshlets: Vec<MeshletInfo>,
    matrix: Matrix4,
    flags: MeshFlags,
}

impl Default for MeshInfo {
    fn default() -> Self {
        Self {
            meshlets: Vec::new(),
            matrix: Matrix4::default_identity(),
            flags: MeshFlags::None,
        }
    }
}

#[allow(dead_code)]
#[derive(Clone)]
struct MeshletInfo {
    min: Vector3,
    max: Vector3,
    center: Vector3,
    axis: Vector3,
}

impl Default for MeshletInfo {
    fn default() -> Self {
        Self {
            min: Vector3::default_zero(),
            max: Vector3::default_zero(),
            center: Vector3::default_zero(),
            axis: Vector3::default_zero(),
        }
    }
}

#[derive(Clone)]
pub struct InfoParams {
    pub is_active: bool,
    pub scene: Resource<Scene>,
    pub renderer: RendererRw,
}

#[derive(Clone)]
struct Data {
    context: ContextRc,
    params: InfoParams,
    show_hierarchy: bool,
    show_graphics: bool,
    show_tlas: bool,
    show_blas: bool,
    show_frustum: bool,
    show_lights: bool,
    freeze_culling_camera: bool,
    visualization_debug_selected: usize,
    visualization_debug_choices: Vec<(u32, &'static str)>,
    mouse_coords: Vector2,
    screen_size: Vector2,
    fps: u32,
    dt: u128,
    cam_matrix: Matrix4,
    near: f32,
    far: f32,
    fov: Degrees,
    aspect_ratio: f32,
    selected_object_id: ObjectId,
    indirect_light_num_bounces: u32,
}
implement_widget_data!(Data);

pub struct Info {
    ui_page: Resource<UIWidget>,
    listener: Listener,
    meshes: HashBuffer<MeshId, MeshInfo, 0>,
}

impl Info {
    pub fn new(context: &ContextRc, params: InfoParams) -> Self {
        let listener = Listener::new(context.message_hub());
        listener
            .register::<DataTypeResourceEvent<Mesh>>()
            .register::<ResourceEvent<Mesh>>()
            .register::<WidgetEvent>()
            .register::<WindowEvent>()
            .register::<MouseEvent>();
        let data = Data {
            context: context.clone(),
            indirect_light_num_bounces: {
                let renderer = params.renderer.read().unwrap();
                let render_context = renderer.render_context();
                let v = render_context.constant_data.read().unwrap().num_bounces();
                v
            },
            params,
            show_hierarchy: false,
            show_graphics: false,
            show_tlas: false,
            show_blas: false,
            show_frustum: false,
            show_lights: false,
            freeze_culling_camera: false,
            visualization_debug_selected: 0,
            visualization_debug_choices: vec![
                (CONSTANT_DATA_FLAGS_NONE, "None"),
                (CONSTANT_DATA_FLAGS_DISPLAY_BASE_COLOR, "Base Color"),
                (CONSTANT_DATA_FLAGS_DISPLAY_METALLIC, "Metallic"),
                (CONSTANT_DATA_FLAGS_DISPLAY_ROUGHNESS, "Roughness"),
                (CONSTANT_DATA_FLAGS_DISPLAY_NORMALS, "Normals"),
                (CONSTANT_DATA_FLAGS_DISPLAY_TANGENT, "Tangents"),
                (CONSTANT_DATA_FLAGS_DISPLAY_BITANGENT, "Bitangent"),
                (CONSTANT_DATA_FLAGS_DISPLAY_UV_0, "TexCoord UV 0"),
                (CONSTANT_DATA_FLAGS_DISPLAY_UV_1, "TexCoord UV 1"),
                (CONSTANT_DATA_FLAGS_DISPLAY_UV_2, "TexCoord UV 2"),
                (CONSTANT_DATA_FLAGS_DISPLAY_UV_3, "TexCoord UV 3"),
                (CONSTANT_DATA_FLAGS_DISPLAY_MESHLETS, "Meshlets"),
                (CONSTANT_DATA_FLAGS_DISPLAY_DEPTH_BUFFER, "DepthBuffer"),
                (
                    CONSTANT_DATA_FLAGS_DISPLAY_RADIANCE_BUFFER,
                    "RadianceBuffer",
                ),
                (
                    CONSTANT_DATA_FLAGS_DISPLAY_MESHLETS_BOUNDING_BOX,
                    "Meshlets BoundingBox",
                ),
                (
                    CONSTANT_DATA_FLAGS_DISPLAY_MESHLETS_CONE_AXIS,
                    "Meshlets ConeAxis",
                ),
                (CONSTANT_DATA_FLAGS_DISPLAY_PATHTRACE, "PathTrace"),
            ],
            mouse_coords: Vector2::default_zero(),
            screen_size: Vector2::default_one(),
            fps: 0,
            dt: 0,
            cam_matrix: Matrix4::default_identity(),
            near: 0.,
            far: 0.,
            fov: Degrees::new(0.),
            aspect_ratio: 1.,
            selected_object_id: INVALID_UID,
        };
        Self {
            ui_page: Self::create(data),
            listener,
            meshes: HashBuffer::default(),
        }
    }

    pub fn is_active(&self) -> bool {
        if let Some(data) = self.ui_page.get().data::<Data>() {
            return data.params.is_active;
        }
        false
    }
    pub fn set_active(&self, is_active: bool) {
        if let Some(data) = self.ui_page.get_mut().data_mut::<Data>() {
            data.params.is_active = is_active;
        }
    }
    pub fn set_scene(&self, scene: Resource<Scene>) {
        if let Some(data) = self.ui_page.get_mut().data_mut::<Data>() {
            data.params.scene = scene;
        }
    }

    fn update_events(&mut self) {
        inox_profiler::scoped_profile!("Info::update_events");

        self.listener
            .process_messages(|e: &WidgetEvent| {
                if let WidgetEvent::Selected(object_id) = e {
                    if let Some(data) = self.ui_page.get_mut().data_mut::<Data>() {
                        data.selected_object_id = *object_id;
                    }
                }
            })
            .process_messages(|e: &DataTypeResourceEvent<Mesh>| {
                let DataTypeResourceEvent::Loaded(id, mesh_data) = e;
                let mut meshlets = Vec::new();
                mesh_data.meshlets.iter().for_each(|meshlet| {
                    meshlets.push(MeshletInfo {
                        min: meshlet.aabb_min,
                        max: meshlet.aabb_max,
                        center: meshlet.cone_center,
                        axis: meshlet.cone_axis,
                    });
                });
                self.meshes.insert(
                    id,
                    MeshInfo {
                        meshlets,
                        ..Default::default()
                    },
                );
            })
            .process_messages(|e: &ResourceEvent<Mesh>| match e {
                ResourceEvent::Changed(id) => {
                    if let Some(data) = self.ui_page.get().data::<Data>() {
                        if let Some(mesh) = data.context.shared_data().get_resource::<Mesh>(id) {
                            if let Some(m) = self.meshes.get_mut(id) {
                                m.matrix = mesh.get().matrix();
                                m.flags = *mesh.get().flags();
                            }
                        }
                    }
                }
                ResourceEvent::Destroyed(id) => {
                    self.meshes.remove(id);
                }
                _ => {}
            })
            .process_messages(|event: &MouseEvent| {
                if event.state == MouseState::Move {
                    if let Some(data) = self.ui_page.get_mut().data_mut::<Data>() {
                        data.mouse_coords = [event.x as f32, event.y as f32].into()
                    }
                }
            })
            .process_messages(|event: &WindowEvent| {
                if let WindowEvent::SizeChanged(width, height) = *event {
                    if let Some(data) = self.ui_page.get_mut().data_mut::<Data>() {
                        data.screen_size = [width.max(1) as f32, height.max(1) as f32].into();
                    }
                }
            });
    }

    pub fn update(&mut self) {
        inox_profiler::scoped_profile!("Info::update");

        self.update_events();

        if let Some(data) = self.ui_page.get_mut().data_mut::<Data>() {
            data.fps = data.context.global_timer().fps();
            data.dt = data.context.global_timer().dt().as_millis();

            if data.show_hierarchy {
                self.listener
                    .message_hub()
                    .send_event(WidgetEvent::Create(WidgetType::Hierarchy));
            } else {
                self.listener
                    .message_hub()
                    .send_event(WidgetEvent::Destroy(WidgetType::Hierarchy));
            }

            if data.show_graphics {
                self.listener
                    .message_hub()
                    .send_event(WidgetEvent::Create(WidgetType::Gfx));
            } else {
                self.listener
                    .message_hub()
                    .send_event(WidgetEvent::Destroy(WidgetType::Gfx));
            }
            if data.show_lights {
                Self::show_lights(data);
            }
            if data.show_frustum {
                if !data.freeze_culling_camera {
                    if let Some(camera) = data
                        .context
                        .shared_data()
                        .match_resource(|c: &Camera| c.is_active())
                    {
                        let c = camera.get();
                        data.near = c.near_plane();
                        data.far = c.far_plane();
                        data.cam_matrix = c.transform();
                        data.fov = c.fov_in_degrees();
                        data.aspect_ratio = c.aspect_ratio();
                    }
                }
                let frustum = compute_frustum(
                    &data.cam_matrix,
                    data.near,
                    data.far,
                    data.fov,
                    data.aspect_ratio,
                );
                Self::show_frustum(data, &frustum);
            }
            if data.show_tlas {
                let renderer = data.params.renderer.read().unwrap();
                let render_context = renderer.render_context();
                let tlas_index = render_context
                    .global_buffers
                    .tlas_start_index
                    .read()
                    .unwrap()
                    .load(Ordering::Relaxed);
                let bhv = render_context.global_buffers.bvh.read().unwrap();
                bhv.for_each_data(|i, _id, n| {
                    if i >= tlas_index as _ {
                        data.context
                            .message_hub()
                            .send_event(DrawEvent::BoundingBox(
                                n.min.into(),
                                n.max.into(),
                                [0.5, 1.0, 0.5, 1.0].into(),
                            ));
                    }
                });
            }
            if data.show_blas {
                let renderer = data.params.renderer.read().unwrap();
                let render_context = renderer.render_context();
                let bhv = render_context.global_buffers.bvh.read().unwrap();
                let bhv_data = bhv.data();
                let meshes = render_context.global_buffers.meshes.read().unwrap();
                meshes.for_each_entry(|_, mesh| {
                    let node = &bhv_data[mesh.blas_index as usize];
                    let matrix = Matrix4::from_translation_orientation_scale(
                        mesh.position.into(),
                        mesh.orientation.into(),
                        mesh.scale.into(),
                    );
                    let min = matrix.rotate_point(node.min.into());
                    let max = matrix.rotate_point(node.max.into());
                    data.context
                        .message_hub()
                        .send_event(DrawEvent::BoundingBox(
                            min,
                            max,
                            [1.0, 0.8, 0.2, 1.0].into(),
                        ));
                });
            }
            if !data.selected_object_id.is_nil() {
                Self::show_object_in_scene(data, &data.selected_object_id);
            }
            match data.visualization_debug_choices[data.visualization_debug_selected].0 {
                CONSTANT_DATA_FLAGS_DISPLAY_MESHLETS_BOUNDING_BOX => {
                    Self::show_meshlets_bounding_box(data, &self.meshes)
                }
                CONSTANT_DATA_FLAGS_DISPLAY_MESHLETS_CONE_AXIS => {
                    Self::show_meshlets_cone_axis(data, &self.meshes)
                }
                _ => {}
            }
        }
    }

    fn show_object_in_scene(data: &Data, object_id: &ObjectId) {
        if let Some(object) = data.context.shared_data().get_resource::<Object>(object_id) {
            let object = object.get();
            let meshes = object.components_of_type::<Mesh>();
            if meshes.is_empty() {
                let children = object.children();
                children.iter().for_each(|o| {
                    Self::show_object_in_scene(data, o.id());
                });
            } else {
                let renderer = data.params.renderer.read().unwrap();
                let render_context = renderer.render_context();
                let bhv = render_context.global_buffers.bvh.read().unwrap();
                meshes.iter().for_each(|mesh| {
                    if let Some(nodes) = bhv.items(mesh.id()) {
                        nodes.iter().for_each(|n| {
                            let matrix = mesh.get().matrix();
                            data.context
                                .message_hub()
                                .send_event(DrawEvent::BoundingBox(
                                    matrix.rotate_point(n.min.into()),
                                    matrix.rotate_point(n.max.into()),
                                    [1.0, 1.0, 0.0, 1.0].into(),
                                ));
                        });
                    }
                });
            }
            let lights = object.components_of_type::<Light>();
            for l in lights {
                let light = l.get();
                let ld = light.data();
                data.context.message_hub().send_event(DrawEvent::Sphere(
                    ld.position.into(),
                    ld.range,
                    [1.0, 1.0, 0.0, 1.0].into(),
                    true,
                ));
            }
        }
    }

    fn show_lights(data: &Data) {
        data.context
            .shared_data()
            .for_each_resource(|_, l: &Light| {
                if l.is_active() {
                    data.context.message_hub().send_event(DrawEvent::Sphere(
                        l.data().position.into(),
                        l.data().range,
                        [l.data().color[0], l.data().color[1], l.data().color[2], 1.].into(),
                        true,
                    ));
                }
            });
    }

    fn show_meshlets_bounding_box(data: &mut Data, meshes: &HashBuffer<MeshId, MeshInfo, 0>) {
        meshes.for_each_entry(|_id, mesh_info| {
            if mesh_info.flags.contains(MeshFlags::Visible) {
                mesh_info.meshlets.iter().for_each(|meshlet_info| {
                    data.context
                        .message_hub()
                        .send_event(DrawEvent::BoundingBox(
                            mesh_info.matrix.rotate_point(meshlet_info.min),
                            mesh_info.matrix.rotate_point(meshlet_info.max),
                            [1.0, 1.0, 0.0, 1.0].into(),
                        ));
                });
            }
        });
    }

    fn show_meshlets_cone_axis(data: &mut Data, meshes: &HashBuffer<MeshId, MeshInfo, 0>) {
        meshes.for_each_entry(|_id, mesh_info| {
            if mesh_info.flags.contains(MeshFlags::Visible) {
                mesh_info.meshlets.iter().for_each(|meshlet_info| {
                    let pos = mesh_info.matrix.rotate_point(meshlet_info.center);
                    data.context.message_hub().send_event(DrawEvent::Line(
                        pos,
                        pos + mesh_info
                            .matrix
                            .orientation()
                            .transform_vector(meshlet_info.axis)
                            * 0.75,
                        [1.0, 1.0, 0.0, 1.0].into(),
                    ));
                });
            }
        });
    }

    fn show_frustum(data: &Data, frustum: &Frustum) {
        let color = [1., 1., 0., 1.];

        //NearPlane
        data.context.message_hub().send_event(DrawEvent::Line(
            frustum.ntr,
            frustum.ntl,
            color.into(),
        ));
        data.context.message_hub().send_event(DrawEvent::Line(
            frustum.ntr,
            frustum.nbr,
            color.into(),
        ));
        data.context.message_hub().send_event(DrawEvent::Line(
            frustum.ntl,
            frustum.nbl,
            color.into(),
        ));
        data.context.message_hub().send_event(DrawEvent::Line(
            frustum.nbr,
            frustum.nbl,
            color.into(),
        ));

        //FarPlane
        data.context.message_hub().send_event(DrawEvent::Line(
            frustum.ftr,
            frustum.ftl,
            color.into(),
        ));
        data.context.message_hub().send_event(DrawEvent::Line(
            frustum.ftr,
            frustum.fbr,
            color.into(),
        ));
        data.context.message_hub().send_event(DrawEvent::Line(
            frustum.ftl,
            frustum.fbl,
            color.into(),
        ));
        data.context.message_hub().send_event(DrawEvent::Line(
            frustum.fbr,
            frustum.fbl,
            color.into(),
        ));

        //LeftPlane
        data.context.message_hub().send_event(DrawEvent::Line(
            frustum.ftl,
            frustum.ntl,
            color.into(),
        ));
        data.context.message_hub().send_event(DrawEvent::Line(
            frustum.fbl,
            frustum.nbl,
            color.into(),
        ));

        //RightPlane
        data.context.message_hub().send_event(DrawEvent::Line(
            frustum.ftr,
            frustum.ntr,
            color.into(),
        ));
        data.context.message_hub().send_event(DrawEvent::Line(
            frustum.fbr,
            frustum.nbr,
            color.into(),
        ));
    }

    fn create(data: Data) -> Resource<UIWidget> {
        let shared_data = data.context.shared_data().clone();
        let message_hub = data.context.message_hub().clone();
        UIWidget::register(&shared_data, &message_hub, data, |ui_data, ui_context| {
            if let Some(data) = ui_data.as_any_mut().downcast_mut::<Data>() {
                if !data.params.is_active {
                    return false;
                }
                if let Some(response) = Window::new("Debug")
                    .vscroll(true)
                    .title_bar(true)
                    .resizable(true)
                    .show(ui_context, |ui| {
                        ui.label(format!("FPS: {} - ms: {:?}", data.fps, data.dt));
                        ui.label(format!(
                            "Mouse: ({},{}) - ({:.3},{:.3})",
                            data.mouse_coords.x,
                            data.mouse_coords.y,
                            data.mouse_coords.x / data.screen_size.x,
                            data.mouse_coords.y / data.screen_size.y
                        ));
                        ui.checkbox(&mut data.show_hierarchy, "Hierarchy");
                        ui.checkbox(&mut data.show_graphics, "Graphics");
                        ui.checkbox(&mut data.show_lights, "Show Lights");
                        ui.checkbox(&mut data.show_tlas, "Show TLAS BHV");
                        ui.checkbox(&mut data.show_blas, "Show BLAS BHVs");
                        ui.checkbox(&mut data.show_frustum, "Show Frustum");
                        let is_freezed = data.freeze_culling_camera;
                        ui.checkbox(&mut data.freeze_culling_camera, "Freeze Culling Camera");
                        if is_freezed != data.freeze_culling_camera {
                            if data.freeze_culling_camera {
                                data.context
                                    .message_hub()
                                    .send_event(CullingEvent::FreezeCamera);
                            } else {
                                data.context
                                    .message_hub()
                                    .send_event(CullingEvent::UnfreezeCamera);
                            }
                        }
                        ui.horizontal(|ui| {
                            ui.label("Indirect light bounces: ");
                            let previous_value = data.indirect_light_num_bounces;
                            ui.add(
                                DragValue::new(&mut data.indirect_light_num_bounces)
                                    .clamp_range(0..=1024),
                            );
                            if previous_value != data.indirect_light_num_bounces {
                                let renderer = data.params.renderer.read().unwrap();
                                let render_context = renderer.render_context();
                                render_context
                                    .constant_data
                                    .write()
                                    .unwrap()
                                    .set_num_bounces(data.indirect_light_num_bounces)
                                    .set_frame_index(0);
                            }
                        });
                        ui.vertical(|ui| {
                            let renderer = data.params.renderer.read().unwrap();
                            let render_context = renderer.render_context();
                            let mut lights = render_context.global_buffers.lights.write().unwrap();
                            let light_type_none: u32 = LightType::None.into();
                            let mut num_lights = 0;
                            lights.for_each_entry_mut(|i, l| {
                                if l.light_type == light_type_none {
                                    return false;
                                }
                                num_lights += 1;
                                let mut is_changed = false;
                                ui.horizontal(|ui| {
                                    let light_name = format!("Light[{}]: ", i);
                                    ui.label(&light_name);
                                    let old_l = *l;
                                    ui.vertical(|ui| {
                                        let directional: u32 = LightType::Directional.into();
                                        if l.light_type == directional {
                                            ui.horizontal(|ui| {
                                                ui.label("Direction: ");
                                                ui.add(
                                                    DragValue::new(&mut l.direction[0])
                                                        .prefix("x: ")
                                                        .speed(0.01)
                                                        .fixed_decimals(3),
                                                );
                                                ui.add(
                                                    DragValue::new(&mut l.direction[1])
                                                        .prefix("y: ")
                                                        .speed(0.01)
                                                        .fixed_decimals(3),
                                                );
                                                ui.add(
                                                    DragValue::new(&mut l.direction[2])
                                                        .prefix("z: ")
                                                        .speed(0.01)
                                                        .fixed_decimals(3),
                                                );
                                            });
                                        } else {
                                            ui.horizontal(|ui| {
                                                ui.label("Position: ");
                                                ui.add(
                                                    DragValue::new(&mut l.position[0])
                                                        .prefix("x: ")
                                                        .speed(0.01)
                                                        .fixed_decimals(3),
                                                );
                                                ui.add(
                                                    DragValue::new(&mut l.position[1])
                                                        .prefix("y: ")
                                                        .speed(0.01)
                                                        .fixed_decimals(3),
                                                );
                                                ui.add(
                                                    DragValue::new(&mut l.position[2])
                                                        .prefix("z: ")
                                                        .speed(0.01)
                                                        .fixed_decimals(3),
                                                );
                                            });
                                        }
                                        ui.horizontal(|ui| {
                                            ui.label("Intensity: ");
                                            ui.add(
                                                DragValue::new(&mut l.intensity)
                                                    .prefix("x: ")
                                                    .speed(0.01)
                                                    .fixed_decimals(3),
                                            );
                                        });
                                        ui.horizontal(|ui| {
                                            ui.label("Range: ");
                                            ui.add(
                                                DragValue::new(&mut l.range)
                                                    .prefix("x: ")
                                                    .speed(0.01)
                                                    .fixed_decimals(3),
                                            );
                                        });
                                    });
                                    is_changed = old_l != *l;
                                });
                                is_changed
                            });
                            let lights_label = format!("Total Num Lights: {}", num_lights);
                            ui.label(&lights_label);
                        });

                        ui.horizontal(|ui| {
                            ui.label("Debug mode:");
                            let combo_box = ComboBox::from_id_source("Debug mode")
                                .selected_text(
                                    data.visualization_debug_choices
                                        [data.visualization_debug_selected]
                                        .1
                                        .to_string(),
                                )
                                .show_ui(ui, |ui| {
                                    let mut is_changed = false;
                                    data.visualization_debug_choices
                                        .iter()
                                        .enumerate()
                                        .for_each(|(i, v)| {
                                            is_changed |= ui
                                                .selectable_value(
                                                    &mut data.visualization_debug_selected,
                                                    i,
                                                    v.1,
                                                )
                                                .changed();
                                        });
                                    is_changed
                                });
                            if let Some(is_changed) = combo_box.inner {
                                if is_changed {
                                    let renderer = data.params.renderer.read().unwrap();
                                    let render_context = renderer.render_context();
                                    render_context
                                        .constant_data
                                        .write()
                                        .unwrap()
                                        .set_flags(CONSTANT_DATA_FLAGS_NONE);
                                    match data.visualization_debug_choices
                                        [data.visualization_debug_selected]
                                        .0
                                    {
                                        CONSTANT_DATA_FLAGS_NONE => {
                                            render_context
                                                .constant_data
                                                .write()
                                                .unwrap()
                                                .set_frame_index(0);
                                        }
                                        _ => {
                                            render_context.constant_data.write().unwrap().add_flag(
                                                data.visualization_debug_choices
                                                    [data.visualization_debug_selected]
                                                    .0,
                                            );
                                        }
                                    }
                                }
                            }
                        });
                    })
                {
                    return response.response.is_pointer_button_down_on();
                }
            }
            false
        })
    }
}
