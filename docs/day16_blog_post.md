# Solving Advent of Code Day 16: Reindeer Maze - Dijkstra's Algorithm with Directional State

## The Problem: Finding the Optimal Path Through a Maze

It's time for the Reindeer Olympics! This year's event is the Reindeer Maze, where reindeer compete for the lowest score. The reindeer start at position `S` facing East and must reach position `E`. 

The scoring system is interesting:
- **Moving forward** costs 1 point
- **Rotating 90 degrees** (clockwise or counterclockwise) costs 1000 points
- You cannot move into walls (`#`)

**Part 1** asks: What is the lowest score a reindeer could possibly get?

**Part 2** asks: How many tiles are part of at least one of the best paths? (This helps you find the best spot to sit and watch!)

## The Challenge: Direction Matters

This isn't a simple pathfinding problem. The key insight is that **direction is part of the state**. You can't just track position—you need to track both position AND which direction you're facing.

Why? Because rotating costs 1000 points! Sometimes it's cheaper to take a longer path that avoids rotations than a shorter path that requires many turns.

## The Naive Approach (And Why It Fails)

You might think: "I'll just use BFS or DFS to find the shortest path!" But that won't work because:

1. **BFS/DFS don't handle weighted edges well** - Rotations cost 1000x more than moving forward
2. **Direction is part of the state** - Being at position (5, 10) facing North is different from being at (5, 10) facing East
3. **You need optimal paths, not just any path** - With such a high cost for rotations, you need to minimize total cost, not just path length

## The Elegant Solution: Dijkstra's Algorithm with State Space

Dijkstra's algorithm is perfect for this problem because it finds the shortest path in a weighted graph. But we need to extend it to handle **state space** that includes direction.

### Understanding the State Space

Instead of just tracking position `(row, col)`, we track **state** `(row, col, direction)`:

```dart
// Directions: 0=North, 1=East, 2=South, 3=West
final state = (row: row, col: col, direction: direction);
```

This means each position can be in 4 different states (one for each direction), dramatically increasing the search space but allowing us to correctly model the problem.

### Part 1: Finding the Optimal Path

Here's how Dijkstra's algorithm works for Part 1:

```dart
String _solvePart1(List<String> input) {
  final grid = input.map((line) => line.split('')).toList();
  final start = _findStart(grid);
  final end = _findEnd(grid);
  
  // Start facing East (direction 1)
  const startDirection = 1;
  
  // Distance map: state -> cost
  final distances = <({int row, int col, int direction}), int>{};
  final queue = <({int cost, int row, int col, int direction})>[];
  final visited = <({int row, int col, int direction})>{};
  
  // Initialize start state
  final startState = (row: start.row, col: start.col, direction: startDirection);
  distances[startState] = 0;
  queue.add((cost: 0, row: start.row, col: start.col, direction: startDirection));
  
  while (queue.isNotEmpty) {
    // Process state with lowest cost
    queue.sort((a, b) => a.cost.compareTo(b.cost));
    final current = queue.removeAt(0);
    final state = (row: current.row, col: current.col, direction: current.direction);
    
    if (visited.contains(state)) continue;
    visited.add(state);
    
    // Check if we reached the end
    if (current.row == end.row && current.col == end.col) {
      return current.cost.toString();
    }
    
    // Three possible actions from each state:
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
  
  return '0'; // No path found
}
```

### Key Insights

