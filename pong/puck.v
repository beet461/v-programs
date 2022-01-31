import gx

struct Puck {
mut:
	pos Dim
	radius f32
	color gx.Color
	speed Dim
	left_reflected bool
	right_reflected bool
}

fn bounce_check(mut puck &Puck, mut app App) {
	pos := puck.pos

	top := pos.y - puck.radius
	bottom := pos.y + puck.radius
	left := pos.x - puck.radius
	right := pos.x + puck.radius

	if left < 0 {
		app.score.p_two++
		create_puck(mut app)
	}
	if right > width {
		app.score.p_one++
		create_puck(mut app)
	}
	if top < 0 {
		puck.speed.y *= -1
	}
	if bottom > height {
		puck.speed.y *= -1
	}

	// the puck will go into the paddles halfway by using this method, but it works and is not really buggy
	if puck.pos.x < app.tiles[0].pos.x + app.tiles[0].dim.x && puck.pos.y > app.tiles[0].pos.y - puck.radius && puck.pos.y < app.tiles[0].pos.y + app.tiles[0].dim.y + puck.radius && !puck.left_reflected {
		puck.speed.x *= -1
		puck.left_reflected = true
		puck.right_reflected = false
	}

	if puck.pos.x > app.tiles[1].pos.x && puck.pos.y > app.tiles[1].pos.y - puck.radius && puck.pos.y < app.tiles[1].pos.y + app.tiles[1].dim.y + puck.radius && !puck.right_reflected {
		puck.speed.x *= -1
		puck.left_reflected = false
		puck.right_reflected = true
	}
}

fn create_puck(mut app App) {
	app.puck = Puck{
		pos: Dim{x: width/2, y: height/2}
		radius: 20
		color: gx.white
		speed: Dim{x: 3, y: 3}
	}
}