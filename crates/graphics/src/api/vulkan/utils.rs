#![allow(dead_code)]

use super::data_formats::VkImageBarrierData;
use super::physical_device::BackendPhysicalDevice;
use super::{types::*, BackendDevice};
use crate::Area;
use sabi_platform::Handle;
use std::ffi::{c_void, CStr, CString};
use std::mem::MaybeUninit;
use std::os::raw::c_char;
use vulkan_bindings::*;

pub fn get_minimum_required_vulkan_layers(enable_validation: bool) -> Vec<CString> {
    let mut result = Vec::new();
    if enable_validation {
        result.push(
            CStr::from_bytes_with_nul(b"VK_LAYER_KHRONOS_validation\0")
                .unwrap()
                .to_owned(),
        );
    }
    result
}

pub fn get_minimum_required_vulkan_extensions() -> Vec<CString> {
    vec![unsafe { CStr::from_ptr(VK_KHR_SWAPCHAIN_EXTENSION_NAME.as_ptr() as *const _) }.to_owned()]
}

pub fn get_available_layers_count() -> u32 {
    unsafe {
        let mut option = ::std::mem::MaybeUninit::uninit();
        assert_eq!(
            VkResult_VK_SUCCESS,
            vkEnumerateInstanceLayerProperties.unwrap()(
                option.as_mut_ptr(),
                ::std::ptr::null_mut()
            )
        );
        option.assume_init()
    }
}

pub fn enumerate_available_layers() -> Vec<VkLayerProperties> {
    let mut layers_count = get_available_layers_count();
    unsafe {
        let mut option: Vec<MaybeUninit<VkLayerProperties>> =
            Vec::with_capacity(layers_count as usize);
        option.set_len(layers_count as usize);
        assert_eq!(
            VkResult_VK_SUCCESS,
            vkEnumerateInstanceLayerProperties.unwrap()(
                &mut layers_count,
                option.as_mut_ptr() as _
            )
        );
        option.into_iter().map(|e| e.assume_init()).collect()
    }
}

pub fn get_available_layers_names(
    supported_layers: &[VkLayerProperties],
) -> Vec<::std::ffi::CString> {
    supported_layers
        .iter()
        .map(|layer| unsafe { ::std::ffi::CStr::from_ptr(layer.layerName.as_ptr()) }.to_owned())
        .collect::<Vec<::std::ffi::CString>>()
}

pub fn get_available_extensions_count() -> u32 {
    unsafe {
        let mut option = ::std::mem::MaybeUninit::uninit();
        assert_eq!(
            VkResult_VK_SUCCESS,
            vkEnumerateInstanceExtensionProperties.unwrap()(
                ::std::ptr::null_mut(),
                option.as_mut_ptr(),
                ::std::ptr::null_mut()
            )
        );
        option.assume_init()
    }
}

pub fn enumerate_available_extensions() -> Vec<VkExtensionProperties> {
    let mut extensions_count = get_available_extensions_count();
    unsafe {
        let mut option: Vec<MaybeUninit<VkExtensionProperties>> =
            Vec::with_capacity(extensions_count as usize);
        option.set_len(extensions_count as usize);

        assert_eq!(
            VkResult_VK_SUCCESS,
            vkEnumerateInstanceExtensionProperties.unwrap()(
                ::std::ptr::null_mut(),
                &mut extensions_count,
                option.as_mut_ptr() as _
            )
        );
        option.into_iter().map(|e| e.assume_init()).collect()
    }
}

pub fn get_available_extensions_names(
    supported_extensions: &[VkExtensionProperties],
) -> Vec<::std::ffi::CString> {
    supported_extensions
        .iter()
        .map(|ext| unsafe { ::std::ffi::CStr::from_ptr(ext.extensionName.as_ptr()) }.to_owned())
        .collect::<Vec<::std::ffi::CString>>()
}

pub fn get_physical_devices_count(instance: VkInstance) -> u32 {
    unsafe {
        let mut option = ::std::mem::MaybeUninit::uninit();
        assert_eq!(
            VkResult_VK_SUCCESS,
            vkEnumeratePhysicalDevices.unwrap()(
                instance,
                option.as_mut_ptr(),
                ::std::ptr::null_mut()
            )
        );
        option.assume_init()
    }
}

