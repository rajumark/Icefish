import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:icefish/core/providers/settings_provider.dart';
import 'package:icefish/core/providers/navigation_provider.dart';
import 'package:icefish/core/services/cli_service.dart';

class FakeCliService implements CliServiceInterface {
  final Map<String, CliResult> _responses = {};
  CliResult _defaultResponse = CliResult.ok('fake output');

  void setResponse(String command, CliResult response) {
    _responses[command] = response;
  }

  void setDefaultResponse(CliResult response) {
    _defaultResponse = response;
  }

  @override
  Future<CliResult> run(String command) async {
    return _responses[command] ?? _defaultResponse;
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

void setupFakeCli({Map<String, CliResult>? responses, CliResult? defaultResponse}) {
  final fake = FakeCliService();
  if (responses != null) {
    for (final entry in responses.entries) {
      fake.setResponse(entry.key, entry.value);
    }
  }
  if (defaultResponse != null) {
    fake.setDefaultResponse(defaultResponse);
  }
  CliService.current = fake;
}

void resetCliService() {
  CliService.reset();
}

Widget createTestApp({Widget? child}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ChangeNotifierProvider(create: (_) => NavigationProvider()),
    ],
    child: MaterialApp(
      home: child ?? const Scaffold(body: Center(child: Text('Test'))),
    ),
  );
}
