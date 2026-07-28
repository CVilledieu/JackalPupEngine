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



// Stack data struct allocating position within dense component arrays
const Entities = struct {
    //Stores ObjectID by EntityID  //sparse[EntityID] = ObjectID;
    sparse: std.ArrayList(EntityID) = .empty,

    //Stores EntityIDs by ObjectID  //dense[ObjectID] = EntityID;
    dense: std.ArrayList(EntityID) = .empty,
    
    //List of entities that were freed and can be reused
    recycled: std.ArrayList(EntityID) = .empty,
    next: EntityID = 0,

    fn init(allocator: std.mem.Allocator, capacity: usize) !Entities{
        var self: Entities = .{};
        errdefer(self.deinit(allocator));

        try self.sparse.ensureTotalCapacity(allocator, capacity);
        try self.dense.ensureTotalCapacity(allocator, capacity);
        try self.recycled.ensureTotalCapacity(allocator, capacity);

        return self;
    }


    fn deinit(self: *Entities, allocator: std.mem.Allocator) void{
        self.sparse.deinit(allocator);
        self.dense.deinit(allocator);
        self.recycled.deinit(allocator);
    }

    fn liveCount(self: *const Entities) u32{
        return @intCast(self.dense.items.len);
    }

    fn contains(self: *const Entities, id: EntityID) bool {
        if (id >= self.sparse.items.len) return false;
        const i = self.sparse.items[id];
        return i < self.dense.items.len and self.dense.items[i] == id;
    }

    fn slot(self: *const Entities, id: EntityID) ?EntityID {
        if (!self.contains(id)) return null;
        return self.sparse.items[id];
    }


    fn add(self: *Entities, allocator: std.mem.Allocator) !EntityID {
        const id = self.free.pop() orelse blk: {
            const fresh = self.next;
            self.next += 1;
            break :blk fresh;
        };

        const dense_index: EntityID = @intCast(self.dense.items.len);
        try self.dense.append(allocator, id);

        // Ensure sparse is large enough to index `id`, then map it.
        if (id >= self.sparse.items.len) {
            try self.sparse.resize(allocator, id + 1);
        }
        self.sparse.items[id] = dense_index;

        return id;
    }

    fn remove(self: *Entities, allocator: std.mem.Allocator, id: EntityID) !?EntityID {
        if (!self.contains(id)) return null;

        const i = self.sparse.items[id];
        const moved_id = self.dense.items[self.dense.items.len - 1];

        // Move the last live entity into the hole, fix its sparse mapping.
        self.dense.items[i] = moved_id;
        self.sparse.items[moved_id] = i;
        _ = self.dense.pop();

        try self.free.append(allocator, id); // recycle
        return i;
    }
};

    

};


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
