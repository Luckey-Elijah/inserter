import 'dart:async';
import 'dart:io';

import 'package:inserter/inserter.dart';

/// {@template line_builder}
/// Callback for writing generating a line(s) of code with the given
/// context of the pattern and full [line] that was matched.
/// {@endtemplate}
typedef LineBuilder = FutureOr<String> Function(File file, String line);

/// {@template matcher}
/// Callback used when evaluating whether a line is matched
/// {@endtemplate}
/// {@macro matcher}
typedef Matcher = bool Function(File file, String line);

/// {@template builder_strategy}
/// Strategy used by a [MatcherBuilder] to determin where the results of
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
}

/// {@template inserter}
/// Additional tooling for mason_cli to write to existing files.
/// {@endtemplate}
class Inserter {
  /// {@macro inserter}
  Inserter({
    required this.files,
    required this.builders,
    StringBuffer? buffer,
  }) : buffer = buffer ?? StringBuffer();

  /// Convience method for running a [Inserter.execute]
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

  /// [File]s that need to be registered for insertion for a giver [Inserter].
  final List<File> files;

  /// When a match is made, the appropiate [LineBuilder] is executed.
  final List<MatcherBuilder> builders;

  /// Buffer used for write files contents.
  final StringBuffer buffer;

  /// {@template inserter.execute}
  /// Run all the [builders] on the given [files].
  /// {@endtemplate}
  Future<void> execute() async {
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

  /// Return whether the handler will should write the line given
  Future<void> _handleLine(String line, File file) async {
    var writeLineAtEnd = true;
    for (final matcherBuilder in builders) {
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
    }

    if (writeLineAtEnd) buffer.writeln(line);
  }
}
