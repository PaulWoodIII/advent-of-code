import 'dart:io';

import 'package:aoc_workspace/core/input_loader.dart';
import 'package:aoc_workspace/years/year2024/day06.dart';
import 'package:test/test.dart';

void main() {
  group('Year2024Day06', () {
    late Year2024Day06 solver;
    late InputLoader inputLoader;

    setUp(() {
      solver = Year2024Day06();
      inputLoader = InputLoader();
    });

    group('Part 1', () {
      test('solves example input correctly', () {
        final input = inputLoader.loadLines(
          year: 2024,
          day: 6,
          inputType: InputType.examplePart1,
        );
        final result = solver.solvePart1(input);
        expect(result, '41'); // Expected result from puzzle example
      });

      test('solves part1 input', () {
        List<String> input;
        try {
          input = inputLoader.loadLines(
            year: 2024,
            day: 6,
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
            day: 6,
            inputType: InputType.examplePart2,
          );
        } on FileSystemException {
          // Part 2 example may not exist yet - use part1 example
          input = inputLoader.loadLines(
            year: 2024,
            day: 6,
            inputType: InputType.examplePart1,
          );
        }
        final result = solver.solvePart2(input);
        expect(result, '6'); // Expected result from puzzle example
      });

      test('detects loop in simple 3x3 grid with guard surrounded', () {
        // Create a simple grid where guard is in center, obstacles on 3 sides
        // Placing obstacle on the 4th side should cause a loop
        final input = [
          '.#.',
          '#^#',
          '...',
        ];
        final result = solver.solvePart2(input);
        // Guard starts at (1,1) facing up
        // With obstacles at (0,0), (1,0), (1,2)
        // Placing obstacle at (1,2) or other positions should cause loops
        expect(result, isNotEmpty);
        expect(result, isNot('0'));
      });

      test('no loop when guard can exit grid', () {
        // Simple grid where guard can exit without looping
        final input = [
          '^.',
          '..',
        ];
        final result = solver.solvePart2(input);
        // Guard can exit immediately, so no positions should cause loops
        expect(result, '0');
      });

      test('handles empty grid', () {
        final input = <String>[];
        final result = solver.solvePart2(input);
        expect(result, '0');
      });

      test('handles grid with no guard', () {
        final input = [
          '..#',
          '...',
          '#..',
        ];
        final result = solver.solvePart2(input);
        expect(result, '0');
      });

      test('solves part2 input', () {
        List<String> input;
        try {
          input = inputLoader.loadLines(
            year: 2024,
            day: 6,
            inputType: InputType.part2,
          );
        } on FileSystemException {
          // Input file may not exist yet
          return;
        }
        final result = solver.solvePart2(input);
        expect(result, isNotEmpty);
        expect(result, isNot('unimplemented'));
        expect(result, isNot('0')); // Real input should have some loop positions
      });
    });
  });
}
