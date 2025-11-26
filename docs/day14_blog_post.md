# Solving Advent of Code Day 14: Robot Simulation and Pattern Detection

## The Problem: Restroom Redoubt

You're trying to help The Historians reach a bathroom, but the area is swarming with robots! Fortunately, these robots move in predictable straight lines. Your task is to predict where they'll be and find the safest path.

**Part 1** asks: After 100 seconds, what's the safety factor? (The product of robot counts in each quadrant)

**Part 2** asks: When do the robots arrange themselves into a Christmas tree pattern? (Find the fewest number of seconds)

The twist: Robots wrap around the edges when they hit boundaries—they teleport to the opposite side!

## Understanding the Setup

Each robot has:
- A **position** `p=x,y` (distance from left wall and top wall)
- A **velocity** `v=vx,vy` (tiles per second in x and y directions)

The space is:
- **Example**: 11 tiles wide × 7 tiles tall
- **Real input**: 101 tiles wide × 103 tiles tall

Robots move one tile per second according to their velocity. When they hit an edge, they wrap around using modulo arithmetic.

## Part 1: Quadrant Counting After 100 Seconds

Let's start with Part 1, which requires simulating robot movement and counting by quadrants:

```dart
String _solvePart1(List<String> input) {
  final isExample = input.length <= 12;
  final width = isExample ? 11 : 101;
  final height = isExample ? 7 : 103;
  const seconds = 100;
  
  // Parse all robots
  final robots = <({int x, int y, int vx, int vy})>[];
  for (final line in input) {
    if (line.trim().isEmpty) continue;
    final robot = _parseRobot(line);
    if (robot != null) robots.add(robot);
  }
  
  // Calculate positions after 100 seconds
  final positions = robots.map((robot) {
    return _calculatePosition(
      robot.x, robot.y, robot.vx, robot.vy,
      seconds, width, height,
    );
  }).toList();
  
  // Count robots in each quadrant
  final quadrants = _countQuadrants(positions, width, height);
  
  // Safety factor = product of quadrant counts
  return (quadrants.topLeft * quadrants.topRight * 
          quadrants.bottomLeft * quadrants.bottomRight).toString();
}
```

### Parsing Robot Data

We use regex to parse each robot's position and velocity:

```dart
({int x, int y, int vx, int vy})? _parseRobot(String line) {
  final pattern = RegExp(r'p=(-?\d+),(-?\d+) v=(-?\d+),(-?\d+)');
  final match = pattern.firstMatch(line.trim());
  if (match == null) return null;
  
  return (
    x: int.parse(match.group(1)!),
    y: int.parse(match.group(2)!),
    vx: int.parse(match.group(3)!),
    vy: int.parse(match.group(4)!),
  );
}
```

**Dart feature**: Record types `({int x, int y, int vx, int vy})` provide a lightweight way to return multiple values without creating a full class.

### Wrapping Arithmetic

The key challenge is handling edge wrapping. We use modulo arithmetic:

```dart
({int x, int y}) _calculatePosition(
  int x, int y, int vx, int vy, int t, int width, int height,
) {
  var newX = (x + vx * t) % width;
  var newY = (y + vy * t) % height;
  
  // Handle negative modulo results
  if (newX < 0) newX += width;
  if (newY < 0) newY += height;
  
  return (x: newX, y: newY);
}
```

**Why this works:**
- `(x + vx * t) % width` gives us the position after t seconds
- In Dart (and most languages), `-5 % 3` returns `-2`, not `1`
- We add the modulus to get a positive result: `-2 + 3 = 1`

**Example**: If a robot starts at `x=2` with `vx=2` in a width-11 space:
- After 1 second: `(2 + 2*1) % 11 = 4`
- After 5 seconds: `(2 + 2*5) % 11 = 12 % 11 = 1`
- After 6 seconds: `(2 + 2*6) % 11 = 14 % 11 = 3`

### Quadrant Counting

Robots exactly on the middle line (horizontally or vertically) don't count in any quadrant:

```dart
({int topLeft, int topRight, int bottomLeft, int bottomRight})
    _countQuadrants(List<({int x, int y})> positions, int width, int height) {
  final midX = width ~/ 2;
  final midY = height ~/ 2;
  var topLeft = 0, topRight = 0, bottomLeft = 0, bottomRight = 0;
  
  for (final pos in positions) {
    // Skip robots exactly on the middle
    if (pos.x == midX || pos.y == midY) continue;
    
    if (pos.x < midX && pos.y < midY) topLeft++;
    else if (pos.x > midX && pos.y < midY) topRight++;
    else if (pos.x < midX && pos.y > midY) bottomLeft++;
    else if (pos.x > midX && pos.y > midY) bottomRight++;
  }
  
  return (topLeft: topLeft, topRight: topRight, 
          bottomLeft: bottomLeft, bottomRight: bottomRight);
}
```

