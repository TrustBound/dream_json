//// Doc comment: optional_string
////
//// Encodes a missing string as null and a present string as a JSON string.

import dream_json/json_encoders as encoders
import gleam/json
import gleam/option

pub fn name_json() -> String {
  json.object([
    #("name", json.string("Alice")),
    #("middle_name", encoders.optional_string(option.None)),
    #("nickname", encoders.optional_string(option.Some("Al"))),
  ])
  |> json.to_string()
}
