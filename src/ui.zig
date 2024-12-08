const std = @import("std");
const raylib = @cImport({
    @cInclude("raylib.h");
});

const Base = struct {
    pos: raylib.Vector2,
    size: raylib.Vector2,
};

pub const Text = struct {
    base: Base,
    text: []const u8 = "",
    font: raylib.Font = undefined,
    fontSize: f32,
    color: raylib.Color,
    centered: bool,
    coalCounterBuf: [4096]u8 = undefined,

    pub fn Init(pos: raylib.Vector2, text: []const u8, font: raylib.Font, fontSize: f32, color: raylib.Color, centered: bool) Text {
        return .{ .base = .{ .pos = pos, .size = raylib.MeasureTextEx(font, text.ptr, fontSize, 0.0) }, .text = text, .font = font, .fontSize = fontSize, .color = color, .centered = centered };
    }

    pub fn Draw(self: *const Text) void {
        var offsetPosX = self.base.pos.x;
        var offsetPosY = self.base.pos.y;
        if (self.centered) {
            offsetPosX = self.base.pos.x - (self.base.size.x / 2);
            offsetPosY = self.base.pos.y - (self.base.size.y / 2);
        }
        raylib.DrawTextEx(self.font, self.text.ptr, raylib.Vector2{ .x = offsetPosX, .y = offsetPosY }, self.fontSize, 0.0, self.color);
    }

    pub fn SetText(self: *Text, number: f128) !void {
        const str = try std.fmt.bufPrintZ(&self.coalCounterBuf, "{d:.0}", .{number});
        self.text = str;
        self.base.size = raylib.MeasureTextEx(self.font, self.text.ptr, self.fontSize, 0.0);
    }
};

pub const Button = struct {
    base: Base,
    text: ?Text = null,
    background: ?raylib.Texture = null,
    pressed: bool = false,
    centered: bool = true,
    reboundTimer: f32 = 0.0,
    animationScale: f32 = 0.8,
    animationScaleValue: f32 = 1.0,

    pub fn Init(pos: raylib.Vector2, size: raylib.Vector2, centered: bool) Button {
        return .{
            .base = .{ .pos = pos, .size = size },
            .centered = centered,
        };
    }

    pub fn Tick(self: *Button, deltaTime: f32) void {
        _ = deltaTime;
        self.pressed = false;

        var offsetPosX = self.base.pos.x;
        var offsetPosY = self.base.pos.y;
        if (self.centered) {
            offsetPosX = self.base.pos.x - (self.base.size.x / 2);
            offsetPosY = self.base.pos.y - (self.base.size.y / 2);
        }

        const leftMouseDown = raylib.IsMouseButtonDown(raylib.MOUSE_BUTTON_LEFT);
        const leftMouseClicked = raylib.IsMouseButtonPressed(raylib.MOUSE_BUTTON_LEFT);
        //const rightMouseClicked = raylib.IsMouseButtonPressed(1);
        const mousePosition = raylib.GetMousePosition();
        const mouseInsideButton = ((mousePosition.x > offsetPosX and mousePosition.y > offsetPosY) and (mousePosition.x < offsetPosX + self.base.size.x and mousePosition.y < offsetPosY + self.base.size.y));
        if (mouseInsideButton and leftMouseClicked) {
            self.pressed = true;
        }

        if (mouseInsideButton and leftMouseDown) {
            self.animationScaleValue = self.animationScale;
        } else {
            self.animationScaleValue = 1.0;
        }
    }

    pub fn Draw(self: *const Button) void {
        var offsetPosX = self.base.pos.x;
        var offsetPosY = self.base.pos.y;
        if (self.centered) {
            offsetPosX = self.base.pos.x - self.base.size.x / 2 * self.animationScaleValue;
            offsetPosY = self.base.pos.y - self.base.size.y / 2 * self.animationScaleValue;
        }

        if (self.background) |value| {
            raylib.DrawTextureEx(value, raylib.Vector2{ .x = offsetPosX, .y = offsetPosY }, 0.0, self.animationScaleValue, raylib.WHITE);
        }
        if (self.text) |value| {
            value.Draw();
        }
    }

    pub fn SetText(self: *Button, text: []const u8, font: raylib.Font, fontSize: f32, color: raylib.Color) void {
        self.text = Text.Init(self.base.pos, text, font, fontSize, color, true);
    }

    pub fn LoadBackground(self: *Button, path: []const u8) void {
        var image = raylib.LoadImage(path.ptr);
        raylib.ImageResize(&image, @as(c_int, @intFromFloat(self.base.size.x)), @as(c_int, @intFromFloat(self.base.size.y)));
        self.background = raylib.LoadTextureFromImage(image);
        raylib.UnloadImage(image);
    }
};

