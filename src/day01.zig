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
    const list = List(i32).initBuffer(&buffer);
    _ = list;

    const starting_number: i32 = 50;
    var sum: i32 = 0;
    var count: i32 = 0;
    var index: i32 = 0;
    var lins = splitAny(u8, data, "\n");
    while (lins.next()) |line| {
        const trimmed_line = trim(u8, line, " ");
        if (trimmed_line.len == 0) continue;
        const first_letters = trimmed_line[0];
        var number = try parseInt(i32, trimmed_line[1..], 10);

        // edge case number can be bigger than 100
        if (number > 100) {
            const div = @divTrunc(number, 100);
            number = number - div * 100;
            count += div;
        }

        if (index == 0) {
            if (first_letters == 76) {
                sum = starting_number - number;
            } else {
                sum = starting_number + number;
            }
        } else {
            if (first_letters == 76) {
                if (sum == 0) {
                    sum = 100;
                }
                sum -= number;
            } else {
                if (sum == 100) {
                    sum = 0;
                }
                sum += number;
            }
        }
        print("-----index: {}----\n", .{index});

        if (sum == 100 or sum == 0) {
            count += 1;
            print("click 0 \n", .{});
        } else if (sum < 0) {
            count += 1;
            print("clickminus \n", .{});
            sum = sum + 100;
        } else if (sum > 99) {
            sum = sum - 100;
            count += 1;
            print("click \n", .{});
        }
        print("number {}\n", .{number});
        print("sum: {}\n", .{sum});
        index += 1;
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
