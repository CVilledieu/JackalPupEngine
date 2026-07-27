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




pub const SparseSet = struct {
    denseIDs: std.ArrayList(EntityID) = .empty,
    openIndices: std.ArrayList(EntityID) = .empty,
    count: u32,


    pub fn init(allocator: std.mem.Allocator, capacity: usize) !Entities{
        var sparse: std.ArrayList(u32) = .empty;
        var free: std.ArrayList(u32) = .empty;

        try sparse.ensureTotalCapacity(allocator, capacity);
        try free.ensureTotalCapacity(allocator, capacity);

        for(capacity..0) |i|{
            try free.append(allocator, @intCast(i));
        }

        return .{
            .count = 0,
            .free = free,
            .sparseSet = sparse,
        };
    }


    pub fn deinit(self: *Entities, allocator: std.mem.Allocator) void{
        self.free.deinit(allocator);
        self.sparseSet.deinit(allocator);
    }

};


pub const ECS = struct {
    malloc: std.mem.Allocator = .{},

    entities: Entities,

    //Components
    renderObjects: std.MultiArrayList(RenderObject) = .{},
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
