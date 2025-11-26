import '../../core/solver.dart';

/// Day 12: Garden Groups
///
/// This puzzle teaches several important computer science concepts:
///
/// **Part 1: Connected Components and Perimeter Calculation**
/// - Finding connected regions in a 2D grid using BFS/DFS
/// - Connected components: cells of the same type connected horizontally or vertically
/// - Perimeter calculation: counting edges that don't touch another cell in the same region
/// - Area calculation: counting cells in each region
/// - Price calculation: area * perimeter for each region
///
/// **Part 2: Side Counting in Polygons - Vertex Detection Algorithm**
/// - Side counting: counting continuous straight sections of fence (not individual edges)
/// - Key insight: In a polygon, the number of sides equals the number of vertices (corners)
/// - Vertex detection: Count corners at positions BETWEEN cells (not at cell positions)
/// - A corner position is defined by 4 surrounding cells (top-left, top-right, bottom-right, bottom-left)
///
/// **Vertex Detection Rules:**
/// 1. External corners (count=1): Exactly 1 of 4 cells is in region → always a vertex
/// 2. Internal corners (count=3): Exactly 3 of 4 cells are in region → always a vertex
/// 3. Hole corners (count=2, transitions=4): All 4 edges are boundaries (diagonal pattern)
///    - Pattern: cells in opposite corners are in region (e.g., top-left & bottom-right)
///    - Special case: If corner is shared between two holes, count it TWICE (once per hole)
/// 4. Perpendicular edges (count=2, transitions=2): Two adjacent cells in region create a vertex
/// 5. Edge midpoints (count=2, transitions=2): Two opposite cells in region → NOT a vertex
///    - These represent straight sections of boundary, not turns
///
/// **Key Algorithm Insights:**
/// - Check all corner positions from (0,0) to (rows, cols) - corners are BETWEEN cells
/// - Count transitions: how many edges cross the boundary (should be 2 or 4)
/// - For count=2 with 2 transitions: check if boundary edges are perpendicular (vertex) or opposite (edge midpoint)
/// - For count=2 with 4 transitions: check if diagonal pattern (shared hole corner) → count twice
///
/// **Key Patterns for Future Puzzles:**
/// - Connected component detection using BFS/DFS traversal
/// - Grid boundary checking (4-directional neighbors)
/// - Counting edges/boundaries in graph structures
/// - Set-based tracking of visited cells
/// - Vertex detection at corner positions (between cells) rather than cell positions
/// - Pattern matching for distinguishing vertices from edge midpoints
/// - Handling special cases (shared corners between multiple holes)
class Year2024Day12 extends DaySolver {
  @override
  int get year => 2024;

  @override
  int get day => 12;

  @override
  String solvePart1(List<String> input) {
    return _solvePart1(input);
  }

  @override
  String solvePart2(List<String> input) {
    return _solvePart2(input);
  }
  
  /// Debug version of solvePart2 that prints vertex information.
  String solvePart2Debug(List<String> input) {
    return _solvePart2(input, debug: true);
  }

