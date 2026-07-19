//! Main entry point for the Entity component system
//! Called by Scene
//!
//!

// Imports
const std = @import("std");
const Types = @import("config").ECS;
const EntityAllocator = @import("entity_alloc.zig").EntityAllocator;
const Physics = @import("physics.zig").Physics;
const Attributes = @import("attributes.zig").Attributes;

// Unpacking / aliasing imported types
const Vec3 = Types.Vec3f;
const Vec4 = Types.Vec4f;

pub const Entities = struct {
    const Self = @This();

    entityIds: EntityAllocator,
    physics: Physics,
    attributes: Attributes,

    pub fn init(allocator: std.mem.Allocator) Self {
        return .{
            .entityIds = Entities.init(),
            .physics = Physics.init(),
            .attributes = Attributes.init(),
        };
    }

    pub fn SpawnEntities(self: *Self, desc: *EntityDesc) void {}
};
