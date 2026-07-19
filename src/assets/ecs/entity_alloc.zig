//! Tracking Entity IDs
//! To be used by the ECS for tracking open

//Imports
const std = @import("std");

const Types = @import("config").ECS;

// Unpacking / aliasing imported types
const EntityID = Types.EntityID;
const Mat4 = Types.Mat4;
const Allocator = std.mem.Allocator;

const FreeIDs = struct {
    const Self = @This();
    stack: []EntityID,
    count: u32,
    pub fn init() Self {}
    pub fn deinit() void {}
};

const Active = struct {
    const Self = @This();
    frameData: []Mat4, //Data to be send to renderer
    frameEntities: []EntityID, //EntityID for corresponding index within frameData
    activeIndex: []u32,

    pub fn init() Self {}
    pub fn deinit() void {}
};

pub const EntityAllocator = struct {
    const Self = @This();

    ids: FreeIDs,
    active: Active,

    pub fn init(allocator: Allocator, listSize: u32) !Self {
        const freeIDs: []EntityID = try allocator.alloc(EntityID, listSize);
        const RIDsByEntity: []EntityID = try allocator.alloc(EntityID, listSize);

        for (freeIDs, 0..listSize) |*entity, i| {
            entity.* = @intCast(i);
        }
        return .{ .count = 0, .freeIDs = freeIDs, .RIDsByEntity = RIDsByEntity };
    }
};