  String _solvePart1(List<String> input) {
    final grid = input.map((line) => line.split('')).toList();
    final rows = grid.length;
    final cols = grid[0].length;

    final visited = <({int row, int col})>{};
    var totalPrice = 0;

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        final cell = (row: row, col: col);
        if (visited.contains(cell)) {
          continue;
        }

        // Find the region starting from this cell
        final region = _findRegion(grid, rows, cols, cell, visited);
        final area = region.length;
        final perimeter = _calculatePerimeter(grid, rows, cols, region);
        totalPrice += area * perimeter;
      }
    }

    return totalPrice.toString();
  }

  String _solvePart2(List<String> input, {bool debug = false}) {
    final grid = input.map((line) => line.split('')).toList();
    final rows = grid.length;
    final cols = grid[0].length;

    final visited = <({int row, int col})>{};
    var totalPrice = 0;

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        final cell = (row: row, col: col);
        if (visited.contains(cell)) {
          continue;
        }

        // Find the region starting from this cell
        final region = _findRegion(grid, rows, cols, cell, visited);
        final area = region.length;
        final plantType = grid[row][col];
        
        if (debug) {
          print('\n=== Region: $plantType (area: $area) ===');
        }
        
        final sides = _calculateSides(grid, rows, cols, region, debug: debug);
        final price = area * sides;
        totalPrice += price;
        
        if (debug) {
          print('Sides: $sides, Price: $area * $sides = $price');
        }
      }
    }

    if (debug) {
      print('\nTotal price: $totalPrice');
    }

    return totalPrice.toString();
  }

  /// Finds all cells in the same region using BFS.
  Set<({int row, int col})> _findRegion(
    List<List<String>> grid,
    int rows,
    int cols,
    ({int row, int col}) start,
    Set<({int row, int col})> visited,
  ) {
    final region = <({int row, int col})>{};
    final queue = <({int row, int col})>[start];
    final plantType = grid[start.row][start.col];

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      if (visited.contains(current)) {
        continue;
      }
      visited.add(current);
      region.add(current);

      // Check neighbors
      final neighbors = [
        (row: current.row - 1, col: current.col),
        (row: current.row + 1, col: current.col),
        (row: current.row, col: current.col - 1),
        (row: current.row, col: current.col + 1),
      ];

      for (final neighbor in neighbors) {
        if (neighbor.row >= 0 &&
            neighbor.row < rows &&
            neighbor.col >= 0 &&
            neighbor.col < cols &&
            grid[neighbor.row][neighbor.col] == plantType &&
            !visited.contains(neighbor)) {
          queue.add(neighbor);
        }
      }
    }

    return region;
  }

  /// Calculates the perimeter of a region.
  int _calculatePerimeter(
    List<List<String>> grid,
    int rows,
    int cols,
    Set<({int row, int col})> region,
  ) {
    var perimeter = 0;

    for (final cell in region) {
      // Check each of the 4 edges of this cell
      final neighbors = [
        (row: cell.row - 1, col: cell.col), // top
        (row: cell.row + 1, col: cell.col), // bottom
        (row: cell.row, col: cell.col - 1), // left
        (row: cell.row, col: cell.col + 1), // right
      ];

      for (final neighbor in neighbors) {
        final isNeighborInRegion = neighbor.row >= 0 &&
            neighbor.row < rows &&
            neighbor.col >= 0 &&
            neighbor.col < cols &&
            region.contains((row: neighbor.row, col: neighbor.col));

        if (!isNeighborInRegion) {
          perimeter++;
        }
      }
    }

    return perimeter;
  }

  /// Calculates the number of sides by counting vertices at corner positions.
  ///
  /// Algorithm:
  /// 1. Check all corner positions (between cells) from (0,0) to (rows, cols)
  /// 2. For each corner, examine the 4 surrounding cells
  /// 3. Count how many cells are in the region (0-4)
  /// 4. Count how many edges cross the boundary (transitions: 0-4)
  /// 5. Apply vertex detection rules to determine if this corner is a vertex
  ///
  /// Vertex types:
  /// - External corner: count=1, transitions=2 → always vertex
  /// - Internal corner: count=3, transitions=2 → always vertex
  /// - Hole corner: count=2, transitions=4 → vertex (count twice if shared between holes)
  /// - Perpendicular edge: count=2, transitions=2, perpendicular edges → vertex
  /// - Edge midpoint: count=2, transitions=2, opposite edges → NOT a vertex
  ///
  /// Returns the number of vertices, which equals the number of sides.
  int _calculateSides(
    List<List<String>> grid,
    int rows,
    int cols,
    Set<({int row, int col})> region, {
    bool debug = false,
  }) {
    if (region.isEmpty) {
      return 0;
    }

    var vertices = 0;
    final vertexList = <String>[];
    
    // Check all corner positions (between cells)
    for (var cornerRow = 0; cornerRow <= rows; cornerRow++) {
      for (var cornerCol = 0; cornerCol <= cols; cornerCol++) {
        final topLeft = (row: cornerRow - 1, col: cornerCol - 1);
        final topRight = (row: cornerRow - 1, col: cornerCol);
        final bottomRight = (row: cornerRow, col: cornerCol);
        final bottomLeft = (row: cornerRow, col: cornerCol - 1);
        
        final topLeftIn = _isInRegion(topLeft, rows, cols, region);
        final topRightIn = _isInRegion(topRight, rows, cols, region);
        final bottomRightIn = _isInRegion(bottomRight, rows, cols, region);
        final bottomLeftIn = _isInRegion(bottomLeft, rows, cols, region);
        
        final count = (topLeftIn ? 1 : 0) +
            (topRightIn ? 1 : 0) +
            (bottomRightIn ? 1 : 0) +
            (bottomLeftIn ? 1 : 0);
        
        // Must be on boundary (not all in or all out)
        if (count == 0 || count == 4) {
          continue;
        }
        
        // Count transitions
        var transitions = 0;
        if (topLeftIn != topRightIn) transitions++;
        if (topRightIn != bottomRightIn) transitions++;
        if (bottomRightIn != bottomLeftIn) transitions++;
        if (bottomLeftIn != topLeftIn) transitions++;
        
        // Vertex must have exactly 2 transitions (normal corner) or 4 (around hole)
        if (transitions != 2 && transitions != 4) {
          continue;
        }
        
        String? reason;
        
        // Count == 1 or 3: always a vertex (external/internal corner)
        if (count == 1 || count == 3) {
          vertices++;
          reason = 'count=$count (${count == 1 ? 'external' : 'internal'} corner)';
        }
        // Count == 2: check pattern to distinguish vertices from edge midpoints
        else if (count == 2) {
          // 4 transitions = vertex around hole (all 4 edges are boundaries)
          // This happens when cells in opposite corners are in the region (diagonal pattern)
          if (transitions == 4) {
            // Check if this is a diagonal hole pattern (cells in opposite corners)
            // Pattern examples: top-left & bottom-right in, OR top-right & bottom-left in
            final isDiagonalHole = (topLeftIn && bottomRightIn && !topRightIn && !bottomLeftIn) ||
                (!topLeftIn && !bottomRightIn && topRightIn && bottomLeftIn);
            
            if (isDiagonalHole) {
              // This corner is shared between two holes - count it twice (once per hole)
              // This is the key insight that fixes the off-by-one error!
              vertices += 2;
              reason = 'count=2, transitions=4 (hole corner - shared, counted twice)';
            } else {
              // Other 4-transition patterns (shouldn't occur in typical cases)
              vertices++;
              reason = 'count=2, transitions=4 (hole corner)';
            }
          }
          // 2 transitions: need to check if edges are perpendicular (vertex) or opposite (edge midpoint)
          else if (transitions == 2) {
            // Determine which edges have boundaries
            final topEdgeBoundary = topLeftIn != topRightIn;
            final rightEdgeBoundary = topRightIn != bottomRightIn;
            final bottomEdgeBoundary = bottomRightIn != bottomLeftIn;
            final leftEdgeBoundary = bottomLeftIn != topLeftIn;
            
            // Check if boundary edges are perpendicular (adjacent edges) or opposite
            // Perpendicular = vertex (boundary turns)
            // Opposite = edge midpoint (straight section, not a turn)
            final perpendicular = (topEdgeBoundary && rightEdgeBoundary) ||
                (rightEdgeBoundary && bottomEdgeBoundary) ||
                (bottomEdgeBoundary && leftEdgeBoundary) ||
                (leftEdgeBoundary && topEdgeBoundary);
            
            if (perpendicular) {
              vertices++;
              reason = 'count=2, transitions=2, perpendicular edges (vertex)';
            } else {
              // Opposite edges = edge midpoint (straight boundary, not a turn)
              // Do NOT count this as a vertex
              reason = 'count=2, transitions=2, opposite edges (edge midpoint - NOT counted)';
            }
          }
        }
        
        if (debug && reason != null) {
          final pattern = '${topLeftIn ? "1" : "0"}${topRightIn ? "1" : "0"}${bottomRightIn ? "1" : "0"}${bottomLeftIn ? "1" : "0"}';
          vertexList.add('  Vertex at corner ($cornerRow, $cornerCol): pattern=$pattern, $reason');
        }
      }
    }
    
    if (debug) {
      print('Region vertices (total: $vertices):');
      for (final vertex in vertexList) {
        print(vertex);
      }
    }
    
    return vertices;
  }
  
  
  /// Helper function to check if a cell position is in the region.
  bool _isInRegion(
    ({int row, int col}) cell,
    int rows,
    int cols,
    Set<({int row, int col})> region,
  ) {
    return cell.row >= 0 &&
        cell.row < rows &&
        cell.col >= 0 &&
        cell.col < cols &&
        region.contains((row: cell.row, col: cell.col));
  }
}
