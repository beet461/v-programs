import gg
import gx

struct App {
mut:
	gg       &gg.Context
	text     []string
	image	 gg.Image
}

const font = $embed_file('../assets/fonts/VictorMonoAll/TTF/VictorMono-Medium.ttf')

fn frame(mut app App) {
	app.gg.begin()
 
	// Draw background image
	app.gg.draw_image(0, 0, 1908, 1034, app.image)
	
	// Text box
	app.gg.draw_rect(110, 110, 520, 60, gx.rgba(255, 178, 46, 70))
	app.gg.draw_rect(120, 120, 500, 40, gx.rgba(190, 51, 255, 70))

	app.gg.draw_text(125, 125, '${app.text.reverse().join('')}|', gx.TextCfg{
		size: 30
	})

	app.gg.end()
}

fn keydown(key gg.KeyCode, mod gg.Modifier, mut app App) {
	mut key_str := key.str()

	match key {
		.backspace {
			if app.text.len <= 0 {
				return
			}
			app.text.delete(0)
			return
		}
		.space {
			key_str = ' '
		}
		else {}
	}

	app.text.prepend(key_str)
}

fn main() {
	mut app := &App{
		gg: 0
	}

	mut font_copy := font

	font_bytes := unsafe {
		font_copy.data().vbytes(font_copy.len)
	}

	app.gg = gg.new_context(
		width: 700
		height: 700
		keydown_fn: keydown
		frame_fn: frame
		user_data: app
		font_bytes_normal: font_bytes
	)

	app.image = app.gg.create_image('../assets/images/png/ghosts.png')

	app.gg.run()
}
