import gg
import gx
import time
import rand

enum Dir {
	up = 1
	down = 2
	right = 3
	left = 4
}

const (
	tick_diff  = 1000
	win_width  = 800
	win_height = 640
)

struct App {
mut:
	gg       &gg.Context
	x        f32
	y        f32
	applex   f32
	appley   f32
	score	 int
	count    int
	dir      Dir
	pre_tick i64
}

const font = $embed_file('../assets/RobotoMono-Regular.ttf')

fn (mut app App) food() {
	app.applex = rand.int_in_range(5, 70)
	app.appley = rand.int_in_range(5, 54)
}

fn frame(mut app App) {
	app.gg.begin()

	// draw border
	app.gg.draw_rect(40, 40, 720, 560, gx.black)
	app.gg.draw_rect(50, 50, 700, 540, gx.rgb(230, 252, 236))

	ticks_now := time.ticks()

	if app.count <= 0 {
		if ticks_now - app.pre_tick >= tick_diff {
			app.pre_tick = ticks_now

			match app.dir {
				.up {
					app.y -= 5
				}
				.down {
					app.y += 5
				}
				.right {
					app.x += 5
				}
				.left {
					app.x -= 5
				}
			}
		}

		// first snake block
		app.gg.draw_rounded_rect(app.x * 10, app.y * 10, 50, 50, 10, gx.rgb(100, 56, 78))

		// apple
		app.gg.draw_rounded_rect(app.applex * 10, app.appley * 10, 50, 50, 25, gx.rgb(135,
			255, 135))
		
		if app.x == app.applex && app.y == app.appley{
				app.score++
				app.food()
				for app.applex % 5 != 0 {
					app.food()
				}
				
				for app.appley % 5 != 0 {
					app.food()
				}
		}

		app.gg.draw_text(10, 10, '$app.score', gx.TextCfg{
			size: 30
		})
	} else {
		app.gg.draw_text(10, 10, '$app.count', gx.TextCfg{
			size: 30
		})
	}

	app.gg.end()
}

fn keydown(key gg.KeyCode, mod gg.Modifier, mut app App) {
	match key {
		.enter {
			app.count--
		}
		.left_control {
			app.gg.end()
		}
		.up {
			if app.dir != .down {
				app.dir = .up
			}
		}
		.down {
			if app.dir != .up {
				app.dir = .down
			}
		}
		.right {
			if app.dir != .left {
				app.dir = .right
			}
		}
		.left {
			if app.dir != .right {
				app.dir = .left
			}
		}
		else {}
	}
}

fn main() {
	mut app := &App{
		gg: 0
		x: 5
		y: 32
		applex: 40
		appley: 32
		count: 3
	}

	mut font_copy := font

	font_bytes := unsafe {
		font_copy.data().vbytes(font_copy.len)
	}

	app.gg = gg.new_context(
		bg_color: gx.rgb(230, 252, 236)
		width: win_width
		height: win_height
		resizable: false
		frame_fn: frame
		keydown_fn: keydown
		user_data: app
		font_bytes_normal: font_bytes
	)

	app.gg.run()
}
