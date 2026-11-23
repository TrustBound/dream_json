# Timestamps

This guide shows how to encode a timestamp in a JSON object. dream_json writes a timestamp as an RFC 3339 string in UTC, for example `"2023-11-14T22:13:20Z"`.

## Encode a timestamp

Encode timestamps as RFC 3339 strings in UTC, for example `"2023-11-14T22:13:20Z"`. Nanoseconds show as a fraction of a second, for example `"2023-11-14T22:13:20.000000005Z"`. `timestamp` encodes `Some(t)` as that string and `None` as `null`:

### Encode a timestamp <a href="https://github.com/TrustBound/dream_json/blob/2.0.0/test/snippets/timestamps.gleam"><img align="right" alt="Tested snippet" src="https://img.shields.io/badge/%F0%9F%A7%AA_tested-snippet-lightgreen.svg?style=flat-square"></a>

```gleam
import dream_json/json_encoders as encoders
import gleam/json
import gleam/option
import gleam/time/timestamp.{type Timestamp}

pub fn audit_json(created_at: Timestamp) -> String {
  json.object([
    #("created_at", encoders.timestamp(option.Some(created_at))),
    // null
    #("deleted_at", encoders.timestamp(option.None)),
  ])
  |> json.to_string()
}
```

## Convert a timestamp to a string

`timestamp` uses `timestamp_to_string`. Call `timestamp_to_string` directly when the timestamp is always present.

### Convert a timestamp to its RFC 3339 string <a href="https://github.com/TrustBound/dream_json/blob/2.0.0/test/snippets/doc_timestamp_to_string.gleam#L5-L11"><img align="right" alt="Tested snippet" src="https://img.shields.io/badge/%F0%9F%A7%AA_tested-snippet-lightgreen.svg?style=flat-square"></a>

```gleam
import dream_json/json_encoders as encoders
import gleam/time/timestamp

pub fn launch_time() -> String {
  timestamp.from_unix_seconds(1_700_000_000)
  |> encoders.timestamp_to_string()
}
```

## The string form

- The string always ends in `Z`, for example `"2023-11-14T22:13:20Z"`.
- A timestamp before 1970 gives an earlier date, for example `"1969-12-31T23:59:59Z"`.
- Nanoseconds show as a fraction of a second after a dot. The fraction has at most nine digits, and trailing zeros are removed: 5 nanoseconds give `"2023-11-14T22:13:20.000000005Z"`, and 123,000,000 nanoseconds give `"2023-11-14T22:13:20.123Z"`. Zero nanoseconds give no fraction.

To read the string back in Gleam, use `timestamp.parse_rfc3339` from `gleam_time`.

## Functions

- `timestamp(ts: Option(Timestamp)) -> Json`: encode an optional timestamp. A JSON string for `Some`, or `null` for `None`.
- `timestamp_to_string(ts: Timestamp) -> String`: convert a timestamp to an RFC 3339 string in UTC.

## See also

- [Getting started](https://github.com/TrustBound/dream_json/blob/main/docs/guides/getting-started.md): install the package and build a first JSON object
- [Optional values](https://github.com/TrustBound/dream_json/blob/main/docs/guides/optional-values.md): encode optional strings, integers, floats and booleans
- [README](https://github.com/TrustBound/dream_json/blob/main/README.md)
