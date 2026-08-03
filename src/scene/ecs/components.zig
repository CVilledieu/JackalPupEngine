//!

const std = @import("std");

pub const Transform = struct {};
pub const Velocity = struct {};
pub const Model = struct {};

pub const typeList = .{
    Transform,
    Velocity,
    Model,
};

pub const typeCount = comTypes.len;

pub const Signature = std.bit_set.IntegerBitSet(nComponents);

pub fn componentId(comptime T: type) u32 {
    inline for (components)
}