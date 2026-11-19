//// Tests for dream_json/json_encoders.

import dream_json/json_encoders
import dream_test/matchers.{be_equal, or_fail_with, should}
import dream_test/types.{type TestSuite}
import dream_test/unit.{describe, group, it}
import gleam/json
import gleam/option.{None, Some}
import gleam/time/timestamp

pub fn tests() -> TestSuite(Nil) {
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
        |> be_equal("\"Timestamp(1700000000, 0)\"")
        |> or_fail_with("Expected the timestamp string")
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
      it("returns the seconds and nanoseconds of the timestamp", fn() {
        // Arrange
        let value =
          timestamp.from_unix_seconds_and_nanoseconds(1_700_000_000, 5)

        // Act
        let result = json_encoders.timestamp_to_string(value)

        // Assert
        result
        |> should
        |> be_equal("Timestamp(1700000000, 5)")
        |> or_fail_with("Expected Timestamp(1700000000, 5)")
      }),
    ]),
  ])
}
