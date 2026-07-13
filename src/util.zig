pub const EntityTypes = struct {
    pub const Vec2f = struct {
        x: f32,
        y: f32,

        pub fn init(x: f32, y: f32) Vec2f {
            return Vec2f{ .x = x, .y = y };
        }
    };

    pub const Vec3f = struct {
        x: f32,
        y: f32,
        z: f32,

        pub fn init(x: f32, y: f32, z: f32) Vec3f {
            return Vec3f{ .x = x, .y = y, .z = z };
        }
    };

    pub const Vec4f = struct {
        x: f32,
        y: f32,
        z: f32,
        w: f32,

        pub fn init(x: f32, y: f32, z: f32, w: f32) Vec4f {
            return Vec4f{ .x = x, .y = y, .z = z, .w = w };
        }
    };
};
