const std = @import("std");
const ui = @import("ui.zig");
const embeds = @import("embeds");

const raylib = @cImport({
    @cInclude("raylib.h");
});

pub fn init() game {
    var initialized = game{ .coalCounter = 0, .tickCounter = 0 };
    initialized.font = raylib.LoadFontFromMemory(".ttf", embeds.embeddedFont.ptr, embeds.embeddedFont.len, 96, null, 0);

    var coalLumpImage = raylib.LoadImageFromMemory(".png", embeds.embeddedCoalLump.ptr, embeds.embeddedCoalLump.len);
    var backgroundImage = raylib.LoadImageFromMemory(".png", embeds.embeddedBackground.ptr, embeds.embeddedBackground.len);
    var buttonBackgroundImage = raylib.LoadImageFromMemory(".png", embeds.embeddedButtonBG.ptr, embeds.embeddedButtonBG.len);
    defer raylib.UnloadImage(coalLumpImage);
    defer raylib.UnloadImage(backgroundImage);
    defer raylib.UnloadImage(buttonBackgroundImage);
    raylib.ImageResize(&coalLumpImage, 250, 250);
    raylib.ImageResize(&backgroundImage, 1200, 900);
    raylib.ImageResize(&buttonBackgroundImage, 260, 70);

    // CoalCounter Text
    const coalLumpCounter = ui.Text.Init(raylib.Vector2{ .x = 400, .y = 150 }, "0", initialized.font, 80, raylib.WHITE, true);
    const coalLumpText = ui.Text.Init(raylib.Vector2{ .x = 400, .y = 200 }, "Coal Lumps", initialized.font, 40, raylib.WHITE, true);
    initialized.textCoalCounter = coalLumpCounter;
    initialized.textCoalText = coalLumpText;

    // CoalLump Button
    var coalLumpButton = ui.Button.Init(raylib.Vector2{ .x = 400, .y = 550 }, raylib.Vector2{ .x = 250, .y = 250 }, true);
    coalLumpButton.background = raylib.LoadTextureFromImage(coalLumpImage);
    initialized.buttonCoalLump = coalLumpButton;

    // Upgrades
    initialized.upgrades.clicker = ui.Upgrade.Init(raylib.Vector2{ .x = 1025, .y = 295 }, raylib.Vector2{ .x = 260, .y = 70 }, "Clicker", 0.5, 10, initialized.font);
    initialized.upgrades.elfHelper = ui.Upgrade.Init(raylib.Vector2{ .x = 1025, .y = 375 }, raylib.Vector2{ .x = 260, .y = 70 }, "Elf Helper", 5.5, 50, initialized.font);
    initialized.upgrades.printer = ui.Upgrade.Init(raylib.Vector2{ .x = 1025, .y = 455 }, raylib.Vector2{ .x = 260, .y = 70 }, "3D Printer", 132.0, 1_000, initialized.font);
    initialized.upgrades.reindeer = ui.Upgrade.Init(raylib.Vector2{ .x = 1025, .y = 535 }, raylib.Vector2{ .x = 260, .y = 70 }, "Reindeer Farm", 14_520.0, 100_000, initialized.font);
    initialized.upgrades.cloner = ui.Upgrade.Init(raylib.Vector2{ .x = 1025, .y = 615 }, raylib.Vector2{ .x = 260, .y = 70 }, "Coal Cloner", 159_720.0, 1_000_000, initialized.font);
    initialized.upgrades.wormHole = ui.Upgrade.Init(raylib.Vector2{ .x = 1025, .y = 695 }, raylib.Vector2{ .x = 260, .y = 70 }, "Wormhole", 351_384_000.0, 2_000_000_000, initialized.font);
    initialized.upgrades.clicker.button.background = raylib.LoadTextureFromImage(buttonBackgroundImage);
    initialized.upgrades.elfHelper.button.background = raylib.LoadTextureFromImage(buttonBackgroundImage);
    initialized.upgrades.printer.button.background = raylib.LoadTextureFromImage(buttonBackgroundImage);
    initialized.upgrades.reindeer.button.background = raylib.LoadTextureFromImage(buttonBackgroundImage);
    initialized.upgrades.cloner.button.background = raylib.LoadTextureFromImage(buttonBackgroundImage);
    initialized.upgrades.wormHole.button.background = raylib.LoadTextureFromImage(buttonBackgroundImage);

    // Background
    var background = ui.Image.Init(raylib.Vector2{ .x = 0, .y = 0 }, raylib.Vector2{ .x = 1200, .y = 900 }, false);
    background.background = raylib.LoadTextureFromImage(backgroundImage);
    initialized.imageBackground = background;

    return initialized;
}

