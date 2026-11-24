//// Guide: Getting started, step 4
////
//// Builds a JSON object that leaves out each field that is None, for an API
//// that reads a missing key and a null key differently.

import gleam/json.{type Json}
import gleam/list
import gleam/option.{type Option}
import gleam/result

pub fn object_without_nones(fields: List(#(String, Option(Json)))) -> Json {
  fields
  |> list.filter_map(present_field)
  |> json.object()
}

fn present_field(
  field: #(String, Option(Json)),
) -> Result(#(String, Json), Nil) {
  let #(name, value) = field
  option.to_result(value, Nil)
  |> result.map(fn(encoded) { #(name, encoded) })
}

pub fn profile_update_json(
  nickname: Option(String),
  age: Option(Int),
) -> String {
  object_without_nones([
    #("nickname", option.map(nickname, json.string)),
    #("age", option.map(age, json.int)),
  ])
  |> json.to_string()
}
