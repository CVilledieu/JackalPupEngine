pub const Vec2f: type = @Vector(2, f32);
pub const Vec3f: type = @Vector(3, f32);
pub const Vec4f: type = @Vector(4, f32);
pub const Mat4 = [4]@Vector(4, f32); //Temp place holder. Will import zlm library for mat4 later

pub const EntityID = u32; //Index within ecs component arrays  //A runtime ID
pub const AssetID = u32; //Non runtime ID Specific to the related entity

//Dense arrays prepared to be sent to renderer
pub const RenderObject = struct {
    transforms: Mat4,
    entity: EntityID,
};
