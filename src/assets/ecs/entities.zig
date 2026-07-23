//! Main entry point for the Entity component system
//! Called by Scene
//!
//! MODULE NOTES: (To help clarify comments)
//!     Arrays labeled with a comment of 'Entity Component' are sparse arrays where Component[EntityID] = ComponentType;

// Imports
const std = @import("std");
const Types = @import("config").ECS;

const Attributes = @import("attributes.zig").Attributes;
const Kinematics = @import("Kinematics.zig");

// Unpacking / aliasing imported types
const EntityID = Types.EntityID;
const Motion = Kinematics.Motion;
const Transform = Kinematics.Transform;

const Mat4 = Types.Mat4;

// Pool of free entity indexes(ids)
const Registry = struct {
    const Self = @This();
    freeEntities: []EntityID,
    count: u32,

    pub fn init(allocator: std.mem.Allocator, capacity: u32) !Self {
        return .{
            .freeEntities = try allocator.alloc(EntityID, capacity),
            .count = 0,
        };
    }

    pub fn deinit(self: *Self, allocator: std.mem.Allocator) void {
        allocator.free(self.freeEntities);
        self.* = undefined;
    }
};

//Dense arrays prepared to be sent to renderer
const RenderObjects = struct {
    transforms: Mat4,
    ids: EntityID,
};

//Core struct
pub const Entities = struct {
    const Self = @This();

    malloc: std.mem.Allocator,

    registry: Registry,
    attributes: Attributes = .{},

    renderObjects: std.MultiArrayList(RenderObjects) = .{},
    motion: std.MultiArrayList(Motion) = .{},
    transforms: std.MultiArrayList(Transform) = .{},

    pub fn init(allocator: std.mem.Allocator, capacity: u32) !Self {
        var self: Self = .{
            .malloc = allocator,
            .registry = try Registry.init(allocator, capacity),
        };

        // If any reservation below fails, tear the whole thing back down.
        errdefer self.deinit();

        try self.active.ensureTotalCapacity(allocator, capacity);
        try self.motion.ensureTotalCapacity(allocator, capacity);
        try self.transforms.ensureTotalCapacity(allocator, capacity);
        try self.attributes.ensureTotalCapacity(allocator, capacity);

        return self;
    }

    pub fn deinit(self: *Self) void {
        self.active.deinit(self.malloc);
        self.motion.deinit(self.malloc);
        self.transforms.deinit(self.malloc);
        self.attributes.deinit(self.malloc);
        self.registry.deinit(self.malloc);
        self.* = undefined;
    }

    pub fn SpawnEntities(self: *Self) void {
        _ = self;
    }
};
