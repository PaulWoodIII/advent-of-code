import '../../core/solver.dart';

/// Day 6: Guard Gallivant
///
/// This puzzle teaches several important computer science concepts:
///
/// **Part 1: Grid Traversal with State Machines**
/// - Simulating an agent moving through a 2D grid with directional state
/// - State machine pattern: agent has position (row, col) and direction (0-3)
/// - Collision detection and directional turning logic
/// - Tracking visited positions using sets
///
/// **Part 2: Cycle Detection in State Machines**
/// - Detecting infinite loops by tracking complete state (position + direction)
/// - Cycle detection: if we revisit the same (row, col, direction) state, we have a loop
/// - Optimization techniques:
///   - Candidate pruning: only test positions that can affect the agent's path
///   - Grid preprocessing: avoid repeated grid copying
///   - In-place modification with restoration
///
/// **Key Patterns for Future Puzzles:**
/// - Grid traversal with directional movement (see day04.dart for grid patterns)
/// - State machine simulation with (position, direction) tuples
/// - Cycle detection using visited state sets
/// - Performance optimization through candidate reduction
class Year2024Day06 extends DaySolver {
  @override
  int get year => 2024;

  @override
  int get day => 6;

  @override
  String solvePart1(List<String> input) {
    return _solvePart1(input);
  }

  @override
  String solvePart2(List<String> input) {
    return _solvePart2(input);
  }

  /// Part 1: Simulate guard patrol path and count distinct positions visited.
  ///
  /// The guard follows a protocol:
  /// 1. If obstacle directly in front, turn right 90 degrees
  /// 2. Otherwise, take a step forward
  ///
  /// Algorithm:
  /// - Find starting position and initial direction from grid symbols (^, >, v, <)
  /// - Simulate movement until guard leaves grid bounds
  /// - Track all distinct positions visited using a Set
  /// - Return count of distinct positions
  ///
  /// Time complexity: O(rows * cols) - guard visits at most all cells once
  /// Space complexity: O(rows * cols) - for visited positions set
  String _solvePart1(List<String> input) {
    if (input.isEmpty) {
      return '0';
    }
    final grid = input.map((line) => line.split('')).toList();
    final rows = grid.length;
    final cols = grid[0].length;
    final start = _findStartPosition(grid, rows, cols);
    if (start.row == -1 || start.col == -1) {
      return '0';
    }
    final visited = <({int row, int col})>{};
    var currentRow = start.row;
    var currentCol = start.col;
    var currentDirection = start.direction;
    while (true) {
      visited.add((row: currentRow, col: currentCol));
      var nextRow = currentRow;
      var nextCol = currentCol;
      switch (currentDirection) {
        case 0:
          nextRow = currentRow - 1;
          break;
        case 1:
          nextCol = currentCol + 1;
          break;
        case 2:
          nextRow = currentRow + 1;
          break;
        case 3:
          nextCol = currentCol - 1;
          break;
      }
      if (nextRow < 0 ||
          nextRow >= rows ||
          nextCol < 0 ||
          nextCol >= cols) {
        break;
      }
      if (grid[nextRow][nextCol] == '#') {
        currentDirection = (currentDirection + 1) % 4;
      } else {
        currentRow = nextRow;
        currentCol = nextCol;
      }
    }
    return visited.length.toString();
  }

