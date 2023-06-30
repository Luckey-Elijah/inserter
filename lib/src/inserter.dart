import 'dart:async';
import 'dart:io';

import 'package:inserter/inserter.dart';

/// {@template line_builder}
/// Callback for writing generating a line(s) of code with the given
/// context of the pattern and full [line] that was matched.
/// {@endtemplate}
typedef LineBuilder = FutureOr<String> Function(File file, String line);

/// {@template builder_strategy}
/// Strategy used by a [MatcherBuilder] to determine where the results of
/// a [LineBuilder] should go.
/// {@endtemplate}
enum BuilderStrategy {
  /// Insert a line **below** the matching line.
  /// {@macro builder_strategy}
  below,

  /// Insert a line **above** the matching line.
  /// {@macro builder_strategy}
  above,

  /// Replace the matching line.
  /// {@macro builder_strategy}
  replace;

  T _map<T>({
    required T Function(BuilderStrategy) onBelow,
    required T Function(BuilderStrategy) onAbove,
    required T Function(BuilderStrategy) onReplace,
  }) {
    switch (this) {
      case BuilderStrategy.below:
        return onBelow(this);
      case BuilderStrategy.above:
        return onAbove(this);
      case BuilderStrategy.replace:
        return onReplace(this);
    }
  }

  @override
  String toString() => name.split('.').last;
}

/// {@template read_line_converter}
/// How the given file's contents are read.
/// {@endtemplate}
typedef LineConverter = Stream<String> Function(File file);

/// {@template inserter_base}
/// Core inserter interface for implementing specialized line readers.
/// {@endtemplate}
abstract class InserterBase {
  /// {@macro inserter_base}
  InserterBase({
    required this.readLines,
    required this.files,
    required this.builders,
    StringBuffer? buffer,
  }) : buffer = buffer ?? StringBuffer();

  /// [File]s that need to be registered for insertion for a giver [Inserter].
  final List<File> files;

  /// When a match is made, the appropriate [LineBuilder] is executed.
  final List<MatcherBuilder> builders;

  /// Buffer used for write files contents.
  final StringBuffer buffer;

  /// {@macro read_line_converter}
  final LineConverter readLines;

  _MatcherBuilderState? _mappedBuildersSource;
  _MatcherBuilderState get _mappedBuilders => _mappedBuildersSource ??= {
        for (final builder in builders)
          builder: (shouldContinue: true, matches: 0)
      };

  /// {@template inserter.execute}
  /// Run all the [builders] on the given [files].
  /// {@endtemplate}
  Future<void> execute() async {
    _mappedBuildersSource = null; // reset state
    // exit earlier -> no-op
    if (builders.isEmpty || files.isEmpty) return;
    for (final file in files) {
      final lines = readLines(file);

      await for (final line in lines) {
        await _handleLine(line, file);
      }

      await file.writeAsString('$buffer', mode: FileMode.writeOnly);
      buffer.clear(); // done with file, clear the buffer
    }
  }

  Future<void> _handleLine(String line, File file) async {
    var writeLineAtEnd = true;
    for (final matcherBuilder in _mappedBuilders.entries
        .where((entry) => entry.value.shouldContinue)
        .map((e) => e.key)) {
      final state = _mappedBuilders[matcherBuilder]!;
      final hasMatch = matcherBuilder.matcher(file, line);
      if (!hasMatch) continue; // go to next builder
      final builtLine = await matcherBuilder.builder(file, line);

      matcherBuilder.strategy._map<void>(
        onBelow: (_) => buffer
          ..writeln(line)
          ..writeln(builtLine),
        onAbove: (_) => buffer
          ..writeln(builtLine)
          ..writeln(line),
        onReplace: (_) {
          buffer.writeln(builtLine);
        },
      );

      // a handler has done what it's needed with source line
      writeLineAtEnd = false;

      final totalMatches = state.matches + (hasMatch ? 0 : 1);

      _mappedBuilders[matcherBuilder] = (
        matches: totalMatches,
        shouldContinue:
            matcherBuilder.stopWhen?.call(file, line, totalMatches) ?? true,
      );
    }

    if (writeLineAtEnd) buffer.writeln(line);
  }
}

/// {@template inserter}
/// Tooling for inserting `String` into `File`s given
/// their respective strategies.
/// {@endtemplate}
class Inserter extends InserterBase {
  /// {@macro inserter}
  Inserter({
    required super.builders,
    required super.files,
    super.buffer,
  }) : super(readLines: readLines);

  /// Convenience method for running an [Inserter.execute]
  /// {@macro inserter.execute}
  static Future<void> run({
    required List<File> files,
    required List<MatcherBuilder> builders,
    StringBuffer? buffer,
  }) {
    final inserter = Inserter(
      files: files,
      builders: builders,
      buffer: buffer,
    );

    return inserter.execute();
  }
}

typedef _MatcherBuilderState = Map<
    MatcherBuilder,
    ({
      bool shouldContinue,
      int matches,
    })>;
