import '../../core/solver.dart';

/// Day 19: Linen Layout
///
/// This puzzle teaches dynamic programming for string matching:
///
/// **Part 1: Check if Designs Can Be Formed**
/// - Given a set of towel patterns and desired designs
/// - Check if each design can be formed by concatenating available patterns
/// - Count how many designs are possible
///
/// **Part 2: Count Ways to Form Designs**
/// - For each design, count the number of different ways it can be formed
/// - Sum up all the counts across all designs
///
/// **Key Algorithm: Dynamic Programming (Word Break Pattern)**
/// - Part 1: dp[i] = true if design[0..i-1] can be formed
/// - Part 2: dp[i] = number of ways to form design[0..i-1]
/// - Base case: dp[0] = 1 (one way to form empty string)
/// - For each position i from 1 to design.length:
///   - For each pattern:
///     - If pattern matches design[i-pattern.length..i-1]:
///       - Part 1: dp[i] = true (if dp[i-pattern.length] is true)
///       - Part 2: dp[i] += dp[i-pattern.length] (sum all ways)
/// - Return dp[design.length]
///
/// **Key Patterns for Future Puzzles:**
/// - Dynamic programming for string matching
/// - Word break problem pattern
/// - Bottom-up DP with boolean array (Part 1) or integer counting (Part 2)
/// - Pattern matching with substring checks
/// - Counting paths/ways in DP (Part 2)
class Year2024Day19 extends DaySolver {
  @override
  int get year => 2024;

  @override
  int get day => 19;

  @override
  String solvePart1(List<String> input) {
    return _solvePart1(input);
  }

  @override
  String solvePart2(List<String> input) {
    return _solvePart2(input);
  }

  /// Parses input to extract patterns and designs.
  ///
  /// Input format:
  /// - First line: comma-separated patterns (e.g., "r, wr, b, g")
  /// - Blank line (filtered out by InputLoader)
  /// - Remaining lines: designs (one per line)
  ///
  /// Note: InputLoader filters out blank lines by default, so we assume:
  /// - First line = patterns
  /// - All other lines = designs
  ///
  /// Returns a record with patterns list and designs list.
  ({List<String> patterns, List<String> designs}) _parseInput(List<String> input) {
    if (input.isEmpty) {
      return (patterns: [], designs: []);
    }
    // First line contains patterns (comma-separated)
    final firstLine = input[0].trim();
    final patterns = firstLine.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    // All remaining lines are designs
    final designs = input.skip(1).map((line) => line.trim()).where((line) => line.isNotEmpty).toList();
    return (patterns: patterns, designs: designs);
  }

  /// Checks if a design can be formed by concatenating patterns.
  ///
  /// Uses dynamic programming:
  /// - dp[i] = true if design[0..i-1] can be formed
  /// - Base case: dp[0] = true (empty string)
  /// - For each position i, check if any pattern matches ending at i
  ///
  /// Time complexity: O(n * m * k) where:
  /// - n = design length
  /// - m = number of patterns
  /// - k = average pattern length
  /// Space complexity: O(n) for dp array
  bool _canFormDesign(String design, List<String> patterns) {
    if (design.isEmpty) {
      return true;
    }
    // dp[i] = true if design[0..i-1] can be formed
    final dp = List<bool>.filled(design.length + 1, false);
    dp[0] = true; // Empty string can always be formed
    for (var i = 1; i <= design.length; i++) {
      for (final pattern in patterns) {
        if (pattern.length <= i) {
          // Check if pattern matches ending at position i
          final start = i - pattern.length;
          if (design.substring(start, i) == pattern && dp[start]) {
            dp[i] = true;
            break; // Found a match, no need to check other patterns
          }
        }
      }
    }
    return dp[design.length];
  }

  /// Part 1: Count how many designs can be formed from available patterns.
  ///
  /// Algorithm:
  /// 1. Parse input to extract patterns and designs
  /// 2. For each design, check if it can be formed using DP
  /// 3. Count how many designs are possible
  ///
  /// Time complexity: O(D * N * M * K) where:
  /// - D = number of designs
  /// - N = average design length
  /// - M = number of patterns
  /// - K = average pattern length
  String _solvePart1(List<String> input) {
    if (input.isEmpty) {
      return '0';
    }
    final parsed = _parseInput(input);
    var count = 0;
    for (final design in parsed.designs) {
      if (_canFormDesign(design, parsed.patterns)) {
        count++;
      }
    }
    return count.toString();
  }

  /// Counts the number of ways a design can be formed by concatenating patterns.
  ///
  /// Uses dynamic programming to count all possible ways:
  /// - dp[i] = number of ways to form design[0..i-1]
  /// - Base case: dp[0] = 1 (one way to form empty string)
  /// - For each position i, sum up ways from all matching patterns
  ///
  /// Time complexity: O(n * m * k) where:
  /// - n = design length
  /// - m = number of patterns
  /// - k = average pattern length
  /// Space complexity: O(n) for dp array
  int _countWaysToFormDesign(String design, List<String> patterns) {
    if (design.isEmpty) {
      return 1;
    }
    // dp[i] = number of ways to form design[0..i-1]
    final dp = List<int>.filled(design.length + 1, 0);
    dp[0] = 1; // One way to form empty string
    for (var i = 1; i <= design.length; i++) {
      for (final pattern in patterns) {
        if (pattern.length <= i) {
          // Check if pattern matches ending at position i
          final start = i - pattern.length;
          if (design.substring(start, i) == pattern) {
            // Add all ways to form the prefix
            dp[i] += dp[start];
          }
        }
      }
    }
    return dp[design.length];
  }

  /// Part 2: Count total number of ways all designs can be formed.
  ///
  /// Algorithm:
  /// 1. Parse input to extract patterns and designs
  /// 2. For each design, count number of ways it can be formed using DP
  /// 3. Sum up all the counts
  ///
  /// Time complexity: O(D * N * M * K) where:
  /// - D = number of designs
  /// - N = average design length
  /// - M = number of patterns
  /// - K = average pattern length
  String _solvePart2(List<String> input) {
    if (input.isEmpty) {
      return '0';
    }
    final parsed = _parseInput(input);
    var totalWays = 0;
    for (final design in parsed.designs) {
      totalWays += _countWaysToFormDesign(design, parsed.patterns);
    }
    return totalWays.toString();
  }
}
