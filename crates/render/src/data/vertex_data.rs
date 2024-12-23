use inox_bitmask::bitmask;

pub const MAX_TEXTURE_COORDS_SETS: usize = 4;

#[bitmask]
#[repr(u32)]
pub enum VertexAttributeLayout {
    HasPosition = 0, // 	1 packed u32 with xyz in 0..1 in min-max (at runtime then 3 float)
    HasColor = 1,    // 	1 packed u32 in rgba 255bit (at runtime then 4 float)
    HasNormal = 1 << 1, // 	1 packed u32 with xy in 2f16 and z recomputed  (at runtime then 3 float)
    HasTangent = 1 << 2, // 	1 packed u32 in rgba 255bit (at runtime then 4 float)
    HasUV1 = 1 << 3, //	1 packed u32 with uv in 2f16 (at runtime then 2 float)
    HasUV2 = 1 << 4, //	1 packed u32 with uv in 2f16 (at runtime then 2 float)
    HasUV3 = 1 << 5, //	1 packed u32 with uv in 2f16 (at runtime then 2 float)
    HasUV4 = 1 << 6, //	1 packed u32 with uv in 2f16 (at runtime then 2 float)
}

impl VertexAttributeLayout {
    pub fn pos_color() -> Self {
        Self::HasPosition | Self::HasColor
    }
    pub fn pos_color_normal() -> Self {
        Self::HasPosition | Self::HasColor | Self::HasNormal
    }
    pub fn pos_color_normal_uv1() -> Self {
        Self::HasPosition | Self::HasColor | Self::HasNormal | Self::HasUV1
    }
    pub fn pos_color_normal_uv1_uv2() -> Self {
        Self::HasPosition | Self::HasColor | Self::HasNormal | Self::HasUV1 | Self::HasUV2
    }
    pub fn offset(&self, attribute: VertexAttributeLayout) -> usize {
        let mut offset = 0;
        for i in 2u32..attribute.into() {
            if self.intersects(VertexAttributeLayout::from(i)) {
                offset += 1;
            }
        }
        offset
    }
    pub fn stride_in_count(&self) -> usize {
        let mut stride = 0;
        if self.intersects(VertexAttributeLayout::HasColor) {
            stride += 1;
        }
        if self.intersects(VertexAttributeLayout::HasNormal) {
            stride += 1;
        }
        if self.intersects(VertexAttributeLayout::HasUV1) {
            stride += 1;
        }
        if self.intersects(VertexAttributeLayout::HasUV2) {
            stride += 1;
        }
        if self.intersects(VertexAttributeLayout::HasUV3) {
            stride += 1;
        }
        if self.intersects(VertexAttributeLayout::HasUV4) {
            stride += 1;
        }
        stride
    }
    pub fn stride_in_byte(&self) -> usize {
        let mut stride = 0;
        if self.intersects(VertexAttributeLayout::HasColor) {
            stride += std::mem::size_of::<u32>();
        }
        if self.intersects(VertexAttributeLayout::HasNormal) {
            stride += std::mem::size_of::<u32>();
        }
        if self.intersects(VertexAttributeLayout::HasUV1) {
            stride += std::mem::size_of::<u32>();
        }
        if self.intersects(VertexAttributeLayout::HasUV2) {
            stride += std::mem::size_of::<u32>();
        }
        if self.intersects(VertexAttributeLayout::HasUV3) {
            stride += std::mem::size_of::<u32>();
        }
        if self.intersects(VertexAttributeLayout::HasUV4) {
            stride += std::mem::size_of::<u32>();
        }
        stride
    }

    pub fn descriptor<'a>(&self, starting_location: u32) -> VertexBufferLayoutBuilder<'a> {
        let mut layout_builder = VertexBufferLayoutBuilder::vertex();
        layout_builder.starting_location(starting_location);
        if self.intersects(VertexAttributeLayout::HasColor) {
            layout_builder.add_attribute::<u32>(VertexFormat::Uint32.into());
        }
        if self.intersects(VertexAttributeLayout::HasNormal) {
            layout_builder.add_attribute::<u32>(VertexFormat::Uint32.into());
        }
        if self.intersects(VertexAttributeLayout::HasTangent) {
            layout_builder.add_attribute::<u32>(VertexFormat::Uint32.into());
        }
        if self.intersects(VertexAttributeLayout::HasUV1) {
            layout_builder.add_attribute::<u32>(VertexFormat::Uint32.into());
        }
        if self.intersects(VertexAttributeLayout::HasUV2) {
            layout_builder.add_attribute::<u32>(VertexFormat::Uint32.into());
        }
        if self.intersects(VertexAttributeLayout::HasUV3) {
            layout_builder.add_attribute::<u32>(VertexFormat::Uint32.into());
        }
        if self.intersects(VertexAttributeLayout::HasUV4) {
            layout_builder.add_attribute::<u32>(VertexFormat::Uint32.into());
        }
        layout_builder
    }
}

