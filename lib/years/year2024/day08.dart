import '../../core/solver.dart';

/// Solver for Advent of Code 2024 Day 8: Resonant Collinearity.
///
/// This puzzle involves finding antinodes created by pairs of antennas
/// with the same frequency.
///
/// Part 1: An antinode occurs at any point that is perfectly in line with
/// two antennas of the same frequency, where one antenna is twice as far
/// away as the other.
///
/// Part 2: An antinode occurs at any grid position exactly in line with
/// at least two antennas of the same frequency, regardless of distance.
/// This includes all positions along the line through any pair of antennas.
class Year2024Day08 extends DaySolver {
  @override
  int get year => 2024;

  @override
  int get day => 8;

  @override
  String solvePart1(List<String> input) {
    return _solvePart1(input);
  }

  @override
  String solvePart2(List<String> input) {
    return _solvePart2(input);
  }

  /// Part 1: Count unique antinode locations within the bounds of the map.
  ///
  /// An antinode occurs at any point that is perfectly in line with two antennas
  /// of the same frequency, where one antenna is twice as far away as the other.
  /// For each pair of antennas with the same frequency, there are two antinodes,
  /// one on either side of them.
  ///
  /// Algorithm:
  /// 1. Parse the grid and group antennas by frequency
  /// 2. For each pair of antennas with the same frequency:
  ///    - Calculate the two antinode positions (one on each side)
  ///    - Add them to a set if they're within bounds
  /// 3. Return the count of unique antinode positions
  ///
  /// Computer Science Concepts:
  /// - Grid/2D array processing
  /// - Geometric calculations (collinearity, distance ratios)
  /// - Set data structure for unique position tracking
  /// - Pairwise combinations
  String _solvePart1(List<String> input) {
    if (input.isEmpty) {
      return '0';
    }
    // Parse grid and find all antennas grouped by frequency
    final grid = input.map((line) => line.split('')).toList();
    final rows = grid.length;
    final cols = grid[0].length;
    final antennasByFrequency = <String, List<_Position>>{};
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final char = grid[r][c];
        if (char != '.') {
          antennasByFrequency.putIfAbsent(char, () => []).add(_Position(r, c));
        }
      }
    }
    // Find all antinodes
    final antinodes = <_Position>{};
    for (final antennas in antennasByFrequency.values) {
      // Check all pairs of antennas with the same frequency
      for (var i = 0; i < antennas.length; i++) {
        for (var j = i + 1; j < antennas.length; j++) {
          final ant1 = antennas[i];
          final ant2 = antennas[j];
          // Calculate the two antinode positions
          // Antinode 1: on the side of ant1, where ant1 is twice as far as ant2
          // This is at position: ant1 - (ant2 - ant1) = 2*ant1 - ant2
          final antinode1 = _Position(
            2 * ant1.row - ant2.row,
            2 * ant1.col - ant2.col,
          );
          // Antinode 2: on the side of ant2, where ant2 is twice as far as ant1
          // This is at position: ant2 + (ant2 - ant1) = 2*ant2 - ant1
          final antinode2 = _Position(
            2 * ant2.row - ant1.row,
            2 * ant2.col - ant1.col,
          );
          // Add antinodes if they're within bounds
          if (_isInBounds(antinode1, rows, cols)) {
            antinodes.add(antinode1);
          }
          if (_isInBounds(antinode2, rows, cols)) {
            antinodes.add(antinode2);
          }
        }
      }
    }
    return antinodes.length.toString();
  }

  /// Checks if a position is within the grid bounds.
  bool _isInBounds(_Position pos, int rows, int cols) {
    return pos.row >= 0 && pos.row < rows && pos.col >= 0 && pos.col < cols;
  }

  /// Part 2: Count unique antinode locations using updated resonant harmonics model.
  ///
  /// An antinode occurs at any grid position exactly in line with at least two
  /// antennas of the same frequency, regardless of distance. This means antinodes
  /// can occur at any position along the line through any pair of antennas with
  /// the same frequency, including positions between them, beyond them, and at
  /// the antenna positions themselves.
  ///
  /// Algorithm:
  /// 1. Parse the grid and group antennas by frequency
  /// 2. For each pair of antennas with the same frequency:
  ///    - Calculate the direction vector between them
  ///    - Normalize the direction vector using GCD to get the step vector
  ///    - Extend the line in both directions, adding all positions within bounds
  /// 3. Return the count of unique antinode positions
  ///
  /// Computer Science Concepts:
  /// - Grid/2D array processing
  /// - Geometric calculations (collinearity, line extension)
  /// - GCD (Greatest Common Divisor) for vector normalization
  /// - Set data structure for unique position tracking
  /// - Pairwise combinations
  String _solvePart2(List<String> input) {
    if (input.isEmpty) {
      return '0';
    }
    // Parse grid and find all antennas grouped by frequency
    final grid = input.map((line) => line.split('')).toList();
    final rows = grid.length;
    final cols = grid[0].length;
    final antennasByFrequency = <String, List<_Position>>{};
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final char = grid[r][c];
        if (char != '.') {
          antennasByFrequency.putIfAbsent(char, () => []).add(_Position(r, c));
        }
      }
    }
    // Find all antinodes
    final antinodes = <_Position>{};
    for (final antennas in antennasByFrequency.values) {
      // Check all pairs of antennas with the same frequency
      for (var i = 0; i < antennas.length; i++) {
        for (var j = i + 1; j < antennas.length; j++) {
          final ant1 = antennas[i];
          final ant2 = antennas[j];
          // Calculate direction vector
          final dr = ant2.row - ant1.row;
          final dc = ant2.col - ant1.col;
          // Normalize direction vector using GCD to get step vector
          final gcd = _gcd(dr.abs(), dc.abs());
          if (gcd == 0) {
            // Same position, skip
            continue;
          }
          final stepR = dr ~/ gcd;
          final stepC = dc ~/ gcd;
          // Extend the line in both directions
          // Start from ant1 and step backwards
          var r = ant1.row;
          var c = ant1.col;
          while (_isInBounds(_Position(r, c), rows, cols)) {
            antinodes.add(_Position(r, c));
            r -= stepR;
            c -= stepC;
          }
          // Start from ant1 and step forwards (including ant2 and beyond)
          r = ant1.row + stepR;
          c = ant1.col + stepC;
          while (_isInBounds(_Position(r, c), rows, cols)) {
            antinodes.add(_Position(r, c));
            r += stepR;
            c += stepC;
          }
        }
      }
    }
    return antinodes.length.toString();
  }

  /// Calculates the Greatest Common Divisor of two integers.
  ///
  /// Uses Euclidean algorithm for efficient computation.
  /// Returns GCD of [a] and [b].
  int _gcd(int a, int b) {
    if (b == 0) {
      return a;
    }
    return _gcd(b, a % b);
  }
}

/// Represents a position in the grid.
class _Position {
  final int row;
  final int col;

  _Position(this.row, this.col);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _Position && other.row == row && other.col == col;
  }

  @override
  int get hashCode => Object.hash(row, col);
}
