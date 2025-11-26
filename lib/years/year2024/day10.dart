import '../../core/solver.dart';

/// Day 10: Hoof It
///
/// This puzzle teaches pathfinding and reachability analysis:
///
/// **Part 1: Pathfinding with Height Constraints - Distinct Destinations**
/// - Finding all valid paths from trailheads (height 0) to peaks (height 9)
/// - Constraint: each step must increase height by exactly 1
/// - Only cardinal directions (up, down, left, right) - no diagonals
/// - Counting distinct reachable peaks from each trailhead
/// - Using DFS (Depth-First Search) to explore all valid paths
/// - Key insight: Multiple paths to same destination count as 1
///
/// **Part 2: Path Counting - All Distinct Paths**
/// - Same constraints as Part 1, but count all distinct paths instead of destinations
/// - A trailhead's rating = number of distinct hiking trails (paths) from that trailhead
/// - Using Dynamic Programming with memoization to count paths efficiently
/// - Key insight: Each path counts separately, even if multiple paths end at same destination
///
/// **Key Patterns for Future Puzzles:**
/// - Grid traversal with movement constraints (see day04.dart, day06.dart)
/// - DFS/BFS for pathfinding problems
/// - Reachability analysis: finding all destinations reachable via valid paths
/// - Path counting: Dynamic Programming with memoization for counting distinct paths
/// - Using Sets to track distinct destinations vs counting all paths
class Year2024Day10 extends DaySolver {
  @override
  int get year => 2024;

  @override
  int get day => 10;

  @override
  String solvePart1(List<String> input) {
    return _solvePart1(input);
  }

  @override
  String solvePart2(List<String> input) {
    return _solvePart2(input);
  }

