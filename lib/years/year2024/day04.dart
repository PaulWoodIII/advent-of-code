import '../../core/solver.dart';

class Year2024Day04 extends DaySolver {
  @override
  int get year => 2024;

  @override
  int get day => 4;

  @override
  String solvePart1(List<String> input) {
    return _solvePart1(input);
  }

  @override
  String solvePart2(List<String> input) {
    return _solvePart2(input);
  }

  /// Part 1: Find all occurrences of "XMAS" in the word search.
  /// The word can appear in any of 8 directions: horizontal, vertical, or diagonal.
  /// Words can overlap.
  String _solvePart1(List<String> input) {
    if (input.isEmpty) {
      return '0';
    }
    final grid = input.map((line) => line.split('')).toList();
    final rows = grid.length;
    final cols = grid[0].length;
    const target = 'XMAS';
    var count = 0;
    // Check each position in the grid
    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        // Check all 8 directions
        for (var dr = -1; dr <= 1; dr++) {
          for (var dc = -1; dc <= 1; dc++) {
            // Skip the case where both dr and dc are 0 (no movement)
            if (dr == 0 && dc == 0) {
              continue;
            }
            // Check if we can form XMAS in this direction
            if (_canFormWord(grid, row, col, dr, dc, target, rows, cols)) {
              count++;
            }
          }
        }
      }
    }
    return count.toString();
  }

  /// Checks if the word can be formed starting at (row, col) going in direction (dr, dc).
  bool _canFormWord(
    List<List<String>> grid,
    int startRow,
    int startCol,
    int dr,
    int dc,
    String word,
    int rows,
    int cols,
  ) {
    // Check if we have enough space in this direction
    final endRow = startRow + (word.length - 1) * dr;
    final endCol = startCol + (word.length - 1) * dc;
    if (endRow < 0 ||
        endRow >= rows ||
        endCol < 0 ||
        endCol >= cols) {
      return false;
    }
    // Check each character in the word
    for (var i = 0; i < word.length; i++) {
      final r = startRow + i * dr;
      final c = startCol + i * dc;
      if (grid[r][c] != word[i]) {
        return false;
      }
    }
    return true;
  }

  /// Part 2: Find all occurrences of X-MAS patterns.
  /// An X-MAS is two MAS words arranged in an X shape with 'A' in the center.
  /// Each MAS can be written forwards or backwards.
  /// Pattern:
  ///   M.S
  ///   .A.
  ///   M.S
  String _solvePart2(List<String> input) {
    if (input.isEmpty) {
      return '0';
    }
    final grid = input.map((line) => line.split('')).toList();
    final rows = grid.length;
    final cols = grid[0].length;
    var count = 0;
    // Check each position that could be the center 'A' of an X-MAS
    // The center must be at least 1 row/col from the edges
    for (var row = 1; row < rows - 1; row++) {
      for (var col = 1; col < cols - 1; col++) {
        // The center must be 'A'
        if (grid[row][col] != 'A') {
          continue;
        }
        // Get the four corners
        final topLeft = grid[row - 1][col - 1];
        final topRight = grid[row - 1][col + 1];
        final bottomLeft = grid[row + 1][col - 1];
        final bottomRight = grid[row + 1][col + 1];
        // Check if the two diagonals form MAS or SAM
        // Diagonal 1: top-left to bottom-right
        final diagonal1 = topLeft + grid[row][col] + bottomRight;
        final isDiagonal1Valid = diagonal1 == 'MAS' || diagonal1 == 'SAM';
        // Diagonal 2: top-right to bottom-left
        final diagonal2 = topRight + grid[row][col] + bottomLeft;
        final isDiagonal2Valid = diagonal2 == 'MAS' || diagonal2 == 'SAM';
        // Both diagonals must be valid
        if (isDiagonal1Valid && isDiagonal2Valid) {
          count++;
        }
      }
    }
    return count.toString();
  }
}

