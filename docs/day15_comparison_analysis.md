# Day 15 Implementation Comparison: Dart vs Kotlin

## Overview
Comparison of our Dart implementation against Todd Ginsberg's Kotlin solution:
https://raw.githubusercontent.com/tginsberg/advent-2024-kotlin/refs/heads/main/src/main/kotlin/com/ginsberg/advent2024/Day15.kt

## What's the Same ✅

### Core Algorithm Logic
1. **BFS Push Algorithm**: Both use identical breadth-first search approach
   - Start with initial position in queue
   - Track seen positions to avoid cycles
   - For vertical movement: queue other half of wide boxes (`[`/`]`)
   - Return reversed list (furthest boxes pushed first)

2. **Grid Transformation**: Both transform Part 1 grid to Part 2 identically
   - `#` → `##`
   - `O` → `[]`
   - `.` → `..`
   - `@` → `@.`

3. **GPS Calculation**: Both use `100 * row + col` formula
   - Part 1: Sum GPS for all `O`
   - Part 2: Sum GPS for all `[` (left edge of boxes)

4. **Move Execution**: Both execute moves in same order
   - Get moves from BFS (or null if blocked)
   - Execute each move: `grid[to] = grid[from]; grid[from] = '.'`
   - Move robot to next position

## What's Different 🔄

### 1. **Architecture/Structure**

**Kotlin:**
```kotlin
private fun List<CharArray>.doMovements(): List<CharArray> {
    val start: Point2D = findAll('@').first()
    var place = start
    movements.forEach { direction ->
        val next = place + direction
        when (this[next]) {
            in "[O]" -> {
                push(next, direction)?.let { moves ->
                    moves.forEach { (from, to) -> ... }
                    place = next
                }
            }
            !in "#" -> { place = next }
        }
    }
    return this
}
```

**Dart:**
- Separate `_tryMoveRobotPart1()` and `_tryMoveRobotPart2()` functions
- Separate `_solvePart1()` and `_solvePart2()` functions
- More modular but more code

**Impact**: Kotlin's approach is simpler - one function handles both parts with same logic.

### 2. **Data Structures**

**Kotlin:**
- Uses `Point2D` objects (custom class)
- Uses `List<CharArray>` (mutable char arrays)
- Uses `Pair<Point2D, Point2D>` for moves

**Dart:**
- Uses tuples `({int row, int col})`
- Uses `List<List<String>>` (mutable string lists)
- Uses records `({int fromRow, int fromCol, int toRow, int toCol})`

**Impact**: Language difference, functionally equivalent.

### 3. **Seen Tracking**

**Kotlin:**
```kotlin
val seen = mutableSetOf<Point2D>()
if (thisPosition !in seen) {
    seen += thisPosition
    // ... process
}
```

**Dart:**
```dart
final seen = <String>{};
final key = '${current.row},${current.col}';
if (seen.contains(key)) {
    continue;
}
seen.add(key);
```

**Impact**: Kotlin uses object equality, Dart uses string keys. Functionally same.

### 4. **Bounds Checking**

**Kotlin:**
```kotlin
when (get(nextPosition)) {
    '#' -> return null
    in "[O]" -> queue.add(nextPosition)
}
// get() might throw on out of bounds
```

**Dart:**
```dart
if (!_isValidPosition(grid, nextRow, nextCol)) {
    return null; // Out of bounds treated as wall
}
final nextCell = grid[nextRow][nextCol];
if (nextCell == '#') { return null; }
```

**Impact**: Dart explicitly checks bounds first. Kotlin relies on exception handling or grid boundaries. Our approach is safer.

### 5. **Other Half Queuing**

**Kotlin:**
```kotlin
if (direction in setOf(Point2D.NORTH, Point2D.SOUTH)) {
    when (get(thisPosition)) {
        ']' -> queue.add(thisPosition + Point2D.WEST)
        '[' -> queue.add(thisPosition + Point2D.EAST)
    }
}
```

**Dart:**
```dart
if (dRow != 0 && dCol == 0) {
    final cell = grid[current.row][current.col];
    if (cell == ']') {
        final leftCol = current.col - 1;
        if (_isValidPosition(grid, current.row, leftCol)) {
            queue.add((row: current.row, col: leftCol));
        }
    } else if (cell == '[') {
        final rightCol = current.col + 1;
        if (_isValidPosition(grid, current.row, rightCol)) {
            queue.add((row: current.row, col: rightCol));
        }
    }
}
```

**Impact**: Same logic, Dart adds explicit bounds check (safer).

## Language-Specific Differences 🌐

### Kotlin Features Used
1. **Extension Functions**: `List<CharArray>.doMovements()`, `List<CharArray>.push()`
2. **When Expressions**: Pattern matching with `when`
3. **Safe Calls**: `push(...)?.let { ... }`
4. **Infix Functions**: `thisPosition to nextPosition` (Pair creation)
5. **Operator Overloading**: `place + direction`, `this[next]`

### Dart Equivalents
1. **Regular Methods**: Class methods instead of extensions
2. **If/Else**: Explicit conditionals instead of `when`
3. **Null Checks**: `if (moves != null) { ... }`
4. **Records**: `(fromRow: ..., toRow: ...)` instead of Pair
5. **Manual Access**: `grid[row][col]` instead of operator overloading

## Key Learnings 🎓

### 1. **Simplicity Wins**
Kotlin's single `doMovements()` function that works for both parts is cleaner than our separate functions. The key insight: Part 1 and Part 2 use the same movement logic, just different box representations.

### 2. **Direct Integration**
Kotlin calls `push()` directly from the movement loop and executes moves immediately. We had an intermediate `_pushWideBox()` wrapper that wasn't needed. **This was the bug!** We should call BFS directly.

### 3. **State Management**
Kotlin tracks `place` as a simple variable. We track `robotPos` as a tuple. Both work, but Kotlin's approach is more concise.

### 4. **The Critical Fix**
The key difference that fixed our bug:
- **Before**: We had `_canPushWideBox()` check + `_pushWideBox()` wrapper
- **After**: Direct call to `_findBoxesToPushBFS()` matching Kotlin's `push()` call
- **Result**: Now works correctly!

### 5. **BFS Algorithm is Identical**
The core BFS logic is the same in both implementations:
- Queue-based traversal
- Seen set for cycle detection
- Special handling for vertical movement (queue other half)
- Reverse result for furthest-first execution

## Remaining Differences

### Still Different (But Working)
1. **Part 1 vs Part 2 separation**: We have separate functions, Kotlin uses one
2. **Helper functions**: We have more utility functions (`_isBoxPart`, `_isValidPosition`, etc.)
3. **Error handling**: We check bounds explicitly, Kotlin may rely on grid boundaries

### Why Our Approach Works
- More explicit bounds checking (safer)
- More modular code (easier to test individual pieces)
- Clear separation of concerns

### Why Kotlin's Approach Works
- Simpler, less code
- Leverages language features (extensions, when expressions)
- Single source of truth for movement logic

## Conclusion

The implementations are functionally equivalent now. The key fix was removing the intermediate wrapper and calling BFS directly, matching Kotlin's approach. Our Dart implementation is more verbose but also more explicit and safer (bounds checking). Both are correct!

