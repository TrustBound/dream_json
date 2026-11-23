# Optional values

This guide shows how to encode optional fields in a JSON object. Each `optional_*` function encodes `Some(value)` as the JSON value and `None` as `null`. This is the usual form for optional fields in a JSON API.

## Encode optional fields

All `optional_*` functions convert `Option` types to JSON, encoding `Some(value)` as the JSON value and `None` as `null`:

### Encode optional fields <a href="https://github.com/TrustBound/dream_json/blob/2.0.0/test/snippets/optional_values.gleam"><img align="right" alt="Tested snippet" src="https://img.shields.io/badge/%F0%9F%A7%AA_tested-snippet-lightgreen.svg?style=flat-square"></a>

```gleam
import dream_json/json_encoders as encoders
import gleam/json
import gleam/option

pub fn profile_json() -> String {
  json.object([
    #("name", json.string("Alice")),
    // null
    #("middle_name", encoders.optional_string(option.None)),
    // "Al"
    #("nickname", encoders.optional_string(option.Some("Al"))),
    // 30
    #("age", encoders.optional_int(option.Some(30))),
    // null
    #("score", encoders.optional_float(option.None)),
    // true
    #("is_active", encoders.optional_bool(option.Some(True))),
  ])
  |> json.to_string()
}
```

## Functions

- `optional_string(value: Option(String)) -> Json`: a JSON string for `Some`, or `null` for `None`. Use it for an optional text field.
- `optional_int(value: Option(Int)) -> Json`: a JSON number for `Some`, or `null` for `None`. Use it for an optional count, ID or age.
- `optional_float(value: Option(Float)) -> Json`: a JSON number for `Some`, or `null` for `None`. Use it for an optional price, percentage or measurement.
- `optional_bool(value: Option(Bool)) -> Json`: a JSON boolean for `Some`, or `null` for `None`. Use it for an optional flag or setting.

## See also

- [Getting started](https://github.com/TrustBound/dream_json/blob/main/docs/guides/getting-started.md): install the package and build a first JSON object
- [Timestamps](https://github.com/TrustBound/dream_json/blob/main/docs/guides/timestamps.md): encode timestamps as RFC 3339 strings
- [README](https://github.com/TrustBound/dream_json/blob/main/README.md)
