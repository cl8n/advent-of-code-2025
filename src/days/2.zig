const std = @import("std");
const puzzle = @import("../puzzle.zig");

pub fn run(allocator: std.mem.Allocator, output: *std.io.Writer) !void {
    const input = try puzzle.downloadAndCachePuzzle(allocator, "https://adventofcode.com/2025/day/2/input");
    defer allocator.free(input);

    try part1(input, output);
    try part2(input, output);
}

fn part1(input: []const u8, output: *std.io.Writer) !void {
    var invalid_id_sum: u64 = 0;

    var product_range_iterator = std.mem.tokenizeAny(u8, input, ",\n");
    while (product_range_iterator.next()) |range| {
        var id_iterator = std.mem.splitScalar(u8, range, '-');

        const first_id = try std.fmt.parseUnsigned(u64, id_iterator.next().?, 10);
        const last_id = try std.fmt.parseUnsigned(u64, id_iterator.next().?, 10);

        var id = first_id;
        while (id <= last_id) : (id += 1) {
            const digit_count = std.math.log10(id) + 1;

            if (digit_count % 2 != 0) {
                continue;
            }

            const low_digits = id % std.math.pow(u64, 10, digit_count / 2);
            const high_digits = id / std.math.pow(u64, 10, digit_count / 2);

            if (low_digits == high_digits) {
                invalid_id_sum += id;
            }
        }
    }

    try output.print("{d}\n", .{invalid_id_sum});
}

fn part2(input: []const u8, output: *std.io.Writer) !void {
    var invalid_id_sum: u64 = 0;

    var product_range_iterator = std.mem.tokenizeAny(u8, input, ",\n");
    while (product_range_iterator.next()) |range| {
        var id_iterator = std.mem.splitScalar(u8, range, '-');

        const first_id = try std.fmt.parseUnsigned(u64, id_iterator.next().?, 10);
        const last_id = try std.fmt.parseUnsigned(u64, id_iterator.next().?, 10);

        var id = first_id;
        id_loop: while (id <= last_id) : (id += 1) {
            const full_digit_count = std.math.log10(id) + 1;

            var digit_count: u64 = 1;
            while (digit_count <= full_digit_count / 2) : (digit_count += 1) {
                if (full_digit_count % digit_count != 0) {
                    continue;
                }

                const power_of_10 = std.math.pow(u64, 10, digit_count);
                const first_low_digits = id % power_of_10;

                var id_remaining = id;
                while (id_remaining > 0) : (id_remaining /= power_of_10) {
                    if (first_low_digits != id_remaining % power_of_10) {
                        break;
                    }
                } else {
                    // All iterations of low digits matched
                    invalid_id_sum += id;
                    continue :id_loop;
                }
            }
        }
    }

    try output.print("{d}\n", .{invalid_id_sum});
}
