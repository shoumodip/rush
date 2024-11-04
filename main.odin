package main

import rl "vendor:raylib"

BACKGROUND_COLOR :: rl.Color{0x18, 0x18, 0x18, 0xFF}
BUILDING_COLOR :: rl.Color{0xBB, 0x66, 0x66, 0xFF}

PLAYER_SIZE :: 30.0
PLAYER_SPEED :: 300.0
PLAYER_COLOR :: rl.Color{0xDD, 0xDD, 0xDD, 0xFF}

CAMERA_SPEED :: 2.0

CROSSHAIR_SIZE :: 25.0
CROSSHAIR_THICC :: 2.5
CROSSHAIR_COLOR :: PLAYER_COLOR

main :: proc() {
	rl.SetConfigFlags(rl.ConfigFlags{rl.ConfigFlag.MSAA_4X_HINT, rl.ConfigFlag.FULLSCREEN_MODE})

	rl.InitWindow(0, 0, "Rush")
	defer rl.CloseWindow()

	rl.HideCursor()
	defer rl.ShowCursor()

	rl.SetTargetFPS(60)

	player: rl.Vector2
	buildings: [100]rl.Rectangle

	for _, i in buildings {
		buildings[i] = rl.Rectangle {
			x      = cast(f32)rl.GetRandomValue(-5000, 5000),
			y      = cast(f32)rl.GetRandomValue(-5000, 5000),
			width  = cast(f32)rl.GetRandomValue(50, 200),
			height = cast(f32)rl.GetRandomValue(50, 200),
		}
	}
	buildings[0].x = 200
	buildings[0].y = 0

	camera := rl.Camera2D {
		zoom = 1.0,
	}

	for !rl.WindowShouldClose() {
		dt := rl.GetFrameTime()

		delta: rl.Vector2
		if rl.IsKeyDown(rl.KeyboardKey.W) || rl.IsKeyDown(rl.KeyboardKey.UP) do delta.y = -1
		if rl.IsKeyDown(rl.KeyboardKey.A) || rl.IsKeyDown(rl.KeyboardKey.LEFT) do delta.x = -1
		if rl.IsKeyDown(rl.KeyboardKey.S) || rl.IsKeyDown(rl.KeyboardKey.DOWN) do delta.y = 1
		if rl.IsKeyDown(rl.KeyboardKey.D) || rl.IsKeyDown(rl.KeyboardKey.RIGHT) do delta.x = 1
		player += rl.Vector2Normalize(delta) * PLAYER_SPEED * dt

		camera.target += (player - camera.target) * CAMERA_SPEED * dt
		camera.offset = {cast(f32)rl.GetScreenWidth(), cast(f32)rl.GetScreenHeight()} / 2

		rl.BeginDrawing()
		rl.ClearBackground(BACKGROUND_COLOR)

		rl.BeginMode2D(camera)
		for b in buildings {
			rl.DrawRectangleRec(b, BUILDING_COLOR)
		}

		rl.DrawCircleV(player, PLAYER_SIZE, PLAYER_COLOR)
		rl.EndMode2D()

		mouse := rl.GetMousePosition()
		rl.DrawLineEx(
			mouse - {0, CROSSHAIR_SIZE / 2},
			mouse + {0, CROSSHAIR_SIZE / 2},
			CROSSHAIR_THICC,
			CROSSHAIR_COLOR,
		)
		rl.DrawLineEx(
			mouse - {CROSSHAIR_SIZE / 2, 0},
			mouse + {CROSSHAIR_SIZE / 2, 0},
			CROSSHAIR_THICC,
			CROSSHAIR_COLOR,
		)

		rl.EndDrawing()
	}
}