pub fn enumerate_physical_devices(instance: VkInstance) -> Vec<VkPhysicalDevice> {
    let mut physical_device_count = get_physical_devices_count(instance);
    let physical_devices: Vec<VkPhysicalDevice> = unsafe {
        let mut option: Vec<MaybeUninit<VkPhysicalDevice>> =
            Vec::with_capacity(physical_device_count as usize);
        option.set_len(physical_device_count as usize);
        assert_eq!(
            VkResult_VK_SUCCESS,
            vkEnumeratePhysicalDevices.unwrap()(
                instance,
                &mut physical_device_count,
                option.as_mut_ptr() as _
            )
        );
        option.into_iter().map(|e| e.assume_init()).collect()
    };
    physical_devices
}

pub fn find_plane_for_display(
    device: &VkPhysicalDevice,
    display: &VkDisplayKHR,
    plane_properties: &[VkDisplayPlanePropertiesKHR],
) -> i32 {
    for (index, plane) in plane_properties.iter().enumerate() {
        if (!plane.currentDisplay.is_null()) && (plane.currentDisplay != *display) {
            continue;
        }

        let mut supported_count: u32 = unsafe {
            let mut output = ::std::mem::MaybeUninit::uninit();
            vkGetDisplayPlaneSupportedDisplaysKHR.unwrap()(
                *device,
                index as u32,
                output.as_mut_ptr(),
                ::std::ptr::null_mut(),
            );
            output.assume_init()
        };

        if supported_count == 0 {
            continue;
        }

        let supported_displays: Vec<VkDisplayKHR> = unsafe {
            let mut option: Vec<MaybeUninit<VkDisplayKHR>> =
                Vec::with_capacity(supported_count as usize);
            option.set_len(supported_count as usize);
            vkGetDisplayPlaneSupportedDisplaysKHR.unwrap()(
                *device,
                index as u32,
                &mut supported_count,
                option.as_mut_ptr() as _,
            );
            option.into_iter().map(|e| e.assume_init()).collect()
        };

        let found = supported_displays.iter().any(|item| item == display);

        if found {
            return index as i32;
        }
    }
    -1
}

pub fn get_supported_alpha_mode(
    display_plane_capabilities: &VkDisplayPlaneCapabilitiesKHR,
) -> VkCompositeAlphaFlagBitsKHR {
    let alpha_mode_types: [u32; 4] = [
        VkDisplayPlaneAlphaFlagBitsKHR_VK_DISPLAY_PLANE_ALPHA_OPAQUE_BIT_KHR as u32,
        VkDisplayPlaneAlphaFlagBitsKHR_VK_DISPLAY_PLANE_ALPHA_GLOBAL_BIT_KHR as u32,
        VkDisplayPlaneAlphaFlagBitsKHR_VK_DISPLAY_PLANE_ALPHA_PER_PIXEL_BIT_KHR as u32,
        VkDisplayPlaneAlphaFlagBitsKHR_VK_DISPLAY_PLANE_ALPHA_PER_PIXEL_PREMULTIPLIED_BIT_KHR
            as u32,
    ];

    for item in alpha_mode_types.iter() {
        if (display_plane_capabilities.supportedAlpha & *item) == 1 {
            return *item as VkCompositeAlphaFlagBitsKHR;
        }
    }
    VkDisplayPlaneAlphaFlagBitsKHR_VK_DISPLAY_PLANE_ALPHA_OPAQUE_BIT_KHR
}

pub fn find_available_memory_type(
    physical_device: VkPhysicalDevice,
    filter: u32,
    properties: VkMemoryPropertyFlags,
) -> u32 {
    let mem_properties = unsafe {
        let mut option = ::std::mem::MaybeUninit::uninit();
        vkGetPhysicalDeviceMemoryProperties.unwrap()(physical_device, option.as_mut_ptr());
        option.assume_init()
    };
    for i in 0..mem_properties.memoryTypeCount {
        let is_correct_type = (filter & (1 << i)) != 0;
        let mem_type = mem_properties.memoryTypes[i as usize];
        let has_needed_properties = (mem_type.propertyFlags & properties) == properties;
        if is_correct_type && has_needed_properties {
            return i;
        }
    }
    eprintln!(
        "Unable to find suitable memory type with filter {} and flags {}",
        filter, properties,
    );
    VK_INVALID_ID as _
}

