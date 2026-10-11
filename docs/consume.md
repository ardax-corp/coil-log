# Consuming coil-log

This package is `log`. `use log::{Logger, Level}` resolves from `src/log.hy`. The repo is private: use an org-authenticated git URL (`git@github.com:ardax-corp/coil-log.git` or HTTPS with credentials).

`io::sync` comes from coil-stdlib, not a dependency of this package. Timestamps come from public [coil-time](https://github.com/ardax-corp/coil-time), which is pure Coil (no `libtime`, no `dload`). coil reads no `coil.toml` and no `coil.lock`; pass `--root` (default search is `src` under cwd).

## Depend on it

With [spool](https://github.com/ardax-corp/spool) (git needs credentials that can read this repo):

```bash
spool add log --git git@github.com:ardax-corp/coil-log.git --rev <commit SHA>
spool add time --git https://github.com/ardax-corp/coil-time.git --rev <commit SHA>
```

Neither repo has tags, so pin commits with `--rev`. This repo's own `coil.toml` names `time` as a path dep under `.ci/`, so add `time` yourself. spool writes `coil.lock` (`rev` + `content_hash`), links `.spool/deps/log` and `.spool/deps/time`, and passes `--root` for each plus coil-stdlib to `coil`.

## Sibling checkout

Clone this repo next to your project, coil-stdlib, and coil-time, and pass the roots yourself:

```bash
coil test \
  --root src \
  --root ../coil-log/src \
  --root ../coil-stdlib/src \
  --root ../coil-time/src
```

`--root` is what loads `src/log.hy`, stdlib `io::sync`, and `src/time.hy`. Writing a log file you open needs `--allow-write` (spool: `[permissions] write = true`).

## Call Logger

Signatures are in [`src/log.hy`](../src/log.hy). Call patterns are in [`tests/logger.hy`](../tests/logger.hy).

```coil
use log::{Logger, Level};

let log = Logger::new(Level::Info);
log.info("ready");
log.debug("not written");
log.error("failed");
```

`Logger::new(min)` writes to stderr. `Logger::to(min, stream)` injects any `io` `Stream` (open a file in tests). `error` / `warn` / `info` / `debug` / `log(Level, string)` are no-ops when `level < min`. Write failures and clock failures do not panic: a failed `timestamp()` omits the secs prefix; a failed write is dropped.

Each event is one line: optional `secs` (int from `Timestamp.secs()`), a short tag (`ERROR` / `WARN` / `INFO` / `DEBUG`), the message, then LF. Scalar `Show` on `Level` would print the backing int; the line uses `level_tag` instead. Newlines in the message are replaced with spaces.

```coil
use log::{Logger, Level};
use io::{open, close};

let s = open("/tmp/app.log", "w")?;
let log = Logger::to(Level::Debug, s);
log.debug("trace");
close(s)?;
```

### stdlib and time

`io` and `string` are compiler built-ins; `io::sync` comes from coil-stdlib via `--root`. `timestamp` comes from coil-time via `--root`; it needs no `dload` grant. This package has no native of its own.
