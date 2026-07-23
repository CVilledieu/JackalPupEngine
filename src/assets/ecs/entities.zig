//! Main entry point for the Entity component system
//! Called by Scene
//!
//! MODULE NOTES: (To help clarify comments)
//!     Arrays labeled with a comment of 'Entity Component' are sparse arrays where Component[EntityID] = ComponentType;

// Imports
const std = @import("std");
const Types = @import("config").ECS;

//Import component containers
const Attributes = @import("attributes.zig");
const Kinematics = @import("kinematics.zig");

// Unpacking / aliasing imported types
const EntityID = Types.EntityID;
const Mat4 = Types.Mat4;

//Unpack components
const Tags = Attributes.Tags;
const Registry = Attributes.Registry;

const Motion = Kinematics.Motion;
const Transform = Kinematics.Transform;

//Dense arrays prepared to be sent to renderer
const RenderObject = struct {
    transforms: Mat4,
    entity: EntityID,
};

//Core struct
pub const Entities = struct {
    const Self = @This();

    malloc: std.mem.Allocator,

    registry: Registry,
    renderObjects: std.MultiArrayList(RenderObject) = .{},

    //Physics
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
