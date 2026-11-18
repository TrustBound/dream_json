//// Tests for the examples in the dream_json doc comments.

import dream_test/matchers.{be_equal, or_fail_with, should}
import dream_test/types.{type TestSuite}
import dream_test/unit.{describe, group, it}
import gleam/time/timestamp
import snippets/doc_optional_bool
import snippets/doc_optional_float
import snippets/doc_optional_int
import snippets/doc_optional_string
import snippets/doc_timestamp
import snippets/doc_timestamp_to_string

pub fn tests() -> TestSuite(Nil) {
  describe("doc comment snippets", [
    group("doc_optional_string.name_json", [
      it("encodes the name, a null middle name and the nickname", fn() {
        // Act
        let result = doc_optional_string.name_json()

        // Assert
        result
        |> should
        |> be_equal(
          "{\"name\":\"Alice\",\"middle_name\":null,\"nickname\":\"Al\"}",
        )
        |> or_fail_with("Expected the name JSON")
      }),
    ]),
    group("doc_optional_int.account_json", [
      it("encodes the user id, a null parent id and the age", fn() {
        // Act
        let result = doc_optional_int.account_json()

        // Assert
        result
        |> should
        |> be_equal("{\"user_id\":123,\"parent_id\":null,\"age\":30}")
        |> or_fail_with("Expected the account JSON")
      }),
    ]),
    group("doc_optional_float.price_json", [
      it("encodes the price and a null discount", fn() {
        // Act
        let result = doc_optional_float.price_json()

        // Assert
        result
        |> should
        |> be_equal("{\"price\":19.99,\"discount\":null}")
        |> or_fail_with("Expected the price JSON")
      }),
    ]),
    group("doc_optional_bool.flags_json", [
      it("encodes true and a null verified flag", fn() {
        // Act
        let result = doc_optional_bool.flags_json()

        // Assert
        result
        |> should
        |> be_equal("{\"is_active\":true,\"is_verified\":null}")
        |> or_fail_with("Expected the flags JSON")
      }),
    ]),
    group("doc_timestamp.record_json", [
      it("encodes the creation time and a null deletion time", fn() {
        // Arrange
        let created_at = timestamp.from_unix_seconds(1_700_000_000)

        // Act
        let result = doc_timestamp.record_json(created_at)

        // Assert
        result
        |> should
        |> be_equal(
          "{\"created_at\":\"Timestamp(1700000000, 0)\",\"deleted_at\":null}",
        )
        |> or_fail_with("Expected the record JSON")
      }),
    ]),
    group("doc_timestamp_to_string.launch_time", [
      it("returns the string form of the timestamp", fn() {
        // Act
        let result = doc_timestamp_to_string.launch_time()

        // Assert
        result
        |> should
        |> be_equal("Timestamp(1700000000, 0)")
        |> or_fail_with("Expected Timestamp(1700000000, 0)")
      }),
    ]),
  ])
}
