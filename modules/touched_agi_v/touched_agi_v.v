module touched_agi_v

import io
import log
import net
import sync

// State describes the Asterisk channel state.  There are mapped
// directly to the Asterisk enumerations.
enum State {
	// StateDown indicates the channel is down and available
	statedown
	// StateReserved indicates the channel is down but reserved
	statereserved
	// StateOffhook indicates that the channel is offhook
	stateoffhook
	// StateDialing indicates that digits have been dialed
	statedialing
	// StateRing indicates the channel is ringing
	statering
	// StateRinging indicates the channel's remote end is rining (the channel is receiving ringback)
	stateringing
	// StateUp indicates the channel is up
	stateup
	// StateBusy indicates the line is busy
	statebusy
	// StateDialingOffHook indicates digits have been dialed while offhook
	statedialingoffhook
	// StatePreRing indicates the channel has detected an incoming call and is waiting for ring
	stateprering
}

// AGI represents an AGI session
pub struct AGI {
pub mut:
	// Variables stored the initial variables
	// transmitted from Asterisk at the start
	// of the AGI session.
	variables map[string]string
	r		  io.BufferedReader
	conn      net.TcpConn
	mu	      sync.Mutex
	// // Logging ability
	logger log.Log
}

// Response represents a response to an AGI
// request.
pub struct Response {
pub mut:
	error        string
	status       int    // HTTP-style status code received
	result       int    // Result is the numerical return (if parseable)
	result_string string // Result value as a string
	value        string // Value is the (optional) string value returned
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

// Res returns the ResultString of a Response, as well as any error encountered.  Depending on the command, this is sometimes more useful than Val()
pub fn (r Response) res() (string, string) {
	return r.result_string, r.error
}

// Err returns the error value from the response
pub fn (r Response) err() string {
	return r.error
}

// Val returns the response value and error
pub fn (r Response) val() (string, string) {
	return r.value, r.error
}

// Regex for AGI response result code and value
// var responseRegex = regexp.MustCompile(`^([\d]{3})\sresult=(\-?[[:alnum:]]*)(\s.*)?$`)

// // New creates an AGI session from the given reader and writer.
pub fn new(mut conn net.TcpConn) AGI {
	return new_with_eagi(mut conn)
}

// NewWithEAGI returns a new AGI session to the given `os.Stdin` `io.Reader`,
// EAGI `io.Reader`, and `os.Stdout` `io.Writer`. The initial variables will
// be read in.
pub fn new_with_eagi(mut conn net.TcpConn) AGI {
	mut a := AGI{
		variables: map[string]string{}
	}
	defer {
		conn.close() or { panic(err) }
	}
	mut reader := io.new_buffered_reader(reader: conn)
	a.r = reader
	a.conn = conn
	return a
}

// Listen binds an AGI HandlerFunc to the given TCP `host:port` address, creating a FastAGI service.
pub fn listen(port string, handler fn(mut a AGI)) {
	mut l := net.listen_tcp(.ip6, ':$port') or { panic(err) }

	defer {
		l.close() or {}
	}
	addr := l.addr() or { panic(err) }
	eprintln('[Touched-AGI] Fast AGI listening on $addr')
	for {
		mut socket := l.accept() or { panic(err) }
		go handler(new(mut socket))
	}
}


// Close closes any network connection associated with the AGI instance
pub fn (mut a AGI) close() {
	a.conn.close() or {panic(err)}
}


pub fn (mut a AGI) send_command(cmd string) {
	mut resp := Response{}
	a.mu.@lock()
	defer {
		a.mu.unlock()
	}
	mut raw_cmd := '$cmd\n'
	a.conn.write(raw_cmd.bytes()) or {return}
	for {
		raw := a.r.read_line() or { return }
		println(raw)
		if raw == '' {
			break
		}
		if raw.contains('HANGUP') {
			resp.error = err_hangup
			return
		}
	}
}

// Answer answers the channel
pub fn (mut a AGI) answer() {
	a.send_command('ANSWER')
}