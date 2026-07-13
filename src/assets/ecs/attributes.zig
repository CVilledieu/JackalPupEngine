//! Contains or handles the less dynamic entity data.
//! Things that are set when the entity is created, but are infrequently updated.
//! AOS approach

const Tags = struct {
    const Self = @This();

    visibility: u8,
    active: u8,
    mesh: u32,
    material: u32,
    assetID: u32, //Non runtime ID Specific to the related entity

    pub fn init(visible: u8, active: u8) Self {
        return .{ .visibility = visible, .active = active };
    }
};

pub const Attributes = struct {
    const Self = @This();

    tags: []Tags,

    pub fn init() Self {
        return .{};
    }

    pub fn Push(self: *Self, id: u32, visibility: u8, active: u8) void {
        self.tags[id].active = active;
        self.tags[id].visibility = visibility;
    }
};
