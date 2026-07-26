import 'package:flutter_test/flutter_test.dart';
import 'package:icefish/core/services/cli_service.dart';
import '../test_helpers.dart';

void main() {
  setUp(() {
    setupFakeCli(
      responses: {
        '--version': CliResult.ok('android-cli version 1.0.0'),
      },
      defaultResponse: CliResult.fail('Command not found'),
    );
  });

  tearDown(() {
    resetCliService();
  });

  group('CliService Integration', () {
    test('should return CliResult on successful command', () async {
      final result = await CliService.run('--version');
      expect(result, isA<CliResult>());
      expect(result.success, isTrue);
    });

    test('should handle invalid command gracefully', () async {
      final result = await CliService.run('invalid-command-that-does-not-exist');
      expect(result.success, isFalse);
      expect(result.error, isNotEmpty);
    });

    test('should parse arguments correctly', () async {
      final result = await CliService.run('sdk list');
      expect(result, isA<CliResult>());
      expect(result.success, isFalse);
    });
  });
}