pub fn create_image_view(
    device: VkDevice,
    image: VkImage,
    format: VkFormat,
    aspect_flags: VkImageAspectFlags,
    layers_count: u32,
) -> VkImageView {
    let view_info = VkImageViewCreateInfo {
        sType: VkStructureType_VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO,
        pNext: ::std::ptr::null_mut(),
        flags: 0,
        image,
        viewType: VkImageViewType_VK_IMAGE_VIEW_TYPE_2D_ARRAY,
        format,
        components: VkComponentMapping {
            r: VkComponentSwizzle_VK_COMPONENT_SWIZZLE_R,
            g: VkComponentSwizzle_VK_COMPONENT_SWIZZLE_G,
            b: VkComponentSwizzle_VK_COMPONENT_SWIZZLE_B,
            a: VkComponentSwizzle_VK_COMPONENT_SWIZZLE_A,
        },
        subresourceRange: VkImageSubresourceRange {
            aspectMask: aspect_flags,
            baseMipLevel: 0,
            levelCount: 1,
            baseArrayLayer: 0,
            layerCount: layers_count as _,
        },
    };

    unsafe {
        let mut option = ::std::mem::MaybeUninit::uninit();
        assert_eq!(
            VkResult_VK_SUCCESS,
            vkCreateImageView.unwrap()(
                device,
                &view_info,
                ::std::ptr::null_mut(),
                option.as_mut_ptr()
            )
        );
        option.assume_init()
    }
}

pub fn find_supported_format(
    physical_device: VkPhysicalDevice,
    formats_candidates: &[VkFormat],
    tiling: VkImageTiling,
    features: VkFormatFeatureFlags,
) -> VkFormat {
    for format in formats_candidates.iter() {
        let props: VkFormatProperties = unsafe {
            let mut option = ::std::mem::MaybeUninit::uninit();
            vkGetPhysicalDeviceFormatProperties.unwrap()(
                physical_device,
                *format,
                option.as_mut_ptr(),
            );
            option.assume_init()
        };
        if (tiling == VkImageTiling_VK_IMAGE_TILING_LINEAR
            && (props.linearTilingFeatures & features) == features)
            || (tiling == VkImageTiling_VK_IMAGE_TILING_OPTIMAL
                && (props.optimalTilingFeatures & features) == features)
        {
            return *format;
        }
    }
    panic!("Failed to find any supported format between available candidates");
}

pub fn find_depth_format(physical_device: VkPhysicalDevice) -> VkFormat {
    let format_candidates = [
        VkFormat_VK_FORMAT_D32_SFLOAT,
        VkFormat_VK_FORMAT_D32_SFLOAT_S8_UINT,
        VkFormat_VK_FORMAT_D24_UNORM_S8_UINT,
    ];
    find_supported_format(
        physical_device,
        &format_candidates,
        VkImageTiling_VK_IMAGE_TILING_OPTIMAL,
        VkFormatFeatureFlagBits_VK_FORMAT_FEATURE_DEPTH_STENCIL_ATTACHMENT_BIT as _,
    )
}

pub fn has_stencil_component(format: VkFormat) -> bool {
    format == VkFormat_VK_FORMAT_D32_SFLOAT_S8_UINT
        || format == VkFormat_VK_FORMAT_D24_UNORM_S8_UINT
}

pub fn create_buffer(
    device: &BackendDevice,
    physical_device: &BackendPhysicalDevice,
    buffer_size: VkDeviceSize,
    usage: VkBufferUsageFlags,
    properties: VkMemoryPropertyFlags,
    buffer: &mut VkBuffer,
    buffer_memory: &mut VkDeviceMemory,
) -> (u64, u64) {
    sabi_profiler::scoped_profile!("Vulkan create_buffer");

    let buffer_info = VkBufferCreateInfo {
        sType: VkStructureType_VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO,
        pNext: ::std::ptr::null_mut(),
        flags: 0,
        size: buffer_size as _,
        usage: usage as _,
        sharingMode: VkSharingMode_VK_SHARING_MODE_EXCLUSIVE,
        queueFamilyIndexCount: 0,
        pQueueFamilyIndices: ::std::ptr::null_mut(),
    };
    unsafe {
        assert_eq!(
            VkResult_VK_SUCCESS,
            vkCreateBuffer.unwrap()(**device, &buffer_info, ::std::ptr::null_mut(), buffer)
        );
    }

    let mem_requirement = unsafe {
        let mut option = ::std::mem::MaybeUninit::uninit();
        vkGetBufferMemoryRequirements.unwrap()(**device, *buffer, option.as_mut_ptr());
        option.assume_init()
    };

    let mem_alloc_info = VkMemoryAllocateInfo {
        sType: VkStructureType_VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO,
        pNext: ::std::ptr::null_mut(),
        allocationSize: mem_requirement.size,
        memoryTypeIndex: find_available_memory_type(
            **physical_device,
            mem_requirement.memoryTypeBits,
            properties as _,
        ),
    };

    unsafe {
        assert_eq!(
            VkResult_VK_SUCCESS,
            vkAllocateMemory.unwrap()(
                **device,
                &mem_alloc_info,
                ::std::ptr::null_mut(),
                buffer_memory
            )
        );

        vkBindBufferMemory.unwrap()(**device, *buffer, *buffer_memory, 0);
    }

    (mem_requirement.size, mem_requirement.alignment)
}

