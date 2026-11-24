# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 2.x     | ✅ Active support  |
| < 2.0   | ❌ Not supported   |

## What dream_json Is Responsible For

dream_json is a library that provides:
- **Optional value encoders** - `optional_string()`, `optional_int()`, `optional_float()`, `optional_bool()`
- **Timestamp encoders** - `timestamp()` and `timestamp_to_string()`

dream_json is **not a framework**. You build the application. You decide what goes into your JSON.

This means dream_json's security surface is small:
- Encoding bugs (a value encoded as the wrong JSON type, or as invalid JSON)
- Resource exhaustion while encoding

String escaping is done by [gleam_json](https://hex.pm/packages/gleam_json).

## What You're Responsible For

Your application code handles:
- **Authentication** - You implement it
- **Authorization** - You control access
- **Data exposure** - You choose which fields go into a JSON response
- **Input validation** - You validate data before you store or encode it

## Reporting a Vulnerability

**Do not report security vulnerabilities through public GitHub issues.**

Email: **engineering@trustbound.ai**

### What to Include

- **Type of vulnerability** (e.g., invalid JSON output)
- **Location** in dream_json's code (file/function)
- **Steps to reproduce** with minimal example
- **Impact** - What can an attacker do?
- **Proof-of-concept** if you have one

Focus on vulnerabilities in **dream_json's code**, not in your application code.

### What to Expect

1. **Acknowledgment** within 48 hours
2. **Assessment** within 7 days
3. **Fix** coordinated with you on timing
4. **Release** with security advisory
5. **Credit** in the advisory (if desired)

## Security in dream_json

### Type Safety

Gleam's type system prevents many vulnerabilities:
- ✅ No null pointer exceptions
- ✅ No buffer overflows
- ✅ Exhaustive pattern matching
- ✅ Immutable data structures

## Dependencies

dream_json's dependencies:
- **gleam_json** - JSON encoding
- **gleam_time** - Timestamps
- **Gleam stdlib** - Type-safe, battle-tested
- **BEAM/OTP** - 30+ years of production use

We monitor dependencies and update promptly for security issues.

## Questions?

- **Security questions**: engineering@trustbound.ai
- **Non-security issues**: [GitHub Issues](https://github.com/TrustBound/dream_json/issues)
- **General discussion**: [GitHub Discussions](https://github.com/TrustBound/dream/discussions)

---

**Remember:** dream_json is a library. It provides tools. You write the application. You're responsible for your application's security.
