"starts_at":"2023-11-14T23:13:20+01:00"   -> Ok, starts_at is 2023-11-14T22:13:20Z
"starts_at":"2023-11-14T22:13:20"         -> Error("starts_at: expected Timestamp, found String")
"starts_at":"Timestamp(1700000000, 0)"    -> Error("starts_at: expected Timestamp, found String")
"starts_at":1700000000                    -> Error("starts_at: expected String, found Int")
no "starts_at" key                        -> Error("starts_at: expected Field, found Nothing")
{"title":                                 -> Error("the body is not valid JSON")
