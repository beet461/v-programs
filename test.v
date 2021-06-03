import gg
import gx

struct App {
	mut: 
	gg &gg.Context
}

fn frame(mut app App) {
	app.gg.begin()
	app.gg.end()
}

fn main() {
	mut app := &App{
		gg: 0
	}
	app.gg = gg.new_context(
		bg_color: gx.blue
	)
}