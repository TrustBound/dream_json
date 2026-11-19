//// Doc comment: timestamp_to_string
////
//// Converts a timestamp that is always present to its string form.

import dream_json/json_encoders as encoders
import gleam/time/timestamp

pub fn launch_time() -> String {
  timestamp.from_unix_seconds(1_700_000_000)
  |> encoders.timestamp_to_string()
}