pub fn destroy_buffer(device: &BackendDevice, buffer: &VkBuffer, buffer_memory: &VkDeviceMemory) {
    sabi_profiler::scoped_profile!("Vulkan destroy_buffer");

    unsafe {
        vkDestroyBuffer.unwrap()(**device, *buffer, ::std::ptr::null_mut());
        vkFreeMemory.unwrap()(**device, *buffer_memory, ::std::ptr::null_mut());
    }
}

pub fn copy_buffer(
    device: &mut BackendDevice,
    buffer_src: &VkBuffer,
    buffer_dst: &mut VkBuffer,
    buffer_size: VkDeviceSize,
) {
    sabi_profiler::scoped_profile!("Vulkan copy_buffer");

    let command_buffer = begin_single_time_commands(device);

    unsafe {
        let copy_region = VkBufferCopy {
            srcOffset: 0,
            dstOffset: 0,
            size: buffer_size,
        };

        vkCmdCopyBuffer.unwrap()(command_buffer, *buffer_src, *buffer_dst, 1, &copy_region);
    }
    end_single_time_commands(device, command_buffer, device.get_transfers_queue());
}

pub fn map_buffer_memory<T>(
    device: &BackendDevice,
    buffer_memory: &mut VkDeviceMemory,
    starting_index: usize,
    data_src: &[T],
) -> (*mut c_void, usize) {
    sabi_profiler::scoped_profile!("Vulkan map_buffer_memory");

    let element_size = ::std::mem::size_of::<T>();
    let offset = starting_index * element_size;
    let length = data_src.len() * element_size;

    let data_ptr = unsafe {
        let mut option = ::std::mem::MaybeUninit::uninit();
        assert_eq!(
            VkResult_VK_SUCCESS,
            vkMapMemory.unwrap()(
                **device,
                *buffer_memory,
                offset as _,
                length as _,
                0,
                option.as_mut_ptr()
            )
        );
        option.assume_init()
    };
    (data_ptr, length)
}
pub fn copy_from_buffer<T>(
    device: &BackendDevice,
    buffer_memory: &mut VkDeviceMemory,
    starting_index: usize,
    data_src: &[T],
) {
    sabi_profiler::scoped_profile!("Vulkan copy_from_buffer");

    let (data_ptr, length) = map_buffer_memory(device, buffer_memory, starting_index, data_src);
    unsafe {
        ::std::ptr::copy_nonoverlapping(data_src.as_ptr() as _, data_ptr, length as _);
    }
    unmap_buffer_memory(device, buffer_memory);
}
pub fn copy_to_buffer<T>(
    device: &BackendDevice,
    buffer_memory: &mut VkDeviceMemory,
    starting_index: usize,
    data_dst: &mut [T],
) {
    sabi_profiler::scoped_profile!("Vulkan copy_to_buffer");

    let (data_ptr, length) = map_buffer_memory(device, buffer_memory, starting_index, data_dst);
    unsafe {
        ::std::ptr::copy_nonoverlapping(data_ptr, data_dst.as_mut_ptr() as _, length as _);
    }
    unmap_buffer_memory(device, buffer_memory);
}
pub fn unmap_buffer_memory(device: &BackendDevice, buffer_memory: &mut VkDeviceMemory) {
    sabi_profiler::scoped_profile!("Vulkan unmap_buffer_memory");
    unsafe {
        vkUnmapMemory.unwrap()(**device, *buffer_memory);
    }
}

