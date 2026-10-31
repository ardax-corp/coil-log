// Leveled line logger. A `Logger` drops events below its minimum `Level` and
// writes each kept event as one line (`<secs> <TAG> <message>`) to a stream:
// stderr by default (through stdlib `io::sync::write_all`), or any `Stream`
// passed to `Logger::to`. Timestamps come from the `time` package.
use io::{stderr, Stream};
use io::sync::{write_all};
use string::{format, to_bytes, from_bytes};
use time::{timestamp};

/// Severity of a log event, from `Debug` (least severe) to `Error` (most severe).
///
/// Levels are ordered by severity, so `Level::Warn >= Level::Info`. A `Logger`
/// writes an event when its level is at least the logger's minimum.
///
/// # Examples
///
/// ```
/// use log::{Level};
/// # use tests::assert;
/// assert!(Level::Error > Level::Warn);
/// assert!(Level::Info >= Level::Debug);
/// ```
#[repr(int)]
#[derive(Eq, Ord)]
enum Level {
    /// Detail for debugging; usually filtered out.
    Debug = 0,
    /// Normal operation: startup, requests, progress.
    Info = 1,
    /// Something unexpected that the program recovered from.
    Warn = 2,
    /// A failure the user or operator should see.
    Error = 3,
}

/// The tag written for `level` in a log line: `DEBUG`, `INFO`, `WARN` or `ERROR`.
///
/// Use this, not `Show`, to print a level: `Level` is a `repr(int)` enum, so
/// `Show` prints its backing int.
///
/// # Examples
///
/// ```
/// use log::{level_tag, Level};
/// # use tests::assert;
/// assert!(level_tag(Level::Warn) == "WARN");
/// assert!(level_tag(Level::Debug) == "DEBUG");
/// ```
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

/// The line a `Logger` writes for an event: `<secs> <TAG> <msg>` and a newline.
///
/// `secs` is the current Unix time in whole seconds (`time::timestamp`); when
/// the clock cannot be read the prefix is left out and the line starts with
/// the tag. Every `\n` and `\r` in `msg` becomes a space, so one event is
/// always exactly one line.
///
/// # Examples
///
/// ```
/// use log::{format_line, Level};
/// use text::{Searchable};
/// # use tests::assert;
/// let line = format_line(Level::Info, "listening\non :8080");
/// assert!(line.ends_with(" INFO listening on :8080\n"));
/// ```
fn format_line(Level level, string msg) -> string {
    let body = flatten_msg(msg);
    let tag = level_tag(level);
    return match timestamp() {
        Result::Ok(ts) => format("%i %s %s\n", ts.secs(), tag, body),
        Result::Err(_) => format("%s %s\n", tag, body),
        default => format("%s %s\n", tag, body),
    };
}

/// A logger that writes events at or above a minimum `Level` to a stream.
///
/// Each kept event is one line in the `format_line` layout. Events below the
/// minimum are dropped without formatting. Logging never fails or panics: a
/// write error drops that line.
///
/// # Examples
///
/// ```
/// use log::{Logger, Level};
/// let log = Logger::new(Level::Info);
/// log.info("server started");
/// log.debug("not written: below the minimum");
/// log.error("disk full");
/// ```
class Logger {
    min: Level,
    out: Stream,
}

impl Logger {
    /// A logger writing events at or above `min` to stderr.
    pub static fn new(Level min) -> Logger {
        return new Logger(min, stderr());
    }

    /// A logger writing events at or above `min` to `out`, such as a file
    /// opened for writing.
    ///
    /// The logger does not close `out`; the caller does.
    ///
    /// # Examples
    ///
    /// ```no_run
    /// use log::{Logger, Level};
    /// use io::{open, close, IoError};
    ///
    /// fn main() -> Result<(), IoError> {
    ///     let file = open("app.log", "w")?;
    ///     let log = Logger::to(Level::Debug, file);
    ///     log.debug("written to app.log");
    ///     close(file)?;
    ///     return ();
    /// }
    /// ```
    pub static fn to(Level min, Stream out) -> Logger {
        return new Logger(min, out);
    }

    /// Write `msg` at `level`, or do nothing when `level` is below the minimum.
    ///
    /// The `error` / `warn` / `info` / `debug` methods are shorthands for this.
    pub fn log(Level level, string msg) {
        if level >= self.min {
            match write_all(self.out, to_bytes(format_line(level, msg))) {
                Result::Ok(_) => 0,
                Result::Err(_) => 0,
                default => 0,
            };
        }
    }

    /// Write `msg` at `Level::Error`.
    pub fn error(string msg) {
        self.log(Level::Error, msg);
    }

    /// Write `msg` at `Level::Warn`.
    pub fn warn(string msg) {
        self.log(Level::Warn, msg);
    }

    /// Write `msg` at `Level::Info`.
    pub fn info(string msg) {
        self.log(Level::Info, msg);
    }

    /// Write `msg` at `Level::Debug`.
    pub fn debug(string msg) {
        self.log(Level::Debug, msg);
    }
}
