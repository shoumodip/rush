package main

import "vendor:raylib"

CAMERA_SPEED :: 2.0
PLAYER_SPEED :: 200.0

CROSSHAIR_SIZE :: 25.0
CROSSHAIR_COLOR :: raylib.Color{0xDD, 0xDD, 0xDD, 0xFF}

BACKGROUND_COLOR :: raylib.Color{0x18, 0x18, 0x18, 0xFF}

Sprite :: struct {
	atlas:    ^raylib.Texture,
	boundary: raylib.Rectangle,
	position: raylib.Vector2,
}

main :: proc() {
	raylib.SetConfigFlags(raylib.ConfigFlags{raylib.ConfigFlag.FULLSCREEN_MODE})

	raylib.InitWindow(0, 0, "Rush")
	defer raylib.CloseWindow()

	raylib.SetTargetFPS(60)

	raylib.InitAudioDevice()
	defer raylib.CloseAudioDevice()

	raylib.HideCursor()
	defer raylib.ShowCursor()

	atlas := raylib.LoadTexture("assets/atlas.png")
	defer raylib.UnloadTexture(atlas)

	player := Sprite {
		atlas    = &atlas,
		boundary = {0.0, 0.0, 49.0, 43.0},
	}

	camera := raylib.Camera2D {
		zoom = 1.0,
	}

	for !raylib.WindowShouldClose() {
		dt := raylib.GetFrameTime()
		mouse := raylib.GetMousePosition()

		delta: raylib.Vector2
		if raylib.IsKeyDown(raylib.KeyboardKey.W) do delta.y = -1.0
		if raylib.IsKeyDown(raylib.KeyboardKey.A) do delta.x = -1.0
		if raylib.IsKeyDown(raylib.KeyboardKey.S) do delta.y = 1.0
		if raylib.IsKeyDown(raylib.KeyboardKey.D) do delta.x = 1.0
		player.position += raylib.Vector2Normalize(delta) * PLAYER_SPEED * dt

		camera.target += (player.position - camera.target) * CAMERA_SPEED * dt
		camera.offset = {cast(f32)raylib.GetScreenWidth(), cast(f32)raylib.GetScreenHeight()} / 2.0

		raylib.BeginDrawing()
		{
			raylib.ClearBackground(BACKGROUND_COLOR)

			raylib.BeginMode2D(camera)
			{
				final := raylib.Rectangle {
					player.position.x,
					player.position.y,
					player.boundary.width,
					player.boundary.height,
				}

				angle := -raylib.Vector2LineAngle(
					raylib.GetWorldToScreen2D(player.position, camera),
					mouse,
				)

				raylib.DrawTexturePro(
					player.atlas^,
					player.boundary,
					final,
					{final.width, final.height} / 2.0,
					angle * raylib.RAD2DEG,
					raylib.WHITE,
				)
			}
			raylib.EndMode2D()

			raylib.DrawLineEx(
				mouse - {0.0, CROSSHAIR_SIZE / 2.0},
				mouse + {0.0, CROSSHAIR_SIZE / 2.0},
				CROSSHAIR_SIZE / 10.0,
				CROSSHAIR_COLOR,
			)

			raylib.DrawLineEx(
				mouse - {CROSSHAIR_SIZE / 2.0, 0.0},
				mouse + {CROSSHAIR_SIZE / 2.0, 0.0},
				CROSSHAIR_SIZE / 10.0,
				CROSSHAIR_COLOR,
			)

		}
		raylib.EndDrawing()
	}
}
