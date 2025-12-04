const std = @import("std");
const puzzle = @import("../puzzle.zig");

pub fn run(allocator: std.mem.Allocator, output: *std.io.Writer) !void {
    const input = try puzzle.downloadAndCachePuzzle(allocator, "https://adventofcode.com/2025/day/1/input");
    defer allocator.free(input);

    try part1(input, output);
    try part2(input, output);
}

fn part1(input: []const u8, output: *std.io.Writer) !void {
    var dial: i16 = 50;
    var times_hit_zero: u32 = 0;

    var line_iterator = std.mem.splitScalar(u8, input, '\n');
    while (line_iterator.next()) |line| {
        if (line.len < 2) {
            continue;
        }

        const direction: i16 = switch (line[0]) {
            'L' => -1,
            'R' => 1,
            else => continue,
        };
        const amount = try std.fmt.parseUnsigned(i16, line[1..], 10);

        dial = @mod(dial + direction * amount, 100);

        if (dial == 0) {
            times_hit_zero += 1;
        }
    }

    try output.print("{d}\n", .{times_hit_zero});
}

fn part2(input: []const u8, output: *std.io.Writer) !void {
    var dial: i16 = 50;
    var times_passed_zero: u32 = 0;

    var line_iterator = std.mem.splitScalar(u8, input, '\n');
    while (line_iterator.next()) |line| {
        if (line.len < 2) {
            continue;
        }

        const direction: i16 = switch (line[0]) {
            'L' => -1,
            'R' => 1,
            else => continue,
        };
        var amount = try std.fmt.parseUnsigned(i16, line[1..], 10);

        while (amount >= 100) {
            times_passed_zero += 1;
            amount -= 100;
        }

        if (amount == 0) {
            continue;
        }

        if ((direction == 1 and dial + amount >= 100) or
            (direction == -1 and dial - amount <= 0 and dial != 0))
        {
            times_passed_zero += 1;
        }

        dial = @mod(dial + direction * amount, 100);
    }

    try output.print("{d}\n", .{times_passed_zero});
}
