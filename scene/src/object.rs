use std::{
    any::{type_name, TypeId},
    collections::HashMap,
    path::{Path, PathBuf},
};

use nrg_graphics::{Material, Mesh};
use nrg_math::Matrix4;
use nrg_resources::{
    DataTypeResource, Deserializable, GenericResource, Handle, Resource, ResourceCastTo,
    ResourceData, ResourceId, SerializableResource, SharedData, SharedDataRw,
};
use nrg_serialize::{generate_random_uid, generate_uid_from_string};
use nrg_ui::{CollapsingHeader, UIProperties, UIPropertiesRegistry, Ui};

use crate::{ObjectData, Transform};

pub type ComponentId = ResourceId;
pub type ObjectId = ResourceId;

#[derive(Default)]
pub struct Object {
    id: ResourceId,
    filepath: PathBuf,
    children: Vec<Resource<Object>>,
    components: HashMap<TypeId, GenericResource>,
}

impl ResourceData for Object {
    fn id(&self) -> ResourceId {
        self.id
    }
}

impl UIProperties for Object {
    fn show(&mut self, ui_registry: &UIPropertiesRegistry, ui: &mut Ui, collapsed: bool) {
        let mut object_name = format!("Object [{:?}]", self.id().to_simple().to_string());
        if let Some(name) = self.path().file_stem() {
            if let Some(name) = name.to_str() {
                object_name = name.to_string();
            }
        }
        CollapsingHeader::new(object_name.as_str())
            .selected(true)
            .show_background(true)
            .default_open(!collapsed)
            .show(ui, |ui| {
                CollapsingHeader::new(format!("Components [{}]", self.components.len()))
                    .default_open(!collapsed)
                    .show(ui, |ui| {
                        for (typeid, c) in self.components.iter() {
                            ui_registry.show(*typeid, c, ui);
                        }
                    });
                CollapsingHeader::new(format!("Children [{}]", self.children.len()))
                    .default_open(false)
                    .show(ui, |ui| {
                        for c in self.children.iter() {
                            c.get_mut().show(ui_registry, ui, collapsed);
                        }
                    });
            });
    }
}

impl SerializableResource for Object {
    fn path(&self) -> &Path {
        self.filepath.as_path()
    }
}
impl DataTypeResource for Object {
    type DataType = ObjectData;

    fn create_from_data(shared_data: &SharedDataRw, object_data: Self::DataType) -> Resource<Self> {
        let object = SharedData::add_resource(
            shared_data,
            Object {
                id: generate_uid_from_string(object_data.path().to_str().unwrap()),
                filepath: object_data.path().to_path_buf(),
                ..Default::default()
            },
        );
        let transform = object
            .get_mut()
            .add_default_component::<Transform>(shared_data);
        transform.get_mut().set_matrix(object_data.transform);

        if !object_data.mesh.to_str().unwrap_or_default().is_empty() {
            let mesh =
                if let Some(mesh) = Mesh::find_from_path(shared_data, object_data.mesh.as_path()) {
                    mesh
                } else {
                    Mesh::create_from_file(shared_data, object_data.mesh.as_path())
                };

            if !object_data.material.to_str().unwrap_or_default().is_empty() {
                let material = if let Some(material) =
                    Material::find_from_path(shared_data, object_data.material.as_path())
                {
                    material
                } else {
                    Material::create_from_file(shared_data, object_data.material.as_path())
                };
                mesh.get_mut().set_material(material);
            }
            object.get_mut().add_component::<Mesh>(mesh);
        }

        for child in object_data.children.iter() {
            let child = Object::create_from_file(shared_data, child.as_path());
            object.get_mut().add_child(child);
        }

        object
    }
}

impl Object {
    pub fn generate_empty(shared_data: &SharedDataRw) -> Resource<Self> {
        SharedData::add_resource::<Object>(
            shared_data,
            Object {
                id: generate_random_uid(),
                ..Default::default()
            },
        )
    }

    pub fn add_child(&mut self, child: Resource<Object>) {
        self.children.push(child);
    }

    pub fn is_child(&self, object_id: ObjectId) -> bool {
        for c in self.children.iter() {
            if c.id() == object_id {
                return true;
            }
        }
        false
    }

    pub fn is_child_recursive(&self, object_id: ObjectId) -> bool {
        for c in self.children.iter() {
            if c.id() == object_id || c.get().is_child_recursive(object_id) {
                return true;
            }
        }
        false
    }

    pub fn has_children(&self) -> bool {
        !self.children.is_empty()
    }

    pub fn children(&self) -> &Vec<Resource<Object>> {
        &self.children
    }

    pub fn components(&self) -> &HashMap<TypeId, GenericResource> {
        &self.components
    }

    pub fn add_default_component<C>(&mut self, shared_data: &SharedDataRw) -> Resource<C>
    where
        C: ResourceData + Default,
    {
        debug_assert!(
            !self.components.contains_key(&TypeId::of::<C>()),
            "Object already contains a component of type {:?}",
            type_name::<C>()
        );
        let component = C::default();
        let resource = SharedData::add_resource(shared_data, component);
        self.components.insert(TypeId::of::<C>(), resource.clone());
        resource
    }
    pub fn add_component<C>(&mut self, component: Resource<C>) -> &mut Self
    where
        C: ResourceData,
    {
        debug_assert!(
            !self.components.contains_key(&TypeId::of::<C>()),
            "Object already contains a component of type {:?}",
            type_name::<C>()
        );
        self.components
            .insert(TypeId::of::<C>(), component as GenericResource);
        self
    }

    pub fn get_component<C>(&self) -> Handle<C>
    where
        C: ResourceData,
    {
        if let Some(component) = self.components.get(&TypeId::of::<C>()) {
            return Some(component.of_type::<C>());
        }
        None
    }

    pub fn update_from_parent<F>(
        &mut self,
        shared_data: &SharedDataRw,
        parent_transform: Matrix4,
        f: F,
    ) where
        F: Fn(&mut Self, Matrix4) + Copy,
    {
        if let Some(transform) = self.get_component::<Transform>() {
            let object_matrix = transform.get().matrix();
            let object_matrix = parent_transform * object_matrix;

            f(self, object_matrix);

            let children = self.children();
            for child in children {
                child
                    .get_mut()
                    .update_from_parent(shared_data, object_matrix, f);
            }
        }
    }
}
