//// Tests for the snippets and the facts of the getting started guide
//// (docs/guides/getting-started.md). Each test asserts the exact value or
//// output that the guide shows.

import dream_json/json_encoders as encoders
import dream_test/matchers.{be_equal, or_fail_with, should}
import dream_test/suite.{type TestSuite}
import dream_test/unit.{describe, it}
import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/option.{None, Some}
import output_file
import snippets/guide_getting_started_account
import snippets/guide_getting_started_leave_out

pub fn tests() -> TestSuite {
  describe("getting started guide", [
    it("step 3: accounts_body writes both example accounts", fn() {
      // Arrange
      let accounts = guide_getting_started_account.example_accounts()

      // Act
      let shown = guide_getting_started_account.accounts_body(accounts) <> "\n"

      // Assert
      shown
      |> should
      |> be_equal(output_file.read("guide_getting_started_accounts_body"))
      |> or_fail_with("Expected the response body of both accounts")
    }),
    it("step 4: profile_update_json leaves out a missing age", fn() {
      // Act
      let body =
        guide_getting_started_leave_out.profile_update_json(Some("Al"), None)

      // Assert
      body
      |> should
      |> be_equal("{\"nickname\":\"Al\"}")
      |> or_fail_with("Expected only the nickname")
    }),
    it("step 4: profile_update_json writes an empty object for no fields", fn() {
      // Act
      let body = guide_getting_started_leave_out.profile_update_json(None, None)

      // Assert
      body
      |> should
      |> be_equal("{}")
      |> or_fail_with("Expected an empty object")
    }),
    it("pitfall: a whole float is written with a fraction", fn() {
      // Act
      let written = encoders.optional_float(Some(30.0)) |> json.to_string()

      // Assert
      written
      |> should
      |> be_equal("30.0")
      |> or_fail_with("Expected 30.0")
    }),
    it("pitfall: decode.float refuses a JSON number with no fraction", fn() {
      // Arrange
      let decoder = {
        use price <- decode.field("price", decode.float)
        decode.success(price)
      }

      // Act
      let result = json.parse("{\"price\":30}", decoder)

      // Assert
      result
      |> should
      |> be_equal(
        Error(
          json.UnableToDecode([decode.DecodeError("Float", "Int", ["price"])]),
        ),
      )
      |> or_fail_with("Expected decode.float to refuse 30")
    }),
    it("pitfall: one_of reads a JSON number with no fraction as a float", fn() {
      // Arrange
      let decoder = {
        use price <- decode.field(
          "price",
          decode.one_of(decode.float, [decode.int |> decode.map(int.to_float)]),
        )
        decode.success(price)
      }

      // Act
      let result = json.parse("{\"price\":30}", decoder)

      // Assert
      result
      |> should
      |> be_equal(Ok(30.0))
      |> or_fail_with("Expected 30.0")
    }),
    it("pitfall: an integer above 2^53 is written with every digit", fn() {
      // Act
      let written =
        encoders.optional_int(Some(9_007_199_254_740_993)) |> json.to_string()

      // Assert
      written
      |> should
      |> be_equal("9007199254740993")
      |> or_fail_with("Expected every digit")
    }),
    it("pitfall: json.string of an encoded object writes a string", fn() {
      // Arrange
      let encoded =
        json.object([#("age", encoders.optional_int(None))]) |> json.to_string()

      // Act
      let written =
        json.object([#("user", json.string(encoded))]) |> json.to_string()

      // Assert
      written
      |> should
      |> be_equal("{\"user\":\"{\\\"age\\\":null}\"}")
      |> or_fail_with("Expected the object as an escaped string")
    }),
    it("pitfall: json.nullable with json.string matches optional_string", fn() {
      // Act
      let written = json.nullable(Some("Al"), json.string) |> json.to_string()

      // Assert
      written
      |> should
      |> be_equal(encoders.optional_string(Some("Al")) |> json.to_string())
      |> or_fail_with("Expected the same JSON")
    }),
  ])
}
