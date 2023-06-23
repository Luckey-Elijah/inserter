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
    this.debugLabel = '',
  });

  ///
  final String debugLabel;

  /// The expression that will be used to match a line.
  final Matcher matcher;

  /// {@macro line_builder}
  final LineBuilder builder;

  /// {@macro builder_strategy}
  final BuilderStrategy strategy;
}
