import gg
import gx
import time
import rand
import math

// Declaring constants and structs
enum Dir {
	up = 1
	down = 2
	right = 3
	left = 4
}

const (
	tick_diff  = 200
	win_width  = 900
	win_height = 900
)

struct Pos {
mut:
	x int
	y int
}

struct Touch {
mut:
	pos  Pos
	time time.Time
}

struct TouchInfo {
mut:
	start Touch
	end   Touch
}

struct App {
mut:
	gg       &gg.Context
	snake    []Pos
	apple    Pos
	touch    TouchInfo
	dir      Dir
	score    int
	pre_tick i64
	turned bool
}

// Two functions are for adding or subtracting two instances of Pos together
fn (x Pos) + (y Pos) Pos {
	return Pos{x.x + y.x, x.y + y.y}
}

fn (x Pos) - (y Pos) Pos {
	return Pos{x.x - y.x, x.y - y.y}
}

fn generate_pos() Pos {
	pos := Pos{
		x: (math.floor(rand.f32_in_range(0, 1) * 14) * 50 + 100).str().int() // Must do .str().int() as there is no f32 to int
		y: (math.floor(rand.f32_in_range(0, 1) * 14) * 50 + 100).str().int()
	}
	return pos
}

// Generates random number divisible by 5 and within board and not on snake
fn (mut app App) food() {
	apple := generate_pos()
	if apple in app.snake[0..] {
		app.food()
	} else {
		app.apple = apple
	}
}

fn (mut app App) reset() {
	// Resets everything back to original state
	app.snake = [Pos{200, 450}, Pos{150, 450}, Pos{100, 450}]
	app.apple = Pos{450, 450}
	app.dir = .right
	app.score = 0
}

fn frame(mut app App) {
	app.gg.begin()

	// If snake has gone out of box, or gone into itself, reset.
	if app.snake[0].x > 750 || app.snake[0].x < 100 || app.snake[0].y > 750 || app.snake[0].y < 100
		|| app.snake[0] in app.snake[1..] {
		app.reset()
	}

	app.gg.draw_empty_rect(99, 99, 703, 703, gx.white)

	// Records ticks now and compares it with the last time it was checked. If it above tick_diff, then it continues
	ticks_now := time.ticks()

	if ticks_now - app.pre_tick >= tick_diff {
		app.pre_tick = ticks_now

		da := match app.dir {
			.up {
				Pos{0, -50}
			}
			.down {
				Pos{0, 50}
			}
			.right {
				Pos{50, 0}
			}
			.left {
				Pos{-50, 0}
			}
		}

		mut head := app.snake[0] + da
		app.snake.prepend(head)
		if app.snake[0] == app.apple {
			app.score++
			app.food()
		} else {
			app.snake.delete_last()
		}

		app.turned = true
	}

	// draw snake and border
	for pos in app.snake {
		app.gg.draw_empty_rect(pos.x, pos.y, 50, 50, gx.black)
		app.gg.draw_rect(pos.x + 1, pos.y + 1, 48, 48, gx.dark_green)
	}

	// draw apple
	app.gg.draw_rounded_rect(app.apple.x, app.apple.y, 50, 50, 25, gx.red)

	app.gg.draw_text(400, 10, 'Score: $app.score', gx.TextCfg{ size: 30, color: gx.white })

	app.gg.end()
}

fn (mut app App) change_dir(dir Dir, o_dir Dir) {
	if app.dir != o_dir && app.turned {
		app.dir = dir
		app.turned = false
	}
}

fn keydown(key gg.KeyCode, mut app App) {
	match key {
		.up, .w {
			app.change_dir(.up, .down)
		}
		.down, .s {
			app.change_dir(.down, .up)
		}
		.right, .d {
			app.change_dir(.right, .left)
		}
		.left, .a {
			app.change_dir(.left, .right)
		}
		else {}
	}
}

fn (mut app App) touch_handle() {
}

fn event(e &gg.Event, mut app App) {
	match e.typ {
		.key_down {
			keydown(e.key_code, mut app)
		}
		.touches_began {
			touch := e.touches[0]
			app.touch.start = Touch{
				pos: Pos{
					x: int(touch.pos_x)
					y: int(touch.pos_y)
				}
				time: time.now()
			}
		}
		.touches_ended {
			touch := e.touches[0]
			app.touch.end = Touch{
				pos: Pos{
					x: int(touch.pos_x)
					y: int(touch.pos_y)
				}
				time: time.now()
			}
			app.touch_handle()
		}
		else {}
	}
}

fn main() {
	mut app := &App{
		gg: 0
		snake: [Pos{200, 450}, Pos{150, 450}, Pos{100, 450}]
		apple: Pos{450, 450}
		dir: .right
	}

	app.gg = gg.new_context(
		bg_color: gx.black
		width: win_width
		height: win_height
		resizable: false
		frame_fn: frame
		user_data: app
		event_fn: event
		window_title: 'Snek'
	)

	app.gg.run()
}
