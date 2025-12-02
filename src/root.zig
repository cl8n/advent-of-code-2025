const std = @import("std");

pub const puzzles = [_]fn (std.mem.Allocator, *std.io.Writer) anyerror!void{
    @import("days/1.zig").run,
    @import("days/2.zig").run,
};
