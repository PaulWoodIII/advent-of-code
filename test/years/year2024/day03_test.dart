import 'dart:io';

import 'package:aoc_workspace/core/input_loader.dart';
import 'package:aoc_workspace/years/year2024/day03.dart';
import 'package:test/test.dart';

void main() {
  group('Year2024Day03', () {
    late Year2024Day03 solver;
    late InputLoader inputLoader;

    setUp(() {
      solver = Year2024Day03();
      inputLoader = InputLoader();
    });

    group('Part 1', () {
      test('solves example input correctly', () {
        final input = inputLoader.loadLines(
          year: 2024,
          day: 3,
          inputType: InputType.examplePart1,
        );
        final result = solver.solvePart1(input);
        // Verify that the solution produces a valid result
        expect(result, isNotEmpty);
        expect(result, isNot('unimplemented'));
        // The example input contains many mul() instructions
        expect(int.parse(result), greaterThan(0));
      });

      test('solves part1 input', () {
        final input = inputLoader.loadLines(
          year: 2024,
          day: 3,
          inputType: InputType.part1,
        );
        final result = solver.solvePart1(input);
        expect(result, isNotEmpty);
        expect(result, isNot('unimplemented'));
      });

      test('handles various invalid patterns', () {
        final testCases = [
          ('mul(4*)', 0), // Invalid: no closing paren
          ('mul(6,9!', 0), // Invalid: exclamation mark
          ('?(12,34)', 0), // Invalid: not mul
          ('mul ( 2 , 4 )', 0), // Invalid: spaces
          ('mul[3,7]', 0), // Invalid: square brackets
          ('mul(32,64]', 0), // Invalid: wrong closing bracket
        ];
        for (final testCase in testCases) {
          final result = solver.solvePart1([testCase.$1]);
          expect(result, testCase.$2.toString(),
              reason: 'Failed for input: ${testCase.$1}');
        }
      });

      test('handles do_not_mul pattern', () {
        // According to the problem, do_not_mul(5,5) contains a valid mul(5,5)
        final result = solver.solvePart1(['do_not_mul(5,5)']);
        expect(result, '25');
      });

      test('handles valid patterns', () {
        final testCases = [
          ('mul(44,46)', 2024), // 44 * 46 = 2024
          ('mul(123,4)', 492), // 123 * 4 = 492
          ('mul(2,4)', 8), // 2 * 4 = 8
          ('mul(11,8)', 88), // 11 * 8 = 88
          ('mul(8,5)', 40), // 8 * 5 = 40
          ('mul(1,1)', 1), // 1 * 1 = 1
          ('mul(999,999)', 998001), // Max 3 digits
        ];
        for (final testCase in testCases) {
          final result = solver.solvePart1([testCase.$1]);
          expect(result, testCase.$2.toString(),
              reason: 'Failed for input: ${testCase.$1}');
        }
      });

      test('handles multiple valid patterns in one line', () {
        final input = ['mul(2,4)mul(3,5)mul(1,1)'];
        final result = solver.solvePart1(input);
        // 2*4 + 3*5 + 1*1 = 8 + 15 + 1 = 24
        expect(result, '24');
      });
    });

    group('Part 2', () {
      test('solves example input correctly', () {
        final input = inputLoader.loadLines(
          year: 2024,
          day: 3,
          inputType: InputType.examplePart2,
        );
        final result = solver.solvePart2(input);
        // Expected: mul(2,4) + mul(8,5) = 8 + 40 = 48
        // mul(5,5) and mul(11,8) are disabled by don't()
        expect(result, '48');
      });

      test('handles do() and don\'t() instructions', () {
        // Test basic enable/disable
        expect(solver.solvePart2(['mul(2,3)']), '6');
        expect(solver.solvePart2(['don\'t()mul(2,3)']), '0');
        expect(solver.solvePart2(['don\'t()mul(2,3)do()mul(4,5)']), '20');
        expect(
            solver.solvePart2(['mul(1,1)don\'t()mul(2,2)do()mul(3,3)']), '10');
      });

      test('solves part2 input', () {
        List<String> input;
        try {
          input = inputLoader.loadLines(
            year: 2024,
            day: 3,
            inputType: InputType.part2,
          );
        } on FileSystemException {
          // Input file may not exist yet
          return;
        }
        final result = solver.solvePart2(input);
        expect(result, isNotEmpty);
        expect(result, isNot('unimplemented'));
        expect(int.parse(result), greaterThan(0));
      });
    });
  });
}
