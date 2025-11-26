import 'dart:async';

/// Contract for any Advent of Code day solution.
///
/// Each solver is responsible for handling a specific `year` and `day` pair
/// and computing stringified answers for both parts of the puzzle.
abstract class DaySolver {
  /// Four-digit year (e.g. 2024).
  int get year;

  /// One-based day index in December (1-25).
  int get day;

  /// Optional hook for eagerly preparing caches or inputs.
  FutureOr<void> warmup() async {}

  /// Computes the answer for part one using the provided input lines.
  FutureOr<String> solvePart1(List<String> input);

  /// Computes the answer for part two using the provided input lines.
  FutureOr<String> solvePart2(List<String> input);
}
