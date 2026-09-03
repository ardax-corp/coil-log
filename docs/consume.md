# Consuming coil-log

This package is `log`. `use log::{Logger, Level}` resolves from `src/log.hy`. The repo is private: use an org-authenticated git URL (`git@github.com:ardax-corp/coil-log.git` or HTTPS with credentials).

coil-stdlib is a sibling `[module] roots` / `--root` entry (for `io` and string helpers), not a spool dependency of this package. Timestamps come from public [coil-time](https://github.com/ardax-corp/coil-time). Typecheck grant is `--allow-dload time`. The compiler does not read `[module] roots` for discovery; pass `--root` (default search is `src` under cwd).

Coil-to-Coil deps will be spool-owned once a public `spool` CLI exists. Until then `{ git }` parses and the pin is `coil.lock` `rev` + `content_hash`.

## Sibling checkout

Clone this repo next to your project, coil-stdlib, and coil-time. In the consumer:

```toml
[package]
name = "app"
version = "0.1.0"

[ffi]
search_paths = ["../coil-time/native"]

[dependencies]
time = { path = "../coil-time", trusted = true }
```

```bash
coil test \
  --allow-dload time \
  --ffi-search-path ../coil-time/native \
  --root src \
  --root ../coil-log/src \
  --root ../coil-stdlib/src \
  --root ../coil-time/src
```

`[dependencies] time = { path = "…" }` is spool metadata. The compiler does not follow path deps for discovery. `--root` is what loads `src/log.hy`, stdlib `io`, and `src/time.hy`. `[ffi] search_paths` locates `libtime`; it is not a dload grant. Do not put `[ffi] allow` in `coil.toml`.

Build coil-time native from that checkout:

```bash
make -C ../coil-time
```

## Git dep and coil.lock

`{ git }` is the parseable form. `version` is optional schema, not a tag. `rev` on the dep is stored only. Do not run `spool add`. There is no public spool CLI.

```toml
[dependencies]
log = { git = "git@github.com:ardax-corp/coil-log.git" }
time = { git = "https://github.com/ardax-corp/coil-time.git", trusted = true }
```

This repo has no tags. The pin is `coil.lock` `rev` + `content_hash`. Omit `tag`. Use sibling checkout until spool materializes `.spool/deps`. The compiler does not read `coil.lock` and does not inject roots.

```
# spool lockfile v1
[[package]]
name = 'log'
git = 'git@github.com:ardax-corp/coil-log.git'
rev = '<commit SHA>'
content_hash = '<tree SHA>'
```

`rev` is the commit. `content_hash` is that commit's git tree (`git rev-parse 'HEAD^{tree}'`). Replace both when you move the pin.

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

`io` / `io::sync` / `string` come from coil-stdlib via `--root`. `timestamp` comes from coil-time; pass `--allow-dload time` and put `libtime` on `--ffi-search-path` / `[ffi] search_paths`. This package has no native of its own.
