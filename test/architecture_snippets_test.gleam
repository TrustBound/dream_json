//// Tests for the dream_json snippet in Dream's architecture reference.

import dream_test/matchers.{be_equal, or_fail_with, should}
import dream_test/types.{type TestSuite}
import dream_test/unit.{describe, group, it}
import gleam/option.{None, Some}
import snippets/architecture_json.{Profile}

pub fn tests() -> TestSuite(Nil) {
  describe("architecture snippets", [
    group("architecture_json.profile_to_json", [
      it("encodes Some as the value and None as null", fn() {
        // Arrange
        let profile = Profile(email: Some("user@example.com"), age: None)

        // Act
        let result = architecture_json.profile_to_json(profile)

        // Assert
        result
        |> should
        |> be_equal("{\"email\":\"user@example.com\",\"age\":null}")
        |> or_fail_with("Expected the email and a null age")
      }),
      it("encodes an age", fn() {
        // Arrange
        let profile = Profile(email: None, age: Some(36))

        // Act
        let result = architecture_json.profile_to_json(profile)

        // Assert
        result
        |> should
        |> be_equal("{\"email\":null,\"age\":36}")
        |> or_fail_with("Expected a null email and the age")
      }),
    ]),
  ])
}
