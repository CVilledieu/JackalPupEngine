//! Contains or handles the less dynamic entity data.
//! Things that dont interact with the physics system

const std = @import("std");

// Imports
const Types = @import("ecs_config.zig");

// Unpacking / aliasing imported types
const AssetID = Types.AssetID;
const EntityID = Types.EntityID;

//Tags used by render object
pub const ObjectDetails = struct {
    mesh: u32,
    material: u32,
    objectID: u32,
};

//Coldest tags. If no other tags are needed will refactor to include assetID into objectTags
pub const OptionalDetails = struct {
    assetID: AssetID, //Non runtime ID Specific to the related entity
};

pub const Tags = struct {
    const Self = @This();

    // AOS: a single dense array of whole Tags structs.
    objDetails: std.ArrayList(ObjectDetails) = .empty,

    /// Reserve backing storage up front. The allocator is injected by the
    /// owning `Entities` container rather than owned here.
    pub fn ensureTotalCapacity(self: *Self, allocator: std.mem.Allocator, capacity: usize) !void {
        try self.objDetails.ensureTotalCapacity(allocator, capacity);
    }

    pub fn deinit(self: *Self, allocator: std.mem.Allocator) void {
        self.objDetails.deinit(allocator);
    }
};

// Pool of free entity indexes(ids)
pub const Registry = struct {
    const Self = @This();
    freeEntities: []EntityID,
    count: u32,

    pub fn init(allocator: std.mem.Allocator, capacity: u32) !Self {
        return .{
            .freeEntities = try allocator.alloc(EntityID, capacity),
            .count = 0,
        };
    }

    pub fn deinit(self: *Self, allocator: std.mem.Allocator) void {
        allocator.free(self.freeEntities);
        self.* = undefined;
    }
};
