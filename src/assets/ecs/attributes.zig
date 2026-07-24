//! Contains or handles the less dynamic entity data.
//! Things that dont interact with the physics system

//External Imports
const std = @import("std");

//Internal Imports
const Types = @import("config").ECS;

// Unpack / Alias imported types
const AssetID = Types.AssetID;
const Self = @This();
// Data related to rendering
pub const ObjectTags = struct {
    mesh: u32,
    material: u32,
    id: u32,
};

// Static pre runtime time data
pub const AssetTags = struct {
    id: AssetID,
};

objectTags: std.ArrayList(ObjectTags) = .empty,
assetTags: std.ArrayList(AssetTags) = .empty,

pub fn deinit(self: *Self, allocator: std.mem.Allocator) void {
    self.objectTags.deinit(allocator);
    self.assetTags.deinit(allocator);
}
