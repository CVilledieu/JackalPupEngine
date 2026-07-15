//!

const std = @import("std");

pub const EntityId = u32;

pub const Entities = struct {
    const Self = @This();
    pub const invalid_index = std.math.maxInt(u32);
    pub const InitError = error{ MismatchedCapacity, CapacityTooLarge };
    pub const SpawnError = error{OutOfIds};
    pub const RemoveError = error{InvalidEntity};

    free: []EntityId, // Which Entity indexes aren't registered to an entity

    active: []EntityId, //Actively registered entities that are being rendered
    active_index_by_id: []u32, //The index of the registered entity within active list

    active_len: u32,
    free_len: u32,

    pub fn init(active: []EntityId, free: []EntityId, active_index_by_id: []u32) InitError!Self {
        if (active.len != free.len or active.len != active_index_by_id.len) {
            return InitError.MismatchedCapacity;
        }
        if (active.len > std.math.maxInt(u32)) {
            return InitError.CapacityTooLarge;
        }

        const cap: u32 = @intCast(active.len);

        // Initialize all ids as free and none as active.
        var i: u32 = 0;
        while (i < cap) : (i += 1) {
            free[i] = cap - 1 - i;
            active_index_by_id[i] = invalid_index;
        }

        return .{
            .active = active,
            .free = free,
            .active_index_by_id = active_index_by_id,
            .active_len = 0,
            .free_len = cap,
        };
    }

    pub fn capacity(self: *const Self) u32 {
        return @intCast(self.active.len);
    }

    pub fn count(self: *const Self) u32 {
        return self.active_len;
    }

    pub fn activeIds(self: *const Self) []const EntityId {
        return self.active[0..@intCast(self.active_len)];
    }

    pub fn spawn(self: *Self) SpawnError!EntityId {
        if (self.free_len == 0) {
            return SpawnError.OutOfIds;
        }

        self.free_len -= 1;
        const id = self.free[@intCast(self.free_len)];

        const active_idx = self.active_len;
        self.active[@intCast(active_idx)] = id;
        self.active_index_by_id[@intCast(id)] = active_idx;
        self.active_len += 1;

        return id;
    }

    pub fn spawnMulti(self: *Self, spawnBuffer: []EntityId, spawnCount: u32) SpawnError!u32 {
        if (self.free_len < spawnCount) {
            return SpawnError.OutOfIds;
        }
        const n = @min(spawnBuffer.len, spawnCount);
        spawnBuffer[0..n].* = self.free[@intCast(self.free_len - n)..@intCast(self.free_len)];
        self.free_len -= spawnCount;
        self.active[@intCast()]

        self.active_len += n;

        return n;
    }

    pub fn remove(self: *Self, id: EntityId) RemoveError!void {
        if (!self.isActive(id)) {
            return RemoveError.InvalidEntity;
        }

        const remove_idx = self.active_index_by_id[@intCast(id)];
        const last_active_idx = self.active_len - 1;
        const last_id = self.active[@intCast(last_active_idx)];

        // Swap-remove from active ids.
        self.active[@intCast(remove_idx)] = last_id;
        self.active_index_by_id[@intCast(last_id)] = remove_idx;

        self.active_len -= 1;
        self.active_index_by_id[@intCast(id)] = invalid_index;

        // Push removed id back to free stack.
        self.free[@intCast(self.free_len)] = id;
        self.free_len += 1;
    }

    pub fn isActive(self: *const Self, id: EntityId) bool {
        const cap = self.capacity();
        if (id >= cap) {
            return false;
        }

        const idx = self.active_index_by_id[@intCast(id)];
        if (idx == invalid_index or idx >= self.active_len) {
            return false;
        }

        // Corruption guard: index map and active array should agree.
        return self.active[@intCast(idx)] == id;
    }
};
