//! Asset Manager stores and prepares the rendering data for the render system.

const std = @import("std");

var alloc_impl = std.heap.DebugAllocator(.{});

const allocator = alloc_impl.allocator();

pub fn init() !void {
    .alloc_impl.init();
    defer _ = .alloc_impl.deinit();
}
