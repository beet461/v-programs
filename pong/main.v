import gg
import gx
import time

const (
	width  = 800
	height = 600
)

struct Score {
mut:
	p_one int
	p_two int
}

struct App {
mut:
	gg        &gg.Context
	puck      Puck
	score     Score
	last_tick i64
	tiles     []&Tile
}

fn frame(mut app App) {
	app.gg.begin()

	app.gg.draw_text(width / 4, 0, 'wasd     $app.score.p_one', gx.TextCfg{
		color: gx.white
		align: .center
		size: 40
	})

	app.gg.draw_text(width / 4 * 3, 0, '$app.score.p_two     ↑←↓→', gx.TextCfg{
		color: gx.white
		align: .center
		size: 40
	})

	now := time.ticks()
	if now - app.last_tick >= 10 {
		app.last_tick = now
		app.puck.pos.x += app.puck.speed.x
		app.puck.pos.y += app.puck.speed.y
		bounce_check(mut &app.puck, mut app)
	}

	ts := app.tiles // all registered tiles
	for i in 0 .. ts.len {
		t := ts[i] // current tile
		// draw border rectangle, with border weight added, behind main tile
		if t.border.enabled {
			app.gg.draw_rect_filled(t.pos.x, t.pos.y, t.dim.x + t.border.weight * 2, t.dim.y +
				t.border.weight * 2, t.border.col)
		}
		// draw main tile
		app.gg.draw_rect_filled(t.pos.x + t.border.weight, t.pos.y + t.border.weight,
			t.dim.x, t.dim.y, t.color)
	}

	app.gg.draw_circle_filled(app.puck.pos.x, app.puck.pos.y, app.puck.radius, app.puck.color)

	app.gg.end()
}

// event runs the given event functions in all tiles
fn event(e &gg.Event, mut app App) {
	for i in 0 .. app.tiles.len {
		app.tiles[i].eventfn(e, app.tiles[mut i], mut app)
	}
}

fn main() {
	mut app := &App{
		gg: 0
	}

	create_puck(mut app)
	create_board(mut app)

	app.gg = gg.new_context(
		bg_color: gx.black
		width: width
		height: height
		window_title: 'gamev'
		frame_fn: frame
		event_fn: event
		user_data: app
	)

	app.gg.run()
}