pub enum VertexFormat {
    Uint8x2 = wgpu::VertexFormat::Uint8x2 as _,
    Uint8x4 = wgpu::VertexFormat::Uint8x4 as _,
    Sint8x2 = wgpu::VertexFormat::Sint8x2 as _,
    Sint8x4 = wgpu::VertexFormat::Sint8x4 as _,
    Unorm8x2 = wgpu::VertexFormat::Unorm8x2 as _,
    Unorm8x4 = wgpu::VertexFormat::Unorm8x4 as _,
    Snorm8x2 = wgpu::VertexFormat::Snorm8x2 as _,
    Snorm8x4 = wgpu::VertexFormat::Snorm8x4 as _,
    Uint16x2 = wgpu::VertexFormat::Uint16x2 as _,
    Uint16x4 = wgpu::VertexFormat::Uint16x4 as _,
    Sint16x2 = wgpu::VertexFormat::Sint16x2 as _,
    Sint16x4 = wgpu::VertexFormat::Sint16x4 as _,
    Unorm16x2 = wgpu::VertexFormat::Unorm16x2 as _,
    Unorm16x4 = wgpu::VertexFormat::Unorm16x4 as _,
    Snorm16x2 = wgpu::VertexFormat::Snorm16x2 as _,
    Snorm16x4 = wgpu::VertexFormat::Snorm16x4 as _,
    Float16x2 = wgpu::VertexFormat::Float16x2 as _,
    Float16x4 = wgpu::VertexFormat::Float16x4 as _,
    Float32 = wgpu::VertexFormat::Float32 as _,
    Float32x2 = wgpu::VertexFormat::Float32x2 as _,
    Float32x3 = wgpu::VertexFormat::Float32x3 as _,
    Float32x4 = wgpu::VertexFormat::Float32x4 as _,
    Uint32 = wgpu::VertexFormat::Uint32 as _,
    Uint32x2 = wgpu::VertexFormat::Uint32x2 as _,
    Uint32x3 = wgpu::VertexFormat::Uint32x3 as _,
    Uint32x4 = wgpu::VertexFormat::Uint32x4 as _,
    Sint32 = wgpu::VertexFormat::Sint32 as _,
    Sint32x2 = wgpu::VertexFormat::Sint32x2 as _,
    Sint32x3 = wgpu::VertexFormat::Sint32x3 as _,
    Sint32x4 = wgpu::VertexFormat::Sint32x4 as _,
    Float64 = wgpu::VertexFormat::Float64 as _,
    Float64x2 = wgpu::VertexFormat::Float64x2 as _,
    Float64x3 = wgpu::VertexFormat::Float64x3 as _,
    Float64x4 = wgpu::VertexFormat::Float64x4 as _,
    Unorm10_10_10_2 = wgpu::VertexFormat::Unorm10_10_10_2 as _,
    Uint8 = wgpu::VertexFormat::Uint8 as _,
    Sint8 = wgpu::VertexFormat::Sint8 as _,
    Unorm8 = wgpu::VertexFormat::Unorm8 as _,
    Snorm8 = wgpu::VertexFormat::Snorm8 as _,
    Uint16 = wgpu::VertexFormat::Uint16 as _,
    Sint16 = wgpu::VertexFormat::Sint16 as _,
    Unorm16 = wgpu::VertexFormat::Unorm16 as _,
    Snorm16 = wgpu::VertexFormat::Snorm16 as _,
    Float16 = wgpu::VertexFormat::Float16 as _,
    Unorm8x4Bgra = wgpu::VertexFormat::Unorm8x4Bgra as _,
}

