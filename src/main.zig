const std = @import("std");
const game = @import("game.zig");
const raylib = @cImport({
    @cInclude("raylib.h");
});

pub fn main() !void {
    raylib.InitWindow(1200, 900, "Coal Clicker");
    raylib.SetTargetFPS(60);

    var gameLoop = game.init();
    try gameLoop.load();

    while (!raylib.WindowShouldClose()) {
        try gameLoop.tick(raylib.GetFrameTime());
        raylib.BeginDrawing();
        raylib.ClearBackground(raylib.RAYWHITE);
        try gameLoop.draw();
        raylib.EndDrawing();
    }

    gameLoop.save();
    raylib.CloseWindow();

    return;
}
