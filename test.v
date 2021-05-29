import gg
import gx

struct App {
mut:
	gg &gg.Context
}

fn frame_fn(mut app App) {
	app.gg.begin()
	app.gg.end()
}

fn main() {
	mut app := &App{
		gg: 0
	}

	app.gg = gg.new_context(
		bg_color: gx.rgb(56, 69, 12)
		user_data: app
		frame_fn: frame_fn
	)	

	app.gg.run()

}
