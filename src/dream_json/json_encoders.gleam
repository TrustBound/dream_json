//// JSON encoders for optional values and timestamps.
////
//// Use these functions when you build a JSON object with `gleam/json` and a
//// field can be missing. Each `optional_*` function encodes `Some(value)` as
//// the JSON value and `None` as `null`. This is the usual form for optional
//// fields in a JSON API.
////
//// ## Quick Start
////
//// ### Build a user object <a href="https://github.com/TrustBound/dream_json/blob/2.0.0/test/snippets/quick_start.gleam"><img align="right" alt="Tested snippet" src="https://img.shields.io/badge/%F0%9F%A7%AA_tested-snippet-lightgreen.svg?style=flat-square"></a>
////
//// ```gleam
//// import dream_json/json_encoders as encoders
//// import gleam/json
//// import gleam/option
//// import gleam/time/timestamp.{type Timestamp}
////
//// pub fn user_json(created_at: Timestamp) -> String {
////   json.object([
////     #("name", json.string("Alice")),
////     #("email", encoders.optional_string(option.Some("alice@example.com"))),
////     // Encodes as null
////     #("age", encoders.optional_int(option.None)),
////     #("created_at", encoders.timestamp(option.Some(created_at))),
////   ])
////   |> json.to_string()
//// }
//// ```
////
//// ## Optional Values
////
//// `optional_string`, `optional_int`, `optional_float` and `optional_bool`
//// encode `Some(value)` as the JSON value and `None` as `null`.
////
//// ## Timestamps
////
//// `timestamp` encodes `Some(timestamp)` as a JSON string and `None` as
//// `null`. The string is the RFC 3339 form in UTC that `timestamp_to_string`
//// returns, for example `"2023-11-14T22:13:20Z"`.

import gleam/json
import gleam/option
import gleam/time/calendar
import gleam/time/timestamp

/// Encodes an optional string as JSON.
///
/// Returns a JSON string for `Some(text)` and `null` for `None`. Use it for
/// an optional text field in a JSON object.
///
/// ## Parameters
///
/// - `value`: the optional string to encode.
///
/// ## Returns
///
/// A `json.Json` string for `Some`, or `null` for `None`.
///
/// ## Example
///
/// ### Encode optional names <a href="https://github.com/TrustBound/dream_json/blob/2.0.0/test/snippets/doc_optional_string.gleam"><img align="right" alt="Tested snippet" src="https://img.shields.io/badge/%F0%9F%A7%AA_tested-snippet-lightgreen.svg?style=flat-square"></a>
///
/// ```gleam
/// import dream_json/json_encoders as encoders
/// import gleam/json
/// import gleam/option
///
/// pub fn name_json() -> String {
///   json.object([
///     #("name", json.string("Alice")),
///     #("middle_name", encoders.optional_string(option.None)),
///     #("nickname", encoders.optional_string(option.Some("Al"))),
///   ])
///   |> json.to_string()
/// }
/// ```
///
/// ## See Also
///
/// - `optional_int`, `optional_float` and `optional_bool` for other types.
pub fn optional_string(value: option.Option(String)) -> json.Json {
  case value {
    option.Some(text) -> json.string(text)
    option.None -> json.null()
  }
}

/// Encodes an optional integer as JSON.
///
/// Returns a JSON number for `Some(num)` and `null` for `None`. Use it for an
/// optional count, ID or age.
///
/// ## Parameters
///
/// - `value`: the optional integer to encode.
///
/// ## Returns
///
/// A `json.Json` number for `Some`, or `null` for `None`.
///
/// ## Example
///
/// ### Encode optional IDs <a href="https://github.com/TrustBound/dream_json/blob/2.0.0/test/snippets/doc_optional_int.gleam"><img align="right" alt="Tested snippet" src="https://img.shields.io/badge/%F0%9F%A7%AA_tested-snippet-lightgreen.svg?style=flat-square"></a>
///
/// ```gleam
/// import dream_json/json_encoders as encoders
/// import gleam/json
/// import gleam/option
///
/// pub fn account_json() -> String {
///   json.object([
///     #("user_id", json.int(123)),
///     #("parent_id", encoders.optional_int(option.None)),
///     #("age", encoders.optional_int(option.Some(30))),
///   ])
///   |> json.to_string()
/// }
/// ```
///
/// ## See Also
///
/// - `optional_float` for a number with a fraction.
pub fn optional_int(value: option.Option(Int)) -> json.Json {
  case value {
    option.Some(num) -> json.int(num)
    option.None -> json.null()
  }
}

