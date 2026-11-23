# Send timestamps and read them back

A timestamp in JSON is only a string, so both sides must agree on its form. dream_json writes every timestamp as an RFC 3339 string in UTC, such as `"2023-11-14T22:13:20Z"`, which standard date parsers read, such as `new Date()` in JavaScript (checked with Node.js 24). When the reader is a Gleam program, such as a client of your API, a worker that reads a queue, or the test of your own encoder, you also need a decoder that turns the string back into a `Timestamp`, and that refuses a string that is not a time. This guide shows exactly what dream_json writes, how to read it back, and what to do when the input is wrong.

## Table of Contents

- [What you'll build](#what-youll-build)
- [Before you start](#before-you-start)
- [Step 1: Write a timestamp](#step-1-write-a-timestamp)
- [What the string looks like](#what-the-string-looks-like)
- [Step 2: Decode one timestamp](#step-2-decode-one-timestamp)
- [Step 3: Decode a whole record](#step-3-decode-a-whole-record)
- [Step 4: Report bad input](#step-4-report-bad-input)
- [Which function to use](#which-function-to-use)
- [What can go wrong](#what-can-go-wrong)
- [Test your round trip](#test-your-round-trip)
- [Common pitfalls](#common-pitfalls)
- [Where to go next](#where-to-go-next)

## What you'll build

In this guide, you build these things:

- Write a required and an optional timestamp into a JSON object.
- Know the exact string for whole seconds, fractions of a second and times before 1970.
- Write a decoder that reads an RFC 3339 string into a `Timestamp`.
- Read a whole record back, with an end time that can be `null` or missing.
- Turn bad input into a message that names the field.
- Test that a record survives the trip to JSON and back.

## Before you start

Add dream_json and the packages that the examples import:

```sh
gleam add dream_json gleam_json gleam_time
```

Each example is a complete module, or code that goes in the module of the step before it. Put it in `src/`, and call its public functions from your `main` or from a test. The [getting started guide](https://github.com/TrustBound/dream_json/blob/main/docs/guides/getting-started.md) shows how the encoders fit into a record encoder.

## Step 1: Write a timestamp

`timestamp_to_string` turns a `Timestamp` into its RFC 3339 string. Use it when the time is always there:

### Convert a timestamp to its RFC 3339 string <a href="https://github.com/TrustBound/dream_json/blob/2.0.0/test/snippets/doc_timestamp_to_string.gleam#L5-L11"><img align="right" alt="Tested snippet" src="https://img.shields.io/badge/%F0%9F%A7%AA_tested-snippet-lightgreen.svg?style=flat-square"></a>

```gleam
import dream_json/json_encoders as encoders
import gleam/time/timestamp

pub fn launch_time() -> String {
  timestamp.from_unix_seconds(1_700_000_000)
  |> encoders.timestamp_to_string()
}
```

`launch_time()` returns `"2023-11-14T22:13:20Z"`.

Most records have both kinds of time: one that is always set, and one that can be missing. Here is a meeting with a start time and an optional end time. The module also holds the decoders of the next steps, so it imports what they need too:

### Write a meeting with two timestamps <a href="https://github.com/TrustBound/dream_json/blob/2.0.0/test/snippets/guide_timestamps_meeting.gleam#L6-L26"><img align="right" alt="Tested snippet" src="https://img.shields.io/badge/%F0%9F%A7%AA_tested-snippet-lightgreen.svg?style=flat-square"></a>

```gleam
import dream_json/json_encoders as encoders
import gleam/dynamic/decode.{type Decoder}
import gleam/json
import gleam/list
import gleam/option.{type Option, None}
import gleam/result
import gleam/string
import gleam/time/timestamp.{type Timestamp}

pub type Meeting {
  Meeting(title: String, starts_at: Timestamp, ends_at: Option(Timestamp))
}

pub fn meeting_to_json(meeting: Meeting) -> String {
  json.object([
    #("title", json.string(meeting.title)),
    #("starts_at", json.string(encoders.timestamp_to_string(meeting.starts_at))),
    #("ends_at", encoders.timestamp(meeting.ends_at)),
  ])
  |> json.to_string()
}
```

The start time goes through `timestamp_to_string` and `json.string`. The end time goes through `encoders.timestamp`, which does the same for `Some` and writes `null` for `None`. For a meeting that starts at `1_700_000_000` seconds and has no end time, `meeting_to_json` returns:

### A meeting with no end time <a href="https://github.com/TrustBound/dream_json/blob/2.0.0/test/outputs/guide_timestamps_meeting_without_end.txt"><img align="right" alt="Tested snippet" src="https://img.shields.io/badge/%F0%9F%A7%AA_tested-snippet-lightgreen.svg?style=flat-square"></a>

```text
{"title":"Standup","starts_at":"2023-11-14T22:13:20Z","ends_at":null}
```

With an end time of `1_700_001_800` seconds and 250,000,000 nanoseconds, it returns:

### A meeting with an end time <a href="https://github.com/TrustBound/dream_json/blob/2.0.0/test/outputs/guide_timestamps_meeting_with_end.txt"><img align="right" alt="Tested snippet" src="https://img.shields.io/badge/%F0%9F%A7%AA_tested-snippet-lightgreen.svg?style=flat-square"></a>

```text
{"title":"Standup","starts_at":"2023-11-14T22:13:20Z","ends_at":"2023-11-14T22:43:20.25Z"}
```

## What the string looks like

dream_json writes the time in UTC, so the string always ends in `Z`. It never writes a local time or an offset such as `+01:00`. The fraction of a second has at most nine digits, and dream_json removes its trailing zeros:

| The timestamp | The string |
|:---|:---|
| `from_unix_seconds(1_700_000_000)` | `"2023-11-14T22:13:20Z"` (no fraction for a whole second) |
| `from_unix_seconds_and_nanoseconds(1_700_000_000, 123_000_000)` | `"2023-11-14T22:13:20.123Z"` |
| `from_unix_seconds_and_nanoseconds(1_700_000_000, 5)` | `"2023-11-14T22:13:20.000000005Z"` |
| `from_unix_seconds(-1)` | `"1969-12-31T23:59:59Z"` (a time before 1970 is an earlier date) |

So the length of the string changes with the fraction. Do not cut the string at a fixed position, and do not compare two times as strings. Parse them, as the next step does.

## Step 2: Decode one timestamp

To read the string back, decode it as a string, then parse it with `timestamp.parse_rfc3339` from `gleam_time`. This function goes in the same module as `meeting_to_json`:

### Decode an RFC 3339 string into a Timestamp <a href="https://github.com/TrustBound/dream_json/blob/2.0.0/test/snippets/guide_timestamps_meeting.gleam#L28-L34"><img align="right" alt="Tested snippet" src="https://img.shields.io/badge/%F0%9F%A7%AA_tested-snippet-lightgreen.svg?style=flat-square"></a>

```gleam
pub fn timestamp_decoder() -> Decoder(Timestamp) {
  use text <- decode.then(decode.string)
  case timestamp.parse_rfc3339(text) {
    Ok(time) -> decode.success(time)
    Error(Nil) -> decode.failure(timestamp.unix_epoch, "Timestamp")
  }
}
```

`decode.then` runs the second part only when the value is a string. `parse_rfc3339` returns `Ok(time)` for a valid string, and the decoder succeeds with that time. For any other string it returns `Error(Nil)`, and `decode.failure` reports that the field expected a `Timestamp`. The first argument of `decode.failure` is a placeholder value that the decoder needs, and your code never sees it.

`parse_rfc3339` reads every string that dream_json writes, with all nine digits of the fraction, so the round trip gives you back the same `Timestamp`.

## Step 3: Decode a whole record

Now use `timestamp_decoder` for both fields of the meeting:

### Decode a meeting <a href="https://github.com/TrustBound/dream_json/blob/2.0.0/test/snippets/guide_timestamps_meeting.gleam#L36-L45"><img align="right" alt="Tested snippet" src="https://img.shields.io/badge/%F0%9F%A7%AA_tested-snippet-lightgreen.svg?style=flat-square"></a>

```gleam
pub fn meeting_decoder() -> Decoder(Meeting) {
  use title <- decode.field("title", decode.string)
  use starts_at <- decode.field("starts_at", timestamp_decoder())
  use ends_at <- decode.optional_field(
    "ends_at",
    None,
    decode.optional(timestamp_decoder()),
  )
  decode.success(Meeting(title:, starts_at:, ends_at:))
}
```

The two time fields need different decoders:

- `starts_at` must be there, so it uses `decode.field`.
- `ends_at` can be `null`, because that is what `encoders.timestamp` writes for `None`. `decode.optional` reads `null` as `None`. It goes inside `decode.optional_field`, which also reads a missing key as `None`, the default in its second argument. That way the decoder also accepts JSON from a program that leaves the key out.

Parse a body with `json.parse(body, meeting_decoder())`. For the second output of Step 1, it returns the same meeting that you encoded: `Ok(Meeting(title: "Standup", starts_at: ..., ends_at: Some(...)))`, with 250,000,000 nanoseconds in the end time. For `{"title":"Standup","starts_at":"2023-11-14T22:13:20Z"}`, with no `ends_at` key, the end time is `None`.

## Step 4: Report bad input

When the JSON comes from outside your program, such as the body of a request, you need to say what is wrong with it. `json.parse` returns a `json.DecodeError`, which tells you the field, what the decoder expected and what it found. This code turns that into a message that you can send back with a `400` response:

### Read a meeting and describe bad input <a href="https://github.com/TrustBound/dream_json/blob/2.0.0/test/snippets/guide_timestamps_meeting.gleam#L47-L66"><img align="right" alt="Tested snippet" src="https://img.shields.io/badge/%F0%9F%A7%AA_tested-snippet-lightgreen.svg?style=flat-square"></a>

```gleam
pub fn read_meeting(body: String) -> Result(Meeting, String) {
  json.parse(body, meeting_decoder())
  |> result.map_error(describe_error)
}

fn describe_error(error: json.DecodeError) -> String {
  case error {
    json.UnableToDecode(errors) ->
      list.map(errors, describe_field_error) |> string.join(", ")
    _ -> "the body is not valid JSON"
  }
}

fn describe_field_error(error: decode.DecodeError) -> String {
  string.join(error.path, ".")
  <> ": expected "
  <> error.expected
  <> ", found "
  <> error.found
}
```

`read_meeting` returns `Ok(meeting)` for good input, and `Error(message)` for bad input. Here is what it returns for the input that you meet in real use:

### What read_meeting returns <a href="https://github.com/TrustBound/dream_json/blob/2.0.0/test/outputs/guide_timestamps_read_meeting.txt"><img align="right" alt="Tested snippet" src="https://img.shields.io/badge/%F0%9F%A7%AA_tested-snippet-lightgreen.svg?style=flat-square"></a>

```text
"starts_at":"2023-11-14T23:13:20+01:00"   -> Ok, starts_at is 2023-11-14T22:13:20Z
"starts_at":"2023-11-14T22:13:20"         -> Error("starts_at: expected Timestamp, found String")
"starts_at":"Timestamp(1700000000, 0)"    -> Error("starts_at: expected Timestamp, found String")
"starts_at":1700000000                    -> Error("starts_at: expected String, found Int")
no "starts_at" key                        -> Error("starts_at: expected Field, found Nothing")
{"title":                                 -> Error("the body is not valid JSON")
```

`UnableToDecode` holds one `DecodeError` for each field that failed, and `describe_field_error` joins the names in its path with dots. The other errors of `json.parse` mean that the text is not JSON at all.

## Which function to use

| Your situation | Use | Why |
|:---|:---|:---|
| Write a time that is always set | `json.string(encoders.timestamp_to_string(t))` | The RFC 3339 string, with no `Option`. |
| Write a time that can be missing | `encoders.timestamp(option)` | The string for `Some`, `null` for `None`. |
| Write a time with a local offset, such as `+01:00` | `timestamp.to_rfc3339(t, offset)` from `gleam_time` | dream_json always writes UTC. |
| Read a time that must be there | `decode.field(name, timestamp_decoder())` | A missing key or a bad string is an error. |
| Read a time that can be `null` | `decode.field(name, decode.optional(timestamp_decoder()))` | `null` becomes `None`. A missing key is still an error. |
| Read a time that can be `null` or missing | `decode.optional_field(name, None, decode.optional(timestamp_decoder()))` | Both become `None`. |

## What can go wrong

These are the inputs that break a timestamp in real use, and what the code of this guide does with each:

- **A time with an offset.** Another system can send `"2023-11-14T23:13:20+01:00"`. `parse_rfc3339` reads it as the same moment in UTC, and `read_meeting` succeeds. If you write it out again, it becomes `"2023-11-14T22:13:20Z"`: the same time, but a different string.
- **A time with no offset.** `"2023-11-14T22:13:20"` does not say which time zone it is in, so `parse_rfc3339` refuses it, and `read_meeting` returns `Error("starts_at: expected Timestamp, found String")`. Ask the sender for UTC, or for an offset. Do not guess the zone.
- **Data from dream_json 1.x.** Version 1 wrote the debug text of the value, such as `"Timestamp(1700000000, 0)"`. No decoder for RFC 3339 reads it, and `read_meeting` refuses it with the same message. Convert stored data before you read it with the new decoder.
- **A number of seconds.** Some APIs send `1700000000` instead of a string. `decode.string` refuses it: `Error("starts_at: expected String, found Int")`.
- **A missing field.** `decode.field` refuses a missing key: `Error("starts_at: expected Field, found Nothing")`. Use `decode.optional_field` only for a field that may really be missing.
- **A year outside 0000 to 9999.** RFC 3339 has room for four digits of year, and `gleam_time` writes the string that dream_json returns. A year after 9999 gives five digits: `from_unix_seconds(253_402_300_800)` gives `"10000-01-01T00:00:00Z"`, and `parse_rfc3339` refuses that string. A year before 0 gives a string that is not RFC 3339 at all: `from_unix_seconds(-62_167_219_201)` gives `"00-1-12-31T23:59:59Z"`. If you use a far-future time to mean "never", use `9999-12-31T23:59:59Z` (`from_unix_seconds(253_402_300_799)`), or better, `None`.

## Test your round trip

The strongest test for a pair of encoder and decoder is a round trip: encode a value, decode the result, and expect the same value. Pick times that touch every form of the string: a fraction of a second, a time before 1970, and a missing end time. Also test one bad input, so that a change to the decoder that starts to accept it fails a test.

These tests use [dream_test](https://hexdocs.pm/dream_test), from GitHub, as the [getting started guide](https://github.com/TrustBound/dream_json/blob/main/docs/guides/getting-started.md#test-your-encoder) shows. Here is a test module for the meeting code:

### Test the round trip of a meeting <a href="https://github.com/TrustBound/dream_json/blob/2.0.0/test/snippets/guide_timestamps_testing.gleam#L6-L68"><img align="right" alt="Tested snippet" src="https://img.shields.io/badge/%F0%9F%A7%AA_tested-snippet-lightgreen.svg?style=flat-square"></a>

```gleam
import dream_test/matchers.{be_equal, or_fail_with, should}
import dream_test/suite.{type TestSuite}
import dream_test/unit.{describe, it}
import gleam/option.{None, Some}
import gleam/time/timestamp
import snippets/guide_timestamps_meeting.{Meeting, meeting_to_json, read_meeting}

pub fn tests() -> TestSuite {
  describe("meeting JSON", [
    it("reads back a meeting with nanoseconds and a time before 1970", fn() {
      // Arrange
      let meeting =
        Meeting(
          title: "Standup",
          starts_at: timestamp.from_unix_seconds_and_nanoseconds(
            1_700_000_000,
            5,
          ),
          ends_at: Some(timestamp.from_unix_seconds(-1)),
        )

      // Act
      let read_back = meeting |> meeting_to_json() |> read_meeting()

      // Assert
      read_back
      |> should
      |> be_equal(Ok(meeting))
      |> or_fail_with("Expected the same meeting back")
    }),
    it("reads back a meeting with no end time", fn() {
      // Arrange
      let meeting =
        Meeting(
          title: "Standup",
          starts_at: timestamp.from_unix_seconds(1_700_000_000),
          ends_at: None,
        )

      // Act
      let read_back = meeting |> meeting_to_json() |> read_meeting()

      // Assert
      read_back
      |> should
      |> be_equal(Ok(meeting))
      |> or_fail_with("Expected the same meeting back")
    }),
    it("refuses a start time with no offset", fn() {
      // Arrange
      let body = "{\"title\":\"Standup\",\"starts_at\":\"2023-11-14T22:13:20\"}"

      // Act
      let result = read_meeting(body)

      // Assert
      result
      |> should
      |> be_equal(Error("starts_at: expected Timestamp, found String"))
      |> or_fail_with("Expected the start time to be refused")
    }),
  ])
}
```

The first test uses 5 nanoseconds, which needs all nine digits of the fraction, and an end time one second before 1970. If the encoder ever drops digits, the decoded time is different, and the test fails. Add `tests()` to the list that your test runner runs, then run `gleam test`.

## Common pitfalls

**Comparing times as strings.** *Symptom:* two times that look different are the same moment, or a sort puts `"2023-11-14T22:13:20Z"` after `"2023-11-14T22:13:20.5Z"`, which is half a second later. *Fix:* a string can have an offset or a fraction of any length. Parse both strings with `timestamp.parse_rfc3339`, and compare the results with `timestamp.compare`.

**Losing digits in a JavaScript client.** *Symptom:* a browser sends back `"2023-11-14T22:13:20.123Z"` for a time that you wrote as `"2023-11-14T22:13:20.123456789Z"`, and a check for "same version" fails. *Fix:* a JavaScript `Date` keeps milliseconds only (checked with Node.js 24). If clients send times back for you to compare, round them down to milliseconds before you write them. Take `#(seconds, nanoseconds)` from `timestamp.to_unix_seconds_and_nanoseconds(t)`, and write `timestamp.from_unix_seconds_and_nanoseconds(seconds, nanoseconds / 1_000_000 * 1_000_000)`. For `123_456_789` nanoseconds, that gives `"2023-11-14T22:13:20.123Z"`.

**Decoding with `decode.optional` alone.** *Symptom:* `expected Field, found Nothing` for JSON that has no `ends_at` key. *Fix:* `decode.optional` reads `null`, not a missing key. Wrap it in `decode.optional_field`, as in [Step 3](#step-3-decode-a-whole-record).

**Old timestamps in stored JSON.** *Symptom:* after the upgrade to 2.0.0, records saved before it fail to decode with `expected Timestamp, found String`. *Fix:* those records hold the version 1 text, `"Timestamp(seconds, nanoseconds)"`. Convert them to RFC 3339 one time, or keep a second decoder for the old form until the old data is gone.

**The current time in a test.** *Symptom:* a test that compares JSON text passes one time and fails the next. *Fix:* build times with `timestamp.from_unix_seconds`, or compare decoded values, as the round trip test does.

## Where to go next

- [Getting started: turn a record into a JSON response](https://github.com/TrustBound/dream_json/blob/main/docs/guides/getting-started.md): the encoders for optional strings, numbers and flags, and how to build a response body.
- [README](https://github.com/TrustBound/dream_json/blob/main/README.md): what the package is, in one page.
- [API reference on HexDocs](https://hexdocs.pm/dream_json/dream_json/json_encoders.html): `timestamp` and `timestamp_to_string`, with the rest of the encoders.
- [gleam_time on HexDocs](https://hexdocs.pm/gleam_time/gleam/time/timestamp.html): `parse_rfc3339`, `to_rfc3339`, `compare` and the other functions of `Timestamp`.
- [The decode module on HexDocs](https://hexdocs.pm/gleam_stdlib/gleam/dynamic/decode.html): `field`, `optional_field`, `optional` and `then`.
