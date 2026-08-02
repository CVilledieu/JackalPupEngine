//! Types and functions for entities
//!

// Imports
const std = @import("std");

//Public types
pub const Vec2f: type = @Vector(2, f32);
pub const Vec3f: type = @Vector(3, f32);
pub const Vec4f: type = @Vector(4, f32);
pub const Mat4 = [4]@Vector(4, f32); //Temp place holder. Will import zlm library for mat4 later

pub const EntityID = u32; //Index within ecs component arrays  //A runtime ID
pub const ObjectID = u32;

pub fn Component(comptime T: type) type {
    return struct {
        const Self = @This();
        sparse: std.ArrayList(EntityID) = .empty, // sparse[EntityID] = ObjectID
        objects: std.ArrayList(EntityID) = .empty, // dense[objectID] = EntityID
        data: std.ArrayList(T) = .empty, // dense index -> value  (packed)

        fn contains(self: *const Self, e: EntityID) bool {
            if (e >= self.sparse.items.len) return false;
            const i = self.sparse.items[e];
            return i < self.objects.items.len and self.objects.items[i] == e;
        }

        fn get(self: *Self, e: EntityID) ?*T {
            if (!self.contains(e)) return null;
            return &self.data.items[self.sparse.items[e]];
        }

        fn add(self: *Self, a: std.mem.Allocator, e: EntityID, value: T) !void {
            if (self.contains(e)) {
                self.data.items[self.sparse.items[e]] = value;
                return;
            }
            const i: EntityID = @intCast(self.objects.items.len);
            try self.objects.append(a, e);
            try self.data.append(a, value);
            if (e >= self.sparse.items.len) try self.sparse.resize(a, e + 1);
            self.sparse.items[e] = i;
        }

        fn remove(self: *Self, e: EntityID) void {
            if (!self.contains(e)) return;
            const i = self.sparse.items[e];
            const last = self.objects.items[self.objects.items.len - 1];
            self.objects.items[i] = last; // swap-remove owner
            self.data.items[i] = self.data.items[self.data.items.len - 1];
            self.sparse.items[last] = i; // fix moved owner's mapping
            _ = self.objects.pop();
            _ = self.data.pop();
        }
    };
}

pub fn ComponentList(comptime T: type) type {
    return struct {
        const Self = @This();
        sparse: std.ArrayList(EntityID) = .empty, // sparse[EntityID] = ObjectID
        objects: std.ArrayList(EntityID) = .empty, // dense[objectID] = EntityID
        data: std.MultiArrayList(T) = .empty, // dense index -> value  (packed)

    };
}
