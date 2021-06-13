import gg
import gx
import time

enum Dir {
	up = 1
	down = 2
	right = 3
	left = 4
}

const (
	tick_diff  = 200
	win_width  = 800
	win_height = 800
)

struct Pos {
	x f32
	y f32
}

struct App {
	mut:
		gg &gg.Context
		snake    []Pos
		apple    Pos
		dir      Dir
		score    int
		pre_tick i64
}	

fn (x Pos) + (y Pos) Pos {
	return Pos{x.x + y.x, x.y + y.y}
}

fn (x Pos) - (y Pos) Pos {
	return Pos{x.x - y.x, x.y - y.y}
}

fn (mut app App) food() {
	app.apple.x = rand.int_in_range(5, 70)
	app.apple.y = rand.int_in_range(5, 70)
	if app.apple.x % 5 == 0 && app.apple.y % 5 == 0 && app.apple !in app.snake {
		return
	} else {
		app.food()
	}
}

fn (mut app App) reset() {
	app.snake = [Pos{15, 35}, Pos{10, 35}, Pos{5, 35}]
	app.apple = Pos{35, 35}
	app.dir = .right
	app.score = 0
}

fn (mut app App) keydown(key gg.KeyCode, mod gg.Modifier) {
	match key {
		.up, .w {
			if app.dir != .down {
				app.dir = .up
			}
		}
		.down, .s {
			if app.dir != .up {
				app.dir = .down
			}
		}
		.right, .d {
			if app.dir != .left {
				app.dir = .right
			}
		}
		.left, .a {
			if app.dir != .right {
				app.dir = .left
			}
		}
		else {}
	}
}

fn event(e &gg.Event, mut app App) {
	match e.typ {
		.key_down {
			app.keydown(e.key_code)
		}
	}
}

fn frame(mut app App) {

}

fn main() {
	mut app := &State {
		gg: 0
	}

	app.gg = gg.new_context({
		bg_color: gx.rgb(230, 252, 236)
		width: win_width
		height: win_height
		window_title: 'Snek'
		resizable: false
		user_data: app
		font_bytes_normal: font_bytes
		event_fn: event
		frame_fn: frame
	})
}