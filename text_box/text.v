import gg
import gx

struct App {
	mut:
	gg &gg.Context
	text []string
}

const font = $embed_file("../assets/VictorMonoAll/TTF/VictorMono-MediumItalic.ttf")

fn frame(mut app App) {
	app.gg.begin()

	//text box
	app.gg.draw_rect(110, 110, 520, 60, gx.blue)
	app.gg.draw_rect(120, 120, 500, 40, gx.white)
	
	app.gg.draw_text(125, 125, '${app.text.reverse().join('')}|', gx.TextCfg{
		size: 30
	})
	
	app.gg.draw_rect(630, 0, 1920, 1000, gx.white)
	app.gg.draw_rect(620, 110, 10, 60, gx.blue)
	app.gg.end()
}

fn keydown(key gg.KeyCode, mod gg.Modifier, mut app App) {
	mut key_str := key.str()
	
	match key {
		.backspace {
			if app.text.len <= 0 { return }
			app.text.delete(0)
			return
		}
		.space {
			key_str = ' '
		} .world_1, .world_2, .escape, .enter, .tab, .insert, .delete, .right, .left, .down, .up, .page_up, .page_down, .home, .end, .caps_lock, .scroll_lock, .num_lock, .print_screen, .pause, .f1, .f2, .f3, .f4, .f5, .f6, .f7, .f8, .f9, .f10, .f11, .f12, .f13, .f14, .f15, .f16, .f17, .f18, .f19, .f20, .f21, .f22, .f23, .f24, .f25, .kp_0, .kp_1, .kp_2, .kp_3, .kp_4, .kp_5, .kp_6, .kp_7, .kp_8, .kp_9, .kp_decimal, .kp_divide, .kp_multiply, .kp_subtract, .kp_add, .kp_enter, .kp_equal, .left_shift, .left_control, .left_alt, .left_super, .right_shift, .right_control, .right_alt, .right_super, .menu {
			key_str = ''
		} else {}
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
		bg_color: gx.white
		width: 700
		height: 700
		keydown_fn: keydown
		frame_fn: frame
		user_data: app
		font_bytes_normal: font_bytes
	)

	app.gg.run()
}