import 'dart:io';

import 'package:aoc_workspace/core/input_loader.dart';
import 'package:aoc_workspace/years/year2024/day11.dart';
import 'package:test/test.dart';

void main() {
  group('Year2024Day11', () {
    late Year2024Day11 solver;
    late InputLoader inputLoader;

    setUp(() {
      solver = Year2024Day11();
      inputLoader = InputLoader();
    });

    group('Part 1', () {
      test('solves example input correctly', () {
        final input = inputLoader.loadLines(
          year: 2024,
          day: 11,
          inputType: InputType.examplePart1,
        );
        final result = solver.solvePart1(input);
        expect(result, '55312'); // After 25 blinks: 125 17 -> 55312 stones
      });

      test('solves part1 input', () {
        List<String> input;
        try {
          input = inputLoader.loadLines(
            year: 2024,
            day: 11,
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
            day: 11,
            inputType: InputType.examplePart2,
          );
        } on FileSystemException {
          // Part 2 example may not exist yet - use part1 example
          input = inputLoader.loadLines(
            year: 2024,
            day: 11,
            inputType: InputType.examplePart1,
          );
        }
        final result = solver.solvePart2(input);
        // Part 2: Same input as Part 1 but with 75 blinks instead of 25
        expect(result, isNotEmpty);
        expect(result, isNot('unimplemented'));
      });

      test('solves part2 input', () {
        List<String> input;
        try {
          input = inputLoader.loadLines(
            year: 2024,
            day: 11,
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
