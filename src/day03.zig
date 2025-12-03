const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const print = std.debug.print;

const data = @embedFile("data/day03.txt");

pub fn main() !void {
    var count: usize = 0;
    var lins = splitAny(u8, data, ",\n");
    while (lins.next()) |line| {
        const trimmed_line = trim(u8, line, " ");
        if (trimmed_line.len == 0) continue;
        var bigest_number: usize = 0;

        // finde the first bigest number
        var number_location: usize = 0;
        var max_number: usize = 0;

        for (trimmed_line, 0..) |c, i| {
            const digit = c - '0';
            if (digit > max_number) {
                max_number = digit;
                number_location = i;
            }
        }

        print("---------------- \n", .{});
        print("number_location: {}\n", .{number_location});
        print("max_number: {}\n", .{max_number});

        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        defer _ = gpa.deinit();
        const allocator = gpa.allocator();

        var mutable_line = try allocator.alloc(u8, trimmed_line.len);
        defer allocator.free(mutable_line);
        @memcpy(mutable_line, trimmed_line);

        mutable_line[number_location] = '0';
        print("c: {s}\n", .{mutable_line});

        // finde the first bigest number left of the number_location
        var second_number_location: usize = 0;
        var second_max_number: usize = 0;
        for (mutable_line[0..number_location], 0..) |c, i| {
            const digit = c - '0';
            if (digit > second_max_number) {
                second_max_number = digit;
                second_number_location = i;
            }
        }

        // fine the first bigest number right of the number_location
        var third_number_location: usize = 0;
        var third_max_number: usize = 0;
        for (mutable_line[number_location + 1 ..], 0..) |c, i| {
            const digit = c - '0';
            if (digit > third_max_number) {
                third_max_number = digit;
                third_number_location = i;
            }
        }

        print("third_max_number: {d}\n", .{third_max_number});
        print("third_number_location: {d}\n", .{third_number_location});

        print("second_max_number: {d}\n", .{second_max_number});
        print("second_number_location: {d}\n", .{second_number_location});

        const left_number = second_max_number * 10 + max_number;
        const right_number = max_number * 10 + third_max_number;

        if (third_max_number == 0) {
            bigest_number = left_number;
        } else if (second_max_number == 0) {
            bigest_number = right_number;
        } else if (left_number > right_number) {
            bigest_number = left_number;
        } else {
            bigest_number = right_number;
        }

        print("---------------------- \n", .{});

        print("bigest_number: {d}\n", .{bigest_number});
        print("----------------------", .{});
        // finde the first bigest number
        count += bigest_number;
    }
    print("count: {d} \n", .{count});
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
