import 'dart:io';

import 'package:args/args.dart';
import 'package:inserter/inserter.dart';
import 'package:mason_logger/mason_logger.dart';

final _logger = Logger();

void main(List<String> args) async {
  BuilderStrategy? strategy;
  String? matchLine;
  String? insertLine;
  var fileInputs = <String>[];

  final strategies = BuilderStrategy.values.map((e) => '$e');
  final parser = ArgParser()
    ..addSeparator('''
Insert lines into files given a strategy.\n
${styleBold.wrap('Usage:')}
  ${styleBold.wrap('inserter')}   Prompt for all inputs.
  ${styleBold.wrap('inserter')}   ${styleItalic.wrap('[options]')} Prompt for missing inputs.''')
    ..addSeparator('''
${styleBold.wrap('Example:')}
  \$ inserter # cli will prompt for remaining inputs
  \$ inserter -s below -f README.md -m "# Inserter" -l "TEST"\n
  The above will insert a new line into the file ${styleItalic.wrap('README.md')}.
  Inserted ${styleItalic.wrap('below')} the line "${styleItalic.wrap('# Inserter')}".
  The new line that is inserted: "TEST"''')
    ..addSeparator('${styleBold.wrap('Options:')}')
    ..addFlag(
      'help',
      abbr: 'h',
      help: 'Show this help and usage message.',
      negatable: false,
    )
    ..addOption(
      'strategy',
      abbr: 's',
      aliases: ['s'],
      help: 'Specify a builder strategy.',
      allowed: [...strategies, ...strategies.map((e) => e.substring(0, 1))],
      allowedHelp: {
        'a|above': 'Insert ${styleBold.wrap('above')} the matched line.',
        'b|below': 'Insert ${styleBold.wrap('below')} the matched line.',
        'r|replace': '${styleBold.wrap('Replace')} the matched line.',
      },
      callback: (option) => strategy = switch (option) {
        'above' || 'a' => BuilderStrategy.above,
        'below' || 'b' => BuilderStrategy.below,
        'replace' || 'r' => BuilderStrategy.replace,
        _ => strategy,
      },
    )
    ..addOption(
      'match',
      help: 'The exact line to be matched in the input files.',
      abbr: 'm',
      aliases: ['m'],
      callback: (match) => matchLine = match,
    )
    ..addOption(
      'newLine',
      abbr: 'l',
      help: 'The new line to be inserted into the ',
      aliases: ['l'],
      callback: (line) => insertLine = line,
    )
    ..addMultiOption(
      'files',
      help: 'Files to insert new lines.',
      abbr: 'f',
      aliases: ['f'],
      callback: (inputs) => fileInputs = inputs,
    );

  final result = parser.parse(args);

  if (result['help'] == true) {
    return _logger.info(
      '''

${parser.usage}''',
    );
  }

  if (fileInputs.isEmpty) {
    var input = '';
    do {
      input = _logger.prompt('File (leave black to finish):');
      if (input.isNotEmpty) fileInputs.add(input);
    } while (input.isNotEmpty);
  }

  for (final result in fileInputs) {
    final file = File(result);
    if (!file.existsSync()) {
      _logger.err('File $result does not exist');
      continue;
    }

    matchLine ??= _logger.prompt('Match line (exact match):');
    insertLine ??= _logger.prompt('Insert line:', defaultValue: matchLine);
    strategy ??= _logger.chooseOne<BuilderStrategy>(
      'Strategy:',
      choices: BuilderStrategy.values,
      display: (choice) => choice.name,
    );

    final progress = _logger.progress(
      '"$insertLine" -> '
      '$strategy "$matchLine" '
      'in "${file.path}".',
    );

    await Inserter.run(
      files: [file],
      builders: [
        MatcherBuilder(
          matcher: (_, line) => line == matchLine,
          builder: (_, __) => insertLine!,
          strategy: strategy!,
        )
      ],
    );

    progress.complete();
  }
}
