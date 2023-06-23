import 'dart:convert';
import 'dart:io';

import 'package:inserter/src/inserter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockFile extends Mock implements File {}

class MockStringBuffer extends Mock implements StringBuffer {}

Stream<List<int>> encodeStringToUtf8(String source) =>
    Stream.value(utf8.encode(source));

void main() {
  group('Inserter.execute/run', () {
    late StringBuffer buffer;
    late File file;
    const source = '''
Contents
of
my
file''';

    setUpAll(() {
      buffer = MockStringBuffer();
      file = MockFile();
    });

    tearDown(() => reset(buffer));

    test('writes nothing when [files] is empty', () async {
      await Inserter.run(
        files: [],
        builders: [],
        buffer: buffer,
      );

      verifyNever(() => buffer.write(any()));
      verifyNever(() => buffer.writeln(any()));
      verifyNever(() => buffer.writeAll(any()));
      verifyNever(() => buffer.writeCharCode(any()));
    });

    test('writes nothing when [builders] is empty', () async {
      when(file.openRead)
          .thenAnswer((invocation) => encodeStringToUtf8(source));

      await Inserter.run(
        files: [file],
        builders: [],
        buffer: buffer,
      );

      verifyNever(() => buffer.write(any()));
      verifyNever(() => buffer.writeln(any()));
      verifyNever(() => buffer.writeAll(any()));
      verifyNever(() => buffer.writeCharCode(any()));
    });
  });
}
