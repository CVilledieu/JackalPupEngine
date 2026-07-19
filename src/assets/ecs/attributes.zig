//! Contains or handles the less dynamic entity data.
//! Things that are set when the entity is created, but are infrequently updated.
//! AOS approach

// Imports
const Types = @import("ecs_config.zig");

// Unpacking / aliasing imported types
const EntityID = Types.EntityID;
const AssetID = Types.AssetID;
const RenderID = Types.RenderID;

const Tags = struct {
    const Self = @This();

    visibility: u8,
    mesh: u32,
    material: u32,

    assetID: AssetID, //Non runtime ID Specific to the related entity

    pub fn init(visible: u8, assetID: AssetID) Self {
        return .{ .visibility = visible, .assetID = assetID };
    }
};

pub const Attributes = struct {
    const Self = @This();

    tags: []Tags,

    pub fn init() Self {
        return .{};
    }
};
