//! Components that are hot or warm

// Imports
const std = @import("std");
const Types = @import("config").ECS;

// Unpacking / aliasing imported types
const EntityID = Types.EntityID;
const Vec3 = Types.Vec3f;
const Vec4 = Types.Vec4f;

const Transforms = struct {
    pos: Vec3,
    scale: Vec3,
    rotation: Vec4,
};

const Motion = struct {
    velocity: Vec3,
};

var transforms = std.MultiArrayList(Transforms);
var motion = std.MultiArrayList(Motion); //Multi array list, because I plan to expand the structs fields

pub fn init(allocator: std.mem.Allocator, capacity: usize) !void {
    try transforms.ensureTotalCapacity(allocator, capacity);
    try motion.ensureTotalCapacity(allocator, capacity);
}
pub fn deinit(allocator: std.mem.Allocator) void {}
