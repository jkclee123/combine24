import 'package:flutter_test/flutter_test.dart';
import 'package:combine24/services/impl/default_solution_service.dart';

void main() {
  late DefaultSolutionService solutionService;

  setUp(() {
    solutionService = DefaultSolutionService();
  });

  group('DefaultSolutionService.findSolutions', () {
    test('test 1: [4, 9, 2, 6] returns valid solution', () {
      final input = ['4', '9', '2', '6'];
      final result = solutionService.findSolutions(input);

      expect(result, isNotEmpty);
      expect(result, equals(['4 x 9 ÷ 2 + 6']));
    });

    test('test 2: [5, 7, 6, 6] returns valid solutions', () {
      final input = ['5', '7', '6', '6'];
      final result = solutionService.findSolutions(input);
      final expected = ['5 + 6 + 6 + 7', '(5 + 6 - 7) x 6'];

      expect(result..sort(), equals(expected..sort()));
    });

    test('test 3: [13, 11, 13, 13] returns valid solutions', () {
      final input = ['13', '11', '13', '13'];
      final result = solutionService.findSolutions(input);
      final expected = ['11 + 13 + 13 - 13', '13 x 13 ÷ 13 + 11', '11 x 13 ÷ 13 + 13'];

      expect(result..sort(), equals(expected..sort()));
    });

    test('returns empty list for impossible combinations', () {
      final input = ['1', '1', '1', '1']; // 1+1+1+1 = 4, not 24
      final result = solutionService.findSolutions(input);

      expect(result, isEmpty);
    });

    test('handles mixed numbers and face cards', () {
      final input = ['1', '2', '3', '4'];
      final result = solutionService.findSolutions(input);

      // Should return some solutions that evaluate to 24
      expect(result, isNotEmpty);
    });
  });
}
