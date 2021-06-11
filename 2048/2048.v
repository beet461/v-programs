import gg
import gx
import rand

struct Theme {
	bg_col  gx.Color
	padding gx.Color
	empty   gx.Color
	text    gx.Color
	tiles   []gx.Color
}

struct Tiles {
mut:
	val int
	col gx.Color
}

enum Dir {
	up
	down
	right
	left
	no_dir
}

struct App {
mut:
	gg    &gg.Context
	field [4][4]Tiles
	dir   Dir
	move  bool
}

// Font
const font = $embed_file('../assets/RobotoMono-Regular.ttf')

// Game constants
const (
	tile_dim      = 100
	padding_width = 10
	corner_radius = 15
	border_width  = 50
	pos_multiple  = tile_dim + padding_width
	board_dim     = tile_dim * 4 + padding_width * 5
	zero_pos      = border_width + padding_width
	win_dim       = border_width * 2 + board_dim
)

// Theme constants
const (
	default  = &Theme{
		bg_col: gx.rgb(254, 255, 186)
		padding: gx.rgb(128, 128, 128)
		empty: gx.rgb(224, 215, 110)
		text: gx.black
		tiles: [
			gx.rgb(181, 181, 167),
			// 2
			gx.rgb(255, 235, 194),
			// 4
			gx.rgb(252, 174, 106),
			// 8
			gx.rgb(245, 137, 98),
			// 16
			gx.rgb(245, 125, 98),
			// 32
			gx.rgb(255, 105, 71),
			// 64
			gx.rgb(255, 225, 117),
			// 128
			gx.rgb(227, 199, 100),
			// 256
			gx.rgb(224, 185, 45),
			// 512
			gx.rgb(230, 185, 25),
			// 1024
			gx.rgb(255, 199, 0),
			// 2048
			gx.rgb(0, 0, 0),
			// anything above 2048
		]
	}

	colorful = &Theme{
		bg_col: gx.rgb(242, 255, 122)
		padding: gx.rgb(186, 255, 184)
		empty: gx.rgb(232, 232, 232)
		text: gx.rgb(122, 160, 255)
		tiles: [
			gx.rgb(255, 79, 79),
			// 2
			gx.rgb(255, 159, 107),
			// 4
			gx.rgb(255, 201, 107),
			// 8
			gx.rgb(255, 227, 87),
			// 16
			gx.rgb(132, 247, 124),
			// 32
			gx.rgb(98, 255, 87),
			// 64
			gx.rgb(14, 207, 0),
			// 128
			gx.rgb(0, 207, 117),
			// 256
			gx.rgb(11, 217, 210),
			// 512
			gx.rgb(19, 135, 237),
			// 1024
			gx.rgb(202, 23, 212),
			// 2048
			gx.rgb(79, 1, 143),
			// anything above 2048
		]
	}

	theme    = colorful
)

// assign colors
fn assign_col(mut tile Tiles) {
	// assign colours
	match tile.val {
		0 { tile.col = theme.empty }
		2 { tile.col = theme.tiles[0] }
		4 { tile.col = theme.tiles[1] }
		8 { tile.col = theme.tiles[2] }
		16 { tile.col = theme.tiles[3] }
		32 { tile.col = theme.tiles[4] }
		64 { tile.col = theme.tiles[5] }
		128 { tile.col = theme.tiles[6] }
		256 { tile.col = theme.tiles[7] }
		512 { tile.col = theme.tiles[8] }
		1024 { tile.col = theme.tiles[9] }
		2048 { tile.col = theme.tiles[10] }
		else { tile.col = theme.tiles[11] }
	}
}

fn (mut app App) gen_tile(num int, mut tile Tiles) {
	mut gen := true
	for gen {
		for i := 0; i < num; i++ {
			if tile.val == 0 {
				tile.val = (rand.int_in_range(1, 3) * 2)
				gen = false
			}
		}
	}
}

fn (mut app App) value(i int, j int, edge int, side int) {
	if side == edge {
		return
	} else if app.field[i][j].val == 0 {
		app.field[i][j].val = app.field[i][j].val
		app.field[i][j].val = 0
	} else if app.field[i][j].val == app.field[i][j].val {
		app.field[i][j].val = app.field[i][j].val * 2
		app.field[i][j].val = 0
	}
}

fn (mut app App) move_tiles(i int, j int) {
	match app.dir {
		.up {
			app.value(i, j - 1, 0, j)
		}
		.down {
			app.value(i, j + 1, 3, j)
		}
		.right {
			app.value(i + 1, j, 3, i)
		}
		.left {
			app.value(i - 1, j, 0, i)
		}
		else {}
	}
}

fn frame(mut app App) {
	app.gg.begin()

	//	app.gg.draw_text()

	// Draw padding rect
	app.gg.draw_rounded_rect(border_width, border_width, board_dim, board_dim, corner_radius,
		theme.padding)

	// Draw squares
	for i := 0; i < 4; i++ {
		for j := 0; j < 4; j++ {
			mut tile := app.field[i][j]
			assign_col(mut tile)

			x := i * pos_multiple + zero_pos
			y := j * pos_multiple + zero_pos

			if app.dir != .no_dir {
				app.move_tiles(i, j)
				app.move = true
			}

			dis := match tile.val {
				0 { '' }
				else { tile.val.str() }
			}
			app.gg.draw_rounded_rect(x, y, tile_dim, tile_dim, corner_radius, tile.col)
			app.gg.draw_text(x + tile_dim / 3, y + tile_dim / 3, '$dis', gx.TextCfg{ size: 30 })
		}
	}

	app.gg.end()
}

fn keydown(key gg.KeyCode, mod gg.Modifier, mut app App) {
	match key {
		.up, .w {
			app.dir = .up
			if app.move && app.dir == .no_dir {
				app.gen_tile(1, mut app.field[rand.int_in_range(0, 4)][rand.int_in_range(0,
					4)])
				app.move = false
			}
		}
		.down, .s {
			app.dir = .down
			if app.move && app.dir == .no_dir {
				app.gen_tile(1, mut app.field[rand.int_in_range(0, 4)][rand.int_in_range(0,
					4)])
				app.move = false
			}
		}
		.right, .d {
			app.dir = .right
			if app.move && app.dir == .no_dir {
				app.gen_tile(1, mut app.field[rand.int_in_range(0, 4)][rand.int_in_range(0,
					4)])
				app.move = false
			}
		}
		.left, .a {
			app.dir = .left
			if app.move && app.dir == .no_dir {
				app.gen_tile(1, mut app.field[rand.int_in_range(0, 4)][rand.int_in_range(0,
					4)])
				app.move = false
			}
		}
		else {}
	}
}

fn main() {
	mut app := &App{
		gg: 0
		move: true
		dir: .no_dir
	}

	mut font_copy := font

	font_bytes := unsafe {
		font_copy.data().vbytes(font_copy.len)
	}

	app.gen_tile(2, mut app.field[rand.int_in_range(0, 4)][rand.int_in_range(0, 4)])

	app.gg = gg.new_context(
		bg_color: theme.bg_col
		width: win_dim
		height: win_dim
		keydown_fn: keydown
		frame_fn: frame
		user_data: app
		font_bytes_normal: font_bytes
	)

	app.gg.run()
}
