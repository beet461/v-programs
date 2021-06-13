import gg
import gx
import ui

struct Uapp {
	mut:
		window &ui.Window
}

struct App {
mut:
	gg &gg.Context
	
}

fn frame(mut app App) {
	app.gg.begin()
	app.gg.draw_rect(100, 100, 100, 100, gx.rgb(254, 127, 197))
	app.gg.end()
}

fn main() {
	mut app := &App {
		gg: 0
	}

	mut uapp := &Uapp{
		window: 0
	}

	window := ui.window({
		state: uapp
	}, [
		ui.rectangle(
			height: 100
			width: 100
			color: gx.rgb(243, 5, 67)
			x: 200
			y: 200
		)
	])

	app.gg = gg.new_context(
		bg_color: gx.white
		frame_fn: frame
		user_data: app
	)
	ui.run(window)
	app.gg.run()
	
}
