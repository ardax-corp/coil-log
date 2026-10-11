# coil-log

Userland logger for [coil](https://github.com/ardax-corp/coil-lang). Package name is `log`, so `use log::{Logger, Level}` resolves here.

This repository is private. Clone with an org-authenticated git URL.

## API

```coil
use log::{Logger, Level};

let log = Logger::new(Level::Info);
log.info("up");
log.debug("skipped");
log.error("boom");
```

`Logger::new` writes one line per event to stderr (`io::sync::write_all`). Inject a `Stream` with `Logger::to` for tests. Events below the min level are a no-op. Lines use tags `ERROR`/`WARN`/`INFO`/`DEBUG` (not scalar `Show`) and a `timestamp().secs()` prefix when coil-time is available.

## Layout

| Path | Role |
|------|------|
| `src/log.hy` | `Level`, `Logger`, `format_line` |
| `coil.toml` | spool manifest (`[package] name = "log"`); coil does not read it |

## Consume

`spool add log` plus `spool add time` (both `--rev <commit SHA>`, no tags yet), or sibling checkouts of this repo, [coil-stdlib](https://github.com/ardax-corp/coil-stdlib), and [coil-time](https://github.com/ardax-corp/coil-time) passed as `--root`. Call `Logger::new` from [docs/consume.md](docs/consume.md).

## License

MIT. See [LICENSE](LICENSE).
