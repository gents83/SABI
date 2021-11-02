use std::path::Path;

use crate::{copy_into_data_folder, ExtensionHandler};
use nrg_messenger::MessengerRw;
use nrg_profiler::debug_log;

const CONFIG_EXTENSION: &str = "cfg";
const MATERIAL_EXTENSION: &str = "material_data";
const MESH_EXTENSION: &str = "mesh_data";
const PIPELINE_EXTENSION: &str = "pipeline_data";
const OBJECT_EXTENSION: &str = "object_data";
const SCENE_EXTENSION: &str = "scene_data";
const CAMERA_EXTENSION: &str = "camera_data";

pub struct CopyCompiler {
    global_messenger: MessengerRw,
}

impl CopyCompiler {
    pub fn new(global_messenger: MessengerRw) -> Self {
        Self { global_messenger }
    }
}

impl ExtensionHandler for CopyCompiler {
    fn on_changed(&mut self, path: &Path) {
        if let Some(ext) = path.extension() {
            let ext = ext.to_str().unwrap().to_string();
            if (ext.as_str() == CONFIG_EXTENSION
                || ext.as_str() == MATERIAL_EXTENSION
                || ext.as_str() == MESH_EXTENSION
                || ext.as_str() == PIPELINE_EXTENSION
                || ext.as_str() == SCENE_EXTENSION
                || ext.as_str() == OBJECT_EXTENSION
                || ext.as_str() == CAMERA_EXTENSION)
                && copy_into_data_folder(&self.global_messenger, path)
            {
                debug_log(format!("Serializing {:?}", path).as_str());
            }
        }
    }
}