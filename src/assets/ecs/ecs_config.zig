pub const Vec2f: type = @Vector(2, f32);
pub const Vec3f: type = @Vector(3, f32);
pub const Vec4f: type = @Vector(4, f32);

pub const RenderID = u32; //Index within ecs active array  // Runtime ID
pub const EntityID = u32; //Index within ecs component arrays  //A runtime ID

pub const AssetID = u32; //Non runtime ID Specific to the related entity

//Entity data needed to be registered into ECS
pub const EntityData = struct {
    const Self = @This();
    pub const VerifyError = error{Incomplete};

    pos: Vec3f,
    scale: Vec3f,
    rotation: Vec4f,

    mesh: u32,
    material: u32,

    //To verify data at runtime before loading entity into ecs
    pub fn verify(self: *Self) VerifyError!void {}
};
