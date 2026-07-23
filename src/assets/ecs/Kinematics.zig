//! Components that are hot or warm

// Imports
const Types = @import("config").ECS;

// Unpacking / aliasing imported types
const EntityID = Types.EntityID;
const Vec3 = Types.Vec3f;
const Vec4 = Types.Vec4f;

pub const Transform = struct {
    pos: Vec3,
    scale: Vec3,
    rotation: Vec4,
};

pub const Motion = struct {
    velocity: Vec3,
};
