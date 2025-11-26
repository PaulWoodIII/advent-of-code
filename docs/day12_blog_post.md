# Solving Advent of Code Day 12: From Perimeter to Polygon Vertices

## The Problem: Garden Groups

Imagine you're planning a garden with different plant types. Each plant type forms connected regions (groups of the same plant connected horizontally or vertically). You need to fence each region, and the cost depends on the region's area and boundary.

**Part 1** asks: What's the total cost if price = area × perimeter?

**Part 2** asks: What's the total cost if price = area × number of sides? (Where a "side" is a continuous straight section of fence, not individual fence segments)

The twist: Part 2 requires understanding polygon geometry—specifically, how to count vertices (corners) where the boundary turns, not just the total length of the boundary.

## Part 1: Connected Components and Perimeter

Let's start with Part 1, which is more straightforward:

```dart
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
```

### Finding Connected Components with BFS

The key algorithm here is **Breadth-First Search (BFS)** to find all connected cells:

```dart
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

    // Check neighbors (up, down, left, right)
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
```

**How BFS works:**
1. Start with a seed cell
2. Add it to a queue
3. While the queue isn't empty:
   - Remove the first cell
   - Add all unvisited neighbors of the same type to the queue
   - Mark the cell as visited

This explores the entire connected region level by level.

### Calculating Perimeter

Once we have a region, calculating perimeter is straightforward:

```dart
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
        perimeter++; // This edge is on the boundary
      }
    }
  }

  return perimeter;
}
```

For each cell in the region, we check its four neighbors. If a neighbor isn't in the region (or is outside the grid), that edge contributes to the perimeter.

## Part 2: The Vertex Detection Challenge

Part 2 is where it gets interesting. Instead of counting perimeter (total fence length), we need to count **sides** (straight sections of fence).

### The Key Insight: Vertices = Sides

In any polygon, **the number of sides equals the number of vertices**. Each side is bounded by two vertices (corners). So if we can count vertices, we can count sides.

But here's the crucial realization: **vertices are at positions BETWEEN cells, not at cell positions**.

### Understanding Corner Positions

Think of a grid where cells are squares. The corners are at the intersections between cells:

```
  0   1   2   3
0 ┌───┬───┬───┐
  │ A │ A │   │
1 ├───┼───┼───┤
  │ A │ B │   │
2 ├───┼───┼───┤
  │   │   │   │
3 └───┴───┴───┘
```

The corners are at positions like (0,0), (0,1), (1,0), etc.—these are the intersection points. Each corner is surrounded by 4 cells (top-left, top-right, bottom-right, bottom-left).

### The Vertex Detection Algorithm

Here's how we detect vertices:

```dart
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
      
      // Count transitions (boundary crossings)
      var transitions = 0;
      if (topLeftIn != topRightIn) transitions++;
      if (topRightIn != bottomRightIn) transitions++;
      if (bottomRightIn != bottomLeftIn) transitions++;
      if (bottomLeftIn != topLeftIn) transitions++;
      
      // Vertex must have exactly 2 transitions (normal corner) or 4 (around hole)
      if (transitions != 2 && transitions != 4) {
        continue;
      }
      
      // Apply vertex detection rules...
    }
  }
  
  return vertices;
}
```

### Vertex Detection Rules

1. **External corners (count=1)**: Exactly 1 of 4 cells is in the region → always a vertex
   ```
   Pattern: 1000, 0100, 0010, 0001
   Example: Corner at the outer edge of a region
   ```

2. **Internal corners (count=3)**: Exactly 3 of 4 cells are in the region → always a vertex
   ```
   Pattern: 1110, 1101, 1011, 0111
   Example: Corner around an internal hole
   ```

3. **Hole corners (count=2, transitions=4)**: All 4 edges are boundaries
   ```
   Pattern: 1010, 0101 (diagonal pattern)
   Special case: If shared between two holes, count TWICE
   ```

4. **Perpendicular edges (count=2, transitions=2)**: Two adjacent cells create a vertex
   ```
   Pattern: 1100, 0110, 0011, 1001 (adjacent cells)
   Example: Corner where boundary turns
   ```

5. **Edge midpoints (count=2, transitions=2)**: Two opposite cells → NOT a vertex
   ```
   Pattern: 1010, 0101 (opposite cells, but only 2 transitions)
   Example: Middle of a straight boundary section
   ```

### The Critical Distinction: Perpendicular vs Opposite Edges

This is the trickiest part. When count=2 and transitions=2, we need to distinguish:

- **Perpendicular edges** (vertex): The two cells are adjacent (share an edge)
  ```
  Pattern: 1100 (top-left and top-right are in region)
  Boundary edges: Top and Right are boundaries → corner!
  ```

- **Opposite edges** (edge midpoint): The two cells are opposite (diagonal)
  ```
  Pattern: 1001 (top-left and bottom-right are in region, but only 2 transitions)
  Boundary edges: Left and Right are boundaries → straight section, not a corner
  ```

Here's how we check:

