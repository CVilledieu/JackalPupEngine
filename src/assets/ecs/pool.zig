//!
//!
//!
//!

//Imports
const std = @import("std");
const EntityTypes = @import("ecs_config.zig");

//Unpack / aliasing
const Mat4 = EntityTypes.Mat4;
const EntityID = EntityTypes.EntityID;
const Allocator = std.mem.Allocator;

pub const Pool = struct {
    const Self = @This();

    render: []Mat4,
    poolID: []EntityID, //poolID[EntityID] provides the index within transforms and entityID corresponding to that entity
    entityID: []u32, //entityID[poolID] provides the entityID for transforms[poolID]

    pub fn init(allocator: Allocator, listSize: u32) !Self {}

    pub fn deinit() void {}

    pub fn add() !void {}
    pub fn remove() !void {}
};
