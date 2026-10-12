use tests::assert;
use log::{Logger, Level, format_line, level_tag};
use io::{open};
use io::file::{read_text};
use io::fs::{remove_file};
use text::{contains, split};

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
    assert!(contains(line, "INFO hello\n") || contains(line, "INFO hello"), "tag and message");
    let parts = match split(line, " ") {
        Result::Ok(p) => p,
        Result::Err(_) => panic "split",
    };
    assert!(len(parts) >= 2, "at least tag and message");
    if contains(line, " INFO ") {
        assert!(len(parts[0]) > 0, "secs prefix");
    }
}

test("format_line flattens newlines") {
    let line = format_line(Level::Warn, "a\nb\rc");
    assert!(contains(line, "WARN a b c"), "flattened");
}

test("min level filters debug") {
    let path = "/tmp/coil_log_filter.txt";
    wipe(path);
    let log = write_logger(path, Level::Info);
    log.debug("nope");
    log.info("yes");
    let body = slurp(path);
    wipe(path);
    assert!(!contains(body, "DEBUG"), "debug dropped");
    assert!(contains(body, "INFO yes"), "info kept");
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
    assert!(contains(body, "ERROR e"), "error");
    assert!(contains(body, "WARN w"), "warn");
    assert!(contains(body, "INFO i"), "info");
    assert!(contains(body, "DEBUG d"), "debug");
}

test("log Level path and empty message") {
    let path = "/tmp/coil_log_empty.txt";
    wipe(path);
    let log = write_logger(path, Level::Error);
    log.log(Level::Warn, "skip");
    log.log(Level::Error, "");
    let body = slurp(path);
    wipe(path);
    assert!(!contains(body, "WARN"), "warn below min");
    assert!(contains(body, "ERROR"), "empty still tagged");
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
    assert!(!contains(body, "INFO"), "info dropped");
    assert!(contains(body, "WARN keep"), "warn");
    assert!(contains(body, "ERROR also"), "error");
}
