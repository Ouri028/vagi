module main

import touched_agi_v

pub struct Agi {
	touched_agi_v.AGI
}

fn main() {
	mut agi := Agi{}
	touched_agi_v.listen('5000', mut &agi)
}

pub fn (mut a Agi) instance() {
	defer {
		a.close()
	}
	// a.answer()
	x := a.get_data('beep', '5000', '13')
	println(x)
	// a.hangup()
}
