const std = @import("std");

pub fn main() !void {
    var allocator_impl = std.heap.DebugAllocator(.{}).init;
    defer _ = allocator_impl.deinit();
    const allocator = allocator_impl.allocator();
}