  /// Finds the starting position and direction from the grid.
  ///
  /// Searches for guard symbols: ^ (up), > (right), v (down), < (left)
  /// Returns tuple with (row, col, direction) where direction is:
  /// - 0 = up (^)
  /// - 1 = right (>)
  /// - 2 = down (v)
  /// - 3 = left (<)
  ///
  /// Returns (-1, -1, 0) if no guard found.
  ({int row, int col, int direction}) _findStartPosition(
      List<List<String>> grid, int rows, int cols) {
    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        final cell = grid[row][col];
        if (cell == '^') {
          return (row: row, col: col, direction: 0);
        }
        if (cell == '>') {
          return (row: row, col: col, direction: 1);
        }
        if (cell == 'v') {
          return (row: row, col: col, direction: 2);
        }
        if (cell == '<') {
          return (row: row, col: col, direction: 3);
        }
      }
    }
    return (row: -1, col: -1, direction: 0);
  }

  /// Gets the original path the guard takes without any new obstacles.
  ///
  /// Simulates the guard's movement from start to exit, collecting all positions visited.
  /// This is used in Part 2 to identify candidate positions for obstacle placement.
  /// Only positions on or adjacent to this path can affect the guard's route.
  ///
  /// Returns a Set of (row, col) positions visited.
  Set<({int row, int col})> _getOriginalPath(
      List<List<String>> grid, int rows, int cols, int startRow, int startCol,
      int startDirection) {
    final path = <({int row, int col})>{};
    var currentRow = startRow;
    var currentCol = startCol;
    var currentDirection = startDirection;
    while (true) {
      path.add((row: currentRow, col: currentCol));
      var nextRow = currentRow;
      var nextCol = currentCol;
      switch (currentDirection) {
        case 0:
          nextRow = currentRow - 1;
          break;
        case 1:
          nextCol = currentCol + 1;
          break;
        case 2:
          nextRow = currentRow + 1;
          break;
        case 3:
          nextCol = currentCol - 1;
          break;
      }
      if (nextRow < 0 ||
          nextRow >= rows ||
          nextCol < 0 ||
          nextCol >= cols) {
        break;
      }
      if (grid[nextRow][nextCol] == '#') {
        currentDirection = (currentDirection + 1) % 4;
      } else {
        currentRow = nextRow;
        currentCol = nextCol;
      }
    }
    return path;
  }

  /// Gets candidate positions to test: original path + adjacent cells.
  ///
  /// Optimization: Instead of testing all empty positions in the grid (potentially
  /// thousands), we only test positions that could affect the guard's path:
  /// - Positions on the original path (obstacle could block the guard)
  /// - Positions adjacent to the original path (obstacle could redirect the guard)
  ///
  /// This dramatically reduces the search space from O(rows * cols) to roughly
  /// O(path_length), typically reducing tested positions by 10-100x.
  ///
  /// Returns a Set of candidate (row, col) positions to test.
  Set<({int row, int col})> _getCandidatePositions(
      Set<({int row, int col})> originalPath, List<List<String>> grid,
      int rows, int cols, int startRow, int startCol) {
    final candidates = <({int row, int col})>{};
    for (final pos in originalPath) {
      if (pos.row == startRow && pos.col == startCol) {
        continue;
      }
      final cell = grid[pos.row][pos.col];
      if (cell != '#') {
        candidates.add(pos);
      }
      for (var dr = -1; dr <= 1; dr++) {
        for (var dc = -1; dc <= 1; dc++) {
          if (dr == 0 && dc == 0) {
            continue;
          }
          final adjRow = pos.row + dr;
          final adjCol = pos.col + dc;
          if (adjRow >= 0 &&
              adjRow < rows &&
              adjCol >= 0 &&
              adjCol < cols &&
              (adjRow != startRow || adjCol != startCol)) {
            final adjCell = grid[adjRow][adjCol];
            if (adjCell != '#' &&
                adjCell != '^' &&
                adjCell != '>' &&
                adjCell != 'v' &&
                adjCell != '<') {
              candidates.add((row: adjRow, col: adjCol));
            }
          }
        }
      }
    }
    return candidates;
  }

  /// Pre-processes the grid by replacing guard symbols with '.'.
  ///
  /// Optimization: Do this once instead of in every _causesLoop call.
  /// Guard symbols (^, >, v, <) are replaced with '.' so they're treated as empty cells
  /// during simulation, allowing the guard to move through its starting position.
  List<List<String>> _preprocessGrid(List<List<String>> grid) {
    return grid.map((row) {
      return row.map((cell) {
        if (cell == '^' || cell == '>' || cell == 'v' || cell == '<') {
          return '.';
        }
        return cell;
      }).toList();
    }).toList();
  }

  /// Checks if placing an obstacle at (obstacleRow, obstacleCol) causes a loop.
  ///
  /// A loop occurs when the guard visits the same (row, col, direction) state twice.
  /// This is cycle detection in a state machine - we track complete state, not just position.
  ///
  /// Algorithm:
  /// 1. Temporarily place obstacle at target position (modify grid in place)
  /// 2. Simulate guard movement, tracking visited states: (row, col, direction)
  /// 3. If we revisit a state, we have a loop -> return true
  /// 4. If guard exits grid, no loop -> return false
  /// 5. Restore original cell value before returning
  ///
  /// Optimization: Uses pre-processed grid and modifies in place, restoring the
  /// original cell value after testing. This avoids copying the entire grid for each test.
  ///
  /// Time complexity: O(rows * cols) worst case per test
  /// Space complexity: O(rows * cols) for visited states set
  bool _causesLoop(List<List<String>> processedGrid, int rows, int cols,
      int startRow, int startCol, int startDirection, int obstacleRow,
      int obstacleCol) {
    final originalCell = processedGrid[obstacleRow][obstacleCol];
    processedGrid[obstacleRow][obstacleCol] = '#';
    final visitedStates = <({int row, int col, int direction})>{};
    var currentRow = startRow;
    var currentCol = startCol;
    var currentDirection = startDirection;
    visitedStates.add((row: currentRow, col: currentCol, direction: currentDirection));
    final maxIterations = rows * cols * 4;
    var iterations = 0;
    while (iterations < maxIterations) {
      iterations++;
      var nextRow = currentRow;
      var nextCol = currentCol;
      switch (currentDirection) {
        case 0:
          nextRow = currentRow - 1;
          break;
        case 1:
          nextCol = currentCol + 1;
          break;
        case 2:
          nextRow = currentRow + 1;
          break;
        case 3:
          nextCol = currentCol - 1;
          break;
      }
      if (nextRow < 0 ||
          nextRow >= rows ||
          nextCol < 0 ||
          nextCol >= cols) {
        processedGrid[obstacleRow][obstacleCol] = originalCell;
        return false;
      }
      if (processedGrid[nextRow][nextCol] == '#') {
        currentDirection = (currentDirection + 1) % 4;
      } else {
        currentRow = nextRow;
        currentCol = nextCol;
      }
      final state = (row: currentRow, col: currentCol, direction: currentDirection);
      if (visitedStates.contains(state)) {
        processedGrid[obstacleRow][obstacleCol] = originalCell;
        return true;
      }
      visitedStates.add(state);
    }
    processedGrid[obstacleRow][obstacleCol] = originalCell;
    return true;
  }

  /// Part 2: Find all positions where placing a new obstruction causes a loop.
  ///
  /// The obstruction can't be placed at the guard's starting position.
  ///
  /// Algorithm:
  /// 1. Get the guard's original path (reuse Part 1 simulation logic)
  /// 2. Build candidate positions: original path + adjacent cells
  /// 3. Pre-process grid once (replace guard symbols)
  /// 4. For each candidate position:
  ///    - Test if placing obstacle causes a loop
  ///    - Count positions that cause loops
  ///
  /// Optimizations applied:
  /// - Candidate pruning: Only test ~500-1000 positions instead of ~10,000+
  /// - Grid preprocessing: Process grid once instead of copying for each test
  /// - In-place modification: Modify cells temporarily and restore
  ///
  /// Performance: Reduced from ~5.4s to ~1.9s (2.8x speedup)
  ///
  /// Time complexity: O(candidates * rows * cols) where candidates << rows * cols
  /// Space complexity: O(rows * cols) for grid and visited states
  String _solvePart2(List<String> input) {
    if (input.isEmpty) {
      return '0';
    }
    final grid = input.map((line) => line.split('')).toList();
    final rows = grid.length;
    final cols = grid[0].length;
    final start = _findStartPosition(grid, rows, cols);
    if (start.row == -1 || start.col == -1) {
      return '0';
    }
    final originalPath = _getOriginalPath(
        grid, rows, cols, start.row, start.col, start.direction);
    final candidates = _getCandidatePositions(
        originalPath, grid, rows, cols, start.row, start.col);
    final processedGrid = _preprocessGrid(grid);
    var count = 0;
    for (final pos in candidates) {
      if (_causesLoop(processedGrid, rows, cols, start.row, start.col,
          start.direction, pos.row, pos.col)) {
        count++;
      }
    }
    return count.toString();
  }
}
