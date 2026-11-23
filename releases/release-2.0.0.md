# dream_json 2.0.0 Release Notes

**Release Date:** not released yet (draft)

This release changes how `dream_json` writes a timestamp. A timestamp is now an RFC 3339 string in UTC. Before, it was the debug text of the Gleam value, which no JSON client could read as a time.

It is a major version because the output of two functions changes. Read "Upgrading" before you upgrade. The package also moved to its own repository, and every code example in its docs is now a tested snippet.

## Key Highlights

- **Timestamps are RFC 3339 (breaking)**: `timestamp_to_string` and `timestamp` write `"2023-11-14T22:13:20Z"`, not `"Timestamp(1700000000, 0)"`
- **Its own repository**: `dream_json` now lives at [TrustBound/dream_json](https://github.com/TrustBound/dream_json), with its own version and its own releases
- **Tested docs**: every code block in the README and in the doc comments comes from a snippet that the tests compile and run

## What's New

### Timestamps Are RFC 3339 Strings

`timestamp_to_string` returns an RFC 3339 string in UTC. `timestamp` encodes `Some(t)` as that string. `None` is still `null`.

```text
Before: "Timestamp(1700000000, 0)"
After:  "2023-11-14T22:13:20Z"
```

Nanoseconds show as a fraction of a second with trailing zeros removed, for example `"2023-11-14T22:13:20.000000005Z"`.

#### Convert a timestamp to its RFC 3339 string <a href="https://github.com/TrustBound/dream_json/blob/2.0.0/test/snippets/doc_timestamp_to_string.gleam#L5-L11"><img align="right" alt="Tested snippet" src="https://img.shields.io/badge/%F0%9F%A7%AA_tested-snippet-lightgreen.svg?style=flat-square"></a>

```gleam
import dream_json/json_encoders as encoders
import gleam/time/timestamp

pub fn launch_time() -> String {
  timestamp.from_unix_seconds(1_700_000_000)
  |> encoders.timestamp_to_string()
}
```

### Its Own Repository

`dream_json` moved out of the Dream repository. It has its own version, its own changelog and its own release workflow. The package name on Hex and the module names are the same as before.

### Tested Docs

Each code example in the README and in the doc comments has a "tested snippet" badge. The badge links to the snippet file at this release's tag. The tests compile and run each snippet, and a check compares each code block with its file.

### Guides

The package has guides in [`docs/guides/`](https://github.com/TrustBound/dream_json/tree/main/docs/guides). The README is short and links to them, and HexDocs shows the guides.

## Testing

- 25 tests run, 0 failed, in about 0.5 seconds with line coverage (Apple M1 Max, 10 cores, 64 GB, macOS 26.5.1, OTP 29, Gleam 1.19.2)

## Upgrading

Update your dependencies:

```toml
[dependencies]
dream_json = ">= 2.0.0 and < 3.0.0"
```

Then run:

```bash
gleam deps update dream_json
```

### Migration Guide

Only one change can affect your code.

#### 1. A program reads the timestamps that `dream_json` writes

Code that parsed the old `Timestamp(seconds, nanoseconds)` text must now parse RFC 3339. In Gleam, use `timestamp.parse_rfc3339` from `gleam_time`. Most JSON clients in other languages read RFC 3339 with their standard date functions.

Stored data that holds the old text does not change. Convert it, or keep a reader for the old form until it is gone.

## Documentation

- [dream_json](https://hexdocs.pm/dream_json) - v2.0.0
- [README](https://github.com/TrustBound/dream_json/blob/main/README.md)
- [Getting started](https://github.com/TrustBound/dream_json/blob/main/docs/guides/getting-started.md)
- [Optional values](https://github.com/TrustBound/dream_json/blob/main/docs/guides/optional-values.md)
- [Timestamps](https://github.com/TrustBound/dream_json/blob/main/docs/guides/timestamps.md)
- [Changelog](https://github.com/TrustBound/dream_json/blob/main/CHANGELOG.md)

## Community

- [Discussions](https://github.com/TrustBound/dream/discussions)
- [Report Issues](https://github.com/TrustBound/dream_json/issues)
- [Contributing Guide](https://github.com/TrustBound/dream_json/blob/main/CONTRIBUTING.md)
