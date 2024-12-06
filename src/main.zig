const std = @import("std");

const raylib = @cImport({
    @cInclude("raylib.h");
});

pub fn main() !void {
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
}
