const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const print = std.debug.print;

const data = @embedFile("data/day01.txt");

pub fn main() !void {
    var buffer: [8]i32 = undefined;
    const lint = List(i32).initBuffer(&buffer);
    _ = lint;
    var lins = splitAny(u8, data, "\n");
    while (lins.next()) |line| {
        const trimmed_line = trim(u8, line, " ");
        if (trimmed_line.len == 0) continue;
        var token = tokenizeAny(u8, trimmed_line, "\t");
        while (token.next()) |token_line| {
            const first_letters = try parseFloat(f32, token_line);
            if (first_letters == "L") {
                print("{s}\n", .{trimmed_line});
            } else {
                print("{s}\n", .{trimmed_line});
            }
        }
    }
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
