//// Guide: Send timestamps and read them back, testing
////
//// Tests that a meeting survives the trip to JSON and back, and that a
//// start time with no offset is refused.

import dream_test/matchers.{be_equal, or_fail_with, should}
import dream_test/suite.{type TestSuite}
import dream_test/unit.{describe, it}
import gleam/option.{None, Some}
import gleam/time/timestamp
import snippets/guide_timestamps_meeting.{Meeting, meeting_to_json, read_meeting}

pub fn tests() -> TestSuite {
  describe("meeting JSON", [
    it("reads back a meeting with nanoseconds and a time before 1970", fn() {
      // Arrange
      let meeting =
        Meeting(
          title: "Standup",
          starts_at: timestamp.from_unix_seconds_and_nanoseconds(
            1_700_000_000,
            5,
          ),
          ends_at: Some(timestamp.from_unix_seconds(-1)),
        )

      // Act
      let read_back = meeting |> meeting_to_json() |> read_meeting()

      // Assert
      read_back
      |> should
      |> be_equal(Ok(meeting))
      |> or_fail_with("Expected the same meeting back")
    }),
    it("reads back a meeting with no end time", fn() {
      // Arrange
      let meeting =
        Meeting(
          title: "Standup",
          starts_at: timestamp.from_unix_seconds(1_700_000_000),
          ends_at: None,
        )

      // Act
      let read_back = meeting |> meeting_to_json() |> read_meeting()

      // Assert
      read_back
      |> should
      |> be_equal(Ok(meeting))
      |> or_fail_with("Expected the same meeting back")
    }),
    it("refuses a start time with no offset", fn() {
      // Arrange
      let body = "{\"title\":\"Standup\",\"starts_at\":\"2023-11-14T22:13:20\"}"

      // Act
      let result = read_meeting(body)

      // Assert
      result
      |> should
      |> be_equal(Error("starts_at: expected Timestamp, found String"))
      |> or_fail_with("Expected the start time to be refused")
    }),
  ])
}
