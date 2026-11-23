//// Guide: Send timestamps and read them back, steps 1 to 4
////
//// Writes a meeting with a required and an optional timestamp as JSON, and
//// reads it back with a decoder that parses RFC 3339 strings.

import dream_json/json_encoders as encoders
import gleam/dynamic/decode.{type Decoder}
import gleam/json
import gleam/list
import gleam/option.{type Option, None}
import gleam/result
import gleam/string
import gleam/time/timestamp.{type Timestamp}

pub type Meeting {
  Meeting(title: String, starts_at: Timestamp, ends_at: Option(Timestamp))
}

pub fn meeting_to_json(meeting: Meeting) -> String {
  json.object([
    #("title", json.string(meeting.title)),
    #("starts_at", json.string(encoders.timestamp_to_string(meeting.starts_at))),
    #("ends_at", encoders.timestamp(meeting.ends_at)),
  ])
  |> json.to_string()
}

pub fn timestamp_decoder() -> Decoder(Timestamp) {
  use text <- decode.then(decode.string)
  case timestamp.parse_rfc3339(text) {
    Ok(time) -> decode.success(time)
    Error(Nil) -> decode.failure(timestamp.unix_epoch, "Timestamp")
  }
}

pub fn meeting_decoder() -> Decoder(Meeting) {
  use title <- decode.field("title", decode.string)
  use starts_at <- decode.field("starts_at", timestamp_decoder())
  use ends_at <- decode.optional_field(
    "ends_at",
    None,
    decode.optional(timestamp_decoder()),
  )
  decode.success(Meeting(title:, starts_at:, ends_at:))
}

pub fn read_meeting(body: String) -> Result(Meeting, String) {
  json.parse(body, meeting_decoder())
  |> result.map_error(describe_error)
}

fn describe_error(error: json.DecodeError) -> String {
  case error {
    json.UnableToDecode(errors) ->
      list.map(errors, describe_field_error) |> string.join(", ")
    _ -> "the body is not valid JSON"
  }
}

fn describe_field_error(error: decode.DecodeError) -> String {
  string.join(error.path, ".")
  <> ": expected "
  <> error.expected
  <> ", found "
  <> error.found
}
