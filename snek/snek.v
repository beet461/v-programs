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

struct App {
mut:
	gg     &gg.Context
	x      f32
	y      f32
	applex f32
	appley f32
	count  int
	dir    Dir
}

const font = $embed_file('../assets/RobotoMono-Regular.ttf')

fn draw_items(mut app App) {
	// first snake block
	app.gg.draw_rounded_rect(app.x * 10, app.y * 10, 50, 50, 10, gx.rgb(100, 56, 78))

	// apple
	app.gg.draw_rounded_rect(app.applex * 10, app.appley * 10, 25, 25, 5, gx.rgb(135,
		255, 135))
	
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

fn frame(mut app App) {
	app.gg.begin()

	// draw border
	app.gg.draw_rect(40, 40, 1020, 720, gx.black)
	app.gg.draw_rect(50, 50, 1000, 700, gx.rgb(230, 252, 236))

	if app.count <= 0 {
		draw_items(mut app)
	} else {
		app.gg.draw_text(100, 100, '$app.count', gx.TextCfg{
			size: 30
		})
	}

	time.sleep(1000000000)

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
			app.dir = .up
			app.y -= 5
		}
		.down {
			app.dir = .down
			app.y += 5
		}
		.right {
			app.dir = .right
			app.x += 5
		}
		.left {
			app.dir = .left
			app.x -= 5
		}
		else {}
	}
}

fn main() {
	mut app := &App{
		gg: 0
		x: 5
		y: 5
		applex: rand.f32_in_range(1, 102)
		appley: rand.f32_in_range(1, 75)
		count: 3
	}

	mut font_copy := font

	font_bytes := unsafe {
		font_copy.data().vbytes(font_copy.len)
	}

	app.gg = gg.new_context(
		bg_color: gx.rgb(230, 252, 236)
		width: 600
		height: 400
		frame_fn: frame
		keydown_fn: keydown
		user_data: app
		font_bytes_normal: font_bytes
	)

	app.gg.run()
}
