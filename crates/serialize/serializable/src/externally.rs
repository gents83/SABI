use crate::de::{FnApply, MapLookupVisitor};
use crate::registry::Registry;
use crate::ser::Wrap;
use serde::de::{self, Deserializer, MapAccess, Visitor};
use serde::ser::{SerializeMap, Serializer};
use std::fmt;

pub fn serialize<S, T>(
    serializer: S,
    variant: &'static str,
    concrete: &T,
) -> Result<S::Ok, S::Error>
where
    S: Serializer,
    T: ?Sized + erased_serde::Serialize,
{
    let mut ser = serializer.serialize_map(Some(1))?;
    ser.serialize_entry(variant, &Wrap(concrete))?;
    ser.end()
}

pub fn deserialize<'de, D, T>(
    deserializer: D,
    trait_object: &'static str,
    registry: &Registry<T>,
) -> Result<Box<T>, D::Error>
where
    D: Deserializer<'de>,
    T: ?Sized,
{
    let visitor = TaggedVisitor {
        trait_object,
        registry,
    };
    deserializer.deserialize_map(visitor)
}

struct TaggedVisitor<'a, T: ?Sized + 'static> {
    trait_object: &'static str,
    registry: &'a Registry<T>,
}

impl<'de, T: ?Sized> Visitor<'de> for TaggedVisitor<'_, T> {
    type Value = Box<T>;

    fn expecting(&self, formatter: &mut fmt::Formatter) -> fmt::Result {
        write!(formatter, "dyn {}", self.trait_object)
    }

    fn visit_map<A>(self, mut map: A) -> Result<Self::Value, A::Error>
    where
        A: MapAccess<'de>,
    {
        let map_lookup = MapLookupVisitor {
            expected: &self,
            registry: self.registry,
        };
        let deserialize_fn = match map.next_key_seed(map_lookup)? {
            Some(deserialize_fn) => deserialize_fn,
            None => {
                return Err(de::Error::custom(format_args!(
                    "expected externally tagged dyn {}",
                    self.trait_object
                )));
            }
        };
        map.next_value_seed(FnApply { deserialize_fn })
    }
}