pub fn create_image(
    device: &BackendDevice,
    physical_device: &BackendPhysicalDevice,
    image_properties: (u32, u32, VkFormat),
    tiling: VkImageTiling,
    usage: VkImageUsageFlags,
    properties: VkMemoryPropertyFlags,
    layers_count: u32,
) -> (VkImage, VkDeviceMemory) {
    let mut image: VkImage = ::std::ptr::null_mut();
    let mut image_memory: VkDeviceMemory = ::std::ptr::null_mut();

    let image_info = VkImageCreateInfo {
        sType: VkStructureType_VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO,
        pNext: ::std::ptr::null_mut(),
        flags: 0,
        imageType: VkImageType_VK_IMAGE_TYPE_2D,
        format: image_properties.2,
        extent: VkExtent3D {
            width: image_properties.0,
            height: image_properties.1,
            depth: 1,
        },
        mipLevels: 1,
        arrayLayers: layers_count as _,
        samples: VkSampleCountFlagBits_VK_SAMPLE_COUNT_1_BIT,
        tiling: tiling as _,
        usage: usage as _,
        sharingMode: VkSharingMode_VK_SHARING_MODE_EXCLUSIVE,
        queueFamilyIndexCount: 0,
        pQueueFamilyIndices: ::std::ptr::null_mut(),
        initialLayout: VkImageLayout_VK_IMAGE_LAYOUT_UNDEFINED,
    };

    unsafe {
        assert_eq!(
            VkResult_VK_SUCCESS,
            vkCreateImage.unwrap()(**device, &image_info, ::std::ptr::null_mut(), &mut image)
        );
    }

    let mem_requirement = unsafe {
        let mut option = ::std::mem::MaybeUninit::uninit();
        vkGetImageMemoryRequirements.unwrap()(**device, image, option.as_mut_ptr());
        option.assume_init()
    };

    let mem_alloc_info = VkMemoryAllocateInfo {
        sType: VkStructureType_VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO,
        pNext: ::std::ptr::null_mut(),
        allocationSize: mem_requirement.size,
        memoryTypeIndex: find_available_memory_type(
            **physical_device,
            mem_requirement.memoryTypeBits,
            properties as _,
        ),
    };

    unsafe {
        assert_eq!(
            VkResult_VK_SUCCESS,
            vkAllocateMemory.unwrap()(
                **device,
                &mem_alloc_info,
                ::std::ptr::null_mut(),
                &mut image_memory
            )
        );

        vkBindImageMemory.unwrap()(**device, image, image_memory, 0);
    }

    (image, image_memory)
}

pub fn image_memory_barrier(
    command_buffer: VkCommandBuffer,
    image_barrier_data: VkImageBarrierData,
) {
    let barrier = VkImageMemoryBarrier {
        sType: VkStructureType_VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER,
        pNext: ::std::ptr::null_mut(),
        srcAccessMask: image_barrier_data.src_access_mask,
        dstAccessMask: image_barrier_data.dst_access_mask,
        oldLayout: image_barrier_data.old_layout,
        newLayout: image_barrier_data.new_layout,
        srcQueueFamilyIndex: VK_QUEUE_FAMILY_IGNORED as _,
        dstQueueFamilyIndex: VK_QUEUE_FAMILY_IGNORED as _,
        image: image_barrier_data.image,
        subresourceRange: VkImageSubresourceRange {
            aspectMask: if image_barrier_data.new_layout
                == VkImageLayout_VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL
            {
                VkImageAspectFlagBits_VK_IMAGE_ASPECT_DEPTH_BIT as _
            } else {
                VkImageAspectFlagBits_VK_IMAGE_ASPECT_COLOR_BIT as _
            },
            baseMipLevel: 0,
            levelCount: 1,
            baseArrayLayer: image_barrier_data.layer_index,
            layerCount: image_barrier_data.layers_count,
        },
    };

    unsafe {
        vkCmdPipelineBarrier.unwrap()(
            command_buffer,
            image_barrier_data.src_stage_mask,
            image_barrier_data.dst_stage_mask,
            0,
            0,
            ::std::ptr::null_mut(),
            0,
            ::std::ptr::null_mut(),
            1,
            &barrier,
        );
    }
}

