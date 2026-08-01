//! Attribute system
//! Contains the less mutated data within the entity system
//! Storing the data in categories (or AoS)

//External Imports
const std = @import("std");

//Internal Imports
const Types = @import("config").ECS;

// Unpack / Alias imported types
const EntityID = Types.EntityID;
const AssetID = Types.AssetID;

// Attributes of the object used for rendering
const ObjectDetails = struct {
    mesh: u32,
    material: u32,
};

// Other attributes: Place holder at the moment
const AssetDetails = struct {
    id: AssetID, // Static pre runtime time data
};

pub const Attributes = struct {
    objectDetails: std.ArrayList(ObjectDetails) = .empty,
    assetDetails: std.ArrayList(AssetDetails) = .empty,

    pub fn init(allocator: std.mem.Allocator, capacity: usize) !@This() {
        var self: @This() = .{};
        try self.objectDetails.ensureTotalCapacity(allocator, capacity);
        try self.assetDetails.ensureTotalCapacity(allocator, capacity);
        return self;
    }

    pub fn deinit(self: *Attributes, allocator: std.mem.Allocator) void {
        self.objectDetails.deinit(allocator);
        self.assetDetails.deinit(allocator);
    }

    pub fn register(self: *Attributes, allocator: std.mem.Allocator, mesh: u32, material: u32, assetID: AssetID) !void {
        try self.objectDetails.append(allocator, .{ .id = assetID });
        try self.assetDetails.append(allocator, .{ .mesh = mesh, .material = material, .id = 0 });
    }

    pub fn spawn(self: *Attributes, mesh: *u32, material: *u32, id: u32) !void {}
};
