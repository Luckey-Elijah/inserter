# Inserter

Additional tooling for mason_cli (and other file insert/writing) to write to existing files.

## Installation 💻

**❗ In order to start using Inserter you must have the [Dart SDK][dart_install_link] installed on your machine.**

Add `inserter` to your `pubspec.yaml`:

```yaml
dependencies:
  inserter:
```

Install it:

```sh
dart pub get
```

---

## Running Tests 🧪

To run all unit tests:

```sh
dart pub global activate coverage 1.2.0
dart test --coverage=coverage
dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info
```

To view the generated coverage report you can use [lcov](https://github.com/linux-test-project/lcov).

```sh
# Generate Coverage Report
genhtml coverage/lcov.info -o coverage/

# Open Coverage Report
open coverage/index.html
```
