import 'dart:io';

import 'package:aoc_workspace/core/input_loader.dart';
import 'package:aoc_workspace/years/year2024/day12.dart';
import 'package:test/test.dart';

void main() {
  group('Year2024Day12', () {
    late Year2024Day12 solver;
    late InputLoader inputLoader;

    setUp(() {
      solver = Year2024Day12();
      inputLoader = InputLoader();
    });

    group('Part 1', () {
      test('solves example input correctly', () {
        final input = inputLoader.loadLines(
          year: 2024,
          day: 12,
          inputType: InputType.examplePart1,
        );
        final result = solver.solvePart1(input);
        expect(result, '140'); // Expected: 4*10 + 4*8 + 4*10 + 1*4 + 3*8 = 140
      });

      test('solves part1 input', () {
        List<String> input;
        try {
          input = inputLoader.loadLines(
            year: 2024,
            day: 12,
            inputType: InputType.part1,
          );
        } on FileSystemException {
          // Part 1 input may not exist yet
          return;
        }
        final result = solver.solvePart1(input);
        expect(result, isNotEmpty);
        expect(result, isNot('unimplemented'));
      });
    });

    group('Part 2', () {
      test('solves example input correctly', () {
        List<String> input;
        try {
          input = inputLoader.loadLines(
            year: 2024,
            day: 12,
            inputType: InputType.examplePart2,
          );
        } on FileSystemException {
          // Part 2 example may not exist yet - use part1 example
          input = inputLoader.loadLines(
            year: 2024,
            day: 12,
            inputType: InputType.examplePart1,
          );
        }

        final result = solver.solvePart2(input);
        expect(result, '80');
      });

      test('solves E-shaped example correctly', () {
        final input = [
          'EEEEE',
          'EXXXX',
          'EEEEE',
          'EXXXX',
          'EEEEE',
        ];

        final result = solver.solvePart2(input);
        expect(result, '236');
      });

      test('solves complex example correctly', () {
        final input = [
          'AAAAAA',
          'AAABBA',
          'AAABBA',
          'ABBAAA',
          'ABBAAA',
          'AAAAAA',
        ];

        final result = solver.solvePart2(input);
        expect(result, '368');
      });

      test('solves part2 input', () {
        List<String> input;
        try {
          input = inputLoader.loadLines(
            year: 2024,
            day: 12,
            inputType: InputType.part2,
          );
        } on FileSystemException {
          // Input file may not exist yet
          return;
        }
        final result = solver.solvePart2(input);
        expect(result, isNotEmpty);
        expect(result, isNot('unimplemented'));
      });
    });
  });
}