**Dart feature**: The `~/` operator performs integer division, perfect for finding the middle index.

## Part 2: Finding the Christmas Tree Pattern

Part 2 is more interesting: we need to find when robots form a recognizable Christmas tree pattern. The key insight is that when robots form a pattern, they're **most clustered together**.

### The Clustering Approach

Instead of trying to recognize a Christmas tree shape programmatically (which is complex), we use a **clustering metric**: the sum of squared distances from the centroid.

```dart
double _calculateClusteringScore(List<({int x, int y})> positions) {
  if (positions.isEmpty) return double.infinity;
  
  // Calculate centroid (average position)
  var sumX = 0.0, sumY = 0.0;
  for (final pos in positions) {
    sumX += pos.x;
    sumY += pos.y;
  }
  final centroidX = sumX / positions.length;
  final centroidY = sumY / positions.length;
  
  // Sum of squared distances from centroid
  var sumSquaredDistances = 0.0;
  for (final pos in positions) {
    final dx = pos.x - centroidX;
    final dy = pos.y - centroidY;
    sumSquaredDistances += dx * dx + dy * dy;
  }
  
  return sumSquaredDistances;
}
```

**Why this works:**
- When robots are spread out randomly, distances from centroid are large → high score
- When robots form a pattern (like a Christmas tree), they cluster together → low score
- The second with the **minimum clustering score** is when the pattern appears!

### Finding the Optimal Second

We search through time steps to find the minimum clustering score:

```dart
String _solvePart2(List<String> input) {
  final isExample = input.length <= 12;
  final width = isExample ? 11 : 101;
  final height = isExample ? 7 : 103;
  
  // Parse robots (same as Part 1)
  final robots = <({int x, int y, int vx, int vy})>[];
  for (final line in input) {
    if (line.trim().isEmpty) continue;
    final robot = _parseRobot(line);
    if (robot != null) robots.add(robot);
  }
  
  // Find the second with minimum clustering score
  const maxSeconds = 20000;
  var bestSecond = 0;
  var bestScore = double.infinity;
  
  for (var t = 0; t < maxSeconds; t++) {
    final positions = _getPositionsAtTime(robots, t, width, height);
    final score = _calculateClusteringScore(positions);
    if (score < bestScore) {
      bestScore = score;
      bestSecond = t;
    }
  }
  
  return bestSecond.toString();
}
```

**Algorithm:**
1. For each second from 0 to 20,000:
   - Calculate all robot positions at that time
   - Compute clustering score
   - Track the minimum score and its corresponding second
2. Return the second with minimum clustering score

## Complexity Analysis

**Part 1:**
- Time: O(n) where n is the number of robots
- Space: O(n) for storing positions

**Part 2:**
- Time: O(n × t) where n is robots and t is max seconds to check
- Space: O(n) for storing positions

For 500 robots checking 20,000 seconds, this is about 10 million operations—very manageable in modern Dart!

## Key Insights

1. **Modulo arithmetic** handles wrapping elegantly—just need to handle negative results
2. **Clustering metrics** can detect patterns without complex shape recognition
3. **Simulation problems** often benefit from checking multiple time steps
4. **Record types** in Dart provide clean, lightweight data structures

## Real-World Applications

- **Game development**: Predicting object positions with wrapping boundaries
- **Physics simulation**: Modeling particles in periodic spaces
- **Pattern recognition**: Using clustering to detect formations
- **Robotics**: Path planning with boundary constraints

## Dart Language Features Used

- **Record types**: `({int x, int y})` for lightweight data structures
- **Regex parsing**: `RegExp` with named groups for input parsing
- **List methods**: `map()`, `toList()` for functional transformations
- **Integer division**: `~/` operator for finding midpoints
- **Null safety**: `!` operator and null checks for safe parsing

## Full Solution

The complete solution can be found in `lib/years/year2024/day14.dart`. Key functions:

- `_parseRobot()`: Parses robot data from input lines
- `_calculatePosition()`: Computes position after t seconds with wrapping
- `_countQuadrants()`: Counts robots in each quadrant
- `_calculateClusteringScore()`: Computes clustering metric for pattern detection
- `_solvePart1()`: Part 1 solution
- `_solvePart2()`: Part 2 solution

This puzzle demonstrates how mathematical concepts (modulo arithmetic, clustering) can solve seemingly complex problems elegantly!

