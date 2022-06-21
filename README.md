# Asterisk FastAGI library for the V programming language (v-lang)

This is an Asterisk FastAGI interface library for V-Lang.

#### Install:

```bash
v install Ouri028.vagi
```

#### Link dependencies in v.mod:

```V
Module {
	name: 'agi'
	description: ''
	version: ''
	license: ''
	dependencies: ['Ouri028.vagi']
}

```

```V
module main

import ouri028.vagi

pub struct Agi {
	vagi.AGI
}

fn main() {
	mut agi := Agi{}
	vagi.listen('5000', mut &agi)
}

pub fn (mut a Agi) instance() {
	defer {
		a.close()
	}
	x := a.get_data('beep', '5000', '13')
	println(x)
}

```

#### Public functions and structs:
```V
fn listen<T>(port string, mut a T)
fn new(mut conn net.TcpConn, mut a AGI) AGI
fn (a AGI) instance()
struct AGI {
pub mut:
// Variables stored the initial variables
// transmitted from Asterisk at the start
// of the AGI session.
        variables map[string]string
        r         io.BufferedReader
        conn      net.TcpConn
        mu        sync.Mutex
}
fn (mut a AGI) answer()
fn (mut a AGI) async_agi_break() Response
fn (mut a AGI) channel_status() Response
fn (mut a AGI) close()
fn (mut a AGI) control_stream_file(filename string, mut escape_digits []string, skip_ms string, ff_char string, rew_char string, pause_char string, offsetms string) Response
fn (mut a AGI) database_del(family string, key string) Response
fn (mut a AGI) database_del_tree(family string, key_tree string) Response
fn (mut a AGI) database_get(family string, key string) Response
fn (mut a AGI) database_put(family string, key string, value string) Response
fn (mut a AGI) dial(target string, timeout string, params string)
fn (mut a AGI) exec(cmd ...string) Response
fn (mut a AGI) get_data(file string, timeout string, max_digits string) Response
fn (mut a AGI) get_full_variable(name string, channel_name string) Response
fn (mut a AGI) get_option(filename string, mut escape_digits []string, timeout string) Response
fn (mut a AGI) get_variable(key string) Response
fn (mut a AGI) go_sub(context string, extension string, priority string, opt_arg string)
fn (mut a AGI) hangup()
fn (mut a AGI) noop()
fn (mut a AGI) receive_char(timeout string)
fn (mut a AGI) receive_text(timeout string)
fn (mut a AGI) record_file(file string, format string, mut escape_digits []string, timeout string, offset_samples string, beep bool, silence string) Response
fn (mut a AGI) say_alpha(label string, mut escape_digits []string) Response
fn (mut a AGI) say_date(date string, mut escape_digits []string)
fn (mut a AGI) say_date_time(date string, mut escape_digits []string, format string, timezone string)
fn (mut a AGI) say_digits(data string, mut escape_digits []string)
fn (mut a AGI) say_number(data string, mut escape_digits []string, gender string)
fn (mut a AGI) say_phonetic(data string, mut escape_digits []string)
fn (mut a AGI) say_time(date string, mut escape_digits []string)
fn (mut a AGI) send_command(cmd string) Response
fn (mut a AGI) send_image(name string)
fn (mut a AGI) send_text(text string)
fn (mut a AGI) set_auto_hangup(time string)
fn (mut a AGI) set_caller_id(caller_id string)
fn (mut a AGI) set_context(context string)
fn (mut a AGI) set_extension(extension string)
fn (mut a AGI) set_music(mode string, class_name string)
fn (mut a AGI) set_priority(priority string)
fn (mut a AGI) set_variable(name string, value string)
fn (mut a AGI) stream_file(filename string, mut escape_digits []string)
fn (mut a AGI) verbose(message string, level string)
fn (mut a AGI) wait_for_digit(timeout string)
struct Response {
pub mut:
        error  string
        status string // HTTP-style status code received
	result string // Asterisk result code
        value  string // Value is the (optional) string value returned
}
```
