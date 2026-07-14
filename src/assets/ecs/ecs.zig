//! Main entry point for the Entity component system
//! Called by Scene
//!
const Types = @import("util");
const Vec3 = Types.Vec3f;
const Vec4 = Types.Vec4f;

pub const EntityDesc = struct {
    //Local space
    pos: Vec3,
    scale: Vec3,
    rot: Vec4,

    //Attributes
    mesh: u32,
};

pub const ECS = struct {};
