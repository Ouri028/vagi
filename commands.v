module v_fastagi

/**
*  response.value = "-1" | "0"
*
* -1. channel failure
*
*  0 successful
* https://wiki.asterisk.org/wiki/display/AST/Asterisk+17+AGICommand_answer
*/

pub fn (mut a AGI) answer() {
	a.send_command('ANSWER')
}

/**
* Interrupts expected flow of Async AGI commands and
* returns control to previous source (typically, the PBX dialplan).
*
* https://wiki.asterisk.org/wiki/display/AST/Asterisk+17+AGICommand_asyncagi+break
*/
pub fn (mut a AGI) async_agi_break() Response {
	return a.send_command('ASYNCAGI BREAK')
}

/**
* response.value = "1" | "2" | "3" | "4" | "5" | "6" | "7" \
*
* 0  Channel is down and available.
*
* 1  Channel is down, but reserved.
*
* 2  Channel is off hook.
*
* 3  Digits (or equivalent) have been dialed.
*
* 4  Line is ringing.
*
* 5  Remote end is ringing.
*
* 6  Line is up.
*
* 7  Line is busy.
* https://wiki.asterisk.org/wiki/display/AST/Asterisk+17+AGICommand_channel+status
*/

pub fn (mut a AGI) channel_status() Response {
	return a.send_command('CHANNEL STATUS')
}

/**
* Playback specified file with ability to be controlled by user
*
* filename -- filename to play (on the asterisk server)
*  (don't use file-type extension!)
*
* escape_digits -- if provided default ['1', '2', '3', '4', '5', '6', '7', '8', '0'],
*
* skip_ms -- number of milliseconds to skip on FF/REW
*
* ff_char -- if provided, the set of chars that fast-forward
*
* rew_char -- if provided, the set of chars that rewind
*
* pause_char -- if provided, the set of chars that pause playback
* https://wiki.asterisk.org/wiki/display/AST/Asterisk+17+AGICommand_control+stream+file
*/
pub fn (mut a AGI) control_stream_file(filename string, escape_digits []string, skip_ms string, ff_char string, rew_char string, pause_char string, offsetms string) Response {

	mut command := 'CONTROL STREAM FILE $filename "$escape_digits" $skip_ms $ff_char $rew_char'
	if pause_char != '' {
		command += ' $pause_char'
	}
	if offsetms != '' {
		command += ' $offsetms'
	}
	return a.send_command(command)
}

/**
* Deletes an entry in the Asterisk database for a given family and key.
* response.value = "0" | "1"
*
* 0  successful
*
* 1  otherwise.
*
* https://wiki.asterisk.org/wiki/display/AST/Asterisk+17+AGICommand_database+del
*/
pub fn (mut a AGI) database_del(family string, key string) Response {
	return a.send_command('DATABASE DEL $family $key')
}

/**
* Deletes a family or specific keytree within a family in the Asterisk database.
* response.result = "0" | "1"
*
* 0   if successful
*
* 1  otherwise.
*
* https://wiki.asterisk.org/wiki/display/AST/Asterisk+17+AGICommand_database+deltree
*/
pub fn (mut a AGI) database_del_tree(family string, key_tree string) Response {
	return a.send_command('DATABASE DELTREE $family $key_tree')
}

/**
* Retrieves an entry in the Asterisk database for a given family and key.
* response.result = "0" | "1"
*
* 0  key is not set
*
* 1  key is set and returns the variable in response.value
*
* https://wiki.asterisk.org/wiki/display/AST/Asterisk+17+AGICommand_database+get
*/
pub fn (mut a AGI) database_get(family string, key string) Response {
	return a.send_command('DATABASE GET $family $key')
}

/**
* Adds or updates an entry in the Asterisk database for a given family, key, and value.
* response.result = "0" | "1"
*
* 0 successful
*
* 1  otherwise.
*
* https://wiki.asterisk.org/wiki/display/AST/Asterisk+17+AGICommand_database+put
*/
pub fn (mut a AGI) database_put(family string, key string, value string) Response {
	return a.send_command('DATABASE PUT $family $key $value')
}

/**
* Executes application with given options.
* Returns whatever the application returns, or -2 on failure to find application.
*/
pub fn (mut a AGI) exec(cmd ...string) Response {
	return a.send_command(cmd.join(' '))
}

/**
* Prompts for DTMF on a channel
* Stream the given file, and receive DTMF data.
* Returns the digits received from the channel at the other end.
* https://wiki.asterisk.org/wiki/display/AST/Asterisk+17+AGICommand_get+data
*/
pub fn (mut a AGI) get_data(file string, timeout string, max_digits string) Response {
	return a.send_command('GET DATA $file $timeout $max_digits')
}

