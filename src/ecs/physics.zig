//! Contains or handles the more dynamic entity data.
//! Things that are elements that are frequently updated
//! SOA approach

const EntityTypes = @import("util").EntityTypes;
const Vec2 = EntityTypes.Vec2f;
const Vec3 = EntityTypes.Vec3f;
const Vec4 = EntityTypes.Vec4f;

pub const Physics = struct {
    const Self = @This();

    pos: []Vec3,
    scale: []Vec3,
    rotation: []Vec4,

    pub fn init() Self {
        return .{};
    }

    pub fn Push(self: *Self, id: u32, pos: Vec3, scale: Vec3, rotation: Vec4) void {
        self.pos[id] = pos;
        self.scale[id] = scale;
        self.rotation[id] = rotation;
    }

    // Unsure how I want to handle remove atm
    // pub fn Remove(self: *Self, id: u32) !void {}

    //Called during engine update phase
    pub fn Update(self: *Self) void {
        for (self.pos, self.rotation, self.scale) |p, r, s| {}
    }
};
