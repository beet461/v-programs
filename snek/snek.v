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

struct App {
mut:
	gg       &gg.Context
	snake    []Pos
	apple    Pos
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

	app.gg.draw_rect(50, 50, 700, 700, gx.white)

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
		app.gg.draw_rect(pos.x * 10, pos.y * 10, 50, 50, gx.white)
		app.gg.draw_rect(pos.x * 10 + 1, pos.y * 10 + 1, 48, 48, gx.rgb(255, 120, 120))
	}

	// draw apple
	app.gg.draw_rounded_rect(app.apple.x * 10, app.apple.y * 10, 50, 50, 25, gx.rgb(135,
		255, 135))

	app.gg.draw_text(350, 10, 'Score: $app.score', gx.TextCfg{ size: 30 })

	app.gg.end()
}

fn keydown(key gg.KeyCode, mod gg.Modifier, mut app App) {
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
		keydown_fn: keydown
		user_data: app
		window_title: 'Snek'
		font_bytes_normal: font_bytes
	)

	app.gg.run()
}
