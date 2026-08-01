//! Components that are hot or warm

// Imports
const std = @import("std");
const Types = @import("config").ECS;

// Unpacking / aliasing imported types
const EntityID = Types.EntityID;
const Vec3 = Types.Vec3f;
const Vec4 = Types.Vec4f;
const Mat4 = Types.Mat4;

pub const Transforms = struct {
    pos: Vec3,
    scale: Vec3,
    rotation: Vec4,
};

pub const Motion = struct {
    velocity: Vec3,
};

pub const Kinematics = struct {
    transforms: std.MultiArrayList(Transforms) = .empty,
    motion: std.MultiArrayList(Motion) = .empty,

    pub fn init(allocator: std.mem.Allocator, capacity: usize) !@This() {
        var self: @This() = .{};
        try self.transforms.ensureTotalCapacity(allocator, capacity);
        try self.motion.ensureTotalCapacity(allocator, capacity);

        return self;
    }

    pub fn deinit(self: *Kinematics, allocator: std.mem.Allocator) void {
        self.transforms.deinit(allocator);
        self.motion.deinit(allocator);
    }

    pub fn register(self: *Kinematics, allocator: std.mem.Allocator, tSrc: Transforms, mSrc: Motion) !void {
        try self.transforms.append(allocator, tSrc);
        try self.motion.append(allocator, mSrc);
    }

    pub fn spawn(self: *Kinematics, mat: *Mat4, id: EntityID) void {}
};
