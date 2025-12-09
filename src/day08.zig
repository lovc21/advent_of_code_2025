const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const print = std.debug.print;

const data = @embedFile("data/day08.txt");

pub fn main() !void {
    // var total_count: usize = 0;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var lines = tokenizeAny(u8, data, "\n");
    var rows: usize = 0;
    while (lines.next()) |line| {
        if (line.len > 0) rows += 1;
    }

    const numbers_matrix = try allocator.alloc([3]i32, rows);
    defer allocator.free(numbers_matrix);

    var lines2 = tokenizeAny(u8, data, "\n");
    var row_idx: usize = 0;
    while (lines2.next()) |line| {
        if (line.len == 0) continue;

        var coords = std.mem.tokenizeAny(u8, line, ",");
        var col_idx: usize = 0;
        while (coords.next()) |coord_str| {
            const num = try std.fmt.parseInt(i32, coord_str, 10);
            numbers_matrix[row_idx][col_idx] = num;
            col_idx += 1;
        }
        row_idx += 1;
    }

    var connected_matrix = List([3]usize){};
    defer connected_matrix.deinit(allocator);

    var distances: f64 = 0;
    for (numbers_matrix, 0..) |row, current_idx| {

        // Euclidean distance
        for (0..rows, 0..) |index_of_row, other_idx| {
            if (current_idx == other_idx) continue;
            const dx = @as(f64, @floatFromInt(row[0] - numbers_matrix[index_of_row][0]));
            const dy = @as(f64, @floatFromInt(row[1] - numbers_matrix[index_of_row][1]));
            const dz = @as(f64, @floatFromInt(row[2] - numbers_matrix[index_of_row][2]));

            distances = sqrt(dz * dz + dy * dy + dx * dx);

            try connected_matrix.append(allocator, [3]usize{
                @intFromFloat(distances),
                index_of_row + 1,
                current_idx + 1,
            });
        }
    }

    std.mem.sort([3]usize, connected_matrix.items, {}, struct {
        fn lessThan(_: void, a: [3]usize, b: [3]usize) bool {
            return a[0] < b[0];
        }
    }.lessThan);

    var groups = Map(usize, List(usize)).init(allocator);
    defer {
        var it = groups.valueIterator();
        while (it.next()) |list| {
            list.deinit(allocator);
        }
        groups.deinit();
    }

    var connections_made: usize = 0;
    const MAX_CONNECTIONS: usize = 1000;
    for (connected_matrix.items, 0..) |_, row_idx_new| {
        if (connections_made >= MAX_CONNECTIONS) break;
        const dis = connected_matrix.items[row_idx_new][0];
        const node1 = connected_matrix.items[row_idx_new][2];
        const node2 = connected_matrix.items[row_idx_new][1];

        if (row_idx_new == 0) {
            var group_maker = List(usize){};
            try group_maker.append(allocator, node1);
            try group_maker.append(allocator, node2);
            try groups.put(0, group_maker);
            connections_made += 1;
        } else {
            var group1: ?usize = null;
            var group2: ?usize = null;
            var it = groups.iterator();
            while (it.next()) |entry| {
                for (entry.value_ptr.items) |item| {
                    if (item == node1) group1 = entry.key_ptr.*;
                    if (item == node2) group2 = entry.key_ptr.*;
                }
            }
        }

        print("distance: {d} node1: {d} node2: {d} \n", .{ dis, node1, node2 });

        connections_made += 1;
    }

    print("\nTotal connections made: {}\n", .{connections_made});
}
// Useful stdlib functions
const sqrt = std.math.sqrt;
const pow = std.math.pow;
const tokenizeAny = std.mem.tokenizeAny;
const tokenizeSeq = std.mem.tokenizeSequence;
const tokenizeSca = std.mem.tokenizeScalar;
const splitAny = std.mem.splitAny;
const splitSeq = std.mem.splitSequence;
const splitSca = std.mem.splitScalar;
const indexOf = std.mem.indexOfScalar;
const indexOfAny = std.mem.indexOfAny;
const indexOfStr = std.mem.indexOfPosLinear;
const lastIndexOf = std.mem.lastIndexOfScalar;
const lastIndexOfAny = std.mem.lastIndexOfAny;
const lastIndexOfStr = std.mem.lastIndexOfLinear;
const trim = std.mem.trim;
const sliceMin = std.mem.min;
const sliceMax = std.mem.max;

const parseInt = std.fmt.parseInt;
const parseFloat = std.fmt.parseFloat;

const assert = std.debug.assert;

const sort = std.sort.block;
const asc = std.sort.asc;
const desc = std.sort.desc;
