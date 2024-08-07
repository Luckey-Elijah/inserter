import 'dart:io';

import 'package:inserter/inserter.dart';

const keyOne = 'KEY_ONE';
const keyTwo = 'KEY_TWO';
const keyThree = 'KEY_THREE';

void main() async {
  final srcFile = File('example/src');

  final builders = [
    MatcherBuilder(
      matcher: (file, line) async => line.contains(keyOne),
      builder: (file, line) async => 'UPDATE FOR $keyOne',
    ),
    MatcherBuilder(
      matcher: (file, line) async => line.contains(keyTwo),
      builder: (file, line) async {
        const insert = 'UPDATE FOR $keyTwo';
        // a log to show when a new line is written
        stdout.writeln('writing $insert in ${file.path}');
        return insert;
      },
      strategy: BuilderStrategy.above,
    ),
    MatcherBuilder(
      matcher: (file, line) async => line.contains(keyThree),
      builder: (file, line) async =>
          line.split(' ').fold<String>('', (previous, word) {
        final forInsert = word == keyThree ? 'UPDATE FOR $keyThree' : word;
        return '${previous.isEmpty ? '' : '$previous '}$forInsert';
      }),

      // stop after one match
      stopWhen: (_, __, totalMatches) async => totalMatches > 0,
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