```dart
// Check which edges have boundaries
final topEdgeBoundary = topLeftIn != topRightIn;
final rightEdgeBoundary = topRightIn != bottomRightIn;
final bottomEdgeBoundary = bottomRightIn != bottomLeftIn;
final leftEdgeBoundary = bottomLeftIn != topLeftIn;

// Check if boundary edges are perpendicular (adjacent) or opposite
final perpendicular = (topEdgeBoundary && rightEdgeBoundary) ||
    (rightEdgeBoundary && bottomEdgeBoundary) ||
    (bottomEdgeBoundary && leftEdgeBoundary) ||
    (leftEdgeBoundary && topEdgeBoundary);

if (perpendicular) {
  vertices++; // This is a vertex
} else {
  // Opposite edges = edge midpoint (not counted)
}
```

### The Off-by-One Bug: Shared Hole Corners

Here's a subtle bug we encountered: when a corner is shared between two holes, it needs to be counted **twice**—once for each hole.

```dart
if (transitions == 4) {
  // Check if this is a diagonal hole pattern
  final isDiagonalHole = (topLeftIn && bottomRightIn && !topRightIn && !bottomLeftIn) ||
      (!topLeftIn && !bottomRightIn && topRightIn && bottomLeftIn);
  
  if (isDiagonalHole) {
    // This corner is shared between two holes - count it twice!
    vertices += 2;
  } else {
    vertices++;
  }
}
```

Why? Because each hole contributes its own boundary, and a shared corner is part of both boundaries.

## Dart Language Features in Action

### 1. Record Types for Coordinates

Dart's record types make coordinate pairs elegant:

```dart
final cell = (row: row, col: col);
```

This is cleaner than creating a class or using a List. Records are lightweight and perfect for simple data structures like coordinates.

### 2. Set Operations

Sets are perfect for tracking visited cells and regions:

```dart
final visited = <({int row, int col})>{};
final region = <({int row, int col})>{};

if (visited.contains(cell)) {
  continue;
}
region.add(current);
```

Sets provide O(1) lookup, making them ideal for membership testing.

### 3. List Methods: map, split, toList

Dart's collection methods make parsing input clean:

```dart
final grid = input.map((line) => line.split('')).toList();
```

This transforms a list of strings into a 2D list of characters in one line.

### 4. Boolean Logic for Pattern Matching

We use boolean logic to detect patterns:

```dart
final topLeftIn = _isInRegion(topLeft, rows, cols, region);
final topRightIn = _isInRegion(topRight, rows, cols, region);
// ...
final count = (topLeftIn ? 1 : 0) + (topRightIn ? 1 : 0) + ...;
```

The ternary operator `condition ? value1 : value2` converts booleans to integers for counting.

### 5. Named Parameters with Defaults

Optional debug parameter with a default:

```dart
int _calculateSides(
  List<List<String>> grid,
  int rows,
  int cols,
  Set<({int row, int col})> region, {
  bool debug = false,
}) {
  // ...
}
```

The `{bool debug = false}` syntax makes the parameter optional, defaulting to `false` if not provided.

## Complexity Analysis

**Part 1:**
- **Time**: O(rows × cols) - we visit each cell once
- **Space**: O(rows × cols) - for the grid and visited set

**Part 2:**
- **Time**: O(rows × cols × regions) - we check all corner positions for each region
- **Space**: O(rows × cols) - for the grid and region sets

The vertex detection algorithm is O(corners) where corners = (rows + 1) × (cols + 1), which is essentially O(rows × cols).

## Real-World Applications

This problem teaches several important concepts:

1. **Connected Component Detection**: Used in image processing (finding objects), network analysis (finding clusters), and geographic information systems (finding regions).

2. **Boundary Detection**: Critical in computer vision, image segmentation, and geographic mapping.

3. **Polygon Analysis**: Understanding vertices vs edges is fundamental in computational geometry, graphics programming, and CAD software.

4. **Pattern Matching**: The vertex detection rules are essentially pattern matching—recognizing geometric patterns in grid data.

## Performance Results

On my machine:
- **Part 1**: ~17ms
- **Part 2**: ~555ms

Part 2 is slower because we check every corner position for every region, but it's still very fast for the puzzle input size.

## Key Takeaways

1. **Corners are between cells**: When working with grid boundaries, remember that corners exist at intersections, not at cell centers.

2. **Pattern matching matters**: Distinguishing vertices from edge midpoints requires careful pattern analysis.

3. **Special cases need special handling**: Shared corners between holes require counting twice—a subtle but important detail.

4. **BFS/DFS for connectivity**: These algorithms are fundamental for finding connected components in graphs and grids.

5. **Dart's type system helps**: Records, sets, and type inference make the code cleaner and safer.

## Conclusion

Day 12 teaches us about **computational geometry**—specifically, how to analyze polygon boundaries in grid-based problems. The key insight is recognizing that vertices (where the boundary turns) are different from edge midpoints (straight sections), and that this distinction requires careful pattern matching.

The algorithm combines several fundamental concepts:
- **Graph traversal** (BFS for connected components)
- **Boundary analysis** (perimeter calculation)
- **Geometric pattern recognition** (vertex detection)
- **Edge case handling** (shared corners)

This puzzle is excellent practice for problems involving grid-based geometry, image processing, or any domain where you need to analyze spatial relationships and boundaries.

---

**Full solution code**: [day12.dart](https://github.com/PaulWoodIII/advent-of-code/blob/main/lib/years/year2024/day12.dart)

