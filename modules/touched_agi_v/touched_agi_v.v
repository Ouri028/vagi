module touched_agi_v

import io
import log
import net
import sync

// State describes the Asterisk channel state.  There are mapped
// directly to the Asterisk enumerations.
enum State {
	// StateDown indicates the channel is down and available
	state_down
	// StateReserved indicates the channel is down but reserved
	state_reserved
	// StateOffhook indicates that the channel is offhook
	state_offhook
	// StateDialing indicates that digits have been dialed
	state_dialing
	// StateRing indicates the channel is ringing
	state_ring
	// StateRinging indicates the channel's remote end is rining (the channel is receiving ringback)
	state_ringing
	// StateUp indicates the channel is up
	state_up
	// StateBusy indicates the line is busy
	state_busy
	// StateDialingOffHook indicates digits have been dialed while offhook
	state_dialing_offhook
	// StatePreRing indicates the channel has detected an incoming call and is waiting for ring
	state_prering
}

// AGI represents an AGI session
pub struct AGI {
pub mut:
	// Variables stored the initial variables
	// transmitted from Asterisk at the start
	// of the AGI session.
	variables map[string]string
	r         io.BufferedReader
	conn      net.TcpConn
	mu        sync.Mutex
	// // Logging ability
	logger log.Log
}

// Response represents a response to an AGI
// request.
pub struct Response {
pub mut:
	error         string
	status        int    // HTTP-style status code received
	result        int    // Result is the numerical return (if parseable)
	result_string string // Result value as a string
	value         string // Value is the (optional) string value returned
}

const (
	// StatusOK indicates the AGI command was
	// accepted.
	status_ok           = 200

	// StatusInvalid indicates Asterisk did not
	// understand the command.
	status_invalid      = 510

	// StatusDeadChannel indicates that the command
	// cannot be performed on a dead (hungup) channel.
	status_dead_channel = 511

	// StatusEndUsage indicates...TODO
	status_end_usage    = 520
	// ErrHangup indicates the channel hung up during processing
	err_hangup          = 'hangup'
)

// Regex for AGI response result code and value
// var responseRegex = regexp.MustCompile(`^([\d]{3})\sresult=(\-?[[:alnum:]]*)(\s.*)?$`)

// // New creates an AGI session from the given reader and writer.
pub fn new(mut conn net.TcpConn, mut a AGI) AGI {
	return a.new_with_eagi(mut conn)
}

// NewWithEAGI returns a new AGI session to the given `os.Stdin` `io.Reader`,
// EAGI `io.Reader`, and `os.Stdout` `io.Writer`. The initial variables will
// be read in.
pub fn (mut a AGI) new_with_eagi(mut conn net.TcpConn) AGI {
	a.variables = map[string]string{}
	mut reader := io.new_buffered_reader(reader: conn)
	a.r = reader
	a.conn = conn
	return a
}

// Listen binds an AGI HandlerFunc to the given TCP `host:port` address, creating a FastAGI service.
pub fn listen<T>(port string, mut a T) {
	mut l := net.listen_tcp(.ip6, ':$port') or { panic('[ERROR] Failed to bind address with error -> ${err.msg()}') }

	defer {
		l.close() or {}
	}

	addr := l.addr() or { panic('[ERROR] Failed to bind address with error -> ${err.msg()}') }
	eprintln('[Touched-AGI] Fast AGI listening on $addr')
	for {
		mut socket := l.accept() or { panic('[ERROR] Failed to accept socket client with error -> ${err.msg()}') }
		new(mut socket, mut a)
		a.instance()
		a.close()
	}
}

pub fn (a AGI) instance() {}

// Close closes any network connection associated with the AGI instance
pub fn (mut a AGI) close() {
	a.conn.close() or { panic(err.msg()) }
	println('Connection Closed()')
}

pub fn (mut a AGI) send_command(cmd ...string) {
	mut resp := Response{}
	mut raw_cmd := cmd.join(' ')
	raw_cmd += '\n'
	println(raw_cmd)
	a.conn.write(raw_cmd.bytes()) or { 
		resp.error = 'Failed to send command to Asterisk with error: ${err.msg()}'
		return
	 }
	for {
		raw := a.r.read_line() or { 
			resp.error = 'Failed to read buffer with error: ${err.msg()}'
			break
		 }
		 println(raw)
		if raw == '' {
			break
		}
		if raw.contains('HANGUP') || raw.contains('-1') {
			resp.error = err_hangup
			break
		}
	}	
}

// Answer answers the channel
pub fn (mut a AGI) answer() {
	a.send_command('ANSWER')
}

pub fn (mut a AGI) stream_file(filename string) {
	command := 'STREAM FILE "${filename}" "[]"'
	a.send_command(command)
}

// GetData plays a file and receives DTMF, returning the received digits
pub fn (mut a AGI) get_data(sound string, timeout string, max_digits string) {
	a.send_command("GET DATA", sound, timeout, max_digits)
}
