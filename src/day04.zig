const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const print = std.debug.print;

const data = @embedFile("data/day04.txt");

// build whit zig build day02 --release=fast -Dcpu=znver1 -Dtarget=x86_64-linux if not its slow as fuck

pub fn main() !void {
    // build a matrix
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var lins = tokenizeAny(u8, data, ",\n");

    var rows: usize = 0;
    var cols: usize = 0;
    while (lins.next()) |line| {
        const trimmed = std.mem.trim(u8, line, " \r");
        if (trimmed.len == 0) continue;
        if (cols == 0) cols = trimmed.len;
        rows += 1;
    }

    // create matrix
    var matrix = try allocator.alloc([]u8, rows);
    defer {
        for (matrix) |row| {
            allocator.free(row);
        }
        allocator.free(matrix);
    }

    for (matrix) |*row| {
        row.* = try allocator.alloc(u8, cols);
    }

    // create matrix2
    const matrix2 = try allocator.alloc([]u8, rows);
    defer {
        for (matrix2) |row| {
            allocator.free(row);
        }
        allocator.free(matrix2);
    }
    for (matrix2) |*row| {
        row.* = try allocator.alloc(u8, cols);
    }

    // fill matrix
    var lins2 = splitAny(u8, data, "\n");
    var row_idx: usize = 0;
    while (lins2.next()) |line| {
        const trimmed_line = trim(u8, line, " ");
        if (trimmed_line.len == 0) continue;

        for (trimmed_line, 0..) |c, colom_index| {
            if (c == '@') {
                matrix[row_idx][colom_index] = 1;
            } else {
                matrix[row_idx][colom_index] = 0;
            }
            matrix2[row_idx][colom_index] = 0;
        }
        row_idx += 1;
    }

    const total: usize = remove(matrix, matrix2, cols, rows);
    print("total: {}\n", .{total});
}

fn remove(matrix: [][]u8, matrix2: [][]u8, cols: usize, rows: usize) usize {
    var count: usize = 0;

    for (matrix, 0..) |row, row_idx| {
        for (row, 0..) |_, col| {
            matrix2[row_idx][col] = 0;
        }
    }

    for (matrix, 0..) |row, j| {
        for (row, 0..) |cell, i| {
            if (cell == 1) {
                var ATcount: usize = 0;

                // check right
                if (i + 1 < cols and matrix[j][i + 1] == 1) {
                    ATcount += 1;
                }
                // check left
                if (i > 0 and matrix[j][i - 1] == 1) {
                    ATcount += 1;
                }

                // check up
                if (j > 0 and matrix[j - 1][i] == 1) {
                    ATcount += 1;
                }
                // check down
                if (j + 1 < rows and matrix[j + 1][i] == 1) {
                    ATcount += 1;
                }

                // check diagonal
                if (j > 0 and i > 0 and matrix[j - 1][i - 1] == 1) {
                    ATcount += 1;
                }
                if (j > 0 and i + 1 < cols and matrix[j - 1][i + 1] == 1) {
                    ATcount += 1;
                }
                if (j + 1 < rows and i > 0 and matrix[j + 1][i - 1] == 1) {
                    ATcount += 1;
                }
                if (j + 1 < rows and i + 1 < cols and matrix[j + 1][i + 1] == 1) {
                    ATcount += 1;
                }
                if (ATcount < 4) {
                    count += 1;
                    matrix2[j][i] = 0;
                } else {
                    matrix2[j][i] = 1;
                }
            }
        }
    }

    // break the recursion
    if (count == 0) {
        return 0;
    }

    for (matrix2, 0..) |src_row, row_idx| {
        @memcpy(matrix[row_idx], src_row);
    }

    return count + remove(matrix, matrix2, cols, rows);
}

fn part1() void {
    var count: usize = 0;

    // build a matrix
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var lins = tokenizeAny(u8, data, ",\n");

    var rows: usize = 0;
    var cols: usize = 0;
    while (lins.next()) |line| {
        const trimmed = std.mem.trim(u8, line, " \r");
        if (trimmed.len == 0) continue;
        if (cols == 0) cols = trimmed.len;
        rows += 1;
    }

    var matrix = try allocator.alloc([]u8, rows);
    defer {
        for (matrix) |row| {
            allocator.free(row);
        }
        allocator.free(matrix);
    }

    for (matrix) |*row| {
        row.* = try allocator.alloc(u8, cols);
    }

    var lins2 = splitAny(u8, data, "\n");
    var row_idx: usize = 0;
    while (lins2.next()) |line| {
        const trimmed_line = trim(u8, line, " ");
        if (trimmed_line.len == 0) continue;

        for (trimmed_line, 0..) |c, colom_index| {
            if (c == '@') {
                matrix[row_idx][colom_index] = 1;
            } else {
                matrix[row_idx][colom_index] = 0;
            }
        }
        row_idx += 1;
    }

    for (matrix) |row| {
        for (row) |cell| {
            print("{any} ", .{cell});
        }
        print("\n", .{});
    }

    print("=====================================================================\n", .{});

    for (matrix, 0..) |row, j| {
        for (row, 0..) |cell, i| {
            if (cell == 1) {
                var ATcount: usize = 0;

                // check right
                if (i + 1 < cols and matrix[j][i + 1] == 1) {
                    ATcount += 1;
                }
                // check left
                if (i > 0 and matrix[j][i - 1] == 1) {
                    ATcount += 1;
                }

                // check up
                if (j > 0 and matrix[j - 1][i] == 1) {
                    ATcount += 1;
                }
                // check down
                if (j + 1 < rows and matrix[j + 1][i] == 1) {
                    ATcount += 1;
                }

                // check diagonal
                if (j > 0 and i > 0 and matrix[j - 1][i - 1] == 1) {
                    ATcount += 1;
                }
                if (j > 0 and i + 1 < cols and matrix[j - 1][i + 1] == 1) {
                    ATcount += 1;
                }
                if (j + 1 < rows and i > 0 and matrix[j + 1][i - 1] == 1) {
                    ATcount += 1;
                }
                if (j + 1 < rows and i + 1 < cols and matrix[j + 1][i + 1] == 1) {
                    ATcount += 1;
                }
                print("========= \n", .{});
                print("ATcount: {}\n", .{ATcount});
                if (ATcount < 4) {
                    count += 1;
                }
            }
        }
    }

    print("count: {}\n", .{count});
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