pub fn (mut a AGI) get_full_variable(name string, channel_name string) Response {
	return a.send_command('GET FULL VARIABLE $name $channel_name')
}

pub fn (mut a AGI) get_option(filename string, escape_digits []string, timeout string) Response {

	return a.send_command('GET OPTION $filename "$escape_digits" $timeout')
}

pub fn (mut a AGI) get_variable(key string) Response {
	return a.send_command('GET VARIABLE $key')
}

pub fn (mut a AGI) go_sub(context string, extension string, priority string, opt_arg string) {
	a.send_command('GOSUB $context $extension $priority $opt_arg')
}

pub fn (mut a AGI) hangup() {
	a.send_command('HANGUP')
}

pub fn (mut a AGI) noop() {
	a.send_command('NOOP')
}

pub fn (mut a AGI) receive_char(timeout string) {
	a.send_command('RECEIVE CHAR $timeout')
}

pub fn (mut a AGI) receive_text(timeout string) {
	a.send_command('RECEIVE TEXT $timeout')
}

pub fn (mut a AGI) record_file(file string, format string, escape_digits []string, timeout string, offset_samples string, beep bool, silence string) Response {

	mut command := 'RECORD FILE "$file" $format "$escape_digits" $timeout $offset_samples'
	if beep {
		command += ' 1'
	}
	if silence != '' {
		command += ' s=$silence'
	}
	return a.send_command(command)
}

pub fn (mut a AGI) say_alpha(label string, escape_digits []string) Response {

	return a.send_command('SAY ALPHA $label "$escape_digits"')
}

pub fn (mut a AGI) say_date(date string, escape_digits []string) {

	a.send_command('SAY DATE $date "$escape_digits"')
}

pub fn (mut a AGI) say_date_time(date string, escape_digits []string, format string, timezone string) {

	mut command := 'SAY DATETIME $date "$escape_digits"'
	if format != '' {
		command += ' $format'
	}
	if timezone != '' {
		command += ' $timezone'
	}
	a.send_command(command)
}

pub fn (mut a AGI) say_digits(data string, escape_digits []string) {

	a.send_command('SAY DIGITS $data "$escape_digits"')
}

pub fn (mut a AGI) say_number(data string, escape_digits []string, gender string) {

	mut command := 'SAY NUMBER $data "$escape_digits"'
	if gender != '' {
		command += ' $gender'
	}
	a.send_command(command)
}

pub fn (mut a AGI) say_phonetic(data string, escape_digits []string) {

	a.send_command('SAY PHONETIC "$data" "$escape_digits"')
}

pub fn (mut a AGI) say_time(date string, escape_digits []string) {

	a.send_command('SAY TIME $date "$escape_digits"')
}

pub fn (mut a AGI) send_image(name string) {
	a.send_command('SEND IMAGE $name')
}

pub fn (mut a AGI) send_text(text string) {
	a.send_command('SEND TEXT "$text"')
}

pub fn (mut a AGI) set_auto_hangup(time string) {
	a.send_command('SET AUTOHANGUP $time')
}

pub fn (mut a AGI) set_caller_id(caller_id string) {
	a.send_command('SET CALLERID $caller_id')
}

pub fn (mut a AGI) set_context(context string) {
	a.send_command('SET CONTEXT $context')
}

pub fn (mut a AGI) set_extension(extension string) {
	a.send_command('SET EXTENSION $extension')
}

pub fn (mut a AGI) set_music(mode string, class_name string) {
	a.send_command('SET MUSIC $mode $class_name')
}

pub fn (mut a AGI) set_priority(priority string) {
	a.send_command('SET PRIORITY $priority')
}

pub fn (mut a AGI) set_variable(name string, value string) {
	a.send_command('SET VARIABLE $name "$value"')
}

pub fn (mut a AGI) stream_file(filename string, escape_digits []string) {

	a.send_command('STREAM FILE "$filename" "$escape_digits"')
}

pub fn (mut a AGI) verbose(message string, level string) {
	mut command := 'VERBOSE "$message"'
	if level != '' {
		command += ' $level'
	}
	a.send_command(command)
}

pub fn (mut a AGI) wait_for_digit(timeout string) {
	a.send_command('WAIT FOR DIGIT $timeout')
}

pub fn (mut a AGI) dial(target string, timeout string, params string) {
	a.exec('Dial', '$target,$timeout', params)
}
