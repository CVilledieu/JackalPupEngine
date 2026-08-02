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

// Stack data struct allocating position within dense component arrays
const Entities = struct {
    //Stores ObjectID by EntityID  //sparse[EntityID] = ObjectID;
    sparse: std.ArrayList(EntityID) = .empty,

    //Stores EntityIDs by ObjectID  //dense[ObjectID] = EntityID;
    dense: std.ArrayList(EntityID) = .empty,

    //List of entities that were freed and can be reused
    recycled: std.ArrayList(EntityID) = .empty,
    next: EntityID = 0,

    fn init(allocator: std.mem.Allocator, capacity: usize) !Entities {
        var self: Entities = .{};
        errdefer (self.deinit(allocator));

        try self.sparse.ensureTotalCapacity(allocator, capacity);
        try self.dense.ensureTotalCapacity(allocator, capacity);
        try self.recycled.ensureTotalCapacity(allocator, capacity);

        return self;
    }

    fn deinit(self: *Entities, allocator: std.mem.Allocator) void {
        self.sparse.deinit(allocator);
        self.dense.deinit(allocator);
        self.recycled.deinit(allocator);
    }

    fn liveCount(self: *const Entities) u32 {
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

fn Pool(comptime T: type) type {
    return struct {
        const Self = @This();
        sparse: std.ArrayList(EntityID) = .empty, // entity -> index in dense
        owners: std.ArrayList(EntityID) = .empty, // dense index -> entity (packed)
        data: std.ArrayList(T) = .empty, // dense index -> value  (packed)

        fn contains(self: *const Self, e: EntityID) bool {
            if (e >= self.sparse.items.len) return false;
            const i = self.sparse.items[e];
            return i < self.owners.items.len and self.owners.items[i] == e;
        }

        fn get(self: *Self, e: EntityID) ?*T {
            if (!self.contains(e)) return null;
            return &self.data.items[self.sparse.items[e]];
        }

        fn add(self: *Self, a: std.mem.Allocator, e: EntityID, value: T) !void {
            if (self.contains(e)) {
                self.data.items[self.sparse.items[e]] = value;
                return;
            }
            const i: EntityID = @intCast(self.owners.items.len);
            try self.owners.append(a, e);
            try self.data.append(a, value);
            if (e >= self.sparse.items.len) try self.sparse.resize(a, e + 1);
            self.sparse.items[e] = i;
        }

        fn remove(self: *Self, e: EntityID) void {
            if (!self.contains(e)) return;
            const i = self.sparse.items[e];
            const last = self.owners.items[self.owners.items.len - 1];
            self.owners.items[i] = last; // swap-remove owner
            self.data.items[i] = self.data.items[self.data.items.len - 1];
            self.sparse.items[last] = i; // fix moved owner's mapping
            _ = self.owners.pop();
            _ = self.data.pop();
        }
    };
}
