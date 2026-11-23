<div align="center">
  <img src="https://raw.githubusercontent.com/TrustBound/dream/main/ricky_and_lucy.png" alt="Ricky Moony and Lucy, a moon shaped mascot for Dream with the star shaped mascot for Gleam, each with cute cartoon eyes and a smile" width="200">

<b>JSON encoding utilities for Gleam applications.</b>

</div>

<br />

<div align="center">
  <a href="https://hex.pm/packages/dream_json"><img src="https://img.shields.io/hexpm/v/dream_json" alt="Hex Package"></a>
  <a href="https://github.com/TrustBound/dream_json/releases"><img src="https://img.shields.io/github/v/release/TrustBound/dream_json?label=Release" alt="Latest Release"></a>
  <a href="https://hexdocs.pm/dream_json"><img src="https://img.shields.io/badge/hex-docs-lightgreen.svg" alt="HexDocs"></a>
  <a href="https://github.com/TrustBound/dream_json/actions/workflows/ci.yml?query=branch%3Amain"><img src="https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/TrustBound/dream_json/badges/coverage.json" alt="Coverage"></a>
  <a href="https://github.com/TrustBound/dream_json/blob/main/LICENSE.md"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT License"></a>
  <a href="https://gleam.run"><img src="https://img.shields.io/badge/gleam-%E2%9C%A8-ffaff3" alt="Gleam"></a>
</div>

<br />

# dream_json

A standalone module with convenience functions that encode optional values and timestamps to JSON. It is built with the same quality standards as [Dream](https://github.com/TrustBound/dream), but it is completely independent. Use it in any Gleam project.

## Features

- ✅ Encode optional values to JSON (`null` if `None`)
- ✅ Timestamp encoding helpers
- ✅ Support for strings, integers, floats, and booleans
- ✅ Zero runtime dependencies on Dream (can be used independently)

## Installation

```bash
gleam add dream_json
```

## Quick Start

### Build a user object <a href="https://github.com/TrustBound/dream_json/blob/2.0.0/test/snippets/quick_start.gleam"><img align="right" alt="Tested snippet" src="https://img.shields.io/badge/%F0%9F%A7%AA_tested-snippet-lightgreen.svg?style=flat-square"></a> <a href="https://github.com/TrustBound/dream_json/blob/2.0.0/docs/guides/getting-started.md#build-a-user-object-"><img align="right" alt="Guide" src="https://img.shields.io/badge/%F0%9F%93%96_read-guide-blue.svg?style=flat-square"></a>

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

## Guides

- [Getting started](https://github.com/TrustBound/dream_json/blob/main/docs/guides/getting-started.md): install the package and build a first JSON object
- [Optional values](https://github.com/TrustBound/dream_json/blob/main/docs/guides/optional-values.md): encode optional strings, integers, floats and booleans as their value or as `null`
- [Timestamps](https://github.com/TrustBound/dream_json/blob/main/docs/guides/timestamps.md): encode timestamps as RFC 3339 strings in UTC

## API Reference

The full API reference is on [HexDocs](https://hexdocs.pm/dream_json). Each guide lists the functions it uses.

## Design Principles

dream_json follows Dream's [design principles](https://github.com/TrustBound/dream/blob/release/3.0.0/docs/reference/design-principles.md) and [contributing guide](https://github.com/TrustBound/dream/blob/release/3.0.0/docs/contributing/contributing.md).

## About Dream

This module was originally built for the [Dream](https://github.com/TrustBound/dream) web toolkit, but it's completely standalone and can be used in any Gleam project. It follows Dream's design principles and will be maintained as part of the Dream ecosystem.

## Contributing

See the [Contributing Guide](https://github.com/TrustBound/dream_json/blob/main/CONTRIBUTING.md) for guidelines.

---

## License

MIT — see [LICENSE.md](https://github.com/TrustBound/dream_json/blob/main/LICENSE.md)

---

<div align="center">
  <sub>Built in Gleam, on the BEAM, by the <a href="https://github.com/trustbound/dream">Dream Team</a> ❤️</sub>
</div>
