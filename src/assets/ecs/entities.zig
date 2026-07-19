//! Tracking Entity IDs
//! To be used by the ECS for tracking open

//Imports
const std = @import("std");

const Attributes = @import("attributes.zig");
const Physics = @import("physics.zig");
const EntityTypes = @import("ecs_config.zig");

// Unpacking / aliasing imported types
const EntityID = EntityTypes.EntityID;
const RenderID = EntityTypes.RenderID;
const Mat4 = EntityTypes.Mat4;
const Allocator = std.mem.Allocator;

pub const Entities = struct {
    const Self = @This();
    RenderData: []Mat4,
    RenderIDs: []EntityID, //EntityID relative to the render data
    RIDsByEntity: []EntityID, //RenderID relative to the EntityID

    freeIDs: []EntityID,
    count: u32,

    pub fn init(allocator: Allocator, listSize: u32) !Self {
        const freeIDs: []EntityID = try allocator.alloc(EntityID, listSize);
        const RIDsByEntity: []EntityID = try allocator.alloc(EntityID, listSize);

        for (freeIDs, 0..listSize) |*entity, i| {
            entity.* = @intCast(i);
        }
        return .{ .count = 0, .freeIDs = freeIDs, .RIDsByEntity = RIDsByEntity };
    }
};
