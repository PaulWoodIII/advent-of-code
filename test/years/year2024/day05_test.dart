import 'dart:io';

import 'package:aoc_workspace/core/input_loader.dart';
import 'package:aoc_workspace/years/year2024/day05.dart';
import 'package:test/test.dart';

void main() {
  group('Year2024Day05', () {
    late Year2024Day05 solver;
    late InputLoader inputLoader;

    setUp(() {
      solver = Year2024Day05();
      inputLoader = InputLoader();
    });

    group('Part 1', () {
      test('solves example input correctly', () {
        final input = inputLoader.loadLines(
          year: 2024,
          day: 5,
          inputType: InputType.examplePart1,
        );
        final result = solver.solvePart1(input);
        expect(result, '143'); // Sum of middle page numbers: 61 + 53 + 29
      });

      test('solves part1 input', () {
        List<String> input;
        try {
          input = inputLoader.loadLines(
            year: 2024,
            day: 5,
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
            day: 5,
            inputType: InputType.examplePart2,
          );
        } on FileSystemException {
          // Part 2 example may not exist yet - use part1 example
          input = inputLoader.loadLines(
            year: 2024,
            day: 5,
            inputType: InputType.examplePart1,
          );
        }
        final result = solver.solvePart2(input);
        expect(result, '123'); // Sum of middle page numbers: 47 + 29 + 47
      });

      test('solves part2 input', () {
        List<String> input;
        try {
          input = inputLoader.loadLines(
            year: 2024,
            day: 5,
            inputType: InputType.part2,
          );
        } on FileSystemException {
          // Part 2 typically uses the same input as part 1 - fall back to part1
          try {
            input = inputLoader.loadLines(
              year: 2024,
              day: 5,
              inputType: InputType.part1,
            );
          } on FileSystemException {
            // Part 1 input may not exist yet
            return;
          }
        }
        final result = solver.solvePart2(input);
        expect(result, isNotEmpty);
        expect(result, isNot('unimplemented'));
      });
    });
  });
}

