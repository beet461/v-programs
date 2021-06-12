import gg
import gx

struct App {
mut:
	gg &gg.Context
	
}

const font = $embed_file('./assets/fonts/RobotoMono-Regular.ttf')

fn frame(mut app App) {
	app.gg.begin()
	app.gg.draw_text(100, 100, '${gg.window_size()}', gx.TextCfg{ size:30 })
	app.gg.end()
}

fn main() {
	mut app := &App {
		gg: 0
	}

	mut font_copy := font
	font_bytes := unsafe {
		font_copy.data().vbytes(font_copy.len)
	}

	app.gg = gg.new_context(
		bg_color: gx.white
		frame_fn: frame
		user_data: app
		font_bytes_normal: font_bytes
	)
	app.gg.run()
}
