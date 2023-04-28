import 'dart:convert';
import 'dart:io';

import 'package:inserter/inserter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockFile extends Mock implements File {}

void main() {
  group('ReadFileLines', () {
    test('readLines() yields Stream of the lines of the file', () {
      final file = MockFile();

      when(file.openRead).thenAnswer((invocation) {
        return Stream.value(
          utf8.encode('''
one
two
three'''),
        );
      });

      expect(readLines(file), emitsInOrder(['one', 'two', 'three']));
    });
  });
}
