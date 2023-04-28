import 'dart:io';

import 'package:inserter/inserter.dart';

const keyOne = 'KEY_ONE';
const keyTwo = 'KEY_TWO';
const keyThree = 'KEY_THREE';

void main() async {
  final srcFile = File('example/src');

  final builders = [
    MatcherBuilder(
      debugLabel: 'UPDATE FOR $keyOne',
      matcher: (file, line) => line.contains(keyOne),
      builder: (file, line) => 'UPDATE FOR $keyOne',
    ),
    MatcherBuilder(
      debugLabel: 'UPDATE FOR $keyTwo',
      matcher: (file, line) => line.contains(keyTwo),
      builder: (file, line) {
        const insert = 'UPDATE FOR $keyTwo';
        // a log to show when a new line is written
        stdout.writeln('writing $insert in ${file.path}');
        return insert;
      },
      strategy: BuilderStrategy.above,
    ),
    MatcherBuilder(
      debugLabel: 'UPDATE FOR $keyThree',
      matcher: (file, line) => line.contains(keyThree),
      builder: (file, line) =>
          line.split(' ').fold<String>('', (previous, word) {
        final forInsert = word == keyThree ? 'UPDATE FOR $keyThree' : word;
        return '${previous.isEmpty ? '' : '$previous '}$forInsert';
      }),
      strategy: BuilderStrategy.replace,
    ),
  ];

  // execute the inserter
  final inserter = Inserter(
    files: [await srcFile.copy('example/execute.test')],
    builders: builders,
  );

  // Run the inserter
  await inserter.execute();

  // Use "Inserter.run" for a one-off insertion.
  await Inserter.run(
    files: [await srcFile.copy('example/run.test')],
    builders: builders,
  );
}
