use std::path::PathBuf;

use sabi_resources::{ConfigBase};
use sabi_serialize::{Deserialize, Serialize, SerializeFile};

use crate::RenderPassData;

#[derive(Default, Serialize, Deserialize, Debug, Clone)]
#[serde(crate = "sabi_serialize")]
pub struct Config {
    pub render_passes: Vec<RenderPassData>,
    pub pipelines: Vec<PathBuf>,
}

impl SerializeFile for Config {
    fn extension() -> &'static str {
        "cfg"
    }
}
impl ConfigBase for Config {
    fn get_filename(&self) -> &'static str {
        "render.cfg"
    }
}
