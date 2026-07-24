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

var malloc: std.mem.Allocator = .{};

//Entity ID stack
var freeEntityIDs: std.ArrayList(EntityID) = .empty;
var entityCount: u32 = 0;

//Rendering formatted entities
var renderObjects: std.MultiArrayList(RenderObject) = .{};

pub fn init(allocator: std.mem.Allocator, capacity: u32) !void {
    malloc = allocator;

    for (0..capacity) |i| {
        freeEntityIDs.append(malloc, @intCast(i));
    }
}

pub fn deinit() void {}
