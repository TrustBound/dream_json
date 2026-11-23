//// Tests for the code blocks in the dream_json README.

import dream_test/matchers.{be_equal, or_fail_with, should}
import dream_test/suite.{type TestSuite}
import dream_test/unit.{describe, group, it}
import gleam/time/timestamp
import output_file
import snippets/quick_start

pub fn tests() -> TestSuite {
  describe("README snippets", [
    group("quick_start.user_json", [
      it("gives the JSON that the getting started guide shows", fn() {
        // Arrange
        let created_at = timestamp.from_unix_seconds(1_700_000_000)

        // Act
        let shown =
          "user_json(timestamp.from_unix_seconds(1_700_000_000))\n  -> "
          <> quick_start.user_json(created_at)
          <> "\n"

        // Assert
        shown
        |> should
        |> be_equal(output_file.read("guide_getting_started_user_json"))
        |> or_fail_with("Expected the output file of Step 1")
      }),
    ]),
  ])
}
