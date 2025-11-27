import 'dart:io';

import 'package:aoc_workspace/core/input_loader.dart';
import 'package:aoc_workspace/years/year2024/day15.dart';
import 'package:test/test.dart';

void main() {
  group('Year2024Day15', () {
    late Year2024Day15 solver;
    late InputLoader inputLoader;

    setUp(() {
      solver = Year2024Day15();
      inputLoader = InputLoader();
    });

    group('Part 1', () {
      test('solves example input correctly', () {
        final input = inputLoader.loadLines(
          year: 2024,
          day: 15,
          inputType: InputType.examplePart1,
        );
        final result = solver.solvePart1(input);
        expect(result, '2028'); // Expected result from puzzle example
      });

      test('solves part1 input', () {
        List<String> input;
        try {
          input = inputLoader.loadLines(
            year: 2024,
            day: 15,
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
      test('solves larger example input correctly (expected 9021)', () {
        // The larger example from the prompt is the same as example_part1,
        // but transformed for Part 2. According to the prompt, this should produce 9021.
        // However, note: the prompt shows a DIFFERENT larger example grid than example_part1.
        // The prompt's larger example has a 10x10 grid, while example_part1 has an 8x8 grid.
        // So we need to use the actual larger example file.
        final file = File(
          '${Directory.current.path}/data/inputs/2024/day_15_example_part2_large.txt',
        );
        if (!file.existsSync()) {
          return; // Skip if file doesn't exist
        }
        final input = file.readAsLinesSync();
        final result = solver.solvePart2(input);
        expect(result, '9021'); // Expected result from puzzle description
      });

      test('larger example produces correct final warehouse state', () {
        final file = File(
          '${Directory.current.path}/data/inputs/2024/day_15_example_part2_large.txt',
        );
        if (!file.existsSync()) {
          return; // Skip if file doesn't exist
        }
        final input = file.readAsLinesSync();

        // Get the actual final grid state
        final actualGrid = solver.debugGetFinalGridPart2(input);

        // Expected final state from the prompt
        final expectedState = [
          '####################',
          '##[].......[].[][]##',
          '##[]...........[].##',
          '##[]........[][][]##',
          '##[]......[]....[]##',
          '##..##......[]....##',
          '##..[]............##',
          '##..@......[].[][]##',
          '##......[][]..[]..##',
          '####################',
        ];

        // Convert actual grid to strings for comparison
        final actualState = actualGrid.map((row) => row.join('')).toList();

        // Compare row by row and show differences
        expect(actualState.length, expectedState.length,
            reason: 'Grid height mismatch');

        for (var i = 0; i < expectedState.length; i++) {
          if (actualState.length > i) {
            expect(actualState[i], expectedState[i],
                reason: 'Row $i mismatch:\n'
                    'Expected: ${expectedState[i]}\n'
                    'Actual:   ${actualState[i]}');
          } else {
            fail('Missing row $i. Expected: ${expectedState[i]}');
          }
        }
      });

      test('solves part2 input', () {
        List<String> input;
        try {
          input = inputLoader.loadLines(
            year: 2024,
            day: 15,
            inputType: InputType.part1, // Part 2 uses same input as Part 1
          );
        } on FileSystemException {
          // Input may not exist yet
          return;
        }
        final result = solver.solvePart2(input);
        print(result);
        expect(result, isNotEmpty);
        expect(result, isNot('unimplemented'));
      });
    });
  });
}
