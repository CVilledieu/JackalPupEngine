//!

//Importing
const std = @import("std");
const Entity: type = @import("entities.zig").Entity;

//Public Types
pub const TableId: type = u16;
pub const ComponentId: type = u32;

//Private Types

const Column: type = struct {
    component: ComponentId,
    element_size: usize,
    data: []u8,
};

//Module core
pub const Table: type = struct {
    id: TableId,
    components: []ComponentId,
    columns: []Column,
    entities: std.ArrayList(Entity),
    rowCount: u32,
};

const ErasedColumn = struct {
    ptr: *anyopaque, // really *ArrayList(T)
    deinit: *const fn (*anyopaque, allocator: std.mem.Allocator) void,
    swapRemove: *const fn (*anyopaque, row: usize) void,
    moveRowTo: *const fn (src: *anyopaque, row: usize, dst: *anyopaque) void,
};

fn makeColumn(comptime T: type, allocator: std.mem.Allocator) ErasedColumn {
    const List = std.ArrayListUnmanaged(T);
    const gen = struct {
        fn deinit(p: *anyopaque, allocator: std.mem.Allocator) void {
            @as(*List, @ptrCast(@alignCast(p))).deinit(a);
        }
        // ...swapRemove, moveRowTo similarly, all type-correct
    };
    // allocate a List, return handle + &gen.deinit, ...
    return .{
        .ptr = List,
    };
}
