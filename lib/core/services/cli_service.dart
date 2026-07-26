import 'dart:io';

class CliResult {
  final bool success;
  final String output;
  final String error;

  CliResult({required this.success, required this.output, this.error = ''});

  factory CliResult.ok(String output) => CliResult(success: true, output: output);
  factory CliResult.fail(String error) => CliResult(success: false, output: '', error: error);
}

class CliService {
  static Future<CliResult> run(String command) async {
    try {
      final args = _parseArgs(command);
      final result = await Process.run('android', args).timeout(
        const Duration(minutes: 5),
        onTimeout: () => ProcessResult(-1, -1, '', 'Command timed out'),
      );

      final output = result.stdout.toString().trim();
      final error = result.stderr.toString().trim();

      if (result.exitCode == 0) {
        return CliResult.ok(output);
      } else {
        return CliResult.fail(error.isNotEmpty ? error : output);
      }
    } catch (e) {
      return CliResult.fail('Error: $e');
    }
  }

  static List<String> _parseArgs(String command) {
    final args = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;
    var quoteChar = '';

    for (var i = 0; i < command.length; i++) {
      final c = command[i];

      if (inQuotes) {
        if (c == quoteChar) {
          inQuotes = false;
        } else {
          buffer.write(c);
        }
      } else if (c == '"' || c == "'") {
        inQuotes = true;
        quoteChar = c;
      } else if (c == ' ') {
        if (buffer.isNotEmpty) {
          args.add(buffer.toString());
          buffer.clear();
        }
      } else {
        buffer.write(c);
      }
    }

    if (buffer.isNotEmpty) {
      args.add(buffer.toString());
    }

    return args;
  }
}
