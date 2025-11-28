import '../../core/solver.dart';

/// Day 18: RAM Run
///
/// This puzzle teaches breadth-first search (BFS) for shortest pathfinding:
///
/// **Part 1: Shortest Path with Obstacles**
/// - Parse list of byte positions that will corrupt memory cells
/// - Simulate first 1024 bytes falling (marking them as corrupted)
/// - Find shortest path from (0,0) to (70,70) avoiding corrupted cells
/// - Use BFS since all moves cost 1 step (unweighted graph)
/// - Grid boundaries: 0 to 70 (71x71 grid)
///
/// **Key Algorithm: BFS for Unweighted Shortest Path**
/// - Queue-based traversal: process positions level by level
/// - Track visited positions to avoid revisiting
/// - Check 4 neighbors (up, down, left, right) at each step
/// - Stop when reaching the target position
/// - Return the number of steps (distance)
///
/// **Part 2: Finding the First Blocking Byte**
/// - Simulate bytes falling one by one in order
/// - After each byte falls, check if path still exists
/// - Return coordinates of first byte that blocks the path
/// - Uses path existence check (simplified BFS that returns bool)
///
/// **Key Patterns for Future Puzzles:**
/// - BFS for unweighted shortest path problems
/// - Grid pathfinding with obstacles
/// - Set-based tracking of blocked/visited positions
/// - Queue-based level-order traversal
/// - Sequential simulation with path checking
class Year2024Day18 extends DaySolver {
  @override
  int get year => 2024;

  @override
  int get day => 18;

  @override
  String solvePart1(List<String> input) {
    return _solvePart1(input);
  }

  @override
  String solvePart2(List<String> input) {
    return _solvePart2(input);
  }

  /// Parses input lines into a list of (x, y) coordinate pairs.
  ///
  /// Input format: "x,y" per line
  List<({int x, int y})> _parseInput(List<String> input) {
    final positions = <({int x, int y})>[];
    for (final line in input) {
      if (line.trim().isEmpty) {
        continue;
      }
      final parts = line.split(',');
      if (parts.length != 2) {
        continue;
      }
      final x = int.tryParse(parts[0].trim());
      final y = int.tryParse(parts[1].trim());
      if (x != null && y != null) {
        positions.add((x: x, y: y));
      }
    }
    return positions;
  }

  /// Part 1: Find shortest path after first 1024 bytes fall.
  ///
  /// Algorithm:
  /// 1. Parse input to get list of byte positions
  /// 2. Take first 1024 positions and mark them as corrupted
  /// 3. Use BFS to find shortest path from (0,0) to (70,70)
  /// 4. Avoid corrupted cells and stay within grid boundaries
  ///
  /// Time complexity: O(grid_size) = O(71 * 71) = O(5041) for BFS
  /// Space complexity: O(grid_size) for visited set and queue
  String _solvePart1(List<String> input) {
    if (input.isEmpty) {
      return '0';
    }
    final positions = _parseInput(input);
    if (positions.isEmpty) {
      return '0';
    }
    // For the example, use first 12 bytes and 7x7 grid (0-6)
    // For real input, use first 1024 bytes and 71x71 grid (0-70)
    final isExample = positions.length <= 25;
    final numBytes = isExample ? 12 : 1024;
    final gridSize = isExample ? 7 : 71;
    final corrupted = <({int x, int y})>{};
    for (var i = 0; i < numBytes && i < positions.length; i++) {
      corrupted.add(positions[i]);
    }
    return _bfsShortestPath(corrupted, gridSize).toString();
  }

