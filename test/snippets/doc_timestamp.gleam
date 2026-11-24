//// Doc comment: timestamp
////
//// Encodes a missing timestamp as null and a present timestamp as an RFC 3339 string.

import dream_json/json_encoders as encoders
import gleam/json
import gleam/option
import gleam/time/timestamp.{type Timestamp}

pub fn record_json(created_at: Timestamp) -> String {
  json.object([
    #("created_at", encoders.timestamp(option.Some(created_at))),
    #("deleted_at", encoders.timestamp(option.None)),
  ])
  |> json.to_string()
}
