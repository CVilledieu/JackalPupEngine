//! Main entry point for the Entity component system
//! Called by Scene

const Types = @import("util");
const Attributes = @import("attributes.zig");
const Physics = @import("physics.zig");

const Vec3 = Types.Vec3f;
const Vec4 = Types.Vec4f;

const EntityDesc = struct {
    //Local space
    pos: Vec3,
    scale: Vec3,
    rot: Vec4,

    //Attributes
    mesh: u32,
};

const ECS = struct {
    physical: Physics,
    attributes: Attributes,
    entityCount: u32,
    pub fn init() @This() {
        return .{
            .localSpace = Physics.init(),
            .attr = Attributes.init(),
            .entityCount = 0,
        };
    }
};

pub fn RegisterEntities(newEntities: *EntityDesc) !void {
    for (newEntities) |entity| {
        .localSpace.Push(.entityCount, entity.pos, entity.scale, entity.rot);
        .attr.Push(.entityCount, entity.visibility, entity.active);
    }
}
