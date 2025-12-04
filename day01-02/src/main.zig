const std = @import("std");
const puzzles = @import("advent_of_code_2025").puzzles;

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const writer = &stdout_writer.interface;

    inline for (puzzles, 1..) |puzzle, day| {
        try writer.print("Day {d}:\n", .{day});
        try puzzle(allocator, writer);

        if (day < puzzles.len) {
            try writer.writeByte('\n');
        }
    }

    try stdout_writer.end();
}