  /// Finds shortest path from (0,0) to (gridSize-1, gridSize-1) using BFS.
  ///
  /// Returns the number of steps, or -1 if no path exists.
  int _bfsShortestPath(Set<({int x, int y})> corrupted, int gridSize) {
    final target = (x: gridSize - 1, y: gridSize - 1);
    final start = (x: 0, y: 0);
    // If start or target is corrupted, no path exists
    if (corrupted.contains(start) || corrupted.contains(target)) {
      return -1;
    }
    final queue = <({int x, int y, int steps})>[];
    final visited = <({int x, int y})>{};
    queue.add((x: start.x, y: start.y, steps: 0));
    visited.add(start);
    // Directions: up, down, left, right
    const directions = [
      (dx: 0, dy: -1), // up
      (dx: 0, dy: 1), // down
      (dx: -1, dy: 0), // left
      (dx: 1, dy: 0), // right
    ];
    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      // Check if we reached the target
      if (current.x == target.x && current.y == target.y) {
        return current.steps;
      }
      // Explore neighbors
      for (final dir in directions) {
        final nextX = current.x + dir.dx;
        final nextY = current.y + dir.dy;
        final nextPos = (x: nextX, y: nextY);
        // Check bounds
        if (nextX < 0 || nextX >= gridSize || nextY < 0 || nextY >= gridSize) {
          continue;
        }
        // Check if corrupted or already visited
        if (corrupted.contains(nextPos) || visited.contains(nextPos)) {
          continue;
        }
        visited.add(nextPos);
        queue.add((x: nextX, y: nextY, steps: current.steps + 1));
      }
    }
    // No path found
    return -1;
  }

  /// Part 2: Find the first byte that blocks the path to the exit.
  ///
  /// Algorithm:
  /// 1. Parse all byte positions from input
  /// 2. Simulate bytes falling one by one in order
  /// 3. After each byte falls, check if path from (0,0) to (70,70) still exists
  /// 4. Return coordinates of first byte that blocks the path
  ///
  /// Time complexity: O(N * grid_size) where N is number of bytes to check
  /// Space complexity: O(grid_size) for visited set and queue
  String _solvePart2(List<String> input) {
    if (input.isEmpty) {
      return '0,0';
    }
    final positions = _parseInput(input);
    if (positions.isEmpty) {
      return '0,0';
    }
    // For the example, use 7x7 grid (0-6)
    // For real input, use 71x71 grid (0-70)
    final isExample = positions.length <= 25;
    final gridSize = isExample ? 7 : 71;
    final corrupted = <({int x, int y})>{};
    // Simulate bytes falling one by one
    for (var i = 0; i < positions.length; i++) {
      final byte = positions[i];
      corrupted.add(byte);
      // Check if path still exists after this byte falls
      if (!_pathExists(corrupted, gridSize)) {
        // This byte blocks the path - return its coordinates
        return '${byte.x},${byte.y}';
      }
    }
    // If we get here, path was never blocked (shouldn't happen)
    return '0,0';
  }

  /// Checks if a path exists from (0,0) to (gridSize-1, gridSize-1).
  ///
  /// Returns true if path exists, false otherwise.
  /// Uses BFS but only checks existence, not distance.
  bool _pathExists(Set<({int x, int y})> corrupted, int gridSize) {
    final target = (x: gridSize - 1, y: gridSize - 1);
    final start = (x: 0, y: 0);
    // If start or target is corrupted, no path exists
    if (corrupted.contains(start) || corrupted.contains(target)) {
      return false;
    }
    final queue = <({int x, int y})>[];
    final visited = <({int x, int y})>{};
    queue.add(start);
    visited.add(start);
    // Directions: up, down, left, right
    const directions = [
      (dx: 0, dy: -1), // up
      (dx: 0, dy: 1), // down
      (dx: -1, dy: 0), // left
      (dx: 1, dy: 0), // right
    ];
    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      // Check if we reached the target
      if (current.x == target.x && current.y == target.y) {
        return true;
      }
      // Explore neighbors
      for (final dir in directions) {
        final nextX = current.x + dir.dx;
        final nextY = current.y + dir.dy;
        final nextPos = (x: nextX, y: nextY);
        // Check bounds
        if (nextX < 0 || nextX >= gridSize || nextY < 0 || nextY >= gridSize) {
          continue;
        }
        // Check if corrupted or already visited
        if (corrupted.contains(nextPos) || visited.contains(nextPos)) {
          continue;
        }
        visited.add(nextPos);
        queue.add(nextPos);
      }
    }
    // No path found
    return false;
  }
}