pub const Image = struct {
    base: Base,
    background: raylib.Texture = undefined,
    centered: bool = true,

    pub fn Init(pos: raylib.Vector2, size: raylib.Vector2, centered: bool) Image {
        return .{
            .base = .{ .pos = pos, .size = size },
            .centered = centered,
        };
    }

    pub fn Draw(self: *Image) void {
        var offsetPosX = self.base.pos.x;
        var offsetPosY = self.base.pos.y;
        if (self.centered) {
            offsetPosX = self.base.pos.x - (self.base.size.x / 2);
            offsetPosY = self.base.pos.y - (self.base.size.y / 2);
        }

        raylib.DrawTexture(self.background, @as(c_int, @intFromFloat(offsetPosX)), @as(c_int, @intFromFloat(offsetPosY)), raylib.WHITE);
    }

    pub fn LoadBackground(self: *Image, path: []const u8) void {
        var image = raylib.LoadImage(path.ptr);
        raylib.ImageResize(&image, @as(c_int, @intFromFloat(self.base.size.x)), @as(c_int, @intFromFloat(self.base.size.y)));
        self.background = raylib.LoadTextureFromImage(image);
        raylib.UnloadImage(image);
    }
};

pub const Upgrade = struct {
    base: Base,
    button: Button,
    name: []const u8,
    generates: f32,
    count: f16 = 0,
    price: f32,
    icon: raylib.Texture = undefined,
    font: raylib.Font = undefined,
    priceBuffer: [4096]u8 = undefined,
    countBuffer: [4096]u8 = undefined,

    pub fn Init(pos: raylib.Vector2, size: raylib.Vector2, name: []const u8, generates: f32, price: f32, font: raylib.Font) Upgrade {
        return .{
            .base = .{ .pos = pos, .size = size },
            .button = .{ .base = .{ .pos = pos, .size = size }, .centered = true, .animationScale = 0.95 },
            .name = name,
            .generates = generates,
            .price = price,
            .font = font,
        };
    }

    pub fn Tick(self: *Upgrade, deltaTime: f32, tickCounter: *f64) void {
        self.button.Tick(deltaTime);
        tickCounter.* += (self.generates * self.count) * deltaTime;
    }

    pub fn Draw(self: *Upgrade) !void {
        self.button.Draw();

        const offsetPos = raylib.Vector2{ .x = self.base.pos.x, .y = self.base.pos.y };

        const nameOffset = raylib.Vector2{ .x = offsetPos.x - 110, .y = offsetPos.y - 24 };
        raylib.DrawTextEx(self.font, self.name.ptr, nameOffset, 30, 0.0, raylib.WHITE);

        const priceOffset = raylib.Vector2{ .x = offsetPos.x - 110, .y = offsetPos.y + 7 };
        const priceStr = try std.fmt.bufPrintZ(&self.priceBuffer, "{d:.1}", .{self.price});
        raylib.DrawTextEx(self.font, priceStr.ptr, priceOffset, 20, 0.0, raylib.WHITE);

        const countStr = try std.fmt.bufPrintZ(&self.countBuffer, "{d:.0}", .{self.count});
        const countWidth = raylib.MeasureTextEx(self.font, countStr, 30, 0.0);
        const countOffset = raylib.Vector2{ .x = offsetPos.x + 110 - countWidth.x, .y = offsetPos.y - 14 };
        raylib.DrawTextEx(self.font, countStr.ptr, countOffset, 30, 0.0, raylib.WHITE);
    }
};
