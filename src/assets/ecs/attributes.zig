//! Contains or handles the less dynamic entity data.
//! Things that dont interact with the physics system

//External Imports
const std = @import("std");

//Internal Imports
const Types = @import("config").ECS;

// Unpack / Alias imported types
const AssetID = Types.AssetID;

// Rendering Object data
const ObjectTags = struct {
    mesh: u32,
    material: u32,
    id: u32, //Index within Rendering Objects array. 0 = not in Rendering Objects
};

const AssetTags = struct {
    id: AssetID, // Static pre runtime time data
};

var objectTags = std.ArrayList(ObjectTags).empty;
var assetTags = std.ArrayList(AssetTags).empty;

pub fn init(allocator: std.mem.Allocator, capacity: usize) !void {
    try objectTags.ensureTotalCapacity(allocator, capacity);
    try assetTags.ensureTotalCapacity(allocator, capacity);
}

pub fn deinit(allocator: std.mem.Allocator) void {
    objectTags.deinit(allocator);
    assetTags.deinit(allocator);
}
