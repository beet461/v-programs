import gg
import gx

// FNevent is called when an event happens. The tile can perform actions based on the event.
type FNevent = fn (key &gg.Event, mut tile Tile, mut app App)

struct Dim {
mut:
	x f32
	y f32
}

// Border is used for configuring borders.
// A bigger rectangle is drawn behind the main tile body.
// Its dimensions are the tile's dimensions + weight * 2.
// Its position is the tile's pos - weight.
struct Border {
mut:
	enabled bool
	weight  f32
	col     gx.Color
}

// Key_Pressed is used to see if a particular key is pressed, so the tile can continue to moved or stopped
struct Key_Pressed {
mut:
	w bool
	a bool
	s bool
	d bool
}

// Tile contains the configuration options for a rectangle/square.
// Any interaction is controlled through its event function. Collision is not really used.
struct Tile {
mut:
	tag         string
	dim         Dim
	pos         Dim
	border      Border
	eventfn     FNevent
	key_pressed Key_Pressed
	collision   bool
	color       gx.Color
}

// TileCfg is a broken down version of Tile, used for configuration of a tile before being built
struct TileCfg {
	tag            string   = '#tile'
	width          f32      = 100
	height         f32      = 100
	pos_x          f32      = 100
	pos_y          f32      = 100
	border_enabled bool     = true
	b_weight       f32      = 1
	b_color        gx.Color = gx.black
	color          gx.Color = gx.white
	eventfn        FNevent  = placeholderev_fn
	collision      bool
}

// tile_builder takes in input as TileCfg and returns a usable Tile object
fn tile_builder(tile TileCfg) &Tile {
	return &Tile{
		tag: tile.tag
		dim: Dim{tile.width, tile.height}
		pos: Dim{tile.pos_x, tile.pos_y}
		border: Border{tile.border_enabled, tile.b_weight, tile.b_color}
		eventfn: tile.eventfn
		key_pressed: Key_Pressed{}
		collision: tile.collision
		color: tile.color
	}
}

// placeholderev_fn is used a place holder event function, because the program crashes if one is not there
fn placeholderev_fn(e &gg.Event, mut tile Tile, mut app App) {
}
