import gg
import time

// smooth_movement moves the tile along speed amount of pixels every 100ms
// as long as pressed is true (pressed represents a key pressed down or not).
// If the result of the movement would mean the tile pos is < 0 or > b, then no movement happens.
fn smooth_movement(mut position &f32, speed f32, pressed &bool, total_length f32, min_border f32, max_border f32) {
	// as long as the given key is pressed, the tile is kept moving
	for *pressed {
		if position + speed < min_border || *position + speed + total_length > max_border {
			return
		}
		position += speed
		time.sleep(1000000)
	}
}

fn player(e &gg.Event, mut tile Tile, mut app App) {
	mut key_up := gg.KeyCode.w
	mut key_down := gg.KeyCode.s
	if tile.tag == 'p2' {
		key_up = gg.KeyCode.up
		key_down = gg.KeyCode.down
	}
	match e.typ {
		.key_down {
			match e.key_code {
				key_up {
					if !tile.key_pressed.w {
						go smooth_movement(mut &tile.pos.y, -5, &tile.key_pressed.w, tile.dim.y +
							tile.border.weight * 2, 10, height - 10)
						tile.key_pressed.w = true
					}
				}
				key_down {
					if !tile.key_pressed.s {
						go smooth_movement(mut &tile.pos.y, 5, &tile.key_pressed.s, tile.dim.y +
							tile.border.weight * 2, 10, height - 10)
						tile.key_pressed.s = true
					}
				}
				else {}
			}
		}
		.key_up {
			match e.key_code {
				key_up {
					tile.key_pressed.w = false
				}
				key_down {
					tile.key_pressed.s = false
				}
				else {}
			}
		}
		else {}
	}
}

fn create_board(mut app App) {
	app.tiles.insert(0, tile_builder(TileCfg{
		tag: 'p1'
		width: 20
		height: 150
		pos_x: 10
		pos_y: height / 2 - 75
		border_enabled: false
		eventfn: player
		collision: true
	}))

	app.tiles.insert(1, tile_builder(TileCfg{
		tag: 'p2'
		width: 20
		height: 150
		pos_x: width - 30
		pos_y: height / 2 - 75
		border_enabled: false
		eventfn: player
		collision: true
	}))

	app.tiles.insert(2, tile_builder(TileCfg{
		tag: 'midline'
		width: 5
		height: height
		pos_x: width / 2 - 2.5
		pos_y: 0
		border_enabled: false
	}))
}
