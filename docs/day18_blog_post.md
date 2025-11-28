# Solving Advent of Code Day 18: RAM Run - Breadth-First Search for Pathfinding

## The Problem: Escaping Corrupted Memory

You and The Historians find yourselves inside a computer at the North Pole! A program is causing bytes to fall into your memory space, corrupting coordinates. Your memory space is a 71×71 grid (coordinates 0-70), and you need to escape from the top-left corner (0,0) to the bottom-right corner (70,70).

**Part 1** asks: After the first 1024 bytes fall, what is the minimum number of steps needed to reach the exit?

**Part 2** asks: What are the coordinates of the first byte that will prevent the exit from being reachable?

## Understanding the Problem

This is a classic pathfinding problem with dynamic obstacles:
- You start at (0,0) and need to reach (70,70)
- Bytes fall in a specific order, corrupting cells
- Corrupted cells cannot be entered
- You can only move up, down, left, or right (no diagonals)
- All moves cost 1 step

The key insight: Since all moves cost the same (1 step), we can use **Breadth-First Search (BFS)** to find the shortest path. BFS guarantees the shortest path in unweighted graphs because it explores all positions at distance 1, then all at distance 2, and so on.

## Part 1: Finding the Shortest Path

### The BFS Algorithm

BFS works like ripples in a pond:
1. Start at the source position
2. Explore all neighbors at distance 1
3. Then explore all neighbors at distance 2
4. Continue until reaching the target

Since we explore level by level, the first time we reach the target is guaranteed to be via the shortest path.

### Implementation

```dart
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
    (dx: 0, dy: 1),  // down
    (dx: -1, dy: 0), // left
    (dx: 1, dy: 0),  // right
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
```

### Key Dart Features

1. **Record Types**: We use records `({int x, int y})` to represent coordinates, making the code more readable and type-safe.

2. **Set Operations**: Using `Set<({int x, int y})>` for both corrupted cells and visited positions provides O(1) lookup time.

3. **Queue Operations**: We use a list as a queue with `removeAt(0)` to process positions in order. In production, you might use `dart:collection`'s `Queue` class for better performance.

4. **Const Directions**: The directions array is `const` since it never changes, allowing Dart to optimize memory usage.

### Why BFS Works

BFS guarantees the shortest path because:
- It explores positions in order of distance from the start
- The first time we reach the target, we've taken the minimum number of steps
- Unlike DFS (depth-first search), BFS doesn't get "stuck" exploring deep paths before checking shorter alternatives

### Complexity Analysis

- **Time Complexity**: O(V) where V is the number of vertices (grid cells). In the worst case, we visit every cell once. For a 71×71 grid, that's 5,041 cells.
- **Space Complexity**: O(V) for the visited set and queue. In the worst case, the queue could contain all cells at the current level.

## Part 2: Finding the First Blocking Byte

Part 2 requires a different approach: we need to simulate bytes falling one by one and check after each byte whether a path still exists.

### The Sequential Simulation Approach

```dart
String _solvePart2(List<String> input) {
  final positions = _parseInput(input);
  final gridSize = positions.length <= 25 ? 7 : 71; // Detect example vs real
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
  
  return '0,0'; // Shouldn't happen
}
```

### Path Existence Check

We can simplify the BFS for Part 2 since we only need to know if a path exists, not its length:

```dart
bool _pathExists(Set<({int x, int y})> corrupted, int gridSize) {
  final target = (x: gridSize - 1, y: gridSize - 1);
  final start = (x: 0, y: 0);
  
  if (corrupted.contains(start) || corrupted.contains(target)) {
    return false;
  }
  
  final queue = <({int x, int y})>[];
  final visited = <({int x, int y})>{};
  queue.add(start);
  visited.add(start);
  
  // ... same BFS logic but return true/false instead of steps
  while (queue.isNotEmpty) {
    final current = queue.removeAt(0);
    if (current.x == target.x && current.y == target.y) {
      return true; // Path exists!
    }
    // ... explore neighbors
  }
  
  return false; // No path found
}
```

### Why This Works

By checking after each byte falls, we find the exact moment when the path becomes impossible. The first byte that blocks the path is the answer.

### Complexity Analysis

- **Time Complexity**: O(N × V) where N is the number of bytes to check and V is the grid size. In the worst case, we might need to check all 3,450 bytes, each requiring a BFS traversal.
- **Space Complexity**: O(V) for each BFS run, but we reuse the same data structures.

## Real-World Applications

BFS pathfinding has many practical applications:
- **GPS Navigation**: Finding shortest routes avoiding traffic/obstacles
- **Game AI**: Pathfinding for characters in video games
- **Network Routing**: Finding shortest paths in computer networks
- **Maze Solving**: Escaping mazes or finding routes through obstacles
- **Social Networks**: Finding degrees of separation between people

## Key Takeaways

1. **BFS for Unweighted Shortest Path**: When all edges have the same cost, BFS is the perfect algorithm for finding shortest paths.

2. **Set-Based Tracking**: Using sets for visited/blocked positions provides efficient O(1) lookups.

3. **Sequential Simulation**: Sometimes the solution requires simulating events one by one and checking conditions after each step.

4. **Early Termination**: Once we find the target in BFS, we can immediately return - we've found the shortest path.

5. **Grid Pathfinding Patterns**: This puzzle demonstrates common patterns for 2D grid pathfinding that appear frequently in coding challenges.

## Full Solution

The complete solution can be found in `lib/years/year2024/day18.dart`. The implementation includes:
- Input parsing for coordinate pairs
- BFS implementation for shortest path finding
- Path existence checking for Part 2
- Automatic detection of example vs. real input
- Comprehensive documentation explaining the algorithms

This puzzle is an excellent introduction to graph traversal algorithms and demonstrates how BFS can solve pathfinding problems efficiently when all moves have equal cost.

