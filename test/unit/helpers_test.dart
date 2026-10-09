import 'package:flutter_test/flutter_test.dart';
import 'package:lrc_finder/core/utils/helpers.dart';

void main() {
  group('Helpers Tests - Parseo de LRC y Formato de Duración', () {
    test('formatDuration debe formatear correctamente segundos en mm:ss', () {
      expect(Helpers.formatDuration(0), '--:--');
      expect(Helpers.formatDuration(null), '--:--');
      expect(Helpers.formatDuration(-5), '--:--');
      expect(Helpers.formatDuration(65), '01:05');
      expect(Helpers.formatDuration(210), '03:30');
      expect(Helpers.formatDuration(3600), '60:00');
    });

    test('parseLrc debe parsear timestamps con 2 dígitos de milisegundos', () {
      const lrc = '''
[00:12.34] First line
[01:05.80] Second line
''';
      final lines = Helpers.parseLrc(lrc);

      expect(lines.length, 2);
      expect(lines[0].text, 'First line');
      expect(lines[0].timestamp, const Duration(seconds: 12, milliseconds: 340));
      expect(lines[1].text, 'Second line');
      expect(lines[1].timestamp, const Duration(minutes: 1, seconds: 5, milliseconds: 800));
    });

    test('parseLrc debe ordenar cronológicamente líneas desordenadas', () {
      const lrc = '''
[00:30.00] Line 2
[00:10.00] Line 1
[00:50.00] Line 3
''';
      final lines = Helpers.parseLrc(lrc);

      expect(lines.length, 3);
      expect(lines[0].text, 'Line 1');
      expect(lines[1].text, 'Line 2');
      expect(lines[2].text, 'Line 3');
    });

    test('parseLrc debe retornar lista vacía con texto nulo o vacío', () {
      expect(Helpers.parseLrc(null), isEmpty);
      expect(Helpers.parseLrc(''), isEmpty);
      expect(Helpers.parseLrc('   \n  '), isEmpty);
    });
  });
}

