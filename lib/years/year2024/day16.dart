import '../../core/solver.dart';

/// Day 16: Reindeer Maze
///
/// This puzzle teaches Dijkstra's algorithm with state space search:
///
/// **Part 1: Shortest Path with Directional State**
/// - Finding the lowest cost path through a maze
/// - State includes position (row, col) AND direction (North, East, South, West)
/// - Moving forward costs 1 point
/// - Rotating 90 degrees (clockwise or counterclockwise) costs 1000 points
/// - Cannot move into walls (#)
/// - Start at S facing East, end at E (any direction)
/// - Uses Dijkstra's algorithm to find shortest path
///
/// **Part 2: Finding All Tiles on Optimal Paths**
/// - Count tiles that are part of at least one optimal path
/// - Uses bidirectional Dijkstra:
///   1. Run Dijkstra from start to get distances to all states
///   2. Run Dijkstra backwards from end to get distances from all states to end
///   3. A tile is on an optimal path if there exists a direction d where:
///      dist_from_start[tile, d] + dist_from_end[tile, d] == optimal_cost
/// - Key insight: Moving backwards means going in the opposite direction
///
/// **Key Algorithm: Dijkstra's with State Space**
/// - State = (row, col, direction) where direction is 0-3 (N, E, S, W)
/// - Priority queue processes states by cost (lowest first)
/// - Three actions from each state:
///   1. Move forward (cost 1) - if not blocked by wall
///   2. Rotate clockwise (cost 1000)
///   3. Rotate counterclockwise (cost 1000)
/// - Track visited states to avoid revisiting
/// - Bidirectional search: forward from start, backward from end
///
/// **Key Patterns for Future Puzzles:**
/// - Dijkstra's algorithm for weighted shortest path
/// - State space search with multiple dimensions (position + direction)
/// - Bidirectional Dijkstra to find all nodes on optimal paths
/// - Priority queue for processing states by cost
/// - Grid pathfinding with movement constraints
class Year2024Day16 extends DaySolver {
  @override
  int get year => 2024;

  @override
  int get day => 16;

  @override
  String solvePart1(List<String> input) {
    return _solvePart1(input);
  }

  @override
  String solvePart2(List<String> input) {
    return _solvePart2(input);
  }

  /// Finds the start position (S) in the grid.
  ({int row, int col}) _findStart(List<List<String>> grid) {
    for (var row = 0; row < grid.length; row++) {
      for (var col = 0; col < grid[row].length; col++) {
        if (grid[row][col] == 'S') {
          return (row: row, col: col);
        }
      }
    }
    return (row: -1, col: -1);
  }

  /// Finds the end position (E) in the grid.
  ({int row, int col}) _findEnd(List<List<String>> grid) {
    for (var row = 0; row < grid.length; row++) {
      for (var col = 0; col < grid[row].length; col++) {
        if (grid[row][col] == 'E') {
          return (row: row, col: col);
        }
      }
    }
    return (row: -1, col: -1);
  }

  /// Checks if a position is within grid bounds and not a wall.
  bool _isValidMove(List<List<String>> grid, int row, int col) {
    if (row < 0 || row >= grid.length || col < 0 || col >= grid[row].length) {
      return false;
    }
    return grid[row][col] != '#';
  }

  /// Gets the next position when moving forward in the given direction.
  ///
  /// Directions: 0=North, 1=East, 2=South, 3=West
  ({int row, int col}) _moveForward(int row, int col, int direction) {
    switch (direction) {
      case 0: // North
        return (row: row - 1, col: col);
      case 1: // East
        return (row: row, col: col + 1);
      case 2: // South
        return (row: row + 1, col: col);
      case 3: // West
        return (row: row, col: col - 1);
      default:
        return (row: row, col: col);
    }
  }