pub fn copy_image_to_buffer(
    device: &BackendDevice,
    image: VkImage,
    buffer: VkBuffer,
    layer_index: u32,
    layers_count: u32,
    area: &Area,
) {
    sabi_profiler::scoped_profile!("Vulkan copy_image_to_buffer");

    let region = VkBufferImageCopy {
        bufferOffset: 0,
        bufferRowLength: area.width as _,
        bufferImageHeight: area.height as _,
        imageSubresource: VkImageSubresourceLayers {
            aspectMask: VkImageAspectFlagBits_VK_IMAGE_ASPECT_COLOR_BIT as _,
            mipLevel: 0,
            baseArrayLayer: layer_index as _,
            layerCount: 1,
        },
        imageOffset: VkOffset3D {
            x: area.x as _,
            y: area.y as _,
            z: 0,
        },
        imageExtent: VkExtent3D {
            width: area.width,
            height: area.height,
            depth: 1,
        },
    };

    let command_buffer = begin_single_time_commands(device);
    image_memory_barrier(
        command_buffer,
        VkImageBarrierData {
            image,
            old_layout: VkImageLayout_VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
            new_layout: VkImageLayout_VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,
            src_access_mask: VkAccessFlagBits_VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT as _,
            dst_access_mask: VkAccessFlagBits_VK_ACCESS_TRANSFER_READ_BIT as _,
            src_stage_mask: VkPipelineStageFlagBits_VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT
                as _,
            dst_stage_mask: VkPipelineStageFlagBits_VK_PIPELINE_STAGE_TRANSFER_BIT as _,
            layer_index,
            layers_count,
        },
    );

    unsafe {
        vkCmdCopyImageToBuffer.unwrap()(
            command_buffer,
            image,
            VkImageLayout_VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,
            buffer,
            1,
            &region,
        );
    }

    image_memory_barrier(
        command_buffer,
        VkImageBarrierData {
            image,
            old_layout: VkImageLayout_VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,
            new_layout: VkImageLayout_VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
            src_access_mask: VkAccessFlagBits_VK_ACCESS_TRANSFER_READ_BIT as _,
            dst_access_mask: VkAccessFlagBits_VK_ACCESS_SHADER_READ_BIT as _,
            src_stage_mask: VkPipelineStageFlagBits_VK_PIPELINE_STAGE_TRANSFER_BIT as _,
            dst_stage_mask: VkPipelineStageFlagBits_VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT as _,
            layer_index,
            layers_count,
        },
    );
    end_single_time_commands(device, command_buffer, device.get_transfers_queue());
}

pub fn copy_buffer_to_image(
    device: &BackendDevice,
    buffer: VkBuffer,
    image: VkImage,
    layer_index: u32,
    layers_count: u32,
    area: &Area,
) {
    let region = VkBufferImageCopy {
        bufferOffset: 0,
        bufferRowLength: 0,
        bufferImageHeight: 0,
        imageSubresource: VkImageSubresourceLayers {
            aspectMask: VkImageAspectFlagBits_VK_IMAGE_ASPECT_COLOR_BIT as _,
            mipLevel: 0,
            baseArrayLayer: layer_index as _,
            layerCount: 1,
        },
        imageOffset: VkOffset3D {
            x: area.x as _,
            y: area.y as _,
            z: 0,
        },
        imageExtent: VkExtent3D {
            width: area.width,
            height: area.height,
            depth: 1,
        },
    };

    let command_buffer = begin_single_time_commands(device);
    image_memory_barrier(
        command_buffer,
        VkImageBarrierData {
            image,
            old_layout: VkImageLayout_VK_IMAGE_LAYOUT_UNDEFINED,
            new_layout: VkImageLayout_VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
            src_access_mask: 0,
            dst_access_mask: VkAccessFlagBits_VK_ACCESS_TRANSFER_WRITE_BIT as _,
            src_stage_mask: VkPipelineStageFlagBits_VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT as _,
            dst_stage_mask: VkPipelineStageFlagBits_VK_PIPELINE_STAGE_TRANSFER_BIT as _,
            layer_index,
            layers_count,
        },
    );

    unsafe {
        vkCmdCopyBufferToImage.unwrap()(
            command_buffer,
            buffer,
            image,
            VkImageLayout_VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
            1,
            &region,
        );
    }

    image_memory_barrier(
        command_buffer,
        VkImageBarrierData {
            image,
            old_layout: VkImageLayout_VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
            new_layout: VkImageLayout_VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
            src_access_mask: VkAccessFlagBits_VK_ACCESS_TRANSFER_WRITE_BIT as _,
            dst_access_mask: VkAccessFlagBits_VK_ACCESS_SHADER_READ_BIT as _,
            src_stage_mask: VkPipelineStageFlagBits_VK_PIPELINE_STAGE_TRANSFER_BIT as _,
            dst_stage_mask: VkPipelineStageFlagBits_VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT as _,
            layer_index,
            layers_count,
        },
    );
    end_single_time_commands(device, command_buffer, device.get_transfers_queue());
}

