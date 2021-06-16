import gg
import gx
import time
import rand

// Declaring constants and structs
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
mut:
	x int
	y int
}

struct Touch {
	mut:
		pos Pos
		time time.Time
}

struct TouchInfo {
	mut:
	start Touch
	end Touch
}

struct App {
mut:
	gg       &gg.Context
	snake    []Pos
	apple    Pos
	touch	TouchInfo
	dir      Dir
	score    int
	pre_tick i64
}


// Font
const font = $embed_file('../assets/fonts/VictorMonoAll/TTF/VictorMono-MediumItalic.ttf')

// Two functions are for adding or subtracting two instances of Pos together
fn (x Pos) + (y Pos) Pos {
	return Pos{x.x + y.x, x.y + y.y}
}

fn (x Pos) - (y Pos) Pos {
	return Pos{x.x - y.x, x.y - y.y}
}

// Generates random number divisible by 5 and within board and not on snake
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
	// Resets everything back to original state
	app.snake = [Pos{15, 35}, Pos{10, 35}, Pos{5, 35}]
	app.apple = Pos{35, 35}
	app.dir = .right
	app.score = 0
}

fn frame(mut app App) {
	app.gg.begin()

	// If snake has gone out of box, or gone into itself, reset.
	if app.snake[0].x > 70 || app.snake[0].x < 5 || app.snake[0].y > 70 || app.snake[0].y < 5
		|| app.snake[0] in app.snake[1..] {
		app.reset()
	}

	app.gg.draw_rect(100, 100, 700, 700, gx.white)

	// Records ticks now and compares it with the last time it was checked. If it above tick_diff, then it continues
	ticks_now := time.ticks()

	if ticks_now - app.pre_tick >= tick_diff {
		app.pre_tick = ticks_now

		// Adds position values to move
		dir_prev := match app.dir {
			.up {
				Pos{0, -5}
			}
			.down {
				Pos{0, 5}
			}
			.right {
				Pos{5, 0}
			}
			.left {
				Pos{-5, 0}
			}
		}

		// Moves head of snake, and all others follow
		mut prev := app.snake[0]
		app.snake[0] = app.snake[0] + dir_prev

		// Moves each square to the position of the one ahead it
		for i in 1 .. app.snake.len {
			tmp := app.snake[i]
			app.snake[i] = prev
			prev = tmp
		}

		// If snake head at the same coordinates as apple, add to score, generate new coordinates for apple, add square on to end of snake
		if app.snake[0] == app.apple {
			app.score++
			app.food()
			app.snake << app.snake.last() + app.snake.last() - app.snake[app.snake.len - 2]
		}
	}

	// draw snake
	for pos in app.snake {
		app.gg.draw_rect(pos.x * 10 + 50, pos.y * 10 + 50, 50, 50, gx.white)
		app.gg.draw_rect(pos.x * 10 + 1 + 50, pos.y * 10 + 1 + 50, 48, 48, gx.rgb(255, 120, 120))
	}

	// draw apple
	app.gg.draw_rounded_rect(app.apple.x * 10 + 50, app.apple.y * 10 + 50, 50, 50, 25, gx.rgb(135,
		255, 135))

	app.gg.draw_text(350, 10, 'Score: $app.score', gx.TextCfg{ size: 30 })

	app.gg.end()
}

fn (mut app App) change_dir(dir Dir, o_dir Dir) {
	if app.dir != o_dir {
		app.dir = dir
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

fn touch_handle() {
	
}

fn click(x f32, y f32, button gg.MouseButton, mut app App) {
	if button == .left {
		if y < 100 {
			app.change_dir(.up, .down)
		} else if y > 850 && y < 1050 {
			app.change_dir(.down, .up)
		} else if x > 850 && x < 1050 {
			app.change_dir(.right, .left)
		} else if x < 100 {
			app.change_dir(.left, .right)
		}
	}
}

fn event(e &gg.Event, mut app App) {
	match e.typ {
		.key_down {
			keydown(e.key_code, mut app)
		} .mouse_down {
			click(e.mouse_x, e.mouse_y, e.mouse_button, mut app)
		} .touches_began {
			touch := e.touches[0]
			app.touch.start = {
				pos: {
					x: int(touch.pos_x)
					y: int(touch.pos_y)
				}
				time: time.now()
			}	
		} .touches_ended {
			touch := e.touches[0]
			app.touch.end = {
				pos: {
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
		snake: [Pos{15, 35}, Pos{10, 35}, Pos{5, 35}]
		apple: Pos{35, 35}
		dir: .right
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
		user_data: app
		event_fn: event
		window_title: 'Snek'
		font_bytes_normal: font_bytes
	)

	app.gg.run()
}
