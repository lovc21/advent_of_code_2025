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

    const connected_matrix = try allocator.alloc([3]usize, rows);
    defer allocator.free(connected_matrix);

    var distances: f64 = 0;
    var best_row: usize = 0;
    for (numbers_matrix, 0..) |row, current_idx| {
        var min_distance: f64 = std.math.floatMax(f64);

        // Euclidean distance
        for (0..rows, 0..) |index_of_row, other_idx| {
            if (current_idx == other_idx) continue;
            const dx = @as(f64, @floatFromInt(row[0] - numbers_matrix[index_of_row][0]));
            const dy = @as(f64, @floatFromInt(row[1] - numbers_matrix[index_of_row][1]));
            const dz = @as(f64, @floatFromInt(row[2] - numbers_matrix[index_of_row][2]));

            distances = sqrt(dz * dz + dy * dy + dx * dx);

            if (distances < min_distance) {
                min_distance = distances;
                best_row = index_of_row;
            }
        }
        print("=====================================================================\n", .{});
        print("lookin in row {d} \n", .{current_idx + 1});
        print("best row {d} \n", .{best_row + 1});
        print("{d} \n", .{min_distance});
        connected_matrix[current_idx][0] = @intFromFloat(min_distance);
        connected_matrix[current_idx][1] = best_row + 1;
        connected_matrix[current_idx][2] = current_idx + 1;
    }
    print("=====================================================================\n", .{});

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
    var number_of_groups: usize = 0;
    for (connected_matrix, 0..) |_, row_idx_new| {
        if (connections_made >= MAX_CONNECTIONS) break;

        const node1 = connected_matrix[row_idx_new][2];
        const node2 = connected_matrix[row_idx_new][1];

        var group1: ?usize = null;
        var group2: ?usize = null;

        var it = groups.iterator();
        while (it.next()) |entry| {
            for (entry.value_ptr.items) |item| {
                if (item == node1) group1 = entry.key_ptr.*;
                if (item == node2) group2 = entry.key_ptr.*;
            }
        }

        if (group1 != null and group2 != null and group1.? == group2.?) {
            continue;
        }

        connections_made += 1;

        if (group1 != null and group2 != null) {
            var list1 = groups.getPtr(group1.?).?;
            const list2 = groups.getPtr(group2.?).?;

            for (list2.items) |item| {
                var exists = false;
                for (list1.items) |existing| {
                    if (existing == item) {
                        exists = true;
                        break;
                    }
                }
                if (!exists) try list1.append(allocator, item);
            }

            var g2_list = groups.fetchRemove(group2.?).?.value;
            g2_list.deinit(allocator);
        } else if (group1) |g1| {
            var list = groups.getPtr(g1).?;
            try list.append(allocator, node2);
        } else if (group2) |g2| {
            var list = groups.getPtr(g2).?;
            try list.append(allocator, node1);
        } else {
            var group_maker = List(usize){};
            try group_maker.append(allocator, node1);
            try group_maker.append(allocator, node2);
            number_of_groups += 1;
            try groups.put(number_of_groups, group_maker);
        }
    }

    print("\nTotal connections made: {}\n", .{connections_made});

    var it = groups.iterator();
    while (it.next()) |entry| {
        std.debug.print("Group {}: ", .{entry.key_ptr.*});
        for (entry.value_ptr.items) |member| {
            std.debug.print("{} ", .{member});
        }
        std.debug.print("\n", .{});
    }

    // Euclidean distance
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
