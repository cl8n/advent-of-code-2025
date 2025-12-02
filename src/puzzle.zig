const std = @import("std");
const base64_encoder = std.base64.url_safe_no_pad.Encoder;

pub fn downloadAndCachePuzzle(allocator: std.mem.Allocator, comptime url: []const u8) ![]u8 {
    var filename_buffer: [base64_encoder.calcSize(url.len)]u8 = undefined;
    const filename = base64_encoder.encode(&filename_buffer, url);

    return std.fs.cwd().readFileAlloc(allocator, filename, std.math.maxInt(usize)) catch {
        const puzzle = try downloadPuzzle(allocator, url);

        try std.fs.cwd().writeFile(.{
            .data = puzzle,
            .sub_path = filename,
        });

        return puzzle;
    };
}

fn downloadPuzzle(allocator: std.mem.Allocator, url: []const u8) ![]u8 {
    var client: std.http.Client = .{ .allocator = allocator };
    defer client.deinit();

    var response_allocating_writer: std.io.Writer.Allocating = .init(allocator);
    defer response_allocating_writer.deinit();

    var session_buffer: [256]u8 = undefined;
    const session = std.mem.trim(
        u8,
        try std.fs.cwd().readFile("session", &session_buffer),
        " \n",
    );

    const result = try client.fetch(.{
        .location = .{ .url = url },
        .response_writer = &response_allocating_writer.writer,
        .extra_headers = &.{
            .{ .name = "Cookie", .value = session },
        },
    });

    if (result.status.class() != .success) {
        std.debug.print("{d}\n", .{result.status});
        std.debug.print("{s}\n", .{try response_allocating_writer.toOwnedSlice()});
        return error.PuzzleInputDownloadFailed;
    }

    return response_allocating_writer.toOwnedSlice();
}