1. **Priority Queue**: We always process the state with the lowest cost first (this is Dijkstra's guarantee)
2. **Three Actions**: From any state, we can move forward, rotate clockwise, or rotate counterclockwise
3. **State Tracking**: We track visited states to avoid reprocessing
4. **Early Termination**: As soon as we reach the end position (any direction), we return the cost

### Moving Forward

The `_moveForward` function calculates the next position based on direction:

```dart
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
```

## Part 2: Finding All Tiles on Optimal Paths

Part 2 asks: "How many tiles are part of at least one optimal path?" This requires a different approach—we need to find **all** optimal paths, not just one.

### The Key Insight: Bidirectional Dijkstra

The solution uses **bidirectional Dijkstra**:

1. **Forward Dijkstra**: Run from start to find distances to all states
2. **Backward Dijkstra**: Run from end to find distances from all states to end
3. **Check each tile**: A tile is on an optimal path if there exists a direction `d` where:
   ```
   dist_from_start[tile, d] + dist_from_end[tile, d] == optimal_cost
   ```

### Backward Movement

The tricky part is understanding backward movement. When moving backward from direction `d`, you go in the **opposite direction**:

```dart
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
```

### Implementation

```dart
String _solvePart2(List<String> input) {
  final grid = input.map((line) => line.split('')).toList();
  final start = _findStart(grid);
  final end = _findEnd(grid);
  
  // Run Dijkstra from start
  final forwardResult = _dijkstraFromStart(grid, start, end);
  final forwardDistances = forwardResult.distances;
  final optimalCost = forwardResult.optimalCost;
  
  // Run Dijkstra backwards from end
  final backwardDistances = _dijkstraFromEnd(grid, end);
  
  // Find all tiles on optimal paths
  final tilesOnOptimalPaths = <({int row, int col})>{};
  
  for (var row = 0; row < grid.length; row++) {
    for (var col = 0; col < grid[row].length; col++) {
      if (!_isValidMove(grid, row, col)) continue;
      
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
```

### Why This Works

If `dist_from_start[tile, d] + dist_from_end[tile, d] == optimal_cost`, then:
- There exists a path from start to `(tile, d)` with cost `c1`
- There exists a path from `(tile, d)` to end with cost `c2`
- `c1 + c2` equals the optimal cost
- Therefore, `(tile, d)` is on an optimal path

## Dart Language Features Used

### Records for State Representation

Dart's records are perfect for representing state:

```dart
final state = (row: row, col: col, direction: direction);
```

Records provide:
- **Type safety**: The compiler ensures correct structure
- **Equality**: Two records with the same values are equal
- **Immutability**: Records are immutable by default
- **Pattern matching**: Can be used in switch expressions

### Map with Record Keys

Dart allows using records as map keys:

```dart
final distances = <({int row, int col, int direction}), int>{};
distances[state] = cost;
```

This is much cleaner than using strings or custom classes!

### Set for Visited Tracking

Using sets for visited states is efficient:

```dart
final visited = <({int row, int col, int direction})>{};
if (visited.contains(state)) continue;
visited.add(state);
```

Sets provide O(1) average-case lookup and insertion.

## Complexity Analysis

### Time Complexity

- **Part 1**: O(V log V) where V = rows × cols × 4 (directions)
  - Each state is processed at most once
  - Priority queue operations are O(log V)
  
- **Part 2**: O(V log V) for each Dijkstra run
  - Forward Dijkstra: O(V log V)
  - Backward Dijkstra: O(V log V)
  - Checking tiles: O(V)
  - Total: O(V log V)

### Space Complexity

- **Part 1**: O(V) for distances map and visited set
- **Part 2**: O(V) for each distances map (forward and backward)

For a typical maze of 100×100 cells:
- V = 100 × 100 × 4 = 40,000 states
- This is manageable for modern computers

## Real-World Applications

### Navigation Systems

This algorithm pattern appears in:
- **GPS navigation**: Finding optimal routes considering turns (which cost time/fuel)
- **Robot pathfinding**: Robots that need to consider orientation
- **Game AI**: Characters that face different directions

### Network Routing

The bidirectional Dijkstra approach is used in:
- **Internet routing**: Finding all nodes on optimal paths
- **Network analysis**: Identifying critical nodes
- **Graph theory**: Finding all shortest paths between nodes

### Optimization Problems

The state space approach generalizes to:
- **Resource allocation**: When state includes resource levels
- **Scheduling**: When state includes time and resource constraints
- **Constraint satisfaction**: When state includes partial solutions

## Key Takeaways

1. **State Space Matters**: When direction/orientation affects cost, include it in the state
2. **Dijkstra's Algorithm**: Perfect for weighted shortest path problems
3. **Bidirectional Search**: Use when you need to find all optimal paths
4. **Records in Dart**: Excellent for representing complex state
5. **Priority Queue**: Essential for Dijkstra's algorithm (though we use a sorted list here)

## Full Solution Code

The complete solution can be found in `lib/years/year2024/day16.dart`. The implementation includes:

- `_solvePart1()`: Forward Dijkstra to find optimal cost
- `_solvePart2()`: Bidirectional Dijkstra to find all tiles on optimal paths
- `_dijkstraFromStart()`: Forward Dijkstra implementation
- `_dijkstraFromEnd()`: Backward Dijkstra implementation
- Helper functions for movement and validation

This puzzle beautifully demonstrates how Dijkstra's algorithm extends to state space search problems, and how bidirectional search can help find all optimal solutions!