pub fn begin_single_time_commands(device: &BackendDevice) -> VkCommandBuffer {
    let command_alloc_info = VkCommandBufferAllocateInfo {
        sType: VkStructureType_VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO,
        pNext: ::std::ptr::null_mut(),
        commandPool: device.get_primary_command_pool(),
        level: VkCommandBufferLevel_VK_COMMAND_BUFFER_LEVEL_PRIMARY,
        commandBufferCount: 1,
    };

    let command_buffer = unsafe {
        let mut option = ::std::mem::MaybeUninit::uninit();
        assert_eq!(
            VkResult_VK_SUCCESS,
            vkAllocateCommandBuffers.unwrap()(**device, &command_alloc_info, option.as_mut_ptr())
        );
        option.assume_init()
    };

    let begin_info = VkCommandBufferBeginInfo {
        sType: VkStructureType_VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO,
        flags: VkCommandBufferUsageFlagBits_VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT as _,
        pNext: ::std::ptr::null_mut(),
        pInheritanceInfo: ::std::ptr::null_mut(),
    };

    unsafe {
        assert_eq!(
            VkResult_VK_SUCCESS,
            vkBeginCommandBuffer.unwrap()(command_buffer, &begin_info)
        );
    }

    command_buffer
}

pub fn end_single_time_commands(
    device: &BackendDevice,
    command_buffer: VkCommandBuffer,
    queue: VkQueue,
) {
    unsafe {
        assert_eq!(
            VkResult_VK_SUCCESS,
            vkEndCommandBuffer.unwrap()(command_buffer)
        );
    }

    immediate_submit(command_buffer, queue);

    unsafe {
        vkFreeCommandBuffers.unwrap()(
            **device,
            device.get_primary_command_pool(),
            1,
            &command_buffer,
        );
    }
}

pub fn immediate_submit(command_buffer: VkCommandBuffer, queue: VkQueue) {
    unsafe {
        let submit_info = VkSubmitInfo {
            sType: VkStructureType_VK_STRUCTURE_TYPE_SUBMIT_INFO,
            pNext: ::std::ptr::null_mut(),
            waitSemaphoreCount: 0,
            pWaitSemaphores: ::std::ptr::null_mut(),
            pWaitDstStageMask: ::std::ptr::null_mut(),
            commandBufferCount: 1,
            pCommandBuffers: &command_buffer,
            signalSemaphoreCount: 0,
            pSignalSemaphores: ::std::ptr::null_mut(),
        };

        let submit_result = vkQueueSubmit.unwrap()(queue, 1, &submit_info, ::std::ptr::null_mut());
        if submit_result != VkResult_VK_SUCCESS {
            eprintln!("Unable to submit queue correctly on GPU");
        }
        vkQueueWaitIdle.unwrap()(queue);
    }
}

pub fn create_instance(
    supported_layers: &[VkLayerProperties],
    supported_extensions: &[VkExtensionProperties],
    enable_validation: bool,
) -> VkInstance {
    let engine_name = "SABI";
    let app_info = VkApplicationInfo {
        sType: VkStructureType_VK_STRUCTURE_TYPE_APPLICATION_INFO,
        pNext: ::std::ptr::null_mut(),
        pApplicationName: ::std::ptr::null_mut(),
        applicationVersion: VK_API_VERSION_1_2,
        pEngineName: engine_name.as_ptr() as _,
        engineVersion: VK_API_VERSION_1_2,
        apiVersion: VK_API_VERSION_1_2,
    };

    let layer_names_str = get_available_layers_names(supported_layers);
    let mut required_layers = get_minimum_required_vulkan_layers(enable_validation);
    for layer in layer_names_str.iter() {
        if let Some(index) = required_layers.iter().position(|l| l == layer) {
            required_layers.remove(index);
        }
    }

    let has_required_layers = required_layers.is_empty();
    debug_assert!(
        has_required_layers,
        "Device has not minimum requirement Vulkan layers"
    );
    required_layers = get_minimum_required_vulkan_layers(enable_validation);
    let layer_names_ptr = required_layers
        .iter()
        .map(|e| e.as_ptr())
        .collect::<Vec<*const c_char>>();

    let extension_names_str = get_available_extensions_names(supported_extensions);
    let extension_names_ptr = extension_names_str
        .iter()
        .map(|e| e.as_ptr() as *const c_char)
        .collect::<Vec<*const c_char>>();

    //Create Instance
    let create_info = VkInstanceCreateInfo {
        sType: VkStructureType_VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
        pNext: ::std::ptr::null_mut(),
        flags: 0,
        pApplicationInfo: &app_info,
        enabledLayerCount: layer_names_ptr.len() as u32,
        ppEnabledLayerNames: layer_names_ptr.as_ptr(),
        enabledExtensionCount: extension_names_ptr.len() as u32,
        ppEnabledExtensionNames: extension_names_ptr.as_ptr(),
    };

    let mut instance: VkInstance = ::std::ptr::null_mut();
    unsafe {
        assert_eq!(
            VkResult_VK_SUCCESS,
            vkCreateInstance.unwrap()(&create_info, ::std::ptr::null_mut(), &mut instance)
        );
    }

    if instance.is_null() {
        eprintln!("Unable to create instance that support Vulkan needed API");
    }
    instance
}

