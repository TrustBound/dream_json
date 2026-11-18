import architecture_snippets_test
import doc_snippets_test
import dream_json/json_encoders_test
import dream_test/coverage
import dream_test/reporters/bdd
import dream_test/reporters/progress
import dream_test/runner
import readme_snippets_test

pub fn main() {
  runner.new([
    json_encoders_test.tests(),
    readme_snippets_test.tests(),
    doc_snippets_test.tests(),
    architecture_snippets_test.tests(),
  ])
  |> runner.progress_reporter(progress.new())
  |> runner.results_reporters([bdd.new() |> bdd.color()])
  |> runner.coverage(
    coverage.new()
    |> coverage.show_missing()
    |> coverage.minimum_percent(100.0)
    |> coverage.json_path("build/coverage/coverage.json"),
  )
  |> runner.exit_on_failure()
  |> runner.run()
}
