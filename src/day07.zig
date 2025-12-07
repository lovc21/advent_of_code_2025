const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const print = std.debug.print;

const data = @embedFile("data/day07.txt");

pub fn main() !void {
    var total_count: usize = 0;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var lines = tokenizeAny(u8, data, "\n");
    var rows: usize = 0;
    var cols: usize = 0;
    while (lines.next()) |line| {
        if (cols == 0) cols = line.len;
        rows += 1;
    }

    print("rows: {}\n", .{rows});

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

    var lins = splitAny(u8, data, "\n");
    var index: usize = 0;
    while (lins.next()) |line| {
        for (line, 0..) |c, col_idx| {
            numbers_matrix[index][col_idx] = c;
        }
        index += 1;
    }

    const sum_matrix = try allocator.alloc([]u64, rows);
    defer {
        for (sum_matrix) |row| {
            allocator.free(row);
        }
        allocator.free(sum_matrix);
    }

    for (sum_matrix) |*row| {
        row.* = try allocator.alloc(u64, cols);
        @memset(row.*, 0);
    }

    for (numbers_matrix, 0..) |row, row_idx| {
        for (row, 0..) |cell, col_idx| {
            // check for ^
            if (cell == '^') {
                if (row_idx > 0 and numbers_matrix[row_idx - 1][col_idx] == '|') {
                    numbers_matrix[row_idx][col_idx - 1] = '|';
                    numbers_matrix[row_idx][col_idx + 1] = '|';
                    total_count += 1;
                }
                // check up for S and |
            } else if (row_idx > 0 and (numbers_matrix[row_idx - 1][col_idx] == 'S' or numbers_matrix[row_idx - 1][col_idx] == '|')) {
                numbers_matrix[row_idx][col_idx] = '|';
            }
        }
    }

    print("1 2 3 4 5 6 7 8 9 1 1 2 3 4 5 6\n", .{});
    for (numbers_matrix) |row| {
        for (row) |cell| {
            print("{c} ", .{cell});
        }
        print("\n", .{});
    }

    print("total_count: {d} \n", .{total_count});

    // . . . . . . . S . . . . . . .
    // . . . . . . . | . . . . . . . 1
    // . . . . . . | ^ | . . . . . . 1 1
    // . . . . . . | . | . . . . . . 1 1
    // . . . . . | ^ | ^ | . . . . . 1 2 1
    // . . . . . | . | . | . . . . . 1 2 1
    // . . . . | ^ | ^ | ^ | . . . . 1 3 3 1
    // . . . . | . | . | . | . . . .
    // . . . | ^ | ^ | | | ^ | . . .
    //
    for (numbers_matrix, 0..) |row, row_idx| {
        for (row, 0..) |cell, col_idx| {
            if (cell == 'S') {
                sum_matrix[row_idx][col_idx] = 1;
            }
        }
    }

    for (numbers_matrix, 0..) |row, row_idx| {
        for (row, 0..) |cell, col_idx| {
            if (cell == '|' and row_idx > 0) {
                // check up
                if (sum_matrix[row_idx - 1][col_idx] > 0) {
                    sum_matrix[row_idx][col_idx] += sum_matrix[row_idx - 1][col_idx];
                }

                // check left
                if (col_idx > 0 and numbers_matrix[row_idx - 1][col_idx - 1] == '^') {
                    sum_matrix[row_idx][col_idx] += sum_matrix[row_idx - 1][col_idx - 1];
                }

                // check right
                if (col_idx + 1 < cols and numbers_matrix[row_idx - 1][col_idx + 1] == '^') {
                    sum_matrix[row_idx][col_idx] += sum_matrix[row_idx - 1][col_idx + 1];
                }
            } else if (cell == '^' and row_idx > 0) {
                // check up
                if (sum_matrix[row_idx - 1][col_idx] > 0) {
                    sum_matrix[row_idx][col_idx] = sum_matrix[row_idx - 1][col_idx];
                }
            }
        }
    }
    var total_count_2: usize = 0;
    for (sum_matrix[rows - 1]) |cell| {
        total_count_2 += cell;
    }
    print("total_count_2: {d} \n", .{total_count_2});
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
