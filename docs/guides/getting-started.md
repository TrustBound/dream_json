# Getting started: turn a record into a JSON response

Most API responses come from a record, and most records have fields that can be missing. A user has no nickname yet. An order has no delivery time until it ships. With `gleam_json` alone, each of those fields needs its own `case` to write the value or `null`, and each timestamp needs a format that the client can read. dream_json gives you one call for each field: `Some(value)` becomes the JSON value, `None` becomes `null`, and a timestamp becomes an RFC 3339 string in UTC. This guide takes you from an empty project to a tested response body.

## Table of Contents

- [What you'll build](#what-youll-build)
- [Before you start](#before-you-start)
- [Step 1: Encode your first object](#step-1-encode-your-first-object)
- [Step 2: Write an encoder for your record](#step-2-write-an-encoder-for-your-record)
- [Step 3: Build the response body](#step-3-build-the-response-body)
- [Step 4: Leave a field out instead of null](#step-4-leave-a-field-out-instead-of-null)
- [Which encoder for which field](#which-encoder-for-which-field)
- [What can go wrong](#what-can-go-wrong)
- [Test your encoder](#test-your-encoder)
- [Common pitfalls](#common-pitfalls)
- [Where to go next](#where-to-go-next)

## What you'll build

In this guide, you build these things:

- Encode an object with an optional field and a timestamp.
- Write `account_to_json` for a record with optional strings, numbers, flags, a list and two timestamps.
- Turn a list of accounts into the JSON body of an API response.
- Leave a field out of the JSON when your API needs that instead of `null`.
- Test the encoder with fixed timestamps.

## Before you start

Add dream_json, and the two packages that its functions work with:

```sh
gleam add dream_json gleam_json gleam_time
```

dream_json depends on `gleam_json` and `gleam_time` already. You add them to your own `gleam.toml` because your code imports `gleam/json` and `gleam/time/timestamp` directly. dream_json has no dependency on the Dream web toolkit, so it works in any Gleam project.

Each example below is a complete module. Put it in `src/`, call its public function from your `main` or from a test, and print the result with `io.println`.

## Step 1: Encode your first object

dream_json has one module, `dream_json/json_encoders`. The examples import it as `encoders`. Each of its functions returns a `json.Json` value, so it goes anywhere that `gleam_json` takes one, such as an entry of `json.object`:

### Build a user object <a href="https://github.com/TrustBound/dream_json/blob/2.0.0/test/snippets/quick_start.gleam"><img align="right" alt="Tested snippet" src="https://img.shields.io/badge/%F0%9F%A7%AA_tested-snippet-lightgreen.svg?style=flat-square"></a>

```gleam
import dream_json/json_encoders as encoders
import gleam/json
import gleam/option
import gleam/time/timestamp.{type Timestamp}

pub fn user_json(created_at: Timestamp) -> String {
  json.object([
    #("name", json.string("Alice")),
    #("email", encoders.optional_string(option.Some("alice@example.com"))),
    // Encodes as null
    #("age", encoders.optional_int(option.None)),
    #("created_at", encoders.timestamp(option.Some(created_at))),
  ])
  |> json.to_string()
}
```

Call it with the time `1_700_000_000` seconds after the Unix epoch:

```text
user_json(timestamp.from_unix_seconds(1_700_000_000))
  -> {"name":"Alice","email":"alice@example.com","age":null,"created_at":"2023-11-14T22:13:20Z"}
```

Here is what each field does:

- `name` is always present, so it uses `json.string` from `gleam_json`.
- `email` is an `Option(String)`. `optional_string` writes `Some("alice@example.com")` as a JSON string.
- `age` is `None`, so `optional_int` writes `null`. The key stays in the object.
- `created_at` goes through `encoders.timestamp`, which writes the time as an RFC 3339 string in UTC. Every common JSON client can parse that form as a date.

## Step 2: Write an encoder for your record

In a real program, the values come from a record, and one function turns the record into JSON. Put that function next to the type, so that each handler that returns the record uses the same JSON. Here is an account with each kind of optional field:

### Encode an account record <a href="https://github.com/TrustBound/dream_json/blob/2.0.0/test/snippets/guide_getting_started_account.gleam#L6-L40"><img align="right" alt="Tested snippet" src="https://img.shields.io/badge/%F0%9F%A7%AA_tested-snippet-lightgreen.svg?style=flat-square"></a>

```gleam
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
```

Each field uses the encoder for its type:

- `optional_string`, `optional_int`, `optional_float` and `optional_bool` write the value for `Some`, and `null` for `None`.
- `tags` is an `Option(List(String))`. dream_json has no encoder for lists, so the code uses `json.nullable` from `gleam_json`, with `json.array` for the value. `json.nullable(value, json.string)` writes the same JSON as `optional_string(value)`, so you can use it for any type that has an encoder.
- `created_at` is always present. `timestamp_to_string` turns it into the RFC 3339 string, and `json.string` makes that string a JSON value.
- `last_login_at` can be missing. `encoders.timestamp` writes the string for `Some` and `null` for `None`.

`account_to_json` returns `json.Json`, not a `String`. This is on purpose: a `Json` value can go inside an array or another object, and you turn it into text one time, at the edge of your program.

## Step 3: Build the response body

A list endpoint returns many accounts in one body. This code goes in the same module as `account_to_json`. `example_accounts` gives two accounts to try it with: Alice has every field, and Bob has only the required ones.

### Build the body of a list response <a href="https://github.com/TrustBound/dream_json/blob/2.0.0/test/snippets/guide_getting_started_account.gleam#L42-L75"><img align="right" alt="Tested snippet" src="https://img.shields.io/badge/%F0%9F%A7%AA_tested-snippet-lightgreen.svg?style=flat-square"></a>

```gleam
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
```

`json.array` calls `account_to_json` for each account, and `json.to_string` turns the result into the text that you send. `accounts_body(example_accounts())` returns this, on one line:

```text
{"accounts":[{"id":1,"name":"Alice","nickname":"Al","age":36,"rating":4.5,"newsletter":true,"tags":["admin","beta"],"created_at":"2023-11-14T22:13:20Z","last_login_at":"2023-11-15T22:13:20.25Z"},{"id":2,"name":"Bob","nickname":null,"age":null,"rating":null,"newsletter":null,"tags":null,"created_at":"2023-11-14T23:13:20Z","last_login_at":null}]}
```

Look at two things in this output:

- Bob's object has the same keys as Alice's. Each missing value is `null`, so a client can read both objects with the same code.
- Alice's last login has 250,000,000 nanoseconds, and the string shows them as `.25`. dream_json removes the trailing zeros of the fraction, and writes no fraction for a whole second. The [timestamps guide](https://github.com/TrustBound/dream_json/blob/main/docs/guides/timestamps.md) shows every form of the string.

`gleam_json` writes compact JSON, with no spaces or line breaks, and it keeps the keys in the order that you give them. Your web framework sends the string as the body, with the header `content-type: application/json`.

## Step 4: Leave a field out instead of null

Some APIs read a missing key and a `null` key differently. A typical case is a partial update: a missing key means "do not change this field", and `null` means "clear this field". The dream_json encoders always write the key, so for these APIs you build the list of fields yourself, and drop the ones that are `None`:

### Leave out the fields that are None <a href="https://github.com/TrustBound/dream_json/blob/2.0.0/test/snippets/guide_getting_started_leave_out.gleam#L6-L34"><img align="right" alt="Tested snippet" src="https://img.shields.io/badge/%F0%9F%A7%AA_tested-snippet-lightgreen.svg?style=flat-square"></a>

```gleam
import gleam/json.{type Json}
import gleam/list
import gleam/option.{type Option}
import gleam/result

pub fn object_without_nones(fields: List(#(String, Option(Json)))) -> Json {
  fields
  |> list.filter_map(present_field)
  |> json.object()
}

fn present_field(
  field: #(String, Option(Json)),
) -> Result(#(String, Json), Nil) {
  let #(name, value) = field
  option.to_result(value, Nil)
  |> result.map(fn(encoded) { #(name, encoded) })
}

pub fn profile_update_json(
  nickname: Option(String),
  age: Option(Int),
) -> String {
  object_without_nones([
    #("nickname", option.map(nickname, json.string)),
    #("age", option.map(age, json.int)),
  ])
  |> json.to_string()
}
```

`profile_update_json(Some("Al"), None)` returns `{"nickname":"Al"}`, with no `age` key. `profile_update_json(None, None)` returns `{}`.

Each field is an `Option(Json)`: `option.map` encodes the value when there is one. `object_without_nones` keeps only the fields that are `Some`. This code does not use dream_json at all, and that is the point: pick the dream_json encoders when the client wants `null`, and this pattern when it wants the key gone.

## Which encoder for which field

| The field in your record | Use | Why |
|:---|:---|:---|
| `Option(String)` | `encoders.optional_string` | A JSON string for `Some`, `null` for `None`. |
| `Option(Int)` | `encoders.optional_int` | A JSON number for `Some`, `null` for `None`. |
| `Option(Float)` | `encoders.optional_float` | A JSON number for `Some`, `null` for `None`. A whole number keeps its fraction: `Some(30.0)` gives `30.0`. |
| `Option(Bool)` | `encoders.optional_bool` | `true` or `false` for `Some`, `null` for `None`. |
| `Option(Timestamp)` | `encoders.timestamp` | An RFC 3339 string in UTC for `Some`, `null` for `None`. |
| `Timestamp`, always present | `json.string(encoders.timestamp_to_string(t))` | The same string, with no `Option` to wrap and unwrap. |
| `Option` of a list, a dict or your own type | `json.nullable(value, encoder)` from `gleam_json` | dream_json has no encoder for these. `json.nullable` writes `null` for `None` and calls your encoder for `Some`. |
| A field that the client wants left out when it is missing | The pattern in [Step 4](#step-4-leave-a-field-out-instead-of-null) | The encoders always write the key. |

## What can go wrong

The encoders accept every value of their type, so encoding cannot fail. The problems show up in the program that reads your JSON:

- **A large integer in a JavaScript client.** `optional_int(Some(9_007_199_254_740_993))` writes every digit, `9007199254740993`. A JavaScript client stores JSON numbers as 64-bit floats, so `JSON.parse` reads it as `9007199254740992` (checked with Node.js 24). Any integer above 2^53 can change this way. If your IDs can grow that big, send them as strings: `json.string(int.to_string(id))`.
- **A whole-number float in a strict reader.** `optional_float(Some(30.0))` writes `30.0`, so a Gleam reader with `decode.float` reads it back. But JSON from another system can say `30` for the same price, and `decode.float` refuses that: `json.parse("{\"price\":30}", decoder)` returns `Error(UnableToDecode([DecodeError("Float", "Int", ["price"])]))`. When you read numbers that you did not write, accept both forms with `decode.one_of(decode.float, [decode.int |> decode.map(int.to_float)])`, which reads `30` as `30.0`.
- **A timestamp that the client cannot parse.** The string has a four-digit year, so a year after 9999 or before year 0 gives a string that `timestamp.parse_rfc3339` refuses. The [timestamps guide](https://github.com/TrustBound/dream_json/blob/main/docs/guides/timestamps.md#what-can-go-wrong) shows these strings and how to read timestamps back safely.

## Test your encoder

An encoder is a pure function, so its test needs no server: build a record, encode it, and compare the string. Comparing the whole string is safe, because `json.object` keeps your key order and writes no spaces. Use fixed timestamps, never `timestamp.system_time()`, so the expected string is the same on every run.

These tests use [dream_test](https://hexdocs.pm/dream_test). It is not on Hex yet, so add it from GitHub, with the same commit that this package tests with:

```toml
[dev-dependencies]
dream_test = { git = "https://github.com/TrustBound/dream_test.git", ref = "1639959578a14ae3577f8e3ae5cac058f933aa53" }
```

Here is a test module for `account_to_json` from Step 2. It checks one account with every field, and one with every optional field missing:

### Test account_to_json <a href="https://github.com/TrustBound/dream_json/blob/2.0.0/test/snippets/guide_getting_started_testing.gleam#L6-L74"><img align="right" alt="Tested snippet" src="https://img.shields.io/badge/%F0%9F%A7%AA_tested-snippet-lightgreen.svg?style=flat-square"></a>

```gleam
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
```

Add `tests()` to the list that your test runner runs, then run `gleam test`. The second test is the one that protects your clients: if someone changes an encoder to `option.unwrap`, the `null` turns into a value, and this test fails.

## Common pitfalls

**Encoding the JSON twice.** *Symptom:* the client gets a string where it expected an object, such as `{"user":"{\"age\":null}"}`. *Fix:* the inner object went through `json.to_string` and then `json.string`. Return `json.Json` from your encoders, as `account_to_json` does, and call `json.to_string` only on the whole body.

**Writing an empty value instead of null.** *Symptom:* the client shows an empty name, or a zero age, for a user who never gave one. *Fix:* `option.unwrap(name, "")` with `json.string` turns "unknown" into "empty". Use `optional_string` and the other encoders, so the client can tell the two apart.

**A test that uses the current time.** *Symptom:* the encoder test passes one time and fails the next, with a different `created_at`. *Fix:* build the record with `timestamp.from_unix_seconds`, as the test above does. If your handler stamps the time itself, pass the time in as an argument, so a test can give a fixed one.

**A client that expects the key to be gone.** *Symptom:* a partial update clears a field that the user did not touch. *Fix:* the API reads `null` as "clear this field". Leave the key out, as in [Step 4](#step-4-leave-a-field-out-instead-of-null).

**IDs that change in the browser.** *Symptom:* a JavaScript client asks for an ID that is off by one or two. *Fix:* the ID is above 2^53. Send it as a string, as [What can go wrong](#what-can-go-wrong) shows.

## Where to go next

- [Send timestamps and read them back](https://github.com/TrustBound/dream_json/blob/main/docs/guides/timestamps.md): the exact form of each timestamp string, a decoder that reads it back, and what to do with bad input.
- [README](https://github.com/TrustBound/dream_json/blob/main/README.md): what the package is, in one page.
- [API reference on HexDocs](https://hexdocs.pm/dream_json/dream_json/json_encoders.html): `optional_string`, `optional_int`, `optional_float`, `optional_bool`, `timestamp` and `timestamp_to_string`.
- [gleam_json on HexDocs](https://hexdocs.pm/gleam_json/gleam/json.html): `json.object`, `json.array`, `json.nullable` and `json.parse`.
