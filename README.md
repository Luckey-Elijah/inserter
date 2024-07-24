# Inserter

Tooling for inserting `String` into `File`s given their respective strategies.

## Install

```sh
dart pub add inserter
```

## Usage

```dart
Future<void> main() async {
  final replaceWithAwesome = MatcherBuilder(
    // Use this to determine which line to trigger the line builder.
    matcher: (file, line) async => line.contains('// REPLACE WITH AWESOME'),

    // The line to be written.
    builder: (file, line) async => 'bool isAwesome() => true;',

    // Where the line will go
    strategy: BuilderStrategy.replace, // also below & above
  );
  await Inserter.run(
    files: [File('update_me.dart')],
    builders: [replaceWithAwesome]
  );
}
```

**What changed in _`update_me.dart`_?**

```diff
void main() {
  print(isAwesome());
}
- // REPLACE WITH AWESOME
+ bool isAwesome() => true;
```

### Non UTF-8 encodings

Extend the `InserterBase` and provide you own `LineConverter` method:

```dart
class MyOtherInserter extends InserterBase {
  MyOtherInserter({
    required this.files,
    required this.builders,
  }) : super({
    buffer: StringBuffer(), // typically, allow injecting this for testing.
    readLines: (file) {
        /// .... not a real method
        return Stream.fromFile(file);
    }
  });
}
```
