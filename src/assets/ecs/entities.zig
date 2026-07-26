//! Main entry point for the Entity component system
//! Called by Scene
//!
//! MODULE NOTES: (To help clarify comments)
//!     Arrays labeled with a comment of 'Entity Component' are sparse arrays where Component[EntityID] = ComponentType;

// Imports
const std = @import("std");

//Import components
const Types = @import("config").ECS;
const Attributes = @import("attributes.zig");
const Kinematics = @import("kinematics.zig");

// Unpacking / aliasing imported types
const EntityID = Types.EntityID;
const RenderObject: type = Types.RenderObject;

pub const Entities = struct {
    malloc: std.mem.Allocator = .{},

    freeIDs: std.ArrayList(EntityID) = .empty,
    count: u32,

    //Components
    renderObjects: std.MultiArrayList(RenderObject) = .{},
    kinematics: Kinematics,
    attributes: Attributes,

    pub fn init(allocator: std.mem.Allocator, capacity: usize) !@This() {
        var self: @This() = .{ .count = 0 };
        try self.freeIDs.ensureTotalCapacity(allocator, capacity);

        for (0..capacity) |i| {
            try self.freeIDs.append(allocator, @intCast(i));
        }

        //Init components
        try self.kinematics.init(allocator, capacity);
        try self.attributes.init(allocator, capacity);

        return self;
    }

    pub fn deinit(self: *Entities, allocator: std.mem.Allocator) void {
        self.freeIDs.deinit(allocator);
    }
};
