const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const print = std.debug.print;

const data = @embedFile("data/day02.txt");

// build whit zig build day02 --release=fast -Dcpu=znver1 -Dtarget=x86_64-linux if not its slow as fuck

pub fn main() !void {
    var count: usize = 0;
    var lins = tokenizeAny(u8, data, ",\n");
    while (lins.next()) |line| {
        var range = tokenizeAny(u8, line, "-");
        const start = try parseInt(usize, range.next().?, 10);
        const end = try parseInt(usize, range.next().?, 10);
        for (start..end + 1) |i| {
            const max_len = 10000000;
            var buf: [max_len]u8 = undefined;
            const numAsString = try std.fmt.bufPrint(&buf, "{}", .{i});

            // part 1
            // check if all chars are the same
            // var allSame = true;
            // for (numAsString) |c| {
            //     if (numAsString[0] != c) {
            //         allSame = false;
            //         break;
            //     }
            // }
            //
            // if (allSame) {
            //     print(" napacen ID je {s}\n", .{numAsString});
            //     count += try parseInt(usize, numAsString, 10);
            //     continue;
            // }
            // else if (numAsString.len % 2 == 0) {
            //     // chek for repeated chars in the middle
            //     const stringlen: usize = numAsString.len / 2;
            //     const firstpart = numAsString[0..stringlen];
            //     const secondpart = numAsString[stringlen..];
            //     if (std.mem.eql(u8, firstpart, secondpart)) {
            //         count += try parseInt(usize, numAsString, 10);
            //         print(" napacen ID je {s}\n", .{numAsString});
            //     }
            // } else {
            //
            // }
            //

            // part 2
            for (2..numAsString.len + 1) |j| {
                if (numAsString.len % j != 0) { // 10 % 2 != 0 False
                    continue;
                }

                var thesame = true;
                const chunk_size = numAsString.len / j; // 10 / 2 = 5
                const prvi = numAsString[0..chunk_size]; // 0 do 5 = 21212
                for (0..numAsString.len / chunk_size) |c| { // 0 1
                    const chunk = numAsString[c * chunk_size .. c * chunk_size + chunk_size]; // 21212
                    // print("MY moving chunk is {s}\n", .{chunk});
                    if (std.mem.eql(u8, prvi, chunk)) {} else {
                        thesame = false;
                        break;
                    }
                }
                if (thesame) {
                    count += try parseInt(usize, numAsString, 10);
                    // print(" napacen ID je {s}\n", .{numAsString});
                    break;
                }
            }
            // print(" number je {s}\n", .{numAsString});
        }

        // print("start: {}\n", .{start});
        // print("end: {}\n", .{end});
    }
    print("count je {d} \n", .{count});
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
