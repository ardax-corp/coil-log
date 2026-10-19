// Min-level logger. Default sink is stderr via stdlib `io::sync::write_all`.
use io::{stderr, Stream};
use io::sync::{write_all};
use string::{format, to_bytes, from_bytes};
use time::{timestamp};

/// Severity. Higher backing int is more severe. Log when `level >= min`.
#[repr(int)]
#[derive(Eq, Ord)]
enum Level {
    Debug = 0,
    Info = 1,
    Warn = 2,
    Error = 3,
}

/// Short tag for a log line. Do not use `Show` — scalar Show is the backing int.
fn level_tag(Level level) -> string {
    return match level {
        Level::Error => "ERROR",
        Level::Warn => "WARN",
        Level::Info => "INFO",
        Level::Debug => "DEBUG",
        default => "DEBUG",
    };
}

fn flatten_msg(string msg) -> string {
    let b = to_bytes(msg);
    let out: Vec<byte> = Vec::new();
    let i = 0;
    let n = b.len();
    let nl: byte = "\n";
    let cr: byte = "\r";
    let sp: byte = " ";
    while i < n {
        let c = b[i];
        if c == nl {
            out.push(sp);
        }
        if c == cr {
            out.push(sp);
        }
        if c != nl {
            if c != cr {
                out.push(c);
            }
        }
        i = i + 1;
    }
    return match from_bytes(out) {
        Result::Ok(s) => s,
        Result::Err(_) => msg,
        default => msg,
    };
}

/// One event, one line. Newlines in `msg` become spaces. Clock from `timestamp().secs()`.
fn format_line(Level level, string msg) -> string {
    let body = flatten_msg(msg);
    let tag = level_tag(level);
    return match timestamp() {
        Result::Ok(ts) => format("%i %s %s\n", ts.secs(), tag, body),
        Result::Err(_) => format("%s %s\n", tag, body),
        default => format("%s %s\n", tag, body),
    };
}

class Logger {
    min: Level,
    out: Stream,
}

impl Logger {
    /// Stderr sink.
    pub static fn new(Level min) -> Logger {
        return new Logger(min, stderr());
    }

    /// Inject a `Stream` (tests: a file opened for write).
    pub static fn to(Level min, Stream out) -> Logger {
        return new Logger(min, out);
    }

    pub fn log(Level level, string msg) {
        if level >= self.min {
            match write_all(self.out, to_bytes(format_line(level, msg))) {
                Result::Ok(_) => 0,
                Result::Err(_) => 0,
                default => 0,
            };
        }
    }

    pub fn error(string msg) {
        self.log(Level::Error, msg);
    }

    pub fn warn(string msg) {
        self.log(Level::Warn, msg);
    }

    pub fn info(string msg) {
        self.log(Level::Info, msg);
    }

    pub fn debug(string msg) {
        self.log(Level::Debug, msg);
    }
}
