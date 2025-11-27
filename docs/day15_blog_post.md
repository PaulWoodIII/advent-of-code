# Solving Advent of Code Day 15: Warehouse Woes - Grid Simulation with Chain Pushing

## The Problem: A Malfunctioning Robot

Imagine a warehouse filled with boxes and a robot that's gone haywire. The robot moves around the warehouse, pushing boxes as it goes. Your task is to predict where all the boxes will end up after the robot completes its movement sequence.

The puzzle has two parts:
- **Part 1**: Standard boxes (single cell, represented as `O`)
- **Part 2**: Wide boxes (two cells wide, represented as `[]`)

After all movements, you need to calculate the sum of GPS coordinates for all boxes, where GPS = `100 * row + col`.

## The Challenge: Chain Pushing

The tricky part isn't moving a single box—it's handling **chain reactions**. When the robot tries to push a box, that box might push another box, which might push yet another box. If any box in the chain would hit a wall, the entire move fails and nothing moves.

For Part 2, boxes are twice as wide, which adds complexity:
- When pushing vertically, you must ensure both columns can move
- Boxes can push multiple boxes simultaneously when aligned
- The robot can push two boxes at once if they're side-by-side

## The Naive Approach (And Why It's Tricky)

At first, you might try a recursive approach:

```dart
bool canPushBox(grid, row, col, direction) {
  // Check if next position is valid
  // If it's a box, recursively check if that box can be pushed
  // If it's a wall, return false
}
```

This works, but for Part 2 with wide boxes, the logic becomes complex:
- You need to check both halves of wide boxes
- You need to handle boxes in different columns simultaneously
- The recursive logic can get tangled

## The Elegant Solution: Breadth-First Search (BFS)

The key insight is to use **BFS (Breadth-First Search)** to find all boxes that need to be pushed in a single pass, then execute all moves in reverse order (furthest boxes first).

### How BFS Works for Pushing

1. **Start with the box the robot wants to push**
2. **Queue all boxes that need to move**:
   - If pushing vertically and you encounter `[` or `]`, queue the other half
   - If the next position contains a box, queue that box
3. **Track seen positions** to avoid infinite loops
4. **If you hit a wall**, return null (can't push)
5. **Return all moves in reverse order** (furthest boxes pushed first)

Here's the core BFS algorithm:

```dart
List<Move>? findBoxesToPushBFS(grid, startRow, startCol, dRow, dCol) {
  final safePushes = <Move>[];
  final queue = <Position>[];
  final seen = <String>{};
  
  queue.add((row: startRow, col: startCol));
  
  while (queue.isNotEmpty) {
    final current = queue.removeAt(0);
    if (seen.contains(key)) continue;
    seen.add(key);
    
    // For vertical movement: queue the other half of wide boxes
    if (dRow != 0 && dCol == 0) {
      if (grid[current.row][current.col] == ']') {
        queue.add((row: current.row, col: current.col - 1)); // Queue [
      } else if (grid[current.row][current.col] == '[') {
        queue.add((row: current.row, col: current.col + 1)); // Queue ]
      }
    }
    
    // Check next position
    final nextRow = current.row + dRow;
    final nextCol = current.col + dCol;
    
    if (grid[nextRow][nextCol] == '#') {
      return null; // Wall! Can't push
    }
    
    if (isBox(grid[nextRow][nextCol])) {
      queue.add((row: nextRow, col: nextCol)); // Queue blocking box
    }
    
    // This move is safe
    safePushes.add((from: current, to: (nextRow, nextCol)));
  }
  
  return safePushes.reversed.toList(); // Furthest first
}
```

### Why Reverse Order Matters

When pushing multiple boxes, you must push the furthest box first. Otherwise, you'll overwrite boxes before they've moved:

```
Before:  [A][B][C]@
         (robot wants to push right)

If you push A first:
  [A][B][C]@ → [ ][A][B][C]@  ❌ Wrong! B and C haven't moved yet

If you push C first (furthest):
  [A][B][C]@ → [A][B][C][ ]@  ✅ Correct!
```

By reversing the BFS result, we ensure furthest boxes are pushed first.

## Key Dart Language Features

### Records for Position Tracking

Dart's records make it easy to track positions:

```dart
final position = (row: 5, col: 10);
final move = (
  fromRow: 5,
  fromCol: 10,
  toRow: 6,
  toCol: 10,
);
```

### List<List<String>> for Mutable Grids

We use `List<List<String>>` where each cell is a String (`"["`, `"]"`, `"@"`, etc.). This allows direct modification:

```dart
grid[row][col] = "[";  // Direct assignment
```

While Dart doesn't have Kotlin's `CharArray`, `List<List<String>>` provides the same functionality with direct cell modification.

### Pattern Matching with Switch Expressions

Dart's switch expressions make grid transformation clean:

```dart
switch (cell) {
  case '#': return ['#', '#'];
  case 'O': return ['[', ']'];
  case '.': return ['.', '.'];
  case '@': return ['@', '.'];
}
```

## Complexity Analysis

- **Time Complexity**: O(M × B) where M is number of moves and B is average boxes per push chain
  - Each move: O(B) for BFS
  - Total: O(M × B)
- **Space Complexity**: O(R × C) for the grid, plus O(B) for BFS queue

For the puzzle input (700 moves, ~10 boxes per chain), this runs in milliseconds.

## Real-World Applications

This pattern appears in:
- **Game development**: Physics engines for pushing objects
- **Robotics**: Path planning with obstacles
- **Warehouse automation**: Robot movement planning
- **Puzzle games**: Sokoban-style games

## Key Learnings

1. **BFS for Chain Reactions**: When actions trigger other actions, BFS helps find all affected entities
2. **Reverse Execution**: When dependencies matter, execute in reverse order
3. **State Tracking**: Use seen sets to avoid infinite loops in graph traversal
4. **Grid Transformations**: Doubling width requires careful handling of multi-cell entities

## The Solution

The complete solution uses BFS to find all boxes that need to be pushed, then executes moves in reverse order. This elegant approach handles both single-cell boxes (Part 1) and wide boxes (Part 2) with the same algorithm.

**Full implementation**: See `lib/years/year2024/day15.dart`

**Reference**: This solution is based on Todd Ginsberg's elegant Kotlin implementation, adapted for Dart's language features.

