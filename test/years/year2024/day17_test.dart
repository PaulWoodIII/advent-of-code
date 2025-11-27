import 'dart:io';

import 'package:aoc_workspace/core/input_loader.dart';
import 'package:aoc_workspace/years/year2024/day17.dart';
import 'package:test/test.dart';

void main() {
  group('Year2024Day17', () {
    late Year2024Day17 solver;
    late InputLoader inputLoader;

    setUp(() {
      solver = Year2024Day17();
      inputLoader = InputLoader();
    });

    group('Part 1', () {
      test('solves example input correctly', () {
        final input = inputLoader.loadLines(
          year: 2024,
          day: 17,
          inputType: InputType.examplePart1,
        );
        final result = solver.solvePart1(input);
        expect(result, '4,6,3,5,6,3,5,2,1,0');
      });

      test('solves part1 input', () {
        List<String> input;
        try {
          input = inputLoader.loadLines(
            year: 2024,
            day: 17,
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
            day: 17,
            inputType: InputType.examplePart2,
          );
        } on FileSystemException {
          // Part 2 example may not exist yet - use part1 example
          input = inputLoader.loadLines(
            year: 2024,
            day: 17,
            inputType: InputType.examplePart1,
          );
        }
        final result = solver.solvePart2(input);
        expect(result, '117440'); // Example: A=117440 produces program output
      },
          timeout: const Timeout(
              Duration(seconds: 30))); // Allow up to 30 seconds for example

      test('solves part2 input', () {
        // Part 2 uses the same input file as Part 1
        final input = inputLoader.loadLines(
          year: 2024,
          day: 17,
          inputType: InputType.part1,
        );
        final result = solver.solvePart2(input);
        expect(result, isNotEmpty);
        expect(result, isNot('unimplemented'));
        expect(result, isNot('not found'));
      },
          timeout: const Timeout(Duration(
              minutes: 1))); // Allow up to 10 minutes for real input search
    });
  });
}