/// Encodes an optional timestamp as JSON.
///
/// Returns a JSON string for `Some(t)` and `null` for `None`. The string is
/// the value of `timestamp_to_string(t)`: RFC 3339 in UTC, for example
/// `"2023-11-14T22:13:20Z"`.
///
/// ## Parameters
///
/// - `ts`: the optional timestamp to encode.
///
/// ## Returns
///
/// A `json.Json` string for `Some`, or `null` for `None`.
///
/// ## Example
///
/// ### Encode optional times <a href="https://github.com/TrustBound/dream_json/blob/2.0.0/test/snippets/doc_timestamp.gleam"><img align="right" alt="Tested snippet" src="https://img.shields.io/badge/%F0%9F%A7%AA_tested-snippet-lightgreen.svg?style=flat-square"></a>
///
/// ```gleam
/// import dream_json/json_encoders as encoders
/// import gleam/json
/// import gleam/option
/// import gleam/time/timestamp.{type Timestamp}
///
/// pub fn record_json(created_at: Timestamp) -> String {
///   json.object([
///     #("created_at", encoders.timestamp(option.Some(created_at))),
///     #("deleted_at", encoders.timestamp(option.None)),
///   ])
///   |> json.to_string()
/// }
/// ```
///
/// ## See Also
///
/// - `timestamp_to_string` for the RFC 3339 string of a timestamp.
pub fn timestamp(ts: option.Option(timestamp.Timestamp)) -> json.Json {
  case ts {
    option.Some(t) -> json.string(timestamp_to_string(t))
    option.None -> json.null()
  }
}

/// Converts a timestamp to an RFC 3339 string in UTC.
///
/// The string always ends in `Z`, for example `"2023-11-14T22:13:20Z"`.
/// A timestamp before 1970 gives an earlier date, for example
/// `"1969-12-31T23:59:59Z"`.
///
/// Nanoseconds show as a fraction of a second after a dot. The fraction has
/// at most nine digits, and trailing zeros are removed: 5 nanoseconds give
/// `"2023-11-14T22:13:20.000000005Z"`, and 123,000,000 nanoseconds give
/// `"2023-11-14T22:13:20.123Z"`. Zero nanoseconds give no fraction.
///
/// `timestamp` uses this function. Call it directly when the timestamp is
/// always present.
///
/// ## Parameters
///
/// - `ts`: the timestamp to convert.
///
/// ## Returns
///
/// A `String` such as `"2023-11-14T22:13:20Z"`.
///
/// ## Example
///
/// ### Convert a timestamp <a href="https://github.com/TrustBound/dream_json/blob/2.0.0/test/snippets/doc_timestamp_to_string.gleam"><img align="right" alt="Tested snippet" src="https://img.shields.io/badge/%F0%9F%A7%AA_tested-snippet-lightgreen.svg?style=flat-square"></a>
///
/// ```gleam
/// import dream_json/json_encoders as encoders
/// import gleam/time/timestamp
///
/// pub fn launch_time() -> String {
///   timestamp.from_unix_seconds(1_700_000_000)
///   |> encoders.timestamp_to_string()
/// }
/// ```
///
/// ## See Also
///
/// - `timestamp` to encode an optional timestamp as JSON.
pub fn timestamp_to_string(ts: timestamp.Timestamp) -> String {
  timestamp.to_rfc3339(ts, calendar.utc_offset)
}

/// Encodes an optional float as JSON.
///
/// Returns a JSON number for `Some(num)` and `null` for `None`. Use it for an
/// optional price, percentage or measurement.
///
/// ## Parameters
///
/// - `value`: the optional float to encode.
///
/// ## Returns
///
/// A `json.Json` number for `Some`, or `null` for `None`.
///
/// ## Example
///
/// ### Encode optional prices <a href="https://github.com/TrustBound/dream_json/blob/2.0.0/test/snippets/doc_optional_float.gleam"><img align="right" alt="Tested snippet" src="https://img.shields.io/badge/%F0%9F%A7%AA_tested-snippet-lightgreen.svg?style=flat-square"></a>
///
/// ```gleam
/// import dream_json/json_encoders as encoders
/// import gleam/json
/// import gleam/option
///
/// pub fn price_json() -> String {
///   json.object([
///     #("price", encoders.optional_float(option.Some(19.99))),
///     #("discount", encoders.optional_float(option.None)),
///   ])
///   |> json.to_string()
/// }
/// ```
///
/// ## See Also
///
/// - `optional_int` for a whole number.
pub fn optional_float(value: option.Option(Float)) -> json.Json {
  case value {
    option.Some(num) -> json.float(num)
    option.None -> json.null()
  }
}

/// Encodes an optional boolean as JSON.
///
/// Returns a JSON boolean for `Some(val)` and `null` for `None`. Use it for an
/// optional flag or setting.
///
/// ## Parameters
///
/// - `value`: the optional boolean to encode.
///
/// ## Returns
///
/// A `json.Json` boolean for `Some`, or `null` for `None`.
///
/// ## Example
///
/// ### Encode optional flags <a href="https://github.com/TrustBound/dream_json/blob/2.0.0/test/snippets/doc_optional_bool.gleam"><img align="right" alt="Tested snippet" src="https://img.shields.io/badge/%F0%9F%A7%AA_tested-snippet-lightgreen.svg?style=flat-square"></a>
///
/// ```gleam
/// import dream_json/json_encoders as encoders
/// import gleam/json
/// import gleam/option
///
/// pub fn flags_json() -> String {
///   json.object([
///     #("is_active", encoders.optional_bool(option.Some(True))),
///     #("is_verified", encoders.optional_bool(option.None)),
///   ])
///   |> json.to_string()
/// }
/// ```
///
/// ## See Also
///
/// - `optional_string` and `optional_int` for other types.
pub fn optional_bool(value: option.Option(Bool)) -> json.Json {
  case value {
    option.Some(val) -> json.bool(val)
    option.None -> json.null()
  }
}
