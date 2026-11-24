//// Doc comment: optional_bool
////
//// Encodes a missing boolean as null and a present boolean as a JSON boolean.

import dream_json/json_encoders as encoders
import gleam/json
import gleam/option

pub fn flags_json() -> String {
  json.object([
    #("is_active", encoders.optional_bool(option.Some(True))),
    #("is_verified", encoders.optional_bool(option.None)),
  ])
  |> json.to_string()
}
