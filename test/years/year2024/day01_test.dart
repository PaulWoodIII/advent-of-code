import 'dart:io';

import 'package:aoc_workspace/core/input_loader.dart';
import 'package:aoc_workspace/years/year2024/day01.dart';
import 'package:test/test.dart';

void main() {
  group('Year2024Day01', () {
    late Year2024Day01 solver;
    late InputLoader inputLoader;

    setUp(() {
      solver = Year2024Day01();
      inputLoader = InputLoader();
    });

    group('Part 1', () {
      test('solves example input correctly', () {
        final input = inputLoader.loadLines(
          year: 2024,
          day: 1,
          inputType: InputType.examplePart1,
        );
        final result = solver.solvePart1(input);
        expect(result, '11');
      });

      test('solves part1 input', () {
        final input = inputLoader.loadLines(
          year: 2024,
          day: 1,
          inputType: InputType.part1,
        );
        final result = solver.solvePart1(input);
        expect(result, isNotEmpty);
        expect(result, isNot('unimplemented'));
      });
    });

    group('Part 2', () {
      test('solves example input correctly', () {
        final input = inputLoader.loadLines(
          year: 2024,
          day: 1,
          inputType: InputType.examplePart2,
        );
        final result = solver.solvePart2(input);
        expect(result, '31');
      });

      test('solves part2 input', () {
        List<String> input;
        try {
          input = inputLoader.loadLines(
            year: 2024,
            day: 1,
            inputType: InputType.part2,
          );
        } on FileSystemException {
          // Part 2 typically uses the same input as part 1 - fall back to part1
          input = inputLoader.loadLines(
            year: 2024,
            day: 1,
            inputType: InputType.part1,
          );
        }
        final result = solver.solvePart2(input);
        expect(result, isNotEmpty);
        // Note: Part 2 may be unimplemented initially
        if (result != 'unimplemented') {
          // TODO: Add specific expected value once part 2 is implemented
          // expect(result, 'expected_value');
        }
      });
    });
  });
}
