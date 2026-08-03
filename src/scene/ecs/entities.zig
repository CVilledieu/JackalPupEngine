//! Entity Registry

//Importing
const std = @import("std");
const TableId: type = @import("tables.zig").TableId;

//Public Types
pub const Entity: type = u32;
pub const ObjectId: type = u32;

pub const EntityRef: type = struct {
    index: Entity,
    generation: u32,
};

//Private Types
const Object: type = struct {
    table: TableId,
    row: u32,
    generation: u32,
};

//Module core
//Handles a sparse array of Object data
//Reuses freed indexes before increasing object array size
pub const Entities: type = struct {
    objects: std.ArrayList(Object) = .empty,
    freeList: std.ArrayList(u32) = .empty, //Object indexes that were freed

    fn init(self: *Entities, allocator: std.mem.Allocator, capacity: usize) !void {
        try self.objects.ensureTotalCapacity(allocator, capacity);
        try self.freeList.ensureTotalCapacity(allocator, capacity);
    }

    fn deinit(self: *Entities, allocator: std.mem.Allocator) void {
        self.freeList.deinit(allocator);
        self.objects.deinit(allocator);
    }

    fn append(self: *Entities, allocator: std.mem.Allocator, archetype: TableId, rowIndex: u32) !EntityRef {
        if (self.freeList.pop()) |value| {
            self.objects.items[value] = .{ .table = archetype, .row = rowIndex };
            return .{ .index = value, .generation = self.objects.items[value].generation };
        } else {
            try self.objects.append(allocator, .{ .table = archetype, .row = rowIndex });
            return .{ .index = @intCast(self.objects.items.len), .generation = 0 };
        }
    }

    //Archetype and row fields are not reset to a default value
    fn free(self: *Entities, allocator: std.mem.Allocator, index: Entity) !void {
        self.objects.items[index].generation += 1;
        try self.freeList.append(allocator, index);
    }

    fn verify(self: *Entities, e: EntityRef) !void {
        return e.index < self.objects.items.len and self.objects.items[e.index].generation == e.generation;
    }
};
