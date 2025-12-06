const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const print = std.debug.print;

const data = @embedFile("data/day06.txt");

pub fn main() !void {
    var total_count: usize = 0;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const split_pos = comptime blk: {
        @setEvalBranchQuota(1000000);
        break :blk std.mem.indexOf(u8, data, "\n\n").?;
    };
    const numbers = comptime blk: {
        break :blk data[0..split_pos];
    };
    const multiples = comptime blk: {
        break :blk data[split_pos + 2 ..];
    };

    var buf: [multiples.len]u8 = undefined;
    var l: usize = 0;
    for (multiples) |c| {
        if (c != ' ') {
            buf[l] = c;
            l += 1;
        }
    }
    print("trimmed_multiples: {s}\n", .{buf[0..]});
    var lines = tokenizeAny(u8, numbers, "\n");
    var rows: usize = 0;
    var cols: usize = 0;
    while (lines.next()) |line| {
        if (cols == 0) cols = line.len;
        rows += 1;
    }

    const numbers_matrix = try allocator.alloc([]u8, rows);
    defer {
        for (numbers_matrix) |row| {
            allocator.free(row);
        }
        allocator.free(numbers_matrix);
    }

    for (numbers_matrix) |*row| {
        row.* = try allocator.alloc(u8, cols);
    }

    var lins2 = splitAny(u8, numbers, "\n");
    var index: usize = 0;
    while (lins2.next()) |line| {
        for (line, 0..) |c, col_idx| {
            if (c == ' ') {
                numbers_matrix[index][col_idx] = 0;
            } else {
                numbers_matrix[index][col_idx] = c - '0';
            }
        }
        index += 1;
    }

    // transpose
    const transposed = try allocator.alloc([]u8, cols);
    defer {
        for (transposed) |row| {
            allocator.free(row);
        }
        allocator.free(transposed);
    }

    for (transposed) |*row| {
        row.* = try allocator.alloc(u8, rows);
    }

    for (0..rows) |row_idx| {
        for (0..cols) |col_idx| {
            transposed[col_idx][row_idx] = numbers_matrix[row_idx][col_idx];
        }
    }

    for (transposed) |row| {
        for (row) |cell| {
            print("{any} ", .{cell});
        }
        print("\n", .{});
    }

    const matrike_new = try allocator.alloc([]u32, cols);
    defer {
        for (matrike_new) |row| {
            allocator.free(row);
        }
        allocator.free(matrike_new);
    }

    for (matrike_new) |*row| {
        row.* = try allocator.alloc(u32, rows);
    }

    var buff: [20]u8 = undefined;
    var int: usize = 0;
    var row_number: usize = 0;

    var line_counts_for_adding: usize = 0;
    var line_counts_for_multiplying: usize = 1;
    var next_row_idx: usize = 0;
    for (transposed) |row| {
        for (row) |cell| {
            if (cell != 0) {
                buff[int] = @intCast(cell + '0');
                int += 1;
            }
        }
        if (int > 0) {
            row_number = try parseInt(u32, buff[0..int], 10);
            int = 0;
            if (row_number != 0) {
                // print("==========\n", .{});
                // print("row_idx: {d}\n", .{next_row_idx});
                // print("buf: {c}\n", .{buf[next_row_idx]});
                if (buf[next_row_idx] == '*') {
                    // print("multiples{d} : {d}\n", .{ line_counts_for_multiplying, row_number });
                    line_counts_for_multiplying *= row_number;
                } else {
                    // print("adding{d} : {d}\n", .{ line_counts_for_adding, row_number });
                    line_counts_for_adding += row_number;
                }
            }
        } else {
            if (line_counts_for_multiplying > 1) {
                total_count += line_counts_for_multiplying;
                line_counts_for_multiplying = 1;
            }
            total_count += line_counts_for_adding;
            line_counts_for_adding = 0;

            next_row_idx += 1;
        }
    }
    if (line_counts_for_multiplying > 1) {
        total_count += line_counts_for_multiplying;
    }
    total_count += line_counts_for_adding;

    print("total_count: {d}\n", .{total_count});
}
// matrika
// [[1,2,3,0,3,2,8,0,0,5,1,0,6,4,0],
//  [0,4,5,0,6,4,0,0,3,8,7,0,2,3,0],
//  [0,0,6,0,9,8,0,0,2,1,5,0,3,1,4]]
//
// transponiranje
//
//
// matrika_2
//
// buff: [20]u8 = undefined;
// row_number: usize = 0;
// for matrix_transposed |row|
//   for row |cell|
//     if cell != 0
//       buffer[len] = cell
//       len += 1
//   row_number = try parseInt(u32, buffer[0..len], 10)
//   len = 0
//   if row_number != 0
//     matrika_2][][]= row_number
//
//

