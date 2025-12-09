const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const print = std.debug.print;

const data = @embedFile("data/day09.txt");

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

    const numbers_matrix = try allocator.alloc([2]u32, rows);
    defer allocator.free(numbers_matrix);

    var lines2 = tokenizeAny(u8, data, "\n");
    var row_idx: usize = 0;
    while (lines2.next()) |line2| {
        var numbers = std.mem.tokenizeAny(u8, line2, ",");
        var col_idx: usize = 0;

        while (numbers.next()) |num_str| {
            const num = try std.fmt.parseInt(u32, num_str, 10);
            numbers_matrix[row_idx][col_idx] = num;
            col_idx += 1;
        }
        row_idx += 1;
    }

    print("x y\n", .{});
    for (numbers_matrix) |row| {
        for (row) |cell| {
            print("{d} ", .{cell});
        }
        print("\n", .{});
    }
    var point_x: u32 = 0;
    var point_y: u32 = 0;
    var point_x2: u32 = 0;
    var point_y2: u32 = 0;
    var global_area: f64 = 0;
    for (numbers_matrix, 0..) |row, row_index| {
        var local_area: f64 = 0;
        for (0..rows, 0..) |index_of_row, second_index| {
            if (row_index == second_index) continue; // skip self
            const third_point_x = numbers_matrix[index_of_row][0];
            const third_point_y = row[1];
            const x1 = @as(f64, @floatFromInt(row[0]));
            const y1 = @as(f64, @floatFromInt(row[1]));
            const x2 = @as(f64, @floatFromInt(numbers_matrix[index_of_row][0]));
            const y2 = @as(f64, @floatFromInt(numbers_matrix[index_of_row][1]));
            const x3 = @as(f64, @floatFromInt(third_point_x));
            const y3 = @as(f64, @floatFromInt(third_point_y));

            const dx = x2 - x1;
            const dy = y2 - y1;
            const dx2 = x3 - x1;
            const dy2 = y3 - y1;

            const length = sqrt(dx * dx + dx2 * dx2);
            const widht = sqrt(dy * dy + dy2 * dy2);

            local_area = length * widht;
            if (local_area > global_area) {
                global_area = local_area;
                point_x = row[0];
                point_y = row[1];

                point_x2 = numbers_matrix[index_of_row][0];
                point_y2 = numbers_matrix[index_of_row][1];
            }
        }
    }
    print("point one {d} {d} \n", .{ point_x, point_y });
    print("point two {d} {d} \n", .{ point_x2, point_y2 });
    const global_area_int: u64 = @intFromFloat(global_area);
    print("global_area: {d} \n", .{global_area_int});
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
