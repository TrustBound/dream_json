//// Tests for the snippets and the facts of the timestamps guide
//// (docs/guides/timestamps.md). Each test asserts the exact value or
//// output that the guide shows.

import dream_json/json_encoders as encoders
import dream_test/matchers.{be_equal, or_fail_with, should}
import dream_test/suite.{type TestSuite}
import dream_test/unit.{describe, it}
import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/option.{None, Some}
import gleam/order
import gleam/string
import gleam/time/timestamp
import output_file
import snippets/guide_timestamps_meeting.{type Meeting, Meeting}

pub fn tests() -> TestSuite {
  describe("timestamps guide", [
    it("step 1: meeting_to_json writes RFC 3339 and null", fn() {
      // Arrange
      let meeting =
        Meeting(
          title: "Standup",
          starts_at: timestamp.from_unix_seconds(1_700_000_000),
          ends_at: None,
        )

      // Act
      let shown = guide_timestamps_meeting.meeting_to_json(meeting) <> "\n"

      // Assert
      shown
      |> should
      |> be_equal(output_file.read("guide_timestamps_meeting_without_end"))
      |> or_fail_with("Expected the meeting JSON")
    }),
    it("step 1: a fraction of a second keeps its significant digits", fn() {
      // Arrange
      let meeting =
        Meeting(
          title: "Standup",
          starts_at: timestamp.from_unix_seconds(1_700_000_000),
          ends_at: Some(timestamp.from_unix_seconds_and_nanoseconds(
            1_700_001_800,
            250_000_000,
          )),
        )

      // Act
      let shown = guide_timestamps_meeting.meeting_to_json(meeting) <> "\n"

      // Assert
      shown
      |> should
      |> be_equal(output_file.read("guide_timestamps_meeting_with_end"))
      |> or_fail_with("Expected the end time with .25")
    }),
    it("step 3: read_meeting reads the JSON that meeting_to_json wrote", fn() {
      // Arrange
      let body =
        output_file.read("guide_timestamps_meeting_with_end")
        |> string.trim_end()

      // Act
      let result = guide_timestamps_meeting.read_meeting(body)

      // Assert
      result
      |> should
      |> be_equal(
        Ok(Meeting(
          title: "Standup",
          starts_at: timestamp.from_unix_seconds(1_700_000_000),
          ends_at: Some(timestamp.from_unix_seconds_and_nanoseconds(
            1_700_001_800,
            250_000_000,
          )),
        )),
      )
      |> or_fail_with("Expected the meeting")
    }),
    it("step 3: read_meeting reads a missing end time as None", fn() {
      // Act
      let result =
        guide_timestamps_meeting.read_meeting(
          "{\"title\":\"Standup\",\"starts_at\":\"2023-11-14T22:13:20Z\"}",
        )

      // Assert
      result
      |> should
      |> be_equal(
        Ok(Meeting(
          title: "Standup",
          starts_at: timestamp.from_unix_seconds(1_700_000_000),
          ends_at: None,
        )),
      )
      |> or_fail_with("Expected no end time")
    }),
    it("step 4: read_meeting gives the results that the guide shows", fn() {
      // Arrange
      let start_fields = [
        "\"starts_at\":\"2023-11-14T23:13:20+01:00\"",
        "\"starts_at\":\"2023-11-14T22:13:20\"",
        "\"starts_at\":\"Timestamp(1700000000, 0)\"",
        "\"starts_at\":1700000000",
      ]
      let inputs =
        list.append(list.map(start_fields, meeting_with_start_field), [
          #("no \"starts_at\" key", "{\"title\":\"Standup\"}"),
          #("{\"title\":", "{\"title\":"),
        ])

      // Act
      let shown = list.map(inputs, read_meeting_line) |> string.concat()

      // Assert
      shown
      |> should
      |> be_equal(output_file.read("guide_timestamps_read_meeting"))
      |> or_fail_with("Expected the output file of Step 4")
    }),
    it("pitfall: rounding down to milliseconds drops the last six digits", fn() {
      // Arrange
      let time =
        timestamp.from_unix_seconds_and_nanoseconds(1_700_000_000, 123_456_789)
      let #(seconds, nanoseconds) =
        timestamp.to_unix_seconds_and_nanoseconds(time)

      // Act
      let written =
        timestamp.from_unix_seconds_and_nanoseconds(
          seconds,
          nanoseconds / 1_000_000 * 1_000_000,
        )
        |> encoders.timestamp_to_string()

      // Assert
      written
      |> should
      |> be_equal("2023-11-14T22:13:20.123Z")
      |> or_fail_with("Expected three fraction digits")
    }),
    it("pitfall: a whole second sorts after a later time with a fraction", fn() {
      // Act
      let order =
        string.compare("2023-11-14T22:13:20Z", "2023-11-14T22:13:20.5Z")

      // Assert
      order
      |> should
      |> be_equal(order.Gt)
      |> or_fail_with("Expected the earlier time to sort last")
    }),
    it("pitfall: decode.optional alone refuses a missing key", fn() {
      // Arrange
      let decoder = {
        use ends_at <- decode.field(
          "ends_at",
          decode.optional(guide_timestamps_meeting.timestamp_decoder()),
        )
        decode.success(ends_at)
      }

      // Act
      let result = json.parse("{}", decoder)

      // Assert
      result
      |> should
      |> be_equal(
        Error(
          json.UnableToDecode([
            decode.DecodeError("Field", "Nothing", ["ends_at"]),
          ]),
        ),
      )
      |> or_fail_with("Expected the missing key to be refused")
    }),
    it("limit: a year after 9999 gives five year digits", fn() {
      // Act
      let written =
        encoders.timestamp_to_string(timestamp.from_unix_seconds(
          253_402_300_800,
        ))

      // Assert
      written
      |> should
      |> be_equal("10000-01-01T00:00:00Z")
      |> or_fail_with("Expected a five digit year")
    }),
    it("limit: parse_rfc3339 refuses a five digit year", fn() {
      // Act
      let parsed = timestamp.parse_rfc3339("10000-01-01T00:00:00Z")

      // Assert
      parsed
      |> should
      |> be_equal(Error(Nil))
      |> or_fail_with("Expected the five digit year to be refused")
    }),
    it("limit: a year before 0 gives a broken string", fn() {
      // Act
      let written =
        encoders.timestamp_to_string(timestamp.from_unix_seconds(
          -62_167_219_201,
        ))

      // Assert
      written
      |> should
      |> be_equal("00-1-12-31T23:59:59Z")
      |> or_fail_with("Expected the string that gleam_time writes today")
    }),
  ])
}

/// A line of the table of Step 4 shows this label, and the body holds the
/// start field.
fn meeting_with_start_field(start_field: String) -> #(String, String) {
  #(
    start_field,
    "{\"title\":\"Standup\"," <> start_field <> ",\"ends_at\":null}",
  )
}

/// Reads the body, and writes the label and the result as one line of the
/// table of Step 4.
fn read_meeting_line(input: #(String, String)) -> String {
  let #(label, body) = input
  string.pad_end(label, to: 42, with: " ")
  <> "-> "
  <> describe_result(guide_timestamps_meeting.read_meeting(body))
  <> "\n"
}

fn describe_result(result: Result(Meeting, String)) -> String {
  case result {
    Ok(meeting) ->
      "Ok, starts_at is " <> encoders.timestamp_to_string(meeting.starts_at)
    Error(message) -> "Error(" <> string.inspect(message) <> ")"
  }
}
