import 'package:flutter_test/flutter_test.dart';
import 'package:combine24/services/impl/default_schema_service.dart';
 

void main() {
  late DefaultSchemaService schemaService;

  setUp(() {
    schemaService = DefaultSchemaService();
  });

  group('DefaultSchemaService.buildFormulaSchema', () {
    test('test 1: 10 + 2 + 6 + 6', () {
      final result = schemaService.buildFormulaSchema('10 + 2 + 6 + 6');
      final expected = [
        ['+', '10'],
        ['+', '2'],
        ['+', '6'],
        ['+', '6']
      ];

      expect(
        DefaultSchemaService.unOrdDeepEq(result, expected),
        true,
      );
    });

    test('test 2: 1 x 2 x 3 x 4', () {
      final result = schemaService.buildFormulaSchema('1 x 2 x 3 x 4');
      final expected = [
        ['*', '1'],
        ['*', '2'],
        ['*', '3'],
        ['*', '4']
      ];

      expect(
        DefaultSchemaService.unOrdDeepEq(result, expected),
        true,
      );
    });

    test('test 3: (1 + 2 + 3) x 4', () {
      final result = schemaService.buildFormulaSchema('(1 + 2 + 3) x 4');
      final expected = [
        ['*', [
            ['+', '1'],
            ['+', '2'],
            ['+', '3']
        ]],
        ['*', '4']
      ];

      expect(
        DefaultSchemaService.unOrdDeepEq(result, expected),
        true,
      );
    });

    test('test 4: (1 + 3) x (2 + 4)', () {
      final result = schemaService.buildFormulaSchema('(1 + 3) x (2 + 4)');
      final expected = [
        ['*', [
          ['+', '1'],
          ['+', '3']
        ]],
        ['*', [
          ['+', '2'],
          ['+', '4']
        ]]
      ];

      expect(
        DefaultSchemaService.unOrdDeepEq(result, expected),
        true,
      );
    });

    test('test 5: 6 x 6 - (10 + 2)', () {
      final result = schemaService.buildFormulaSchema('6 x 6 - (10 + 2)');
      final expected = [
        ['+', [
          ['*', '6'],
          ['*', '6']
        ]],
        ['-', '10'],
        ['-', '2']
      ];

      expect(
        DefaultSchemaService.unOrdDeepEq(result, expected),
        true,
      );
    });

    test('test 6: (12 + 10 + 2) ÷ 1', () {
      final result = schemaService.buildFormulaSchema('(12 + 10 + 2) ÷ 1');
      final expected = [
        ['*', [
          ['+', '12'],
          ['+', '10'],
          ['+', '2']
        ]],
        ['*', '1']
      ];

      expect(
        DefaultSchemaService.unOrdDeepEq(result, expected),
        true,
      );
    });

    test('test 7: (12 + 12) ÷ (5 ÷ 5)', () {
      final result = schemaService.buildFormulaSchema('(12 + 12) ÷ (5 ÷ 5)');
      final expected = [
        ['*', [
          ['+', '12'],
          ['+', '12']
        ]],
        ['/', '5'],
        ['*', '5']
      ];

      expect(
        DefaultSchemaService.unOrdDeepEq(result, expected),
        true,
      );
    });

    test('test 8: 13 x (10 - 8) - 2', () {
      final result = schemaService.buildFormulaSchema('13 x (10 - 8) - 2');
      final expected = [
        ['+', [
          ['*', '13'],
          ['*', [
            ['+', '10'],
            ['-', '8']
          ]]
        ]],
        ['-', '2']
      ];

      expect(
        DefaultSchemaService.unOrdDeepEq(result, expected),
        true,
      );
    });

    test('test 9: 4 x 9 - 2 x 6', () {
      final result = schemaService.buildFormulaSchema('4 x 9 - 2 x 6');
      final expected = [
        ['+', [
          ['*', '4'],
          ['*', '9']
        ]],
        ['-', [
          ['*', '2'],
          ['*', '6']
        ]]
      ];

      expect(
        DefaultSchemaService.unOrdDeepEq(result, expected),
        true,
      );
    });
  });
}
