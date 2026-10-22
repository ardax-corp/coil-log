use tests::assert;
use log::{Logger, Level, format_line, level_tag};
use io::{open};
use io::file::{read_text};
use io::fs::{remove_file};
use text::{Searchable};

fn write_logger(string path, Level min) -> Logger {
    let s = match open(path, "w") {
        Result::Ok(st) => st,
        Result::Err(_) => panic "open write",
    };
    return Logger::to(min, s);
}

fn slurp(string path) -> string {
    return match read_text(path) {
        Result::Ok(t) => t,
        Result::Err(_) => panic "read_text",
    };
}

fn wipe(string path) {
    match remove_file(path) {
        Result::Ok(_) => 0,
        Result::Err(_) => 0,
        default => 0,
    };
}

test("level tags are short names") {
    assert!(level_tag(Level::Error) == "ERROR");
    assert!(level_tag(Level::Warn) == "WARN");
    assert!(level_tag(Level::Info) == "INFO");
    assert!(level_tag(Level::Debug) == "DEBUG");
}

test("format_line has tag message and timestamp secs") {
    let line = format_line(Level::Info, "hello");
    assert!(line.contains("INFO hello\n") || line.contains("INFO hello"), "tag and message");
    let parts = line.split(" ");
    assert!(parts.len() >= 2, "at least tag and message");
    if line.contains(" INFO ") {
        assert!(parts[0].len() > 0, "secs prefix");
    }
}

test("format_line flattens newlines") {
    let line = format_line(Level::Warn, "a\nb\rc");
    assert!(line.contains("WARN a b c"), "flattened");
}

test("min level filters debug") {
    let path = "/tmp/coil_log_filter.txt";
    wipe(path);
    let log = write_logger(path, Level::Info);
    log.debug("nope");
    log.info("yes");
    let body = slurp(path);
    wipe(path);
    assert!(!body.contains("DEBUG"), "debug dropped");
    assert!(body.contains("INFO yes"), "info kept");
}

test("each level method writes its tag") {
    let path = "/tmp/coil_log_methods.txt";
    wipe(path);
    let log = write_logger(path, Level::Debug);
    log.error("e");
    log.warn("w");
    log.info("i");
    log.debug("d");
    let body = slurp(path);
    wipe(path);
    assert!(body.contains("ERROR e"), "error");
    assert!(body.contains("WARN w"), "warn");
    assert!(body.contains("INFO i"), "info");
    assert!(body.contains("DEBUG d"), "debug");
}

test("log Level path and empty message") {
    let path = "/tmp/coil_log_empty.txt";
    wipe(path);
    let log = write_logger(path, Level::Error);
    log.log(Level::Warn, "skip");
    log.log(Level::Error, "");
    let body = slurp(path);
    wipe(path);
    assert!(!body.contains("WARN"), "warn below min");
    assert!(body.contains("ERROR"), "empty still tagged");
}

test("warn min keeps error") {
    let path = "/tmp/coil_log_warn_min.txt";
    wipe(path);
    let log = write_logger(path, Level::Warn);
    log.info("drop");
    log.warn("keep");
    log.error("also");
    let body = slurp(path);
    wipe(path);
    assert!(!body.contains("INFO"), "info dropped");
    assert!(body.contains("WARN keep"), "warn");
    assert!(body.contains("ERROR also"), "error");
}
