---

## Phase 1 — Component registry + signatures

The comptime foundation everything else keys off. The whole game's component set is one closed tuple; IDs are just indices into it.

```zig
// --- the closed set of component types (edit this one list to add components) ---
pub const component_types = .{ Transform, Velocity, Mesh, Frozen /* ZST tag */ };
pub const num_components = component_types.len;

// A signature = which components a table/query cares about, as a bitset.
pub const Signature = std.bit_set.IntegerBitSet(num_components);

// --- comptime: type -> stable id (index into the tuple) ---
pub fn componentId(comptime T: type) u32 {
    inline for (component_types, 0..) |C, i| {
        if (C == T) return @intCast(i);
    }
    @compileError("type is not a registered component: " ++ @typeName(T));
}

// --- comptime-built runtime table of {size, alignment} for erased columns ---
const ComponentInfo = struct { size: usize, alignment: usize };

pub const component_info: [num_components]ComponentInfo = blk: {
    var arr: [num_components]ComponentInfo = undefined;
    inline for (component_types, 0..) |C, i| {
        arr[i] = .{ .size = @sizeOf(C), .alignment = @alignOf(C) };
    }
    break :blk arr;
};

// --- convenience: build a Signature from a list of component types ---
pub fn signatureOf(comptime types: anytype) Signature {
    var sig = Signature.initEmpty();
    inline for (types) |T| sig.set(componentId(T));
    return sig;
}
```

Notes:
- `Frozen` (a fieldless tag) lands here with `size == 0`; the column code must special-case that.
- `signatureOf(.{ Transform, Velocity })` gives you the table/query key with no runtime cost.
- If you ever exceed 64 components, `IntegerBitSet` still works (it uses multiple words); nothing else changes.

---

## Phase 2 — Column (Technique B, type-erased)

The heart of the storage. It knows *nothing* about `T` except its size and alignment. The one place `T` re-enters is the `as(T)` view used on the hot path.

```zig
pub const Column = struct {
    component_id: u32,
    element_size: usize,     // bytes per element (0 for ZST)
    element_align: usize,    // required alignment
    bytes: [*]u8,            // raw storage (undefined when capacity == 0 / ZST)
    len: usize,              // number of live rows
    capacity: usize,         // rows the storage can hold

    pub fn init(component_id: u32) Column {
        const info = component_info[component_id];
        return .{
            .component_id = component_id,
            .element_size = info.size,
            .element_align = info.alignment,
            .bytes = undefined,
            .len = 0,
            .capacity = 0,
        };
    }

    pub fn deinit(self: *Column, alloc: Allocator) void {
        if (self.element_size == 0 or self.capacity == 0) return; // ZST/empty: nothing owned
        // free `capacity * element_size` bytes at `element_align`
        rawFree(alloc, self.bytes, self.capacity * self.element_size, self.element_align);
        self.* = undefined;
    }

    // Grow to hold at least `want` rows. Runtime alignment => use the raw allocator API.
    fn ensureCapacity(self: *Column, alloc: Allocator, want: usize) !void {
        if (self.element_size == 0) return;         // ZST: capacity is meaningless
        if (want <= self.capacity) return;

        var new_cap = if (self.capacity == 0) 8 else self.capacity * 2;
        while (new_cap < want) new_cap *= 2;

        // NOTE: alignment is a RUNTIME value here, so alignedAlloc (comptime-align) won't do.
        // Use the low-level allocator interface with a runtime alignment (std.mem.Alignment).
        const new_ptr = try rawAlloc(alloc, new_cap * self.element_size, self.element_align);
        if (self.capacity != 0) {
            @memcpy(new_ptr[0 .. self.len * self.element_size],
                    self.bytes[0 .. self.len * self.element_size]);
            rawFree(alloc, self.bytes, self.capacity * self.element_size, self.element_align);
        }
        self.bytes = new_ptr;
        self.capacity = new_cap;
    }

    // Reserve one row; returns its byte range so the caller can memcpy a value in.
    // For ZST, returns an empty slice but still bumps len.
    pub fn pushSlot(self: *Column, alloc: Allocator) ![]u8 {
        try self.ensureCapacity(alloc, self.len + 1);
        const row = self.len;
        self.len += 1;
        return self.rawAt(row);
    }

    // POD swap-remove: overwrite `row` with the last row's bytes, shrink.
    pub fn swapRemove(self: *Column, row: usize) void {
        const last = self.len - 1;
        if (self.element_size != 0 and row != last) {
            @memcpy(self.rawAt(row), self.rawAt(last));
        }
        self.len -= 1;
    }

    pub fn rawAt(self: *Column, row: usize) []u8 {
        if (self.element_size == 0) return self.bytes[0..0];
        const off = row * self.element_size;
        return self.bytes[off .. off + self.element_size];
    }

    // The ONLY typed re-entry point. Hot path casts once, then sweeps. Zero indirection.
    pub fn as(self: *Column, comptime T: type) []T {
        std.debug.assert(componentId(T) == self.component_id);
        if (self.element_size == 0) return &[_]T{};      // ZST: empty typed slice
        const ptr: [*]T = @ptrCast(@alignCast(self.bytes));
        return ptr[0..self.len];
    }
};
```

