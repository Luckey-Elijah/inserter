# Inserter

Tooling for inserting `String` into `File`s given their respective strategies.

## Install

```sh
dart pub install inserter
```

## Usage

```dart
Future<void> main() async {
  final insertAwesomeBelowLine = MatcherBuilder(
    // Use this to determine which line to trigger the line builder.
    matcher: (file, line) => line.contains('// INSERT BELOW'),
    
    // The line to be written.
    builder: (file, line) => 'bool void isAwesome() => true;',

    // Where the line will go
    strategy: BuilderStrategy.below,
  );
  await Inserter.run(
    files: [File('update_me.dart')],
    builders: [insertAwesomeBelowLine] 
  );
}
```

And your line will be updated!

### Non UTF-8 encodings

Extend the `InserterBase` and provide you own `LineConverter` method:

```dart
class MyOtherInserter extends InserterBase {
  MyOtherInserter({
    required this.files,
    required this.builders,
  }) : super({
    buffer: StringBuffer(), // typically, allow injecting this for testing.
    readlines: (file) {
        /// .... not a real method
        return Stream.fromFile(file);
    }
  });
}
```