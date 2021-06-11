struct String {
	mut: 
		text []string
}

fn main() {
	mut stryng := &String{}
	stryng.text = ['df', 'dfdf']
	println(stryng.text.len)
	stryng.text.prepend('sd')
	println(stryng.text)
	println(stryng.text.len)
	stryng.text.reverse_in_place()
	println(stryng.text)

}