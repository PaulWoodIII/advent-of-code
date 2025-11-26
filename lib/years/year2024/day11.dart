import '../../core/solver.dart';

/// Day 11: Plutonian Pebbles
///
/// This puzzle teaches simulation and transformation rules with optimization:
///
/// **Part 1: Stone Transformation Simulation (25 blinks)**
/// - Simulating stones that transform according to specific rules each "blink"
/// - Rule 1: 0 -> 1
/// - Rule 2: Even-digit numbers split into two stones (left half, right half)
/// - Rule 3: Otherwise multiply by 2024
/// - Count stones after 25 blinks
///
/// **Part 2: Extended Simulation (75 blinks)**
/// - Same transformation rules as Part 1
/// - Count stones after 75 blinks
/// - Uses frequency counting optimization to handle exponential growth
///
/// **Optimization: Frequency Counting**
/// - Instead of tracking individual stones, track counts per unique value
/// - Example: [125, 17, 17, 17] becomes {125: 1, 17: 3}
/// - When transforming, transform each unique value once, multiply counts
/// - Prevents exponential memory growth while maintaining correctness
/// - Similar to Hashlife memoization: reuse computations for identical states
///
/// **Key Patterns for Future Puzzles:**
/// - Simulation problems with transformation rules
/// - String manipulation for digit splitting
/// - Frequency counting for exponential growth optimization
/// - Memoization patterns for repeated computations
class Year2024Day11 extends DaySolver {
  @override
  int get year => 2024;

  @override
  int get day => 11;

  @override
  String solvePart1(List<String> input) {
    return _solvePart1(input);
  }

  @override
  String solvePart2(List<String> input) {
    return _solvePart2(input);
  }

  /// Part 1: Count stones after 25 blinks.
  ///
  /// Each blink, stones transform simultaneously according to:
  /// 1. If stone is 0, replace with 1
  /// 2. If stone has even number of digits, split into two stones
  ///    (left half and right half, removing leading zeros)
  /// 3. Otherwise, multiply by 2024
  ///
  /// Algorithm:
  /// 1. Parse initial stones from input (space-separated numbers)
  /// 2. Simulate 25 blinks
  /// 3. Return count of final stones
  ///
  /// Time complexity: O(blinks * stones_per_iteration)
  /// Space complexity: O(stones_per_iteration) - can grow exponentially
  String _solvePart1(List<String> input) {
    return _simulateBlinks(input, 25);
  }

  /// Transforms a single stone according to the rules.
  ///
  /// Returns a list of stones (1 or 2) resulting from the transformation.
  /// Rule 1: 0 -> [1]
  /// Rule 2: Even-digit numbers -> [leftHalf, rightHalf]
  /// Rule 3: Otherwise -> [stone * 2024]
  List<int> _transformStone(int stone) {
    if (stone == 0) {
      return [1];
    }
    final digits = stone.toString();
    if (digits.length.isEven) {
      final halfLength = digits.length ~/ 2;
      final leftHalf = int.parse(digits.substring(0, halfLength));
      final rightHalf = int.parse(digits.substring(halfLength));
      return [leftHalf, rightHalf];
    }
    return [stone * 2024];
  }

  /// Part 2: Count stones after 75 blinks.
  ///
  /// Same transformation rules as Part 1, but extended to 75 blinks.
  /// The exponential growth makes this computationally intensive but
  /// the same simulation approach works.
  ///
  /// Algorithm:
  /// 1. Parse initial stones from input (space-separated numbers)
  /// 2. Simulate 75 blinks
  /// 3. Return count of final stones
  ///
  /// Time complexity: O(blinks * stones_per_iteration)
  /// Space complexity: O(stones_per_iteration) - can grow exponentially
  String _solvePart2(List<String> input) {
    return _simulateBlinks(input, 75);
  }

  /// Simulates stone transformations for a given number of blinks.
  ///
  /// Uses frequency counting optimization: tracks counts per unique stone value
  /// instead of maintaining individual stones. This prevents exponential memory
  /// growth while maintaining correctness.
  ///
  /// Each blink, stones transform simultaneously according to:
  /// 1. If stone is 0, replace with 1
  /// 2. If stone has even number of digits, split into two stones
  ///    (left half and right half, removing leading zeros)
  /// 3. Otherwise, multiply by 2024
  ///
  /// Algorithm:
  /// 1. Parse initial stones and count frequencies (Map<stoneValue, count>)
  /// 2. For each blink:
  ///    - Create new frequency map
  ///    - For each unique stone value and its count:
  ///      - Transform the stone value (produces 1 or 2 new values)
  ///      - Add transformed values to new map, multiplying by original count
  /// 3. Sum all counts in final frequency map
  ///
  /// [input] - Input lines containing space-separated initial stone numbers
  /// [blinks] - Number of blinks to simulate
  /// Returns the count of stones after all blinks
  ///
  /// Time complexity: O(blinks * unique_stone_values)
  /// Space complexity: O(unique_stone_values) - much better than O(total_stones)
  String _simulateBlinks(List<String> input, int blinks) {
    if (input.isEmpty || input[0].trim().isEmpty) {
      return '0';
    }
    // Parse initial stones and count frequencies
    final initialStones = input[0]
        .trim()
        .split(RegExp(r'\s+'))
        .map((s) => int.parse(s))
        .toList();
    var frequencies = <int, int>{};
    for (final stone in initialStones) {
      frequencies[stone] = (frequencies[stone] ?? 0) + 1;
    }
    // Simulate blinks using frequency counting
    for (var blink = 0; blink < blinks; blink++) {
      final newFrequencies = <int, int>{};
      for (final entry in frequencies.entries) {
        final stone = entry.key;
        final count = entry.value;
        final transformed = _transformStone(stone);
        for (final newStone in transformed) {
          newFrequencies[newStone] = (newFrequencies[newStone] ?? 0) + count;
        }
      }
      frequencies = newFrequencies;
    }
    // Sum all counts to get total stone count
    var totalCount = 0;
    for (final count in frequencies.values) {
      totalCount += count;
    }
    return totalCount.toString();
  }
}
