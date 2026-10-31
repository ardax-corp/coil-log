# Consuming coil-log

This package is `log`. `use log::{Logger, Level}` resolves from `src/log.hy`.

`io::sync` comes from coil-stdlib. Timestamps come from [coil-time](https://github.com/ardax-corp/coil-time), which is pure Coil (no `libtime`, no `dload`). coil reads no `coil.toml` and no `coil.lock`; pass `--root` (default search is `src` under cwd).

## Depend on it

With [spool](https://github.com/ardax-corp/spool):

```bash
spool add log --git https://github.com/ardax-corp/coil-log.git --rev <commit SHA>
```

This repo has no tags, so pin a commit with `--rev`. Its `coil.toml` declares `time` as a git dependency on coil-time's default branch, so spool resolves it too. spool writes `coil.lock` (`rev` + `content_hash`), links `.spool/deps/log` and `.spool/deps/time`, and passes `--root` for each plus coil-stdlib to `coil`.

## Sibling checkout

Without spool, clone this repo next to your project, along with coil-stdlib and coil-time, and pass the roots yourself:

```bash
git clone https://github.com/ardax-corp/coil-log.git ../coil-log
git clone https://github.com/ardax-corp/coil-stdlib.git ../coil-stdlib
git clone https://github.com/ardax-corp/coil-time.git ../coil-time

coil \
  --root ../coil-log/src \
  --root ../coil-stdlib/src \
  --root ../coil-time/src \
  main.hy
```

`--root` is what loads `src/log.hy`, stdlib `io::sync`, and `src/time.hy`. Writing a log file you open needs `--allow-write` (spool: `[permissions] write = true`).

## Call Logger

Signatures and examples are in the `///` docs of [`src/log.hy`](../src/log.hy). More call patterns are in [`tests/logger.hy`](../tests/logger.hy).

```coil
use log::{Logger, Level};

fn main() {
    let log = Logger::new(Level::Info);
    log.info("ready");
    log.debug("not written");
    log.error("failed");
}
```

`Logger::new(min)` writes to stderr. `Logger::to(min, stream)` injects any `io` `Stream` (a log file, or a file in tests). `error` / `warn` / `info` / `debug` / `log(Level, string)` are no-ops when `level < min`. Write failures and clock failures do not panic: a failed `timestamp()` omits the secs prefix; a failed write is dropped.

Each event is one line: optional `secs` (int from `Timestamp.secs()`), a short tag (`ERROR` / `WARN` / `INFO` / `DEBUG`), the message, then LF. Scalar `Show` on `Level` would print the backing int; the line uses `level_tag` instead. Newlines in the message are replaced with spaces. `format_line(level, msg)` returns that line without writing it.

```coil
use log::{Logger, Level};
use io::{open, close, IoError};

fn main() -> Result<(), IoError> {
    let file = open("/tmp/app.log", "w")?;
    let log = Logger::to(Level::Debug, file);
    log.debug("trace");
    close(file)?;
    return ();
}
```

### stdlib and time

`io` and `string` are compiler built-ins; `io::sync` comes from coil-stdlib via `--root`. `timestamp` comes from coil-time via `--root`; it needs no `dload` grant. This package has no native code of its own.