#[allow(unused_assignments)]
pub fn create_surface(instance: VkInstance, handle: &Handle) -> VkSurfaceKHR {
    let mut surface: VkSurfaceKHR = ::std::ptr::null_mut();

    #[cfg(target_os = "android")]
    {
        surface = create_surface_android(instance, handle);
    }
    #[cfg(target_os = "ios")]
    {
        surface = create_surface_ios(instance, handle);
    }
    #[cfg(target_os = "macos")]
    {
        surface = create_surface_macos(instance, handle);
    }
    #[cfg(target_os = "unix")]
    {
        surface = create_surface_unix(instance, handle);
    }
    #[cfg(target_os = "wasm32")]
    {
        surface = create_surface_wasm32(instance, handle);
    }
    #[cfg(target_os = "windows")]
    {
        surface = create_surface_win32(instance, handle);
    }

    if surface.is_null() {
        eprintln!("Unable to create a surface to support Vulkan needed API");
    }
    surface
}

pub fn pick_suitable_physical_device(
    instance: VkInstance,
    surface: VkSurfaceKHR,
) -> ::std::option::Option<BackendPhysicalDevice> {
    for vk_physical_device in enumerate_physical_devices(instance) {
        let physical_device = BackendPhysicalDevice::create(vk_physical_device, surface);

        if physical_device.is_device_suitable() {
            return Some(physical_device);
        }
    }
    None
}

pub fn create_surface_win32(instance: VkInstance, handle: &Handle) -> VkSurfaceKHR {
    let surface_create_info = VkWin32SurfaceCreateInfoKHR {
        sType: VkStructureType_VK_STRUCTURE_TYPE_WIN32_SURFACE_CREATE_INFO_KHR,
        pNext: ::std::ptr::null_mut(),
        flags: 0,
        hinstance: handle.handle_impl.hinstance as *mut vulkan_bindings::HINSTANCE__,
        hwnd: handle.handle_impl.hwnd as *mut vulkan_bindings::HWND__,
    };

    let surface: VkSurfaceKHR = unsafe {
        let mut output = ::std::mem::MaybeUninit::uninit();
        assert_eq!(
            VkResult_VK_SUCCESS,
            vkCreateWin32SurfaceKHR.unwrap()(
                instance,
                &surface_create_info,
                ::std::ptr::null_mut(),
                output.as_mut_ptr()
            )
        );
        output.assume_init()
    };
    surface
}

pub fn create_command_pool(device: VkDevice, queue_family_index: u32) -> VkCommandPool {
    let command_pool_info = VkCommandPoolCreateInfo {
        sType: VkStructureType_VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO,
        pNext: ::std::ptr::null_mut(),
        flags: VkCommandPoolCreateFlagBits_VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT as _,
        queueFamilyIndex: queue_family_index,
    };

    unsafe {
        let mut option = ::std::mem::MaybeUninit::uninit();
        assert_eq!(
            VkResult_VK_SUCCESS,
            vkCreateCommandPool.unwrap()(
                device,
                &command_pool_info,
                ::std::ptr::null_mut(),
                option.as_mut_ptr()
            )
        );
        option.assume_init()
    }
}

pub fn allocate_command_buffers(
    device: VkDevice,
    command_pool: VkCommandPool,
    level: VkCommandBufferLevel,
    num_frames: usize,
) -> Vec<VkCommandBuffer> {
    let command_alloc_info = VkCommandBufferAllocateInfo {
        sType: VkStructureType_VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO,
        pNext: ::std::ptr::null_mut(),
        commandPool: command_pool,
        level,
        commandBufferCount: num_frames as _,
    };

    unsafe {
        let mut option: Vec<MaybeUninit<VkCommandBuffer>> = Vec::with_capacity(num_frames as usize);
        option.set_len(num_frames as usize);
        assert_eq!(
            VkResult_VK_SUCCESS,
            vkAllocateCommandBuffers.unwrap()(
                device,
                &command_alloc_info,
                option.as_mut_ptr() as _
            )
        );
        option.into_iter().map(|e| e.assume_init()).collect()
    }
}