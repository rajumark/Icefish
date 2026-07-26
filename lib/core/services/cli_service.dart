import 'dart:io';

class CliResult {
  final bool success;
  final String output;
  final String error;

  CliResult({required this.success, required this.output, this.error = ''});

  factory CliResult.ok(String output) => CliResult(success: true, output: output);
  factory CliResult.fail(String error) => CliResult(success: false, output: '', error: error);
}

abstract class CliServiceInterface {
  Future<CliResult> run(String command);
  List<String> parseArgs(String command);
}

class CliServiceImpl implements CliServiceInterface {
  CliServiceImpl._();

  static final CliServiceImpl _instance = CliServiceImpl._();
  factory CliServiceImpl() => _instance;

  @override
  Future<CliResult> run(String command) async {
    try {
      final args = parseArgs(command);
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

  @override
  List<String> parseArgs(String command) {
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

class CliService {
  static CliServiceInterface _current = CliServiceImpl();

  static CliServiceInterface get current => _current;
  static set current(CliServiceInterface value) { _current = value; }

  static Future<CliResult> run(String command) => _current.run(command);
  static List<String> parseArgs(String command) => _current.parseArgs(command);
  static void reset() { _current = CliServiceImpl(); }
}
