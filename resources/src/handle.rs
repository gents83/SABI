use std::{any::Any, marker::PhantomData, sync::Arc};

use nrg_serialize::INVALID_UID;

use crate::{
    Resource, ResourceCastTo, ResourceData, ResourceId, SharedData, SharedDataRw, TypedStorage,
};

pub trait Handle: Send + Sync + Any {
    fn as_any(self: Arc<Self>) -> Arc<dyn Any + Send + Sync>;
}

pub struct ResourceHandle<T>
where
    T: ResourceData + ?Sized,
{
    id: ResourceId,
    shared_data: SharedDataRw,
    _marker: PhantomData<T>,
}

impl<T> Handle for ResourceHandle<T>
where
    T: ResourceData,
{
    #[inline]
    fn as_any(self: Arc<Self>) -> Arc<dyn Any + Send + Sync> {
        self
    }
}

impl<T> Default for ResourceHandle<T>
where
    T: ResourceData,
{
    #[inline]
    fn default() -> Self {
        Self {
            id: INVALID_UID,
            shared_data: SharedDataRw::default(),
            _marker: PhantomData::default(),
        }
    }
}

impl<T> ResourceHandle<T>
where
    T: ResourceData,
{
    #[inline]
    pub fn new(id: ResourceId, shared_data: SharedDataRw) -> Self {
        Self {
            id,
            shared_data,
            _marker: PhantomData::default(),
        }
    }

    #[inline]
    pub fn id(&self) -> ResourceId {
        self.id
    }

    #[inline]
    pub fn is_valid(&self) -> bool {
        !self.id.is_nil() && SharedData::has_resource::<T>(&self.shared_data, self.id)
    }

    #[inline]
    pub fn resource(&self) -> Resource<T> {
        let shared_data = self.shared_data.read().unwrap();
        shared_data
            .get_storage::<T>()
            .resource(self.id)
            .of_type::<T>()
    }
}

pub type ResourceRef<T> = Arc<ResourceHandle<T>>;
pub type GenericRef = Arc<dyn Handle>;

pub trait HandleCastTo {
    fn of_type<T: ResourceData>(self) -> ResourceRef<T>;
}

impl HandleCastTo for GenericRef {
    #[inline]
    fn of_type<T: ResourceData>(self) -> ResourceRef<T> {
        let any = Arc::into_raw(self.as_any());
        Arc::downcast(unsafe { Arc::from_raw(any) }).unwrap()
    }
}
