//// Doc comment: optional_float
////
//// Encodes a missing float as null and a present float as a JSON number.

import dream_json/json_encoders as encoders
import gleam/json
import gleam/option

pub fn price_json() -> String {
  json.object([
    #("price", encoders.optional_float(option.Some(19.99))),
    #("discount", encoders.optional_float(option.None)),
  ])
  |> json.to_string()
}
