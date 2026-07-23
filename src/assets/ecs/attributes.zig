//! Contains or handles the less dynamic entity data.
//! Things that dont interact with the physics system

const std = @import("std");

// Imports
const Types = @import("ecs_config.zig");

// Unpacking / aliasing imported types
const EntityID = Types.EntityID;
const AssetID = Types.AssetID;

pub const Tags = struct {
    visibility: u8,
    mesh: u32,
    material: u32,

    assetID: AssetID, //Non runtime ID Specific to the related entity
};

pub const Attributes = struct {
    const Self = @This();

    // AOS: a single dense array of whole Tags structs.
    tags: std.ArrayList(Tags) = .empty,

    /// Reserve backing storage up front. The allocator is injected by the
    /// owning `Entities` container rather than owned here.
    pub fn ensureTotalCapacity(self: *Self, allocator: std.mem.Allocator, capacity: usize) !void {
        try self.tags.ensureTotalCapacity(allocator, capacity);
    }

    pub fn deinit(self: *Self, allocator: std.mem.Allocator) void {
        self.tags.deinit(allocator);
    }
};

pub const Tags = struct {
    assetID: u32, //Static pre comptime id
    roID: u32, //Render Object ID
};

pub const Model = struct {
    mesh: u32,
    material: u32,
    assetID: u32,
    roID: u32,
};
