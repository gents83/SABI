use std::path::{Path, PathBuf};

use image::{ImageFormat, RgbaImage};
use inox_filesystem::{convert_from_local_path, File};
use inox_messenger::MessageHubRc;
use inox_log::debug_log;
use inox_resources::{
    Data, DataTypeResource, Handle, ResourceEvent, ResourceId, ResourceTrait, SerializableResource,
    SharedData, SharedDataRc,
};
use inox_serialize::inox_serializable::SerializableRegistryRc;

use crate::{RenderContext, TextureHandler, INVALID_INDEX, TEXTURE_CHANNEL_COUNT};

pub type TextureId = ResourceId;

#[derive(Clone)]
pub struct Texture {
    id: TextureId,
    message_hub: MessageHubRc,
    shared_data: SharedDataRc,
    path: PathBuf,
    data: Option<Vec<u8>>,
    uniform_index: i32,
    width: u32,
    height: u32,
    update_from_gpu: bool,
}

impl DataTypeResource for Texture {
    type DataType = RgbaImage;
    type OnCreateData = ();

    fn new(id: ResourceId, shared_data: &SharedDataRc, message_hub: &MessageHubRc) -> Self {
        Self {
            id,
            message_hub: message_hub.clone(),
            shared_data: shared_data.clone(),
            path: PathBuf::new(),
            data: None,
            uniform_index: INVALID_INDEX,
            width: 0,
            height: 0,
            update_from_gpu: false,
        }
    }

    fn invalidate(&mut self) -> &mut Self {
        self.uniform_index = INVALID_INDEX;
        debug_log!("Texture {:?} will be reloaded", self.path);
        self
    }
    fn is_initialized(&self) -> bool {
        self.uniform_index != INVALID_INDEX
    }
    fn deserialize_data(
        path: &Path,
        _registry: &SerializableRegistryRc,
        mut f: Box<dyn FnMut(Self::DataType) + 'static>,
    ) {
        let mut file = File::new(path);
        let filepath = path.to_path_buf();
        file.load(move |bytes| {
            let image_data = image::load_from_memory_with_format(
                bytes.as_slice(),
                ImageFormat::from_path(filepath.as_path()).unwrap(),
            )
            .unwrap();
            f(image_data.to_rgba8());
        });
    }
    fn on_create(
        &mut self,
        _shared_data_rc: &SharedDataRc,
        _message_hub: &MessageHubRc,
        _id: &TextureId,
        _on_create_data: Option<&<Self as ResourceTrait>::OnCreateData>,
    ) {
    }
    fn on_destroy(
        &mut self,
        _shared_data: &SharedData,
        _message_hub: &MessageHubRc,
        _id: &TextureId,
    ) {
    }

    fn create_from_data(
        shared_data: &SharedDataRc,
        message_hub: &MessageHubRc,
        id: ResourceId,
        data: Self::DataType,
    ) -> Self
    where
        Self: Sized,
    {
        let dimensions = data.dimensions();
        let mut texture = Self::new(id, shared_data, message_hub);
        texture.data = Some(data.as_raw().clone());
        texture.width = dimensions.0;
        texture.height = dimensions.1;
        texture
    }
}

impl SerializableResource for Texture {
    fn set_path(&mut self, path: &Path) {
        self.path = path.to_path_buf();
    }
    fn path(&self) -> &Path {
        self.path.as_path()
    }

    fn extension() -> &'static str {
        "png"
    }

    fn is_matching_extension(path: &Path) -> bool {
        const IMAGE_PNG_EXTENSION: &str = "png";
        const IMAGE_JPG_EXTENSION: &str = "jpg";
        const IMAGE_JPEG_EXTENSION: &str = "jpeg";
        const IMAGE_BMP_EXTENSION: &str = "bmp";
        const IMAGE_TGA_EXTENSION: &str = "tga";
        const IMAGE_DDS_EXTENSION: &str = "dds";
        const IMAGE_TIFF_EXTENSION: &str = "tiff";
        const IMAGE_GIF_EXTENSION: &str = "bmp";
        const IMAGE_ICO_EXTENSION: &str = "ico";

        if let Some(ext) = path.extension().unwrap().to_str() {
            return ext == IMAGE_PNG_EXTENSION
                || ext == IMAGE_JPG_EXTENSION
                || ext == IMAGE_JPEG_EXTENSION
                || ext == IMAGE_BMP_EXTENSION
                || ext == IMAGE_TGA_EXTENSION
                || ext == IMAGE_DDS_EXTENSION
                || ext == IMAGE_TIFF_EXTENSION
                || ext == IMAGE_GIF_EXTENSION
                || ext == IMAGE_ICO_EXTENSION;
        }
        false
    }
}

impl Texture {
    fn mark_as_dirty(&self) -> &Self {
        self.message_hub
            .send_event(ResourceEvent::<Self>::Changed(self.id));
        self
    }
    pub fn find_from_path(shared_data: &SharedDataRc, texture_path: &Path) -> Handle<Self> {
        let path = convert_from_local_path(Data::data_folder().as_path(), texture_path);
        SharedData::match_resource(shared_data, |t: &Texture| t.path == path)
    }
    pub fn path(&self) -> &Path {
        self.path.as_path()
    }
    pub fn dimensions(&self) -> (u32, u32) {
        (self.width, self.height)
    }
    pub fn width(&self) -> u32 {
        self.width
    }
    pub fn height(&self) -> u32 {
        self.height
    }
    pub fn image_data(&self) -> &Option<Vec<u8>> {
        &self.data
    }
    pub fn uniform_index(&self) -> i32 {
        self.uniform_index
    }
    pub fn set_texture_data(&mut self, uniform_index: usize, width: u32, height: u32) -> &mut Self {
        self.uniform_index = uniform_index as _;
        self.width = width;
        self.height = height;
        self
    }

    pub fn capture_image(
        &mut self,
        texture_id: &TextureId,
        texture_handler: &TextureHandler,
        context: &RenderContext,
    ) {
        inox_profiler::scoped_profile!("texture::capture_image");
        if self.data.is_none() {
            let mut image_data = Vec::new();
            image_data.resize_with(
                (self.width * self.height * TEXTURE_CHANNEL_COUNT) as _,
                || 0u8,
            );
            self.data = Some(image_data)
        }
        texture_handler.copy(
            &context.device,
            texture_id,
            self.data.as_mut().unwrap().as_mut_slice(),
        );
        self.mark_as_dirty();
    }
}
