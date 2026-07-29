//! Main entry point for the Entity component system
//!

// Imports
const std = @import("std");

//Import components
const Types = @import("config").ECS;
const Attributes = @import("attributes.zig");
const Kinematics = @import("kinematics.zig");

// Unpacking / aliasing imported types
const EntityID = Types.EntityID;
const RenderObject: type = Types.RenderObject;

pub const ECS = struct {
    malloc: std.mem.Allocator = .{},
    entities: Entities,

    //Components
    kinematics: Kinematics,
    attributes: Attributes,

    pub fn init(allocator: std.mem.Allocator, capacity: usize) !@This() {
        var entities = try Entities.init(allocator, capacity);
        errdefer entities.deinit(allocator);

        var attributes = try Attributes.init(allocator, capacity);
        errdefer attributes.deinit(allocator);

        var kinematics = try Kinematics.init(allocator, capacity);
        errdefer kinematics.deinit(allocator);

        return .{
            .malloc = allocator,
            .entities = entities,
            .attributes = attributes,
            .kinematics = kinematics,
        };
    }

    pub fn deinit(self: *ECS, allocator: std.mem.Allocator) void {
        self.kinematics.deinit(allocator);
        self.attributes.deinit(allocator);
        self.entities.deinit(allocator);
    }

    //Add new entities to ECS
    pub fn add(self: *ECS, dest: *[]EntityID) !void {
        self.
    }

    //Remove entities from ECS
    pub fn remove(self: *ECS, item: EntityID) void {}

    //Add already registered entity to rendering list
    pub fn spawn(self: *ECS, items: []const EntityID) void {}

    //Remove already registered entity from rendering list
    pub fn despawn(self: *ECS, items: []const EntityID) void {}
};
