//! Components that are hot or warm

// Imports
const Types = @import("config").ECS;

// Unpacking / aliasing imported types
const EntityID = Types.EntityID;
const Vec3 = Types.Vec3f;
const Vec4 = Types.Vec4f;

//Transforms
pub const Transforms = struct {
    pos: Vec3,
    scale: Vec3,
    rotation: Vec4,
};

//Motion
pub const Motion = struct {
    velocity: Vec3,
};
