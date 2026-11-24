//// Guide: Getting started, steps 2 and 3
////
//// Turns an account record with optional fields and timestamps into the
//// JSON body of an API response.

import dream_json/json_encoders as encoders
import gleam/json.{type Json}
import gleam/option.{type Option, None, Some}
import gleam/time/timestamp.{type Timestamp}

pub type Account {
  Account(
    id: Int,
    name: String,
    nickname: Option(String),
    age: Option(Int),
    rating: Option(Float),
    newsletter: Option(Bool),
    tags: Option(List(String)),
    created_at: Timestamp,
    last_login_at: Option(Timestamp),
  )
}

pub fn account_to_json(account: Account) -> Json {
  json.object([
    #("id", json.int(account.id)),
    #("name", json.string(account.name)),
    #("nickname", encoders.optional_string(account.nickname)),
    #("age", encoders.optional_int(account.age)),
    #("rating", encoders.optional_float(account.rating)),
    #("newsletter", encoders.optional_bool(account.newsletter)),
    #("tags", json.nullable(account.tags, json.array(_, json.string))),
    #(
      "created_at",
      json.string(encoders.timestamp_to_string(account.created_at)),
    ),
    #("last_login_at", encoders.timestamp(account.last_login_at)),
  ])
}

pub fn accounts_body(accounts: List(Account)) -> String {
  json.object([#("accounts", json.array(accounts, account_to_json))])
  |> json.to_string()
}

pub fn example_accounts() -> List(Account) {
  [
    Account(
      id: 1,
      name: "Alice",
      nickname: Some("Al"),
      age: Some(36),
      rating: Some(4.5),
      newsletter: Some(True),
      tags: Some(["admin", "beta"]),
      created_at: timestamp.from_unix_seconds(1_700_000_000),
      last_login_at: Some(timestamp.from_unix_seconds_and_nanoseconds(
        1_700_086_400,
        250_000_000,
      )),
    ),
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
    ),
  ]
}
