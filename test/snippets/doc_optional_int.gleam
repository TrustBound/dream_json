//// Doc comment: optional_int
////
//// Encodes a missing integer as null and a present integer as a JSON number.

import dream_json/json_encoders as encoders
import gleam/json
import gleam/option

pub fn account_json() -> String {
  json.object([
    #("user_id", json.int(123)),
    #("parent_id", encoders.optional_int(option.None)),
    #("age", encoders.optional_int(option.Some(30))),
  ])
  |> json.to_string()
}
