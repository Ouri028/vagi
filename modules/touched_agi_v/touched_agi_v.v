module touched_agi_v

import io
import net
import regex
import sync

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
}

// Response represents a response to an AGI
// request.
pub struct Response {
pub mut:
	error  string
	status string // HTTP-style status code received
	value  string // Value is the (optional) string value returned
}

const (
	err_hangup = 'HANGUP'
)

// // New creates an AGI session from the given reader and writer.
pub fn new(mut conn net.TcpConn, mut a AGI) AGI {
	return a.new_with_eagi(mut conn)
}

// NewWithEAGI returns a new AGI session to the given `os.Stdin` `io.Reader`,
// EAGI `io.Reader`, and `os.Stdout` `io.Writer`. The initial variables will
// be read in.
pub fn (mut a AGI) new_with_eagi(mut conn net.TcpConn) AGI {
	mut reader := io.new_buffered_reader(reader: io.make_readerwriter(conn, conn))
	a.r = reader
	a.conn = conn
	a.mu = sync.new_mutex()
	for {
		raw := a.r.read_line() or {
			eprintln('Failed to read buffer with error: $err.msg()')
			break
		}
		data := raw.split(': ')
		a.variables[data[0]] = data[1]
		if raw.contains('agi_arg_1') {
			break
		}
	}
	return a
}

// Listen binds an AGI HandlerFunc to the given TCP `host:port` address, creating a FastAGI service.
pub fn listen<T>(port string, mut a T) {
	mut l := net.listen_tcp(.ip6, ':$port') or {
		panic('[ERROR] Failed to bind address with error -> $err.msg()')
	}

	defer {
		l.close() or {}
	}

	addr := l.addr() or { panic('[ERROR] Failed to bind address with error -> $err.msg()') }
	eprintln('[Touched-AGI] Fast AGI listening on $addr')
	for {
		mut socket := l.accept() or {
			panic('[ERROR] Failed to accept socket client with error -> $err.msg()')
		}
		new(mut socket, mut a)
		a.instance()
		a.close()
	}
}

pub fn (a AGI) instance() {}

// Close closes any network connection associated with the AGI instance
pub fn (mut a AGI) close() {
	a.conn.close() or {}
	println('Connection Closed()')
}

pub fn (mut a AGI) send_command(cmd string) Response {
	mut resp := Response{}
	mut raw_cmd := cmd + '\n'
	mut re := regex.regex_opt(r'^([\d]{3})\sresult=(\-?[a-zA-Z0-9]*)(\s.*)?$') or {
		resp.error = 'Failed to parse regex with error: $err.msg()'
		return resp
	}
	defer {
		a.mu.unlock()
	}
	a.mu.@lock()
	a.conn.write_string(raw_cmd) or {
		resp.error = 'Failed to send command to Asterisk with error: $err.msg()'
	}

	for  {
		raw := a.r.read_line() or {
			resp.error = 'Failed to read buffer with error: $err.msg()'
			return resp
		}
		println(raw)
		if raw.contains('HANGUP') || raw.contains('-1') {
			resp.error = err_hangup
			break
		}
		_, _ := re.match_string(raw)
		resp.status = '${re.get_group_by_id(raw, 0)}'
		resp.value = '${re.get_group_by_id(raw, 1)}'
		if resp.status != '200' && resp.status != '' {
			resp.error = 'Non-200 status code'
		}
		if resp.status == '200' {
			return resp
		}
	}
	return resp
}

// answer answers the channel
pub fn (mut a AGI) answer() {
	a.send_command('ANSWER')
}

pub fn (mut a AGI) stream_file(filename string, escape_digits []string) {
	a.send_command('STREAM FILE "$filename" "$escape_digits"')
}

// get_data plays a file and receives DTMF, returning the received digits as a string
pub fn (mut a AGI) get_data(file string, timeout string, max_digits string) Response {
	return a.send_command('GET DATA $file $timeout $max_digits')
}

// get_data plays a file and receives DTMF, returning the received digits as a string
pub fn (mut a AGI) hangup() {
	a.send_command('HANGUP')
}
