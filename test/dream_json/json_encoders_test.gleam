//// Tests for dream_json/json_encoders.

import dream_json/json_encoders
import dream_test/matchers.{be_equal, or_fail_with, should}
import dream_test/suite.{type TestSuite}
import dream_test/unit.{describe, group, it}
import gleam/json
import gleam/option.{None, Some}
import gleam/string
import gleam/time/timestamp
import output_file

pub fn tests() -> TestSuite {
  describe("dream_json/json_encoders", [
    group("optional_string", [
      it("returns a JSON string for Some", fn() {
        // Arrange
        let value = Some("Al")

        // Act
        let result = json_encoders.optional_string(value) |> json.to_string()

        // Assert
        result
        |> should
        |> be_equal("\"Al\"")
        |> or_fail_with("Expected the string \"Al\"")
      }),
      it("returns null for None", fn() {
        // Arrange
        let value = None

        // Act
        let result = json_encoders.optional_string(value) |> json.to_string()

        // Assert
        result
        |> should
        |> be_equal("null")
        |> or_fail_with("Expected null")
      }),
    ]),
    group("optional_int", [
      it("returns a JSON number for Some", fn() {
        // Arrange
        let value = Some(30)

        // Act
        let result = json_encoders.optional_int(value) |> json.to_string()

        // Assert
        result
        |> should
        |> be_equal("30")
        |> or_fail_with("Expected the number 30")
      }),
      it("returns null for None", fn() {
        // Arrange
        let value = None

        // Act
        let result = json_encoders.optional_int(value) |> json.to_string()

        // Assert
        result
        |> should
        |> be_equal("null")
        |> or_fail_with("Expected null")
      }),
    ]),
    group("optional_float", [
      it("returns a JSON number for Some", fn() {
        // Arrange
        let value = Some(19.99)

        // Act
        let result = json_encoders.optional_float(value) |> json.to_string()

        // Assert
        result
        |> should
        |> be_equal("19.99")
        |> or_fail_with("Expected the number 19.99")
      }),
      it("returns null for None", fn() {
        // Arrange
        let value = None

        // Act
        let result = json_encoders.optional_float(value) |> json.to_string()

        // Assert
        result
        |> should
        |> be_equal("null")
        |> or_fail_with("Expected null")
      }),
    ]),
    group("optional_bool", [
      it("returns a JSON boolean for Some", fn() {
        // Arrange
        let value = Some(True)

        // Act
        let result = json_encoders.optional_bool(value) |> json.to_string()

        // Assert
        result
        |> should
        |> be_equal("true")
        |> or_fail_with("Expected true")
      }),
      it("returns null for None", fn() {
        // Arrange
        let value = None

        // Act
        let result = json_encoders.optional_bool(value) |> json.to_string()

        // Assert
        result
        |> should
        |> be_equal("null")
        |> or_fail_with("Expected null")
      }),
    ]),
    group("timestamp", [
      it("returns the timestamp as a JSON string for Some", fn() {
        // Arrange
        let value = Some(timestamp.from_unix_seconds(1_700_000_000))

        // Act
        let result = json_encoders.timestamp(value) |> json.to_string()

        // Assert
        result
        |> should
        |> be_equal("\"2023-11-14T22:13:20Z\"")
        |> or_fail_with("Expected \"2023-11-14T22:13:20Z\"")
      }),
      it("returns null for None", fn() {
        // Arrange
        let value = None

        // Act
        let result = json_encoders.timestamp(value) |> json.to_string()

        // Assert
        result
        |> should
        |> be_equal("null")
        |> or_fail_with("Expected null")
      }),
    ]),
    group("timestamp_to_string", [
      it("returns RFC 3339 in UTC for whole seconds", fn() {
        // Arrange
        let value = timestamp.from_unix_seconds(1_700_000_000)

        // Act
        let result = json_encoders.timestamp_to_string(value)

        // Assert
        result
        |> should
        |> be_equal("2023-11-14T22:13:20Z")
        |> or_fail_with("Expected 2023-11-14T22:13:20Z")
      }),
      it("shows all nine fraction digits for 5 nanoseconds", fn() {
        // Arrange
        let value =
          timestamp.from_unix_seconds_and_nanoseconds(1_700_000_000, 5)

        // Act
        let result = json_encoders.timestamp_to_string(value)

        // Assert
        result
        |> should
        |> be_equal("2023-11-14T22:13:20.000000005Z")
        |> or_fail_with("Expected 2023-11-14T22:13:20.000000005Z")
      }),
      it("removes trailing zeros from the fraction", fn() {
        // Arrange
        let value =
          timestamp.from_unix_seconds_and_nanoseconds(
            1_700_000_000,
            123_000_000,
          )

        // Act
        let result = json_encoders.timestamp_to_string(value)

        // Assert
        result
        |> should
        |> be_equal("2023-11-14T22:13:20.123Z")
        |> or_fail_with("Expected 2023-11-14T22:13:20.123Z")
      }),
      it("returns a date before 1970 for negative seconds", fn() {
        // Arrange
        let value = timestamp.from_unix_seconds(-1)

        // Act
        let result = json_encoders.timestamp_to_string(value)

        // Assert
        result
        |> should
        |> be_equal("1969-12-31T23:59:59Z")
        |> or_fail_with("Expected 1969-12-31T23:59:59Z")
      }),
      it("writes the JSON that the 2.0.0 changelog shows", fn() {
        // Arrange
        let value = timestamp.from_unix_seconds(1_700_000_000)
        // Version 1 wrote the debug text of the value
        let version_1 = json.string(string.inspect(value)) |> json.to_string()

        // Act
        let version_2 = json_encoders.timestamp(Some(value)) |> json.to_string()
        let shown = "Before: " <> version_1 <> "\nAfter:  " <> version_2 <> "\n"

        // Assert
        shown
        |> should
        |> be_equal(output_file.read("release_2_0_0_timestamp_text"))
        |> or_fail_with("Expected the output file of the changelog")
      }),
    ]),
  ])
}
