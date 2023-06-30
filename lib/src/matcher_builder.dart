import 'dart:io';

import 'package:inserter/inserter.dart';

/// {@template matcher_builder}
/// Describes the context of when a line is matched and how to build the
/// line need for the [Inserter] calling it.
/// {@endtemplate}
class MatcherBuilder {
  /// {@macro matcher_builder}
  const MatcherBuilder({
    required this.matcher,
    required this.builder,
    this.strategy = BuilderStrategy.below,
    this.stopWhen,
  });

  /// {@macro matcher}
  final Matcher matcher;

  /// {@macro line_builder}
  final LineBuilder builder;

  /// {@macro builder_strategy}
  final BuilderStrategy strategy;

  /// {@macro element}
  final StopWhen? stopWhen;
}

/// {@template matcher}
/// Callback used when evaluating whether a line is matched
/// {@endtemplate}
typedef Matcher = bool Function(
  /// The current file evaluated.
  File file,

  /// The current line evaluated.
  String line,
);

/// {@template element}
/// Evaluated after [MatcherBuilder.matcher] and [MatcherBuilder.builder]
/// are executed.
///
/// Control when the current [MatcherBuilder] should stop matching and inserting
/// lines.
/// {@endtemplate}
typedef StopWhen = bool Function(
  /// The current file evaluated.
  File file,

  /// The current line evaluated.
  String line,

  /// Count of matches made
  int totalMatches,
);
