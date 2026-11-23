# Changelog

All notable changes to `dream_json` will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - Unreleased

### Changed (breaking)

- `timestamp_to_string` returns an RFC 3339 string in UTC. `timestamp`
  encodes `Some(t)` as that string. `None` is still `null`.

  ```text
  Before: "Timestamp(1700000000, 0)"
  After:  "2023-11-14T22:13:20Z"
  ```

  Nanoseconds show as a fraction of a second with trailing zeros removed,
  for example `"2023-11-14T22:13:20.000000005Z"`.

### Upgrading

- Code that parsed the old `Timestamp(seconds, nanoseconds)` text must now
  parse RFC 3339, for example with `timestamp.parse_rfc3339` from
  `gleam_time`.

### Changed

- The README examples are tested snippets. Each one has a "tested
  snippet" badge that links to its source at this release's tag.
- The doc comment examples are tested snippets too.
- Moved to its own repository
- The package has two guides in `docs/guides/`: "Getting started: turn a
  record into a JSON response" and "Send timestamps and read them back".
  Each one walks through a task step by step, with failure cases, a test
  and common pitfalls. Every code block is a tested snippet. The README is
  short and links to them, and HexDocs shows the guides.

### Testing

- 54 tests, 0 failed, in about 0.5 seconds (`gleam test` with line coverage). Apple M1 Max, 10 cores, 64 GB, macOS 26.5.1, OTP 29, Gleam 1.19.2.

## [1.0.2] - 2025-11-21

### Changed
- Added HexDocs documentation badge to README

## [1.0.1] - 2025-11-22

### Fixed
- Fixed logo display on hex.pm by using full GitHub URL
- Added Dream logo to README

## [1.0.0] - 2025-11-21

### Added
- Initial stable release
- `optional_string()` - Encode optional string to JSON
- `optional_int()` - Encode optional integer to JSON
- `optional_float()` - Encode optional float to JSON
- `optional_bool()` - Encode optional boolean to JSON
- `timestamp()` - Encode optional timestamp to JSON string
- `timestamp_to_string()` - Convert timestamp to string

