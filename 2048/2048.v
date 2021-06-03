import gg
import gx

struct App {
	mut: 
	gg &gg.Context
}

struct Theme {
	bg	gx.color
	padding gx.color
	empty gx.color
	text gx.color
	tiles []gx.color
}

const (
	default = &Theme {
		bg: gx.rgb(254, 255, 186)
		padding: gx.rgb(161, 130, 58)
		empty: gx.rgb(161, 130, 58)
		text: gx.black
		tiles: [
			gx.rgb(181, 181, 167) //2
			gx.rgb(255, 235, 194) //4
			gx.rgb(252, 174, 106) //8
			gx.rgb(245, 137, 98) //16
			gx.rgb(245, 125, 98) //32
			gx.rgb(255, 105, 71) //64
			gx.rgb(255, 225, 117) //128
			gx.rgb() //256
			gx.rgb() //512
			gx.rgb() //1024
			gx.rgb() //2048
		]
	}
)

fn frame(mut app App) {
	app.gg.begin()
	app.gg.draw_rect(10, 10, 50, 50, gx.red)
	app.gg.end()
}

fn main() {
	mut app := &App{
		gg: 0
	}

	

	app.gg = gg.new_context(
		bg_color: gx.rgb()
		width: 100
		height: 100
		frame_fn: 
		user_data: app
	)

	app.gg.run()
}