  /// Part 1: Find the lowest score to reach the end tile.
  ///
  /// Uses Dijkstra's algorithm with state space (row, col, direction).
  /// Start at S facing East (direction 1), end at E (any direction).
  ///
  /// Algorithm:
  /// 1. Parse grid and find start/end positions
  /// 2. Initialize distances: all states have infinite cost except start
  /// 3. Use priority queue to process states by cost (lowest first)
  /// 4. For each state, consider three actions:
  ///    - Move forward (cost 1) if not blocked
  ///    - Rotate clockwise (cost 1000)
  ///    - Rotate counterclockwise (cost 1000)
  /// 5. Update distances and add new states to queue
  /// 6. Return cost when reaching end position
  ///
  /// Time complexity: O(V log V) where V = rows * cols * 4 (directions)
  /// Space complexity: O(V) for distances and visited tracking
  String _solvePart1(List<String> input) {
    if (input.isEmpty) {
      return '0';
    }
    final grid = input.map((line) => line.split('')).toList();
    final start = _findStart(grid);
    final end = _findEnd(grid);
    if (start.row == -1 || end.row == -1) {
      return '0';
    }
    // Directions: 0=North, 1=East, 2=South, 3=West
    // Start facing East (direction 1)
    const startDirection = 1;
    // Distance map: state (row, col, direction) -> cost
    final distances = <({int row, int col, int direction}), int>{};
    // Priority queue: (cost, row, col, direction)
    final queue = <({int cost, int row, int col, int direction})>[];
    // Visited states to avoid reprocessing
    final visited = <({int row, int col, int direction})>{};
    // Initialize start state
    final startState = (row: start.row, col: start.col, direction: startDirection);
    distances[startState] = 0;
    queue.add((cost: 0, row: start.row, col: start.col, direction: startDirection));
    while (queue.isNotEmpty) {
      // Sort queue by cost (lowest first) and process first element
      queue.sort((a, b) => a.cost.compareTo(b.cost));
      final current = queue.removeAt(0);
      final state = (row: current.row, col: current.col, direction: current.direction);
      // Skip if already visited
      if (visited.contains(state)) {
        continue;
      }
      visited.add(state);
      // Check if we reached the end (any direction is fine)
      if (current.row == end.row && current.col == end.col) {
        return current.cost.toString();
      }
      // Consider three actions:
      // 1. Move forward (cost 1)
      final nextPos = _moveForward(current.row, current.col, current.direction);
      if (_isValidMove(grid, nextPos.row, nextPos.col)) {
        final nextState = (row: nextPos.row, col: nextPos.col, direction: current.direction);
        final newCost = current.cost + 1;
        if (!distances.containsKey(nextState) || newCost < distances[nextState]!) {
          distances[nextState] = newCost;
          queue.add((cost: newCost, row: nextPos.row, col: nextPos.col, direction: current.direction));
        }
      }
      // 2. Rotate clockwise (cost 1000)
      final clockwiseDirection = (current.direction + 1) % 4;
      final clockwiseState = (row: current.row, col: current.col, direction: clockwiseDirection);
      final clockwiseCost = current.cost + 1000;
      if (!distances.containsKey(clockwiseState) || clockwiseCost < distances[clockwiseState]!) {
        distances[clockwiseState] = clockwiseCost;
        queue.add((cost: clockwiseCost, row: current.row, col: current.col, direction: clockwiseDirection));
      }
      // 3. Rotate counterclockwise (cost 1000)
      final counterclockwiseDirection = (current.direction + 3) % 4;
      final counterclockwiseState = (row: current.row, col: current.col, direction: counterclockwiseDirection);
      final counterclockwiseCost = current.cost + 1000;
      if (!distances.containsKey(counterclockwiseState) || counterclockwiseCost < distances[counterclockwiseState]!) {
        distances[counterclockwiseState] = counterclockwiseCost;
        queue.add((cost: counterclockwiseCost, row: current.row, col: current.col, direction: counterclockwiseDirection));
      }
    }
    // No path found
    return '0';
  }

