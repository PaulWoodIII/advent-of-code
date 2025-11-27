import '../../core/solver.dart';

/// Day 15: Warehouse Woes
///
/// This puzzle teaches grid simulation with pushing mechanics:
///
/// **Part 1: Robot and Box Movement Simulation**
/// - Robot (@) moves through a warehouse grid
/// - When robot tries to move into a box (O), it pushes the box
/// - Boxes can push other boxes in a chain
/// - If pushing would cause any box or robot to hit a wall (#), nothing moves
/// - After all moves, calculate GPS coordinates: 100 * row + col for each box
/// - Sum all GPS coordinates
///
/// **Part 2: Expanded Grid with Wide Boxes**
/// - Grid is expanded: each tile becomes 2 tiles wide (columns doubled, rows stay same)
///   - # → ##, O → [], . → .., @ → @.
/// - Boxes are now 2 columns wide, represented as [] (left edge [ and right edge ])
/// - When pushing boxes, must check both columns can move
/// - Boxes can push multiple boxes simultaneously when aligned
/// - GPS coordinates use the leftmost column of each box (the [)
///
/// **Key Algorithm: Chain Pushing**
/// - When robot tries to move into a box, check if that box can be pushed
/// - Recursively check if boxes in the chain can all move
/// - If any box in chain would hit a wall, the entire move fails
/// - Only move if all boxes in chain can move successfully
/// - For wide boxes: check both columns when moving vertically
///
/// **Key Patterns for Future Puzzles:**
/// - Grid simulation with state changes
/// - Recursive chain checking for push mechanics
/// - Parsing multi-part input (grid + commands)
/// - Coordinate-based calculations (GPS = 100 * row + col)
/// - Grid expansion/transformation (columns only, not rows)
/// - Handling multi-column entities in grid simulations
class Year2024Day15 extends DaySolver {
  @override
  int get year => 2024;

  @override
  int get day => 15;

  @override
  String solvePart1(List<String> input) {
    return _solvePart1(input);
  }

  @override
  String solvePart2(List<String> input) {
    return _solvePart2(input);
  }

  /// Parses the input into grid and movement commands.
  ({List<List<String>> grid, String movements}) _parseInput(
      List<String> input) {
    final grid = <List<String>>[];
    var i = 0;
    while (i < input.length && input[i].trim().isNotEmpty) {
      final line = input[i];
      final hasGridChars = line.contains('#') ||
          line.contains('.') ||
          line.contains('O') ||
          line.contains('@') ||
          line.contains('[') ||
          line.contains(']');
      if (hasGridChars) {
        grid.add(line.split(''));
      } else {
        break;
      }
      i++;
    }
    while (i < input.length && input[i].trim().isEmpty) {
      i++;
    }
    final movements = StringBuffer();
    while (i < input.length) {
      movements.write(input[i]);
      i++;
    }
    return (grid: grid, movements: movements.toString());
  }

  /// Gets direction offsets for a movement command.
  ({int dRow, int dCol}) _getDirection(String direction) {
    switch (direction) {
      case '^':
        return (dRow: -1, dCol: 0);
      case 'v':
        return (dRow: 1, dCol: 0);
      case '<':
        return (dRow: 0, dCol: -1);
      case '>':
        return (dRow: 0, dCol: 1);
      default:
        return (dRow: 0, dCol: 0);
    }
  }

  /// Finds robot starting position.
  ({int row, int col}) _findRobot(List<List<String>> grid) {
    for (var row = 0; row < grid.length; row++) {
      for (var col = 0; col < grid[row].length; col++) {
        if (grid[row][col] == '@') {
          return (row: row, col: col);
        }
      }
    }
    return (row: -1, col: -1);
  }

  /// Checks if a position is within grid bounds.
  bool _isValidPosition(List<List<String>> grid, int row, int col) {
    return row >= 0 && row < grid.length && col >= 0 && col < grid[row].length;
  }

  /// Checks if a position contains a wall.
  bool _isWall(List<List<String>> grid, int row, int col) {
    if (!_isValidPosition(grid, row, col)) {
      return false;
    }
    return grid[row][col] == '#';
  }

  /// Checks if a position contains a box.
  bool _isBox(List<List<String>> grid, int row, int col) {
    if (!_isValidPosition(grid, row, col)) {
      return false;
    }
    return grid[row][col] == 'O';
  }

