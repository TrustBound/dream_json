//// Tests for the code blocks in the dream_json README.

import dream_test/matchers.{be_equal, or_fail_with, should}
import dream_test/types.{type TestSuite}
import dream_test/unit.{describe, group, it}
import gleam/time/timestamp
import snippets/optional_values
import snippets/quick_start
import snippets/timestamps

pub fn tests() -> TestSuite(Nil) {
  describe("README snippets", [
    group("quick_start.user_json", [
      it("encodes the optional fields and the timestamp", fn() {
        // Arrange
        let created_at = timestamp.from_unix_seconds(1_700_000_000)

        // Act
        let result = quick_start.user_json(created_at)

        // Assert
        result
        |> should
        |> be_equal(
          "{\"name\":\"Alice\",\"email\":\"alice@example.com\",\"age\":null,\"created_at\":\"2023-11-14T22:13:20Z\"}",
        )
        |> or_fail_with("Expected the user JSON")
      }),
    ]),
    group("optional_values.profile_json", [
      it("encodes Some as the value and None as null", fn() {
        // Act
        let result = optional_values.profile_json()

        // Assert
        result
        |> should
        |> be_equal(
          "{\"name\":\"Alice\",\"middle_name\":null,\"nickname\":\"Al\",\"age\":30,\"score\":null,\"is_active\":true}",
        )
        |> or_fail_with("Expected the profile JSON")
      }),
    ]),
    group("timestamps.audit_json", [
      it("encodes the timestamp and null", fn() {
        // Arrange
        let created_at = timestamp.from_unix_seconds(1_700_000_000)

        // Act
        let result = timestamps.audit_json(created_at)

        // Assert
        result
        |> should
        |> be_equal(
          "{\"created_at\":\"2023-11-14T22:13:20Z\",\"deleted_at\":null}",
        )
        |> or_fail_with("Expected the audit JSON")
      }),
    ]),
  ])
}
