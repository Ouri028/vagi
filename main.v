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
	a.answer()
	a.stream_file('moo2')
}
