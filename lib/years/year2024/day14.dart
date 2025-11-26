import '../../core/solver.dart';

/// Day 14: Restroom Redoubt
///
/// This puzzle teaches simulation with wrapping boundaries and pattern detection:
///
/// **Part 1: Robot Movement Simulation**
/// - Robots move in straight lines with constant velocity
/// - When robots hit an edge, they wrap around (teleport to opposite side)
/// - After 100 seconds, count robots in each quadrant
/// - Quadrants are divided by the middle (horizontally and vertically)
/// - Robots exactly on the middle don't count in any quadrant
/// - Safety factor = product of quadrant counts
///
/// **Part 2: Christmas Tree Pattern Detection**
/// - Robots occasionally arrange themselves into a Christmas tree pattern
/// - Find the fewest number of seconds when this pattern appears
/// - Pattern occurs when robots are most clustered together
/// - Use clustering score (sum of squared distances from centroid) to detect pattern
/// - The second with minimum clustering score is when the pattern forms
///
/// **Key Algorithm: Wrapping Arithmetic**
/// - Position after t seconds: (x + vx*t) mod width, (y + vy*t) mod height
/// - Use modulo arithmetic to handle wrapping
/// - For negative results, add the modulus to get positive result
///
/// **Key Algorithm: Clustering Detection**
/// - Calculate centroid of all robot positions
/// - Sum squared distances from centroid (lower = more clustered)
/// - Find time step with minimum clustering score
/// - This indicates when robots form a recognizable pattern
///
/// **Key Patterns for Future Puzzles:**
/// - Parsing structured input with regex patterns
/// - Simulation with wrapping boundaries
/// - Modulo arithmetic for periodic behavior
/// - Grid quadrant analysis
/// - Pattern detection using clustering metrics
/// - Finding optimal time steps in simulations
class Year2024Day14 extends DaySolver {
  @override
  int get year => 2024;

  @override
  int get day => 14;

  @override
  String solvePart1(List<String> input) {
    return _solvePart1(input);
  }

  @override
  String solvePart2(List<String> input) {
    return _solvePart2(input);
  }

  /// Parses a robot from a line of input.
  ///
  /// Expected format: p=x,y v=vx,vy
  /// Returns a record with position and velocity, or null if parsing fails.
  ({int x, int y, int vx, int vy})? _parseRobot(String line) {
    final pattern = RegExp(r'p=(-?\d+),(-?\d+) v=(-?\d+),(-?\d+)');
    final match = pattern.firstMatch(line.trim());
    if (match == null) {
      return null;
    }
    return (
      x: int.parse(match.group(1)!),
      y: int.parse(match.group(2)!),
      vx: int.parse(match.group(3)!),
      vy: int.parse(match.group(4)!),
    );
  }

  /// Calculates the position of a robot after t seconds with wrapping.
  ///
  /// Uses modulo arithmetic to handle wrapping at boundaries.
  /// For negative results, adds the modulus to get a positive result.
  ({int x, int y}) _calculatePosition(
    int x,
    int y,
    int vx,
    int vy,
    int t,
    int width,
    int height,
  ) {
    var newX = (x + vx * t) % width;
    var newY = (y + vy * t) % height;
    // Handle negative modulo results
    if (newX < 0) {
      newX += width;
    }
    if (newY < 0) {
      newY += height;
    }
    return (x: newX, y: newY);
  }

  /// Counts robots in each quadrant after simulation.
  ///
  /// Quadrants are divided by the middle (horizontally and vertically).
  /// Robots exactly on the middle don't count in any quadrant.
  ///
  /// Returns a record with counts for each quadrant:
  /// - topLeft: x < width/2, y < height/2
  /// - topRight: x > width/2, y < height/2
  /// - bottomLeft: x < width/2, y > height/2
  /// - bottomRight: x > width/2, y > height/2
  ({int topLeft, int topRight, int bottomLeft, int bottomRight})
      _countQuadrants(
    List<({int x, int y})> positions,
    int width,
    int height,
  ) {
    final midX = width ~/ 2;
    final midY = height ~/ 2;
    var topLeft = 0;
    var topRight = 0;
    var bottomLeft = 0;
    var bottomRight = 0;
    for (final pos in positions) {
      // Skip robots exactly on the middle (horizontally or vertically)
      if (pos.x == midX || pos.y == midY) {
        continue;
      }
      if (pos.x < midX && pos.y < midY) {
        topLeft++;
      } else if (pos.x > midX && pos.y < midY) {
        topRight++;
      } else if (pos.x < midX && pos.y > midY) {
        bottomLeft++;
      } else if (pos.x > midX && pos.y > midY) {
        bottomRight++;
      }
    }
    return (
      topLeft: topLeft,
      topRight: topRight,
      bottomLeft: bottomLeft,
      bottomRight: bottomRight,
    );
  }

