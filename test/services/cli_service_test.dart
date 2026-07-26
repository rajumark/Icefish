import 'package:flutter_test/flutter_test.dart';
import 'package:icefish/core/services/cli_service.dart';

void main() {
  group('CliResult', () {
    test('should create success result', () {
      final result = CliResult.ok('output');
      expect(result.success, isTrue);
      expect(result.output, 'output');
      expect(result.error, '');
    });

    test('should create failure result', () {
      final result = CliResult.fail('error');
      expect(result.success, isFalse);
      expect(result.output, '');
      expect(result.error, 'error');
    });

    test('should have empty error by default', () {
      final result = CliResult(success: true, output: 'out');
      expect(result.error, '');
    });
  });

  group('CliServiceImpl.parseArgs', () {
    final service = CliServiceImpl();

    test('should parse simple command', () {
      final args = service.parseArgs('sdk list');
      expect(args, ['sdk', 'list']);
    });

    test('should parse command with quotes', () {
      final args = service.parseArgs('create --name="My App"');
      expect(args, ['create', '--name=My App']);
    });

    test('should parse single quotes', () {
      final args = service.parseArgs("create --name='My App'");
      expect(args, ['create', '--name=My App']);
    });

    test('should parse multiple args', () {
      final args = service.parseArgs('run --apks=test.apk --debug --device=emulator-5554');
      expect(args.length, 4);
      expect(args[0], 'run');
      expect(args[1], '--apks=test.apk');
      expect(args[2], '--debug');
      expect(args[3], '--device=emulator-5554');
    });

    test('should handle empty string', () {
      final args = service.parseArgs('');
      expect(args, isEmpty);
    });

    test('should handle extra spaces', () {
      final args = service.parseArgs('  sdk   list  ');
      expect(args, ['sdk', 'list']);
    });

    test('should handle quoted spaces inside', () {
      final args = service.parseArgs('create --name="My App" --output="./my app"');
      expect(args, ['create', '--name=My App', '--output=./my app']);
    });
  });
}