fn part1() void {
    var total_count: usize = 0;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const split_pos = comptime blk: {
        @setEvalBranchQuota(1000000);
        break :blk std.mem.indexOf(u8, data, "\n\n").?;
    };
    const numbers = comptime blk: {
        break :blk data[0..split_pos];
    };
    const multiples = comptime blk: {
        break :blk data[split_pos + 2 ..];
    };

    var buf: [multiples.len]u8 = undefined;
    var l: usize = 0;
    for (multiples) |c| {
        if (c != ' ') {
            buf[l] = c;
            l += 1;
        }
    }
    print("trimmed_multiples: {s}\n", .{buf[0..]});

    var lines = tokenizeAny(u8, numbers, "\n");
    var rows: usize = 0;
    var cols: usize = 0;
    while (lines.next()) |line| {
        const trimmed = std.mem.trim(u8, line, " \r");
        if (trimmed.len == 0) continue;
        if (cols == 0) {
            var num_iter = tokenizeAny(u8, trimmed, " ");
            while (num_iter.next()) |_| {
                cols += 1;
            }
        }

        rows += 1;
    }

    const numbers_matrix = try allocator.alloc([]u32, rows);
    defer {
        for (numbers_matrix) |row| {
            allocator.free(row);
        }
        allocator.free(numbers_matrix);
    }

    for (numbers_matrix) |*row| {
        row.* = try allocator.alloc(u32, cols);
    }

    var lins2 = splitAny(u8, numbers, "\n");
    var index: usize = 0;
    var buffer: [20]u8 = undefined;
    var len: usize = 0;
    while (lins2.next()) |line| {
        const trimmed_line = trim(u8, line, " ");
        if (trimmed_line.len == 0) continue;
        var col_idx: usize = 0;
        for (trimmed_line) |c| {
            if (c == ' ') {
                if (len > 0) {
                    print("c: {s}\n", .{buffer[0..len]});
                    const num = try parseInt(u32, buffer[0..len], 10);
                    numbers_matrix[index][col_idx] = num;
                    col_idx += 1;
                    len = 0;
                }
            } else {
                buffer[len] = c;
                len += 1;
            }
        }
        if (len > 0) {
            const num = try parseInt(u32, buffer[0..len], 10);
            numbers_matrix[index][col_idx] = num;
            len = 0;
        }
        index += 1;
    }

    // transpose
    const transposed = try allocator.alloc([]u32, cols);
    defer {
        for (transposed) |row| {
            allocator.free(row);
        }
        allocator.free(transposed);
    }

    for (transposed) |*row| {
        row.* = try allocator.alloc(u32, rows);
    }

    for (0..rows) |row_idx| {
        for (0..cols) |col_idx| {
            transposed[col_idx][row_idx] = numbers_matrix[row_idx][col_idx];
        }
    }

    var line_counts_for_adding: usize = 0;
    var line_counts_for_multiplying: usize = 1;
    for (transposed, 0..) |row, col_idx| {
        for (row) |cell| {
            if (buf[col_idx] == '*') {
                line_counts_for_multiplying *= cell;
            } else {
                line_counts_for_adding += cell;
            }
        }
        if (line_counts_for_multiplying > 1) {
            total_count += line_counts_for_multiplying;
            line_counts_for_multiplying = 1;
        }
        total_count += line_counts_for_adding;
        line_counts_for_adding = 0;
    }
    print("total_count: {d}\n", .{total_count});
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