impl From<VertexFormat> for wgpu::VertexFormat {
    fn from(format: VertexFormat) -> wgpu::VertexFormat {
        match format {
            VertexFormat::Uint8 => wgpu::VertexFormat::Uint8,
            VertexFormat::Sint8 => wgpu::VertexFormat::Sint8,
            VertexFormat::Unorm8 => wgpu::VertexFormat::Unorm8,
            VertexFormat::Snorm8 => wgpu::VertexFormat::Snorm8,
            VertexFormat::Uint8x2 => wgpu::VertexFormat::Uint8x2,
            VertexFormat::Uint8x4 => wgpu::VertexFormat::Uint8x4,
            VertexFormat::Sint8x2 => wgpu::VertexFormat::Sint8x2,
            VertexFormat::Sint8x4 => wgpu::VertexFormat::Sint8x4,
            VertexFormat::Unorm8x2 => wgpu::VertexFormat::Unorm8x2,
            VertexFormat::Unorm8x4 => wgpu::VertexFormat::Unorm8x4,
            VertexFormat::Snorm8x2 => wgpu::VertexFormat::Snorm8x2,
            VertexFormat::Snorm8x4 => wgpu::VertexFormat::Snorm8x4,
            VertexFormat::Uint16 => wgpu::VertexFormat::Uint16,
            VertexFormat::Sint16 => wgpu::VertexFormat::Sint16,
            VertexFormat::Unorm16 => wgpu::VertexFormat::Unorm16,
            VertexFormat::Snorm16 => wgpu::VertexFormat::Snorm16,
            VertexFormat::Uint16x2 => wgpu::VertexFormat::Uint16x2,
            VertexFormat::Uint16x4 => wgpu::VertexFormat::Uint16x4,
            VertexFormat::Sint16x2 => wgpu::VertexFormat::Sint16x2,
            VertexFormat::Sint16x4 => wgpu::VertexFormat::Sint16x4,
            VertexFormat::Unorm16x2 => wgpu::VertexFormat::Unorm16x2,
            VertexFormat::Unorm16x4 => wgpu::VertexFormat::Unorm16x4,
            VertexFormat::Snorm16x2 => wgpu::VertexFormat::Snorm16x2,
            VertexFormat::Snorm16x4 => wgpu::VertexFormat::Snorm16x4,
            VertexFormat::Float16 => wgpu::VertexFormat::Float16,
            VertexFormat::Float16x2 => wgpu::VertexFormat::Float16x2,
            VertexFormat::Float16x4 => wgpu::VertexFormat::Float16x4,
            VertexFormat::Float32 => wgpu::VertexFormat::Float32,
            VertexFormat::Float32x2 => wgpu::VertexFormat::Float32x2,
            VertexFormat::Float32x3 => wgpu::VertexFormat::Float32x3,
            VertexFormat::Float32x4 => wgpu::VertexFormat::Float32x4,
            VertexFormat::Uint32 => wgpu::VertexFormat::Uint32,
            VertexFormat::Uint32x2 => wgpu::VertexFormat::Uint32x2,
            VertexFormat::Uint32x3 => wgpu::VertexFormat::Uint32x3,
            VertexFormat::Uint32x4 => wgpu::VertexFormat::Uint32x4,
            VertexFormat::Sint32 => wgpu::VertexFormat::Sint32,
            VertexFormat::Sint32x2 => wgpu::VertexFormat::Sint32x2,
            VertexFormat::Sint32x3 => wgpu::VertexFormat::Sint32x3,
            VertexFormat::Sint32x4 => wgpu::VertexFormat::Sint32x4,
            VertexFormat::Float64 => wgpu::VertexFormat::Float64,
            VertexFormat::Float64x2 => wgpu::VertexFormat::Float64x2,
            VertexFormat::Float64x3 => wgpu::VertexFormat::Float64x3,
            VertexFormat::Float64x4 => wgpu::VertexFormat::Float64x4,
            VertexFormat::Unorm10_10_10_2 => wgpu::VertexFormat::Unorm10_10_10_2,
            VertexFormat::Unorm8x4Bgra => wgpu::VertexFormat::Unorm8x4Bgra,
        }
    }
}

