# Getting started

This guide shows how to add dream_json to a Gleam project and build a first JSON object with optional fields and a timestamp.

## Install

Add the package as a dependency:

```bash
gleam add dream_json
```

dream_json has no runtime dependency on Dream. You can use it in any Gleam project.

## Build a first JSON object

Use the encoders when you build a JSON object with `gleam/json` and a field can be missing. Each `optional_*` function encodes `Some(value)` as the JSON value and `None` as `null`. `timestamp` encodes a timestamp as an RFC 3339 string in UTC.

### Build a user object <a href="https://github.com/TrustBound/dream_json/blob/2.0.0/test/snippets/quick_start.gleam"><img align="right" alt="Tested snippet" src="https://img.shields.io/badge/%F0%9F%A7%AA_tested-snippet-lightgreen.svg?style=flat-square"></a>

```gleam
import dream_json/json_encoders as encoders
import gleam/json
import gleam/option
import gleam/time/timestamp.{type Timestamp}

pub fn user_json(created_at: Timestamp) -> String {
  json.object([
    #("name", json.string("Alice")),
    #("email", encoders.optional_string(option.Some("alice@example.com"))),
    // Encodes as null
    #("age", encoders.optional_int(option.None)),
    #("created_at", encoders.timestamp(option.Some(created_at))),
  ])
  |> json.to_string()
}
```

## See also

- [Optional values](https://github.com/TrustBound/dream_json/blob/main/docs/guides/optional-values.md): encode optional strings, integers, floats and booleans
- [Timestamps](https://github.com/TrustBound/dream_json/blob/main/docs/guides/timestamps.md): encode timestamps as RFC 3339 strings
- [README](https://github.com/TrustBound/dream_json/blob/main/README.md)
