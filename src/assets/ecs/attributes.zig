//! Attribute system
//! Contains the less mutated data within the entity system
//! Storing the data in categories (or AoS)

//External Imports
const std = @import("std");

//Internal Imports
const Types = @import("config").ECS;

// Unpack / Alias imported types
const AssetID = Types.AssetID;

// Rendering Object data
const ObjectDetails = struct {
    mesh: u32,
    material: u32,
    id: u32, //Index within Rendering Objects array. 0 = not in Rendering Objects
};

const AssetDetails = struct {
    id: AssetID, // Static pre runtime time data
};

pub const Attributes = struct {
    objectList: std.ArrayList(ObjectDetails) = .empty,
    assetList: std.ArrayList(AssetDetails) = .empty,

    pub fn init(self: *Attributes, allocator: std.mem.Allocator, capacity: usize) !void {
        try self.objectList.ensureTotalCapacity(allocator, capacity);
        try self.assetList.ensureTotalCapacity(allocator, capacity);
        return self;
    }

    pub fn deinit(self: *Attributes, allocator: std.mem.Allocator) void {
        self.assetList.deinit(allocator);
        self.objectList.deinit(allocator);
    }

    pub fn register(self: *Attributes, allocator: std.mem.Allocator, mesh: u32, material: u32, assetID: AssetID) !void {
        try self.assetList.append(allocator, .{ .id = assetID });
        try self.objectList.append(allocator, .{ .mesh = mesh, .material = material, .id = 0 });
    }

    pub fn spawn(self: *Attributes, mesh: *u32, material: *u32, id: u32) !void {}
};
