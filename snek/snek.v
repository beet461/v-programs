import gg
import gx
import time

enum Dir {
	up = 1
	down = 2
	right = 3
	left = 4
}

struct App {
mut:
	gg        &gg.Context
	x         int
	y         int
	count     int
	dir       Dir
}

const font = $embed_file('../assets/RobotoMono-Regular.ttf')

fn draw_items(mut app App) {
	app.gg.draw_rounded_rect(177 * 10, 98 * 10, 50, 50, 10, gx.rgb(100, 56, 78))

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

	time.sleep(100000000)
}

fn frame(mut app App) {
	app.gg.begin()

	if app.count <= 0 {
		draw_items(mut app)
	} else {
		app.gg.draw_text(100, 100, '$app.count', gx.TextCfg{
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
		.right {
			app.dir = .right
		}
		.up {
			app.dir = .up
		}
		.left {
			app.dir = .left
		}
		.down {
			app.dir = .down
		}
		else {}
	}
}

fn main() {
	mut app := &App{
		gg: 0
		x: 5
		y: 5
		count: 3
	}

	mut font_copy := font

	font_bytes := unsafe {
		font_copy.data().vbytes(font_copy.len)
	}

	app.gg = gg.new_context(
		bg_color: gx.rgb(56, 69, 12)
		width: 600
		height: 400
		frame_fn: frame
		keydown_fn: keydown
		user_data: app
		font_bytes_normal: font_bytes
	)

	app.gg.run()
}
