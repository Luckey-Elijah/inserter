import 'dart:convert';
import 'dart:io';

/// {@template read_file_lines}
/// Uses a `utf8.decoder` and `LineSplitter` to read the files contents
/// line by line via a stream.
/// {@endtemplate}
Stream<String> readLines(File file) {
  return file
      .openRead()
      .transform(utf8.decoder)
      .transform(const LineSplitter());
}
