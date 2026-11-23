//// Reads the output files in `test/outputs/`. The docs show each file in an
//// output block, and a test compares the file with the real output.

import dream_test/file
import gleam/result

/// Reads the output file `test/outputs/<name>.txt`. A file that cannot be
/// read gives an empty string, so the test that compares it fails.
pub fn read(name: String) -> String {
  file.read("test/outputs/" <> name <> ".txt")
  |> result.unwrap("")
}