impl From<wgpu::VertexFormat> for VertexFormat {
    fn from(format: wgpu::VertexFormat) -> Self {
        match format {
            wgpu::VertexFormat::Uint8 => VertexFormat::Uint8,
            wgpu::VertexFormat::Sint8 => VertexFormat::Sint8,
            wgpu::VertexFormat::Unorm8 => VertexFormat::Unorm8,
            wgpu::VertexFormat::Snorm8 => VertexFormat::Snorm8,
            wgpu::VertexFormat::Uint8x2 => VertexFormat::Uint8x2,
            wgpu::VertexFormat::Uint8x4 => VertexFormat::Uint8x4,
            wgpu::VertexFormat::Sint8x2 => VertexFormat::Sint8x2,
            wgpu::VertexFormat::Sint8x4 => VertexFormat::Sint8x4,
            wgpu::VertexFormat::Unorm8x2 => VertexFormat::Unorm8x2,
            wgpu::VertexFormat::Unorm8x4 => VertexFormat::Unorm8x4,
            wgpu::VertexFormat::Snorm8x2 => VertexFormat::Snorm8x2,
            wgpu::VertexFormat::Snorm8x4 => VertexFormat::Snorm8x4,
            wgpu::VertexFormat::Uint16 => VertexFormat::Uint16,
            wgpu::VertexFormat::Sint16 => VertexFormat::Sint16,
            wgpu::VertexFormat::Unorm16 => VertexFormat::Unorm16,
            wgpu::VertexFormat::Snorm16 => VertexFormat::Snorm16,
            wgpu::VertexFormat::Uint16x2 => VertexFormat::Uint16x2,
            wgpu::VertexFormat::Uint16x4 => VertexFormat::Uint16x4,
            wgpu::VertexFormat::Sint16x2 => VertexFormat::Sint16x2,
            wgpu::VertexFormat::Sint16x4 => VertexFormat::Sint16x4,
            wgpu::VertexFormat::Unorm16x2 => VertexFormat::Unorm16x2,
            wgpu::VertexFormat::Unorm16x4 => VertexFormat::Unorm16x4,
            wgpu::VertexFormat::Snorm16x2 => VertexFormat::Snorm16x2,
            wgpu::VertexFormat::Snorm16x4 => VertexFormat::Snorm16x4,
            wgpu::VertexFormat::Float16 => VertexFormat::Float16,
            wgpu::VertexFormat::Float16x2 => VertexFormat::Float16x2,
            wgpu::VertexFormat::Float16x4 => VertexFormat::Float16x4,
            wgpu::VertexFormat::Float32 => VertexFormat::Float32,
            wgpu::VertexFormat::Float32x2 => VertexFormat::Float32x2,
            wgpu::VertexFormat::Float32x3 => VertexFormat::Float32x3,
            wgpu::VertexFormat::Float32x4 => VertexFormat::Float32x4,
            wgpu::VertexFormat::Uint32 => VertexFormat::Uint32,
            wgpu::VertexFormat::Uint32x2 => VertexFormat::Uint32x2,
            wgpu::VertexFormat::Uint32x3 => VertexFormat::Uint32x3,
            wgpu::VertexFormat::Uint32x4 => VertexFormat::Uint32x4,
            wgpu::VertexFormat::Sint32 => VertexFormat::Sint32,
            wgpu::VertexFormat::Sint32x2 => VertexFormat::Sint32x2,
            wgpu::VertexFormat::Sint32x3 => VertexFormat::Sint32x3,
            wgpu::VertexFormat::Sint32x4 => VertexFormat::Sint32x4,
            wgpu::VertexFormat::Float64 => VertexFormat::Float64,
            wgpu::VertexFormat::Float64x2 => VertexFormat::Float64x2,
            wgpu::VertexFormat::Float64x3 => VertexFormat::Float64x3,
            wgpu::VertexFormat::Float64x4 => VertexFormat::Float64x4,
            wgpu::VertexFormat::Unorm10_10_10_2 => VertexFormat::Unorm10_10_10_2,
            wgpu::VertexFormat::Unorm8x4Bgra => VertexFormat::Unorm8x4Bgra,
        }
    }
}

pub struct VertexBufferLayoutBuilder<'a> {
    layout: wgpu::VertexBufferLayout<'a>,
    attributes: Vec<wgpu::VertexAttribute>,
    offset: wgpu::BufferAddress,
    location: u32,
}

impl<'a> VertexBufferLayoutBuilder<'a> {
    pub fn vertex() -> Self {
        Self {
            attributes: vec![],
            layout: wgpu::VertexBufferLayout {
                attributes: &[],
                array_stride: 0,
                step_mode: wgpu::VertexStepMode::Vertex,
            },
            offset: 0,
            location: 0,
        }
    }
    pub fn instance() -> Self {
        Self {
            attributes: vec![],
            layout: wgpu::VertexBufferLayout {
                attributes: &[],
                array_stride: 0,
                step_mode: wgpu::VertexStepMode::Instance,
            },
            offset: 0,
            location: 0,
        }
    }
    pub fn add_attribute<T>(&mut self, format: wgpu::VertexFormat) {
        self.attributes.push(wgpu::VertexAttribute {
            offset: self.offset,
            shader_location: self.location,
            format,
        });
        self.offset += std::mem::size_of::<T>() as wgpu::BufferAddress;
        self.location += 1;
    }

    pub fn starting_location(&mut self, location: u32) {
        self.location = location;
    }

    pub fn location(&self) -> u32 {
        self.location
    }

    pub fn build(&'a self) -> wgpu::VertexBufferLayout<'a> {
        let mut layout = self.layout.clone();
        layout.array_stride = self.offset;
        layout.attributes = &self.attributes;
        layout
    }
}
