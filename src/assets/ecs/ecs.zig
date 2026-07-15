//! Main entry point for the Entity component system
//! Called by Scene
//!
//!

// Imports
const Types = @import("ecs_config.zig");
const Entities = @import("entities.zig");
const Physics = @import("physics.zig");
const Attributes = @import("attributes.zig");

// Unpacking / aliasing imported types
const Vec3 = Types.Vec3f;
const Vec4 = Types.Vec4f;
const EntityDesc = Types.EntityDesc;

pub const ECS = struct {
    const Self = @This();

    entityIds: Entities,
    physics: Physics,
    attributes: Attributes,

    pub fn init() Self {
        return .{
            .entityIds = Entities.init(),
            .physics = Physics.init(),
            .attributes = Attributes.init(),
        };
    }

    pub fn SpawnEntities(self: *Self, desc: *EntityDesc) void {}
};
