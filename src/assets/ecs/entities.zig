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

pub const Components = struct {

};

pub const Entities = struct {
    sparseSet: std.ArrayList(EntityID) = .empty,
    count: u32,

    pub fn init(allocator: std.mem.Allocator, capacity: usize) !@This(){}

};

pub const EntitiesV1 = struct {
    malloc: std.mem.Allocator = .{},

    freeIDs: std.ArrayList(EntityID) = .empty,
    count: u32,

    //Components
    renderObjects: std.MultiArrayList(RenderObject) = .{},
    kinematics: Kinematics,
    attributes: Attributes,

    pub fn init(allocator: std.mem.Allocator, capacity: usize) !@This() {
        var attributes = try Attributes.init(allocator, capacity);
        errdefer attributes.deinit(allocator);

        var kinematics = try Kinematics.init(allocator, capacity);
        errdefer kinematics.deinit(allocator);

        var freeIDs: std.ArrayList(EntityID) = .empty;
        errdefer freeIDs.deinit(allocator);
        try freeIDs.ensureTotalCapacity(allocator, capacity);

        for (0..capacity) |i| {
            freeIDs.appendAssumeCapacity(@intCast(i));
        }

        return .{
            .malloc = allocator,
            .freeIDs = freeIDs,
            .count = 0,
            .attributes = attributes,
            .kinematics = kinematics,
        };
    }

    pub fn deinit(self: *Entities, allocator: std.mem.Allocator) void {
        self.renderObjects.deinit(allocator);
        self.kinematics.deinit(allocator);
        self.attributes.deinit(allocator);
        self.freeIDs.deinit(allocator);
    }

    //Add new entities to ECS
    pub fn add(self: *Entities, dest: *[]EntityID) !void {
        self.
    }

    //Remove entities from ECS
    pub fn remove(self: *Entities, item: EntityID) void {}

    //Add already registered entity to rendering list
    pub fn spawn(self: *Entities, items: []const EntityID) void {}

    //Remove already registered entity from rendering list
    pub fn despawn(self: *Entities, items: []const EntityID) void {}
};
