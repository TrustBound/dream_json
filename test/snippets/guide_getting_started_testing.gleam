//// Guide: Getting started, testing
////
//// Tests account_to_json with fixed timestamps, one test for an account
//// with every field and one for an account with no optional fields.

import dream_test/matchers.{be_equal, or_fail_with, should}
import dream_test/suite.{type TestSuite}
import dream_test/unit.{describe, it}
import gleam/json
import gleam/option.{None, Some}
import gleam/time/timestamp
import snippets/guide_getting_started_account.{Account, account_to_json}

pub fn tests() -> TestSuite {
  describe("account_to_json", [
    it("writes each optional field that is present", fn() {
      // Arrange
      let account =
        Account(
          id: 1,
          name: "Alice",
          nickname: Some("Al"),
          age: Some(36),
          rating: Some(4.5),
          newsletter: Some(True),
          tags: Some(["admin"]),
          created_at: timestamp.from_unix_seconds(1_700_000_000),
          last_login_at: Some(timestamp.from_unix_seconds(1_700_086_400)),
        )

      // Act
      let body = account_to_json(account) |> json.to_string()

      // Assert
      body
      |> should
      |> be_equal(
        "{\"id\":1,\"name\":\"Alice\",\"nickname\":\"Al\",\"age\":36,"
        <> "\"rating\":4.5,\"newsletter\":true,\"tags\":[\"admin\"],"
        <> "\"created_at\":\"2023-11-14T22:13:20Z\","
        <> "\"last_login_at\":\"2023-11-15T22:13:20Z\"}",
      )
      |> or_fail_with("Expected every field with its value")
    }),
    it("writes null for each optional field that is missing", fn() {
      // Arrange
      let account =
        Account(
          id: 2,
          name: "Bob",
          nickname: None,
          age: None,
          rating: None,
          newsletter: None,
          tags: None,
          created_at: timestamp.from_unix_seconds(1_700_003_600),
          last_login_at: None,
        )

      // Act
      let body = account_to_json(account) |> json.to_string()

      // Assert
      body
      |> should
      |> be_equal(
        "{\"id\":2,\"name\":\"Bob\",\"nickname\":null,\"age\":null,"
        <> "\"rating\":null,\"newsletter\":null,\"tags\":null,"
        <> "\"created_at\":\"2023-11-14T23:13:20Z\",\"last_login_at\":null}",
      )
      |> or_fail_with("Expected null for each missing field")
    }),
  ])
}
