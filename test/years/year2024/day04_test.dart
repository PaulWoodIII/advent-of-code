import 'package:aoc_workspace/core/input_loader.dart';
import 'package:aoc_workspace/years/year2024/day04.dart';
import 'package:test/test.dart';

void main() {
  group('Year2024Day04', () {
    late Year2024Day04 solver;
    late InputLoader inputLoader;

    setUp(() {
      solver = Year2024Day04();
      inputLoader = InputLoader();
    });

    group('Part 1', () {
      test('solves example input correctly', () {
        final exampleInput = [
          'MMMSXXMASM',
          'MSAMXMSMSA',
          'AMXSXMAAMM',
          'MSAMASMSMX',
          'XMASAMXAMM',
          'XXAMMXXAMA',
          'SMSMSASXSS',
          'SAXAMASAAA',
          'MAMMMXMMMM',
          'MXMXAXMASX',
        ];
        final result = solver.solvePart1(exampleInput);
        // According to the problem, this should find 18 occurrences
        expect(result, '18');
      });

      test('finds horizontal XMAS (left to right)', () {
        final input = ['XMAS'];
        expect(solver.solvePart1(input), '1');
      });

      test('finds horizontal SAMX (right to left)', () {
        final input = ['SAMX'];
        expect(solver.solvePart1(input), '1');
      });

      test('finds vertical XMAS (top to bottom)', () {
        final input = [
          'X',
          'M',
          'A',
          'S',
        ];
        expect(solver.solvePart1(input), '1');
      });

      test('finds vertical SAMX (bottom to top)', () {
        final input = [
          'S',
          'A',
          'M',
          'X',
        ];
        expect(solver.solvePart1(input), '1');
      });

      test('finds diagonal XMAS (top-left to bottom-right)', () {
        final input = [
          'X...',
          '.M..',
          '..A.',
          '...S',
        ];
        expect(solver.solvePart1(input), '1');
      });

      test('finds diagonal SAMX (bottom-right to top-left)', () {
        final input = [
          '...S',
          '..A.',
          '.M..',
          'X...',
        ];
        expect(solver.solvePart1(input), '1');
      });

      test('finds diagonal XMAS (top-right to bottom-left)', () {
        final input = [
          '...X',
          '..M.',
          '.A..',
          'S...',
        ];
        expect(solver.solvePart1(input), '1');
      });

      test('finds diagonal SAMX (bottom-left to top-right)', () {
        final input = [
          'S...',
          '.A..',
          '..M.',
          '...X',
        ];
        expect(solver.solvePart1(input), '1');
      });

      test('finds overlapping occurrences', () {
        final input = [
          'XMASXMAS',
        ];
        // Should find multiple overlapping occurrences
        // XMAS starting at position 0
        // XMAS starting at position 1 (SAMX backwards)
        // XMAS starting at position 4
        expect(int.parse(solver.solvePart1(input)), greaterThan(1));
      });

      test('handles empty input', () {
        expect(solver.solvePart1([]), '0');
      });

      test('handles single character', () {
        expect(solver.solvePart1(['X']), '0');
      });

      test('solves part1 input', () {
        final input = inputLoader.loadLines(
          year: 2024,
          day: 4,
          inputType: InputType.part1,
        );
        final result = solver.solvePart1(input);
        expect(result, isNotEmpty);
        expect(result, isNot('unimplemented'));
        expect(int.parse(result), greaterThan(0));
      });
    });

    group('Part 2', () {
      test('solves example input correctly', () {
        // Based on the problem description, this example should find 9 X-MAS patterns
        // The example grid from part 2 description
        final exampleInput = [
          'MMMSXXMASM',
          'MSAMXMSMSA',
          'AMXSXMAAMM',
          'MSAMASMSMX',
          'XMASAMXAMM',
          'XXAMMXXAMA',
          'SMSMSASXSS',
          'SAXAMASAAA',
          'MAMMMXMMMM',
          'MXMXAXMASX',
        ];
        final result = solver.solvePart2(exampleInput);
        // According to the problem, this should find 9 occurrences
        expect(result, '9');
      });

      test('finds simple X-MAS pattern (both MAS)', () {
        final input = [
          'M.S',
          '.A.',
          'M.S',
        ];
        expect(solver.solvePart2(input), '1');
      });

      test('finds X-MAS pattern (both SAM)', () {
        final input = [
          'S.M',
          '.A.',
          'S.M',
        ];
        expect(solver.solvePart2(input), '1');
      });

      test('finds X-MAS pattern (MAS and SAM)', () {
        final input = [
          'M.M',
          '.A.',
          'S.S',
        ];
        // Top-left to bottom-right: M-A-S = MAS
        // Top-right to bottom-left: M-A-S = MAS (but reading backwards)
        // Actually wait, let me think:
        // Top-left is M, bottom-right is S → MAS
        // Top-right is M, bottom-left is S → reading from top-right to bottom-left: M-A-S = MAS
        // But wait, that's not right. Let me reconsider.
        // If top-right is M and bottom-left is S, reading top-right to bottom-left:
        // We go: top-right (M) → center (A) → bottom-left (S)
        // So that's M-A-S = MAS
        // But if we read it backwards (bottom-left to top-right): S-A-M = SAM
        // So the pattern M.M / .A. / S.S has:
        // Diagonal 1 (top-left to bottom-right): M-A-S = MAS ✓
        // Diagonal 2 (top-right to bottom-left): M-A-S = MAS (reading backwards: S-A-M = SAM) ✓
        expect(solver.solvePart2(input), '1');
      });

      test('finds X-MAS pattern (SAM and MAS)', () {
        final input = [
          'S.S',
          '.A.',
          'M.M',
        ];
        // Top-left to bottom-right: S-A-M = SAM
        // Top-right to bottom-left: S-A-M = SAM (reading backwards: M-A-S = MAS)
        expect(solver.solvePart2(input), '1');
      });

      test('does not find X-MAS when center is not A', () {
        final input = [
          'M.S',
          '.M.',
          'M.S',
        ];
        expect(solver.solvePart2(input), '0');
      });

      test('does not find X-MAS when diagonals are invalid', () {
        final input = [
          'M.M',
          '.A.',
          'M.M',
        ];
        // Top-left to bottom-right: M-A-M (not MAS or SAM)
        expect(solver.solvePart2(input), '0');
      });

      test('handles empty input', () {
        expect(solver.solvePart2([]), '0');
      });

      test('handles grid too small', () {
        final input = [
          'MA',
          'AS',
        ];
        // Need at least 3x3 for X-MAS pattern
        expect(solver.solvePart2(input), '0');
      });

      test('finds multiple X-MAS patterns', () {
        final input = [
          'M.S...',
          '.A....',
          'M.S...',
          '...M.S',
          '....A.',
          '...M.S',
        ];
        // Should find 2 X-MAS patterns (one at each A)
        expect(solver.solvePart2(input), '2');
      });

      test('solves part2 input', () {
        List<String> input;
        try {
          input = inputLoader.loadLines(
            year: 2024,
            day: 4,
            inputType: InputType.part2,
          );
        } catch (e) {
          // Part 2 typically uses the same input as part 1 - fall back to part1
          input = inputLoader.loadLines(
            year: 2024,
            day: 4,
            inputType: InputType.part1,
          );
        }
        final result = solver.solvePart2(input);
        expect(result, isNotEmpty);
        expect(result, isNot('unimplemented'));
        expect(int.parse(result), greaterThan(0));
      });
    });
  });
}