const Upgrades = struct {
    clicker: ui.Upgrade = undefined,
    elfHelper: ui.Upgrade = undefined,
    printer: ui.Upgrade = undefined,
    reindeer: ui.Upgrade = undefined,
    cloner: ui.Upgrade = undefined,
    wormHole: ui.Upgrade = undefined,
};

const game = struct {
    coalCounter: f128,
    tickCounter: f64,
    upgrades: Upgrades = undefined,

    textCoalText: ui.Text = undefined,
    textCoalCounter: ui.Text = undefined,
    buttonCoalLump: ui.Button = undefined,

    imageBackground: ui.Image = undefined,
    font: raylib.Font = undefined,

    pub fn deinit(self: *game) void {
        raylib.UnloadTexture(self.buttonCoalLump.background);
        raylib.UnloadTexture(self.imageBackground.background);
        raylib.UnloadTexture(self.upgrades.clicker.button.background);
        raylib.UnloadTexture(self.upgrades.elfHelper.button.background);
        raylib.UnloadTexture(self.upgrades.printer.button.background);
        raylib.UnloadTexture(self.upgrades.reindeer.button.background);
        raylib.UnloadTexture(self.upgrades.cloner.button.background);
        raylib.UnloadTexture(self.upgrades.wormHole.button.background);
        raylib.UnloadFont(self.font);
    }

    pub fn tick(self: *game, deltaTime: f32) !void {
        self.buttonCoalLump.Tick(deltaTime);

        self.upgrades.clicker.Tick(deltaTime, &self.tickCounter);
        self.upgrades.elfHelper.Tick(deltaTime, &self.tickCounter);
        self.upgrades.printer.Tick(deltaTime, &self.tickCounter);
        self.upgrades.reindeer.Tick(deltaTime, &self.tickCounter);
        self.upgrades.cloner.Tick(deltaTime, &self.tickCounter);
        self.upgrades.wormHole.Tick(deltaTime, &self.tickCounter);

        if (self.buttonCoalLump.pressed) {
            self.tickCounter += 1;
        }

        if (self.tickCounter > 0) {
            self.coalCounter += self.tickCounter;
            self.tickCounter = 0;
            try self.textCoalCounter.SetText(self.coalCounter);
        }

        if (self.upgrades.clicker.button.pressed and self.coalCounter >= self.upgrades.clicker.price) {
            self.upgrades.clicker.count += 1;
            self.coalCounter -= self.upgrades.clicker.price;
            self.upgrades.clicker.price *= 1.2;
        }

        if (self.upgrades.elfHelper.button.pressed and self.coalCounter >= self.upgrades.elfHelper.price) {
            self.upgrades.elfHelper.count += 1;
            self.coalCounter -= self.upgrades.elfHelper.price;
            self.upgrades.elfHelper.price *= 1.2;
        }

        if (self.upgrades.printer.button.pressed and self.coalCounter >= self.upgrades.printer.price) {
            self.upgrades.printer.count += 1;
            self.coalCounter -= self.upgrades.printer.price;
            self.upgrades.printer.price *= 1.2;
        }

        if (self.upgrades.reindeer.button.pressed and self.coalCounter >= self.upgrades.reindeer.price) {
            self.upgrades.reindeer.count += 1;
            self.coalCounter -= self.upgrades.reindeer.price;
            self.upgrades.reindeer.price *= 1.2;
        }

        if (self.upgrades.cloner.button.pressed and self.coalCounter >= self.upgrades.cloner.price) {
            self.upgrades.cloner.count += 1;
            self.coalCounter -= self.upgrades.cloner.price;
            self.upgrades.cloner.price *= 1.2;
        }

        if (self.upgrades.wormHole.button.pressed and self.coalCounter >= self.upgrades.wormHole.price) {
            self.upgrades.wormHole.count += 1;
            self.coalCounter -= self.upgrades.wormHole.price;
            self.upgrades.wormHole.price *= 1.2;
        }
    }

    pub fn draw(self: *game) !void {
        self.imageBackground.Draw();

        try self.upgrades.clicker.Draw();
        try self.upgrades.elfHelper.Draw();
        try self.upgrades.printer.Draw();
        try self.upgrades.reindeer.Draw();
        try self.upgrades.cloner.Draw();
        try self.upgrades.wormHole.Draw();

        self.buttonCoalLump.Draw();
        self.textCoalCounter.Draw();
        self.textCoalText.Draw();
    }

    pub fn load(self: *game) !void {
        _ = self;
        std.debug.print("Load: Not implemented yet!", .{});
    }

    pub fn save(self: *game) void {
        _ = self;
        std.debug.print("Save: Not implemented yet!", .{});
    }
};
