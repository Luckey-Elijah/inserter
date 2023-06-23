import 'package:inserter/inserter.dart';
import 'package:test/test.dart';

void main() {
  group('MatcherBuilder', () {
    test('has a default [strategy] of [BuilderStrategy.below]', () {
      final mb = MatcherBuilder(
        builder: (_, __) => '',
        matcher: (_, __) => true,
      );

      expect(mb.strategy, BuilderStrategy.below);
    });
  });
}