  /// Part 1: Calculate safety factor after 100 seconds.
  ///
  /// Algorithm:
  /// 1. Parse all robots from input
  /// 2. Calculate position of each robot after 100 seconds (with wrapping)
  /// 3. Count robots in each quadrant (excluding middle)
  /// 4. Return product of quadrant counts
  ///
  /// For the example: space is 11x7
  /// For the real input: space is 101x103
  ///
  /// Time complexity: O(n) where n is number of robots
  /// Space complexity: O(n)
  String _solvePart1(List<String> input) {
    // Determine space dimensions from input
    // Example uses 11x7, real input uses 101x103
    final isExample = input.length <= 12;
    final width = isExample ? 11 : 101;
    final height = isExample ? 7 : 103;
    const seconds = 100;
    // Parse all robots
    final robots = <({int x, int y, int vx, int vy})>[];
    for (final line in input) {
      if (line.trim().isEmpty) {
        continue;
      }
      final robot = _parseRobot(line);
      if (robot != null) {
        robots.add(robot);
      }
    }
    // Calculate positions after 100 seconds
    final positions = robots.map((robot) {
      return _calculatePosition(
        robot.x,
        robot.y,
        robot.vx,
        robot.vy,
        seconds,
        width,
        height,
      );
    }).toList();
    // Count robots in each quadrant
    final quadrants = _countQuadrants(positions, width, height);
    // Calculate safety factor (product of quadrant counts)
    final safetyFactor = quadrants.topLeft *
        quadrants.topRight *
        quadrants.bottomLeft *
        quadrants.bottomRight;
    return safetyFactor.toString();
  }

  /// Calculates positions of all robots at a given time.
  List<({int x, int y})> _getPositionsAtTime(
    List<({int x, int y, int vx, int vy})> robots,
    int t,
    int width,
    int height,
  ) {
    return robots.map((robot) {
      return _calculatePosition(
        robot.x,
        robot.y,
        robot.vx,
        robot.vy,
        t,
        width,
        height,
      );
    }).toList();
  }

  /// Calculates a clustering score for robot positions.
  ///
  /// Lower score indicates better clustering (robots are closer together).
  /// Uses the sum of squared distances from the centroid as a measure.
  /// This is used to find when robots form a recognizable pattern like a Christmas tree.
  double _calculateClusteringScore(List<({int x, int y})> positions) {
    if (positions.isEmpty) {
      return double.infinity;
    }
    // Calculate centroid
    var sumX = 0.0;
    var sumY = 0.0;
    for (final pos in positions) {
      sumX += pos.x;
      sumY += pos.y;
    }
    final centroidX = sumX / positions.length;
    final centroidY = sumY / positions.length;
    // Calculate sum of squared distances from centroid
    var sumSquaredDistances = 0.0;
    for (final pos in positions) {
      final dx = pos.x - centroidX;
      final dy = pos.y - centroidY;
      sumSquaredDistances += dx * dx + dy * dy;
    }
    return sumSquaredDistances;
  }

  /// Part 2: Find the fewest number of seconds for robots to form a Christmas tree.
  ///
  /// Algorithm:
  /// 1. Parse all robots from input
  /// 2. For each second from 0 to a reasonable limit, simulate robot positions
  /// 3. Find the second where robots are most clustered (minimum clustering score)
  /// 4. Return that second
  ///
  /// The Christmas tree pattern occurs when robots are most clustered together.
  /// We find the second with the minimum clustering score (sum of squared distances from centroid).
  ///
  /// Time complexity: O(n * t) where n is number of robots, t is max seconds to check
  /// Space complexity: O(n)
  String _solvePart2(List<String> input) {
    // Determine space dimensions from input
    final isExample = input.length <= 12;
    final width = isExample ? 11 : 101;
    final height = isExample ? 7 : 103;
    // Parse all robots
    final robots = <({int x, int y, int vx, int vy})>[];
    for (final line in input) {
      if (line.trim().isEmpty) {
        continue;
      }
      final robot = _parseRobot(line);
      if (robot != null) {
        robots.add(robot);
      }
    }
    // Find the second where robots are most clustered
    // Try up to a reasonable limit (patterns typically form within first few thousand seconds)
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
}