  /// Part 1: Find sum of all trailhead scores.
  ///
  /// A trailhead is a position with height 0.
  /// A trailhead's score is the number of distinct 9-height positions
  /// reachable via hiking trails (paths that increase by exactly 1 per step).
  ///
  /// Algorithm:
  /// 1. Parse grid and convert heights to integers
  /// 2. Find all trailheads (positions with height 0)
  /// 3. For each trailhead, use DFS to find all reachable 9-height positions
  /// 4. Count distinct 9-height positions for each trailhead
  /// 5. Sum all trailhead scores
  ///
  /// Time complexity: O(rows * cols * paths_per_trailhead)
  /// Space complexity: O(rows * cols) for grid and visited tracking
  String _solvePart1(List<String> input) {
    if (input.isEmpty) {
      return '0';
    }
    final grid = input
        .map((line) => line.split('').map((c) => int.parse(c)).toList())
        .toList();
    final rows = grid.length;
    final cols = grid[0].length;
    var totalScore = 0;
    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        if (grid[row][col] == 0) {
          final reachableNines = _findReachableNines(
              grid, rows, cols, row, col);
          totalScore += reachableNines.length;
        }
      }
    }
    return totalScore.toString();
  }

  /// Finds all distinct 9-height positions reachable from a trailhead.
  ///
  /// Uses DFS to explore all valid paths from the starting position.
  /// A valid path must:
  /// - Start at height 0
  /// - End at height 9
  /// - Increase by exactly 1 at each step
  /// - Only move in cardinal directions (no diagonals)
  ///
  /// Returns a Set of (row, col) positions with height 9.
  Set<({int row, int col})> _findReachableNines(
    List<List<int>> grid,
    int rows,
    int cols,
    int startRow,
    int startCol,
  ) {
    final reachableNines = <({int row, int col})>{};
    final visited = <({int row, int col, int height})>{};
    _dfs(grid, rows, cols, startRow, startCol, 0, reachableNines, visited);
    return reachableNines;
  }

  /// Depth-First Search to explore valid hiking trails.
  ///
  /// Recursively explores all valid paths from current position.
  /// Valid next steps must:
  /// - Be within grid bounds
  /// - Have height exactly (currentHeight + 1)
  /// - Not have been visited at this height before (prevents infinite loops)
  ///
  /// When reaching height 9, adds the position to reachableNines set.
  void _dfs(
    List<List<int>> grid,
    int rows,
    int cols,
    int row,
    int col,
    int currentHeight,
    Set<({int row, int col})> reachableNines,
    Set<({int row, int col, int height})> visited,
  ) {
    final state = (row: row, col: col, height: currentHeight);
    if (visited.contains(state)) {
      return;
    }
    visited.add(state);
    if (currentHeight == 9) {
      reachableNines.add((row: row, col: col));
      return;
    }
    final nextHeight = currentHeight + 1;
    final directions = [
      (-1, 0),
      (1, 0),
      (0, -1),
      (0, 1),
    ];
    for (final (dr, dc) in directions) {
      final nextRow = row + dr;
      final nextCol = col + dc;
      if (nextRow >= 0 &&
          nextRow < rows &&
          nextCol >= 0 &&
          nextCol < cols &&
          grid[nextRow][nextCol] == nextHeight) {
        _dfs(grid, rows, cols, nextRow, nextCol, nextHeight,
            reachableNines, visited);
      }
    }
  }

  /// Part 2: Find sum of all trailhead ratings.
  ///
  /// A trailhead is a position with height 0.
  /// A trailhead's rating is the number of distinct hiking trails (paths)
  /// that begin at that trailhead and end at height 9.
  ///
  /// Unlike Part 1 which counts distinct destinations, Part 2 counts
  /// all distinct paths - multiple paths to the same destination each count.
  ///
  /// Algorithm:
  /// 1. Parse grid and convert heights to integers
  /// 2. Find all trailheads (positions with height 0)
  /// 3. For each trailhead, count all distinct paths to height 9 using DP
  /// 4. Sum all trailhead ratings
  ///
  /// Uses dynamic programming with memoization:
  /// - countPaths(row, col, height) = number of paths from (row, col) at height to height 9
  /// - Base case: if height == 9, return 1 (one path: stay here)
  /// - Recursive case: sum paths from all valid neighbors at height+1
  ///
  /// Time complexity: O(rows * cols * 10) - each cell visited at most once per height
  /// Space complexity: O(rows * cols * 10) for memoization cache
  String _solvePart2(List<String> input) {
    if (input.isEmpty) {
      return '0';
    }
    final grid = input
        .map((line) => line.split('').map((c) => int.parse(c)).toList())
        .toList();
    final rows = grid.length;
    final cols = grid[0].length;
    var totalRating = 0;
    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        if (grid[row][col] == 0) {
          final memo = <({int row, int col, int height}), int>{};
          final pathCount = _countPaths(
              grid, rows, cols, row, col, 0, memo);
          totalRating += pathCount;
        }
      }
    }
    return totalRating.toString();
  }

  /// Counts all distinct paths from current position to height 9.
  ///
  /// Uses dynamic programming with memoization to avoid recomputing paths.
  /// A path is valid if it increases by exactly 1 at each step.
  ///
  /// Returns the number of distinct paths from (row, col) at currentHeight to height 9.
  int _countPaths(
    List<List<int>> grid,
    int rows,
    int cols,
    int row,
    int col,
    int currentHeight,
    Map<({int row, int col, int height}), int> memo,
  ) {
    final state = (row: row, col: col, height: currentHeight);
    if (memo.containsKey(state)) {
      return memo[state]!;
    }
    if (currentHeight == 9) {
      memo[state] = 1;
      return 1;
    }
    final nextHeight = currentHeight + 1;
    var pathCount = 0;
    final directions = [
      (-1, 0),
      (1, 0),
      (0, -1),
      (0, 1),
    ];
    for (final (dr, dc) in directions) {
      final nextRow = row + dr;
      final nextCol = col + dc;
      if (nextRow >= 0 &&
          nextRow < rows &&
          nextCol >= 0 &&
          nextCol < cols &&
          grid[nextRow][nextCol] == nextHeight) {
        pathCount += _countPaths(
            grid, rows, cols, nextRow, nextCol, nextHeight, memo);
      }
    }
    memo[state] = pathCount;
    return pathCount;
  }
}
