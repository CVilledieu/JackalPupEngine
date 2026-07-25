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

pub const Kinematics = struct {
    transforms: std.MultiArrayList(Transforms) = .empty,
    motion: std.MultiArrayList(Motion) = .empty,

    pub fn init(allocator: std.mem.Allocator, capacity: usize) !Kinematics {
        return .{
            .transforms.ensureTotalCapacity(allocator, capacity),
            .motion.ensureTotalCapacity(allocator, capacity),
        };
    }

    pub fn deinit(self: *Kinematics, allocator: std.mem.Allocator) void {
        self.transforms.deinit(allocator);
        self.motion.deinit(allocator);
    }
};