  /// Runs Dijkstra from start to find distances to all reachable states.
  ///
  /// Returns a map of state (row, col, direction) -> cost from start.
  /// Also returns the optimal cost to reach the end.
  ({Map<({int row, int col, int direction}), int> distances, int optimalCost}) _dijkstraFromStart(
      List<List<String>> grid, ({int row, int col}) start, ({int row, int col}) end) {
    const startDirection = 1; // Start facing East
    final distances = <({int row, int col, int direction}), int>{};
    final queue = <({int cost, int row, int col, int direction})>[];
    final visited = <({int row, int col, int direction})>{};
    var optimalCost = -1;
    final startState = (row: start.row, col: start.col, direction: startDirection);
    distances[startState] = 0;
    queue.add((cost: 0, row: start.row, col: start.col, direction: startDirection));
    while (queue.isNotEmpty) {
      queue.sort((a, b) => a.cost.compareTo(b.cost));
      final current = queue.removeAt(0);
      final state = (row: current.row, col: current.col, direction: current.direction);
      if (visited.contains(state)) {
        continue;
      }
      visited.add(state);
      if (current.row == end.row && current.col == end.col) {
        if (optimalCost == -1 || current.cost < optimalCost) {
          optimalCost = current.cost;
        }
      }
      final nextPos = _moveForward(current.row, current.col, current.direction);
      if (_isValidMove(grid, nextPos.row, nextPos.col)) {
        final nextState = (row: nextPos.row, col: nextPos.col, direction: current.direction);
        final newCost = current.cost + 1;
        if (!distances.containsKey(nextState) || newCost < distances[nextState]!) {
          distances[nextState] = newCost;
          queue.add((cost: newCost, row: nextPos.row, col: nextPos.col, direction: current.direction));
        }
      }
      final clockwiseDirection = (current.direction + 1) % 4;
      final clockwiseState = (row: current.row, col: current.col, direction: clockwiseDirection);
      final clockwiseCost = current.cost + 1000;
      if (!distances.containsKey(clockwiseState) || clockwiseCost < distances[clockwiseState]!) {
        distances[clockwiseState] = clockwiseCost;
        queue.add((cost: clockwiseCost, row: current.row, col: current.col, direction: clockwiseDirection));
      }
      final counterclockwiseDirection = (current.direction + 3) % 4;
      final counterclockwiseState = (row: current.row, col: current.col, direction: counterclockwiseDirection);
      final counterclockwiseCost = current.cost + 1000;
      if (!distances.containsKey(counterclockwiseState) || counterclockwiseCost < distances[counterclockwiseState]!) {
        distances[counterclockwiseState] = counterclockwiseCost;
        queue.add((cost: counterclockwiseCost, row: current.row, col: current.col, direction: counterclockwiseDirection));
      }
    }
    return (distances: distances, optimalCost: optimalCost);
  }

  /// Gets the previous position when moving backwards from the given direction.
  ///
  /// If we're at (r, c) facing direction d, the position we came from is
  /// in the opposite direction.
  ({int row, int col}) _moveBackward(int row, int col, int direction) {
    switch (direction) {
      case 0: // North - came from South
        return (row: row + 1, col: col);
      case 1: // East - came from West
        return (row: row, col: col - 1);
      case 2: // South - came from North
        return (row: row - 1, col: col);
      case 3: // West - came from East
        return (row: row, col: col + 1);
      default:
        return (row: row, col: col);
    }
  }

  /// Runs Dijkstra backwards from end to find distances from all states to end.
  ///
  /// Returns a map of state (row, col, direction) -> cost to end.
  /// Starts from end position with all 4 directions (since end can be reached from any direction).
  Map<({int row, int col, int direction}), int> _dijkstraFromEnd(
      List<List<String>> grid, ({int row, int col}) end) {
    final distances = <({int row, int col, int direction}), int>{};
    final queue = <({int cost, int row, int col, int direction})>[];
    final visited = <({int row, int col, int direction})>{};
    // Start from end with all 4 directions (cost 0 for all)
    for (var dir = 0; dir < 4; dir++) {
      final endState = (row: end.row, col: end.col, direction: dir);
      distances[endState] = 0;
      queue.add((cost: 0, row: end.row, col: end.col, direction: dir));
    }
    while (queue.isNotEmpty) {
      queue.sort((a, b) => a.cost.compareTo(b.cost));
      final current = queue.removeAt(0);
      final state = (row: current.row, col: current.col, direction: current.direction);
      if (visited.contains(state)) {
        continue;
      }
      visited.add(state);
      // Move backwards (from direction d, go to position in opposite direction)
      final prevPos = _moveBackward(current.row, current.col, current.direction);
      if (_isValidMove(grid, prevPos.row, prevPos.col)) {
        // When moving backwards, we maintain the same direction
        final prevState = (row: prevPos.row, col: prevPos.col, direction: current.direction);
        final newCost = current.cost + 1;
        if (!distances.containsKey(prevState) || newCost < distances[prevState]!) {
          distances[prevState] = newCost;
          queue.add((cost: newCost, row: prevPos.row, col: prevPos.col, direction: current.direction));
        }
      }
      // Rotate clockwise (cost 1000)
      final clockwiseDirection = (current.direction + 1) % 4;
      final clockwiseState = (row: current.row, col: current.col, direction: clockwiseDirection);
      final clockwiseCost = current.cost + 1000;
      if (!distances.containsKey(clockwiseState) || clockwiseCost < distances[clockwiseState]!) {
        distances[clockwiseState] = clockwiseCost;
        queue.add((cost: clockwiseCost, row: current.row, col: current.col, direction: clockwiseDirection));
      }
      // Rotate counterclockwise (cost 1000)
      final counterclockwiseDirection = (current.direction + 3) % 4;
      final counterclockwiseState = (row: current.row, col: current.col, direction: counterclockwiseDirection);
      final counterclockwiseCost = current.cost + 1000;
      if (!distances.containsKey(counterclockwiseState) || counterclockwiseCost < distances[counterclockwiseState]!) {
        distances[counterclockwiseState] = counterclockwiseCost;
        queue.add((cost: counterclockwiseCost, row: current.row, col: current.col, direction: counterclockwiseDirection));
      }
    }
    return distances;
  }

  /// Part 2: Count tiles that are part of at least one optimal path.
  ///
  /// Uses bidirectional Dijkstra to find all tiles on optimal paths:
  /// 1. Run Dijkstra from start to get distances to all states
  /// 2. Run Dijkstra backwards from end to get distances from all states to end
  /// 3. Find optimal cost
  /// 4. For each tile, check if there exists any direction where:
  ///    dist_from_start[tile, dir] + dist_from_end[tile, dir] == optimal_cost
  /// 5. Count unique tiles
  ///
  /// Algorithm:
  /// - A tile is on an optimal path if there exists a direction d such that:
  ///   dist_from_start[tile, d] + dist_from_end[tile, d] == optimal_cost
  /// - This means we can reach the tile from start with cost c1, and reach end
  ///   from the tile with cost c2, where c1 + c2 equals the optimal cost
  ///
  /// Time complexity: O(V log V) for each Dijkstra run
  /// Space complexity: O(V) for distances maps
  String _solvePart2(List<String> input) {
    if (input.isEmpty) {
      return '0';
    }
    final grid = input.map((line) => line.split('')).toList();
    final start = _findStart(grid);
    final end = _findEnd(grid);
    if (start.row == -1 || end.row == -1) {
      return '0';
    }
    // Run Dijkstra from start
    final forwardResult = _dijkstraFromStart(grid, start, end);
    final forwardDistances = forwardResult.distances;
    final optimalCost = forwardResult.optimalCost;
    if (optimalCost == -1) {
      return '0';
    }
    // Run Dijkstra backwards from end
    final backwardDistances = _dijkstraFromEnd(grid, end);
    // Find all tiles on optimal paths
    final tilesOnOptimalPaths = <({int row, int col})>{};
    // Check each tile and direction
    for (var row = 0; row < grid.length; row++) {
      for (var col = 0; col < grid[row].length; col++) {
        if (!_isValidMove(grid, row, col)) {
          continue;
        }
        // Check if this tile is on an optimal path via any direction
        for (var dir = 0; dir < 4; dir++) {
          final state = (row: row, col: col, direction: dir);
          final forwardDist = forwardDistances[state];
          final backwardDist = backwardDistances[state];
          if (forwardDist != null && backwardDist != null) {
            if (forwardDist + backwardDist == optimalCost) {
              tilesOnOptimalPaths.add((row: row, col: col));
              break; // Found at least one direction, no need to check others
            }
          }
        }
      }
    }
    return tilesOnOptimalPaths.length.toString();
  }
}
