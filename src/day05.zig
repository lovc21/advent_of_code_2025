const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const print = std.debug.print;

const data = @embedFile("data/day05.txt");

pub fn main() !void {
    var total_count: usize = 0;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const split_pos = std.mem.indexOf(u8, data, "\n\n").?;
    const numbers = data[split_pos + 2 ..];

    // print("puzzle_input part two: {s}\n", .{numbers});
    var numbers_list = std.ArrayList(u64){};
    defer numbers_list.deinit(allocator);

    var lines = tokenizeAny(u8, numbers, "\n");
    while (lines.next()) |line| {
        const trimmed = std.mem.trim(u8, line, " \r");
        if (trimmed.len == 0) continue;
        try numbers_list.append(allocator, try parseInt(u64, trimmed, 10));
    }

    // print("puzzle_input part one: {s}\n", .{ranges});
    const row_count = comptime blk: {
        @setEvalBranchQuota(1000000);
        var count: usize = 0;
        var iter = tokenizeAny(u8, data[0..std.mem.indexOf(u8, data, "\n\n").?], "\n");
        while (iter.next()) |_| count += 1;
        break :blk count;
    };

    const matrix_ranges = comptime blk: {
        var result: [row_count][2]u64 = undefined;
        const ranges_str = data[0..std.mem.indexOf(u8, data, "\n\n").?];
        var iter = tokenizeAny(u8, ranges_str, "\n");
        var idx: usize = 0;
        while (iter.next()) |line| : (idx += 1) {
            const split = std.mem.indexOf(u8, line, "-").?;
            result[idx][0] = parseInt(u64, line[0..split], 10) catch unreachable;
            result[idx][1] = parseInt(u64, line[split + 1 ..], 10) catch unreachable;
        }

        var i: usize = 0;
        while (i < row_count) : (i += 1) {
            var j: usize = 0;
            while (j < row_count - 1 - i) : (j += 1) {
                if (result[j][0] > result[j + 1][0]) {
                    const tmp = result[j];
                    result[j] = result[j + 1];
                    result[j + 1] = tmp;
                }
            }
        }

        var result2: [row_count][2]u64 = undefined;
        var write_idx: usize = 0;
        var current = result[0];

        var j: usize = 1;
        while (j < row_count) : (j += 1) {
            if (result[j][0] <= current[1] + 1) {
                current[1] = @max(current[1], result[j][1]);
            } else {
                result2[write_idx] = current;
                write_idx += 1;
                current = result[j];
            }
        }

        result2[write_idx] = current;
        write_idx += 1;
        break :blk .{
            .original = result,
            .merged = result2[0..write_idx].*,
        };
    };
    const matrix_ranges_original = matrix_ranges.original;
    const matrix_ranges_merged = matrix_ranges.merged;

    for (numbers_list.items) |n| {
        if (isInRange(&matrix_ranges_original, n)) {
            print("Number {d} is a fresh number!\n", .{n});
            total_count += 1;
        }
    }
    print("Total count: {d}\n", .{total_count});

    const number_of_fresh: u64 = numberOfFresh(&matrix_ranges_merged);
    print("Number of fresh numbers: {d}\n", .{number_of_fresh});
}

fn isInRange(comptime ranges: []const [2]u64, n: u64) bool {
    for (ranges) |range| {
        if (n >= range[0] and n <= range[1]) return true;
    }
    return false;
}

fn numberOfFresh(comptime ranges: []const [2]u64) u64 {
    var total: u64 = 0;
    for (ranges) |range| {
        total += range[1] - range[0] + 1;
        print("{d}-{d}  \n", .{ range[0], range[1] });
    }
    return total;
}

// Useful stdlib functions
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