The three things to get right here, all POD/erasure-specific:
- **Runtime alignment** — `std.mem.Allocator.alignedAlloc` needs a *comptime* alignment; your alignment is erased to a runtime field, so you go through the raw allocator interface (`rawAlloc`/`rawFree` with a `std.mem.Alignment`). *(Exact signatures vary by Zig version — that's the "process" you signed up for with B.)* Simpler fallback if you dislike it: over-align every column to a fixed max (e.g. 16) and use a normal aligned alloc.
- **ZST guard** — every allocation/`@memcpy`/offset path checks `element_size == 0` first, so `Frozen`-style tags cost zero bytes and never divide by zero.
- **`as(T)` is the hot path** — one `@ptrCast`+`@alignCast`, then a plain slice. Identical codegen to what Technique C would produce.

---

## Phase 3 — Entity registry

Pure indirection: identity + generation + "where does your data live." No component data here.

```zig
pub const Entity = packed struct { index: u32, generation: u32 };
pub const TableId = u32;

const EntityRecord = struct {
    generation: u32,   // must match a handle's generation to be valid
    table: TableId,    // which table holds this entity's row
    row: u32,          // which row within that table
};

pub const Registry = struct {
    records: std.ArrayListUnmanaged(EntityRecord) = .{},
    free_list: std.ArrayListUnmanaged(u32) = .{},

    // Reserve a slot; caller fills in table/row after placing the entity in a table.
    pub fn alloc(self: *Registry, gpa: Allocator) !Entity {
        if (self.free_list.pop()) |idx| {
            // generation was already bumped at destroy time; reuse as-is
            return .{ .index = idx, .generation = self.records.items[idx].generation };
        }
        const idx: u32 = @intCast(self.records.items.len);
        try self.records.append(gpa, .{ .generation = 0, .table = 0, .row = 0 });
        return .{ .index = idx, .generation = 0 };
    }

    pub fn isAlive(self: *Registry, e: Entity) bool {
        return e.index < self.records.items.len and
            self.records.items[e.index].generation == e.generation;
    }

    pub fn locate(self: *Registry, e: Entity) *EntityRecord {
        std.debug.assert(self.isAlive(e));
        return &self.records.items[e.index];
    }

    // Free the slot; bumping generation invalidates every outstanding handle to it.
    pub fn free(self: *Registry, gpa: Allocator, e: Entity) !void {
        const rec = &self.records.items[e.index];
        rec.generation +%= 1;             // wrapping bump = stale-handle detection
        try self.free_list.append(gpa, e.index);
    }
};
```

The one subtlety: **generation is bumped on `free`, not on `alloc`.** That way a recycled slot hands out the already-incremented generation, and any old handle (with the previous generation) fails `isAlive`. This is your entire defense against dangling entity references.

---

## Phase 4 — Table (archetype)

Owns a set of columns (one per component in its signature) kept row-aligned with an `entities` array. Built from a signature at creation time.

```zig
pub const Table = struct {
    signature: Signature,
    component_ids: []u32,                 // sorted; the columns are parallel to this
    columns: []Column,
    col_index: [num_components]u16,       // component_id -> column slot, or SENTINEL
    entities: std.ArrayListUnmanaged(Entity) = .{},
    len: usize = 0,

    const SENTINEL: u16 = std.math.maxInt(u16);

    pub fn init(gpa: Allocator, signature: Signature) !Table {
        var ids = std.ArrayListUnmanaged(u32){};
        var cols = std.ArrayListUnmanaged(Column){};
        var col_index = [_]u16{SENTINEL} ** num_components;

        var it = signature.iterator(.{});     // yields set bit positions = component ids
        var slot: u16 = 0;
        while (it.next()) |cid_usize| {
            const cid: u32 = @intCast(cid_usize);
            try ids.append(gpa, cid);
            try cols.append(gpa, Column.init(cid));
            col_index[cid] = slot;
            slot += 1;
        }
        return .{
            .signature = signature,
            .component_ids = try ids.toOwnedSlice(gpa),
            .columns = try cols.toOwnedSlice(gpa),
            .col_index = col_index,
        };
    }

    pub fn deinit(self: *Table, gpa: Allocator) void {
        for (self.columns) |*c| c.deinit(gpa);
        gpa.free(self.columns);
        gpa.free(self.component_ids);
        self.entities.deinit(gpa);
    }

    pub fn columnFor(self: *Table, component_id: u32) ?*Column {
        const slot = self.col_index[component_id];
        if (slot == SENTINEL) return null;
        return &self.columns[slot];
    }

    // Append an entity's row: reserve a slot in every column, record the entity.
    // Caller then fills each column via rawAt(row).
    pub fn appendEntity(self: *Table, gpa: Allocator, e: Entity) !u32 {
        const row: u32 = @intCast(self.len);
        try self.entities.append(gpa, e);
        for (self.columns) |*c| _ = try c.pushSlot(gpa);
        self.len += 1;
        return row;
    }

    // Swap-remove `row` from every column + entities.
    // Returns the entity that got MOVED into `row` (so the World can patch its record),
    // or null if `row` was the last one.
    pub fn removeRow(self: *Table, row: u32) ?Entity {
        const last: u32 = @intCast(self.len - 1);
        const moved: ?Entity = if (row != last) self.entities.items[last] else null;

        for (self.columns) |*c| c.swapRemove(row);
        self.entities.items[row] = self.entities.items[last];
        _ = self.entities.pop();
        self.len -= 1;
        return moved;
    }
};
```

The two invariants this phase must never break:
- **Row alignment across columns + entities** — `appendEntity` pushes to *every* column and to `entities` in lockstep; `removeRow` swap-removes all of them at the same index. Break this and column N's row R stops describing the same entity as column M's row R.
- **`removeRow` returns the moved entity** — because the swap pulled the last entity into the hole, the World must patch *that* entity's `row` in the registry. This return value is how phases 5–6 keep the registry honest. (`appendEntity` deliberately leaves the columns *uninitialized* — the caller writes the actual component bytes, which is exactly what the migration algorithm in Phase 6 does.)

---

These four phases give you a testable foundation before any migration logic: you can already create a table from a signature, push/pop rows, and round-trip typed data through `Column.as(T)`.

Want me to continue with **Phase 5 (find-or-create table + create/destroy entity)** and **Phase 6 (the `addComponent` migration in full)** in the same pseudocode style? Phase 6 is where the `removeRow`-returns-moved-entity contract and the pointer-refetch gotcha actually get exercised.