  /// Checks if a box at (row, col) can be pushed in direction (dRow, dCol).
  ///
  /// Recursively checks if all boxes in the chain can be pushed.
  /// Returns true if the entire chain can move, false otherwise.
  bool _canPushBox(
    List<List<String>> grid,
    int row,
    int col,
    int dRow,
    int dCol,
  ) {
    final nextRow = row + dRow;
    final nextCol = col + dCol;
    // If next position is out of bounds, treat as wall - can't push
    if (!_isValidPosition(grid, nextRow, nextCol)) {
      return false;
    }
    // If next position is a wall, can't push
    if (_isWall(grid, nextRow, nextCol)) {
      return false;
    }
    // If next position is a box, recursively check if that box can be pushed
    if (_isBox(grid, nextRow, nextCol)) {
      return _canPushBox(grid, nextRow, nextCol, dRow, dCol);
    }
    // Next position is empty, can push
    return true;
  }

  /// Pushes a box at (row, col) in direction (dRow, dCol).
  ///
  /// Recursively pushes all boxes in the chain.
  void _pushBox(
    List<List<String>> grid,
    int row,
    int col,
    int dRow,
    int dCol,
  ) {
    final nextRow = row + dRow;
    final nextCol = col + dCol;
    // If next position is a box, push it first (recursively)
    if (_isBox(grid, nextRow, nextCol)) {
      _pushBox(grid, nextRow, nextCol, dRow, dCol);
    }
    // Move this box to next position
    grid[nextRow][nextCol] = 'O';
    grid[row][col] = '.';
  }

  /// Attempts to move the robot in the given direction.
  ///
  /// Returns true if the move was successful, false otherwise.
  bool _tryMoveRobot(
    List<List<String>> grid,
    int robotRow,
    int robotCol,
    int dRow,
    int dCol,
  ) {
    final nextRow = robotRow + dRow;
    final nextCol = robotCol + dCol;
    // Check if next position is valid
    if (!_isValidPosition(grid, nextRow, nextCol)) {
      return false;
    }
    final nextCell = grid[nextRow][nextCol];
    // If next position is a wall, can't move
    if (nextCell == '#') {
      return false;
    }
    // If next position is empty, move robot
    if (nextCell == '.') {
      grid[nextRow][nextCol] = '@';
      grid[robotRow][robotCol] = '.';
      return true;
    }
    // If next position is a box, try to push it
    if (nextCell == 'O') {
      // Check if we can push the box (and any boxes behind it)
      if (_canPushBox(grid, nextRow, nextCol, dRow, dCol)) {
        // Push the box chain
        _pushBox(grid, nextRow, nextCol, dRow, dCol);
        // Move robot
        grid[nextRow][nextCol] = '@';
        grid[robotRow][robotCol] = '.';
        return true;
      }
      // Can't push, move fails
      return false;
    }
    return false;
  }

  /// Part 1: Simulate robot movement and calculate sum of box GPS coordinates.
  String _solvePart1(List<String> input) {
    if (input.isEmpty) return '0';
    final parsed = _parseInput(input);
    final grid = parsed.grid;
    final movements = parsed.movements;

    if (grid.isEmpty) return '0';

    // Find robot position
    var robotPos = _findRobot(grid);
    if (robotPos.row == -1) return '0';

    // Process each movement command
    for (var i = 0; i < movements.length; i++) {
      final direction = movements[i];
      if (direction != '^' &&
          direction != 'v' &&
          direction != '<' &&
          direction != '>') {
        continue;
      }
      final dir = _getDirection(direction);
      if (_tryMoveRobot(grid, robotPos.row, robotPos.col, dir.dRow, dir.dCol)) {
        robotPos = (row: robotPos.row + dir.dRow, col: robotPos.col + dir.dCol);
      }
    }

    // Calculate sum of GPS coordinates for all boxes
    // GPS = 100 * row + col (0-indexed)
    var sum = 0;
    for (var row = 0; row < grid.length; row++) {
      for (var col = 0; col < grid[row].length; col++) {
        if (grid[row][col] == 'O') {
          final gps = 100 * row + col;
          sum += gps;
        }
      }
    }
    return sum.toString();
  }

  /// Transforms the grid for Part 2: doubles width of each tile.
  ///
  /// - # → ##
  /// - O → []
  /// - . → ..
  /// - @ → @.
  List<List<String>> _transformGridForPart2(List<List<String>> grid) {
    final transformed = <List<String>>[];
    for (var row = 0; row < grid.length; row++) {
      final newRow = <String>[];
      for (var col = 0; col < grid[row].length; col++) {
        final cell = grid[row][col];
        switch (cell) {
          case '#':
            newRow.addAll(['#', '#']);
            break;
          case 'O':
            newRow.addAll(['[', ']']);
            break;
          case '.':
            newRow.addAll(['.', '.']);
            break;
          case '@':
            newRow.addAll(['@', '.']);
            break;
          default:
            newRow.addAll([cell, cell]);
        }
      }
      transformed.add(newRow);
    }
    return transformed;
  }

  /// Checks if a position contains a box left edge ([).
  bool _isBoxLeftEdge(List<List<String>> grid, int row, int col) {
    if (!_isValidPosition(grid, row, col)) {
      return false;
    }
    return grid[row][col] == '[';
  }

  /// Checks if a position contains a box right edge (]).
  bool _isBoxRightEdge(List<List<String>> grid, int row, int col) {
    if (!_isValidPosition(grid, row, col)) {
      return false;
    }
    return grid[row][col] == ']';
  }

  /// Checks if a position contains any part of a box ([ or ]).
  bool _isBoxPart(List<List<String>> grid, int row, int col) {
    return _isBoxLeftEdge(grid, row, col) || _isBoxRightEdge(grid, row, col);
  }

  /// BFS-based push algorithm matching Todd Ginsberg's Kotlin implementation exactly.
  /// Based on: https://raw.githubusercontent.com/tginsberg/advent-2024-kotlin/refs/heads/main/src/main/kotlin/com/ginsberg/advent2024/Day15.kt
  ///
  /// Returns a list of (from, to) positions for boxes that need to move.
  /// Returns null if a wall blocks the push.
  List<({int fromRow, int fromCol, int toRow, int toCol})>? _findBoxesToPushBFS(
    List<List<String>> grid,
    int startRow,
    int startCol,
    int dRow,
    int dCol,
  ) {
    final safePushes = <({int fromRow, int fromCol, int toRow, int toCol})>[];
    final queue = <({int row, int col})>[];
    final seen = <String>{};

    // Start with the actual position (matching Kotlin: queue = mutableListOf(position))
    queue.add((row: startRow, col: startCol));

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0); // removeFirst() equivalent
      final key = '${current.row},${current.col}';

      // Match Kotlin: if (thisPosition !in seen) { seen += thisPosition; ... }
      if (seen.contains(key)) {
        continue;
      }
      seen.add(key);

      // For vertical movement: queue the other half of wide boxes
      // Matching Kotlin: if (direction in setOf(Point2D.NORTH, Point2D.SOUTH))
      if (dRow != 0 && dCol == 0) {
        final cell = grid[current.row][current.col];
        if (cell == ']') {
          // queue.add(thisPosition + Point2D.WEST)
          final leftCol = current.col - 1;
          if (_isValidPosition(grid, current.row, leftCol)) {
            queue.add((row: current.row, col: leftCol));
          }
        } else if (cell == '[') {
          // queue.add(thisPosition + Point2D.EAST)
          final rightCol = current.col + 1;
          if (_isValidPosition(grid, current.row, rightCol)) {
            queue.add((row: current.row, col: rightCol));
          }
        }
      }

      // Calculate next position: val nextPosition = thisPosition + direction
      final nextRow = current.row + dRow;
      final nextCol = current.col + dCol;

      // Check next position: when (get(nextPosition))
      // In Kotlin, get() might throw on out of bounds, but we check first
      if (!_isValidPosition(grid, nextRow, nextCol)) {
        // Out of bounds treated as wall
        return null;
      }

      final nextCell = grid[nextRow][nextCol];

      // Matching Kotlin: when (get(nextPosition)) { '#' -> return null }
      if (nextCell == '#') {
        return null; // Wall! Can't push anything!
      }

      // Matching Kotlin: in "[O]" -> queue.add(nextPosition)
      if (nextCell == '[' || nextCell == ']' || nextCell == 'O') {
        queue.add((row: nextRow, col: nextCol));
      }

      // Matching Kotlin: safePushes.add(thisPosition to nextPosition)
      safePushes.add((
        fromRow: current.row,
        fromCol: current.col,
        toRow: nextRow,
        toCol: nextCol,
      ));
    }

    // Matching Kotlin: return safePushes.reversed()
    return safePushes.reversed.toList();
  }

  /// Attempts to move the robot in the given direction (Part 2 with wide boxes).
  bool _tryMoveRobotPart2(
    List<List<String>> grid,
    int robotRow,
    int robotCol,
    int dRow,
    int dCol,
  ) {
    final nextRow = robotRow + dRow;
    final nextCol = robotCol + dCol;
    // Check if next position is valid
    if (!_isValidPosition(grid, nextRow, nextCol)) {
      return false;
    }
    final nextCell = grid[nextRow][nextCol];
    // If next position is a wall, can't move
    if (nextCell == '#') {
      return false;
    }
    // If next position is empty, move robot
    if (nextCell == '.') {
      grid[nextRow][nextCol] = '@';
      grid[robotRow][robotCol] = '.';
      return true;
    }
    // If next position is part of a box, try to push it
    // Matching Kotlin: when (this[next]) { in "[O]" -> push(next, direction)?.let { ... } }
    if (_isBoxPart(grid, nextRow, nextCol)) {
      // Try to push - BFS will return null if blocked by wall
      final moves = _findBoxesToPushBFS(grid, nextRow, nextCol, dRow, dCol);
      if (moves != null) {
        // Execute moves (matching Kotlin: moves.forEach { (from, to) -> ... })
        for (final move in moves) {
          grid[move.toRow][move.toCol] = grid[move.fromRow][move.fromCol];
          grid[move.fromRow][move.fromCol] = '.';
        }
        // Move robot (matching Kotlin: place = next)
        grid[nextRow][nextCol] = '@';
        grid[robotRow][robotCol] = '.';
        return true;
      }
      // Can't push, move fails
      return false;
    }
    return false;
  }

  /// Part 2: Transform grid, simulate robot movement, calculate sum of box GPS coordinates.
  String _solvePart2(List<String> input) {
    if (input.isEmpty) return '0';
    final parsed = _parseInput(input);
    var grid = parsed.grid;
    final movements = parsed.movements;

    if (grid.isEmpty) return '0';

    // Transform grid for Part 2
    grid = _transformGridForPart2(grid);

    // Find robot position
    var robotPos = _findRobot(grid);
    if (robotPos.row == -1) return '0';

    // Process each movement command
    for (var i = 0; i < movements.length; i++) {
      final direction = movements[i];
      if (direction != '^' &&
          direction != 'v' &&
          direction != '<' &&
          direction != '>') {
        continue;
      }
      final dir = _getDirection(direction);
      if (_tryMoveRobotPart2(
          grid, robotPos.row, robotPos.col, dir.dRow, dir.dCol)) {
        robotPos = (row: robotPos.row + dir.dRow, col: robotPos.col + dir.dCol);
      }
    }

    // Calculate sum of GPS coordinates for all boxes
    // GPS = 100 * row + col (using leftmost column [ of each box)
    var sum = 0;
    for (var row = 0; row < grid.length; row++) {
      for (var col = 0; col < grid[row].length; col++) {
        if (grid[row][col] == '[') {
          final gps = 100 * row + col;
          sum += gps;
        }
      }
    }
    return sum.toString();
  }

  /// Debug method to get final grid state after Part 2 simulation.
  List<List<String>> debugGetFinalGridPart2(List<String> input) {
    if (input.isEmpty) return [];
    final parsed = _parseInput(input);
    var grid = parsed.grid;
    final movements = parsed.movements;

    if (grid.isEmpty) return [];

    // Transform grid for Part 2
    grid = _transformGridForPart2(grid);

    // Find robot position
    var robotPos = _findRobot(grid);
    if (robotPos.row == -1) return grid;

    // Process each movement command
    for (var i = 0; i < movements.length; i++) {
      final direction = movements[i];
      if (direction != '^' &&
          direction != 'v' &&
          direction != '<' &&
          direction != '>') {
        continue;
      }
      final dir = _getDirection(direction);
      if (_tryMoveRobotPart2(
          grid, robotPos.row, robotPos.col, dir.dRow, dir.dCol)) {
        robotPos = (row: robotPos.row + dir.dRow, col: robotPos.col + dir.dCol);
      }
    }

    return grid;
  }
}
