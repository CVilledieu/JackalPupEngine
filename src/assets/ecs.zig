//!

//
const std = @import("std");

const Entities = @import("entities.zig").Entities;
const Kinematics = @import("Kinematics.zig").Kinematics;

pub const ECS = struct {
    allocator: std.mem.Allocator,
    entities: Entities,

    kinematics: Kinematics,

    pub fn init(allocator: std.mem.Allocator, capacity: usize) !@This() {
        return .{
            .allocator = allocator,
            .entities = try Entities.init(allocator, capacity),
            .kinematics = try Kinematics.init(allocator, capacity),
        };
    }

    pub fn deinit(self: *ECS) void {
        self.entities.deinit(self.allocator);
        self.kinematics.deinit(self.allocator);
    }

    pub fn add() !void {}
    pub fn remove() !void {}

    pub fn spawn() !void {}
    pub fn despawn() void {}
};
