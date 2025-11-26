import '../../core/solver.dart';

/// Solver for Advent of Code 2024 Day 7: Bridge Repair.
///
/// This puzzle involves determining which calibration equations can be made true
/// by inserting operators between numbers. Operators are evaluated left-to-right
/// without operator precedence.
class Year2024Day07 extends DaySolver {
  @override
  int get year => 2024;

  @override
  int get day => 7;

  @override
  String solvePart1(List<String> input) {
    return _solvePart1(input);
  }

  @override
  String solvePart2(List<String> input) {
    return _solvePart2(input);
  }

  /// Part 1: Determine which equations can be made true by inserting
  /// + and * operators between numbers (evaluated left-to-right).
  /// Returns the sum of test values from equations that can be made true.
  ///
  /// Input format: Each line is "target: num1 num2 num3 ..."
  /// Example: "190: 10 19" means can we make 10 ? 19 = 190 (answer: 10 * 19)
  ///
  /// Algorithm: Brute-force enumeration with binary encoding.
  /// - For n numbers, there are n-1 operator positions
  /// - With 2 operators (+ and *), there are 2^(n-1) combinations
  /// - Use bit manipulation: each bit position represents one operator choice
  ///   - Bit 0 = addition (+)
  ///   - Bit 1 = multiplication (*)
  /// - Evaluate each combination left-to-right without operator precedence
  /// - If any combination equals the target value, include it in the sum
  ///
  /// Performance Optimizations:
  /// - Early pruning: skip branches where intermediate result exceeds target
  ///
  /// Computer Science Concepts:
  /// - Brute-force search / exhaustive enumeration
  /// - Bit manipulation for generating combinations
  /// - Left-to-right evaluation (no operator precedence)
  /// - Branch pruning optimization
  String _solvePart1(List<String> input) {
    var totalCalibration = 0;
    for (final line in input) {
      if (line.trim().isEmpty) continue;
      // Parse "target: num1 num2 ..." format
      final parts = line.split(':');
      if (parts.length != 2) continue;
      final target = int.tryParse(parts[0].trim());
      if (target == null) continue;
      // Extract numbers from the right side of the colon
      final numbersStr = parts[1].trim().split(RegExp(r'\s+'));
      final numbers =
          numbersStr.map((s) => int.tryParse(s)).whereType<int>().toList();
      if (numbers.isEmpty) continue;
      // Check if this equation can be made true
      if (_canMakeTarget(numbers, target)) {
        totalCalibration += target;
      }
    }
    return totalCalibration.toString();
  }

  /// Checks if the target value can be achieved by inserting + and * operators
  /// between the numbers, evaluating left-to-right.
  ///
  /// Uses binary encoding where bit j=0 means addition, bit j=1 means multiplication.
  /// For example, with numbers [a, b, c]:
  /// - i=0 (binary 00): a + b + c
  /// - i=1 (binary 01): a + b * c
  /// - i=2 (binary 10): a * b + c
  /// - i=3 (binary 11): a * b * c
  ///
  /// Optimized with early pruning: if intermediate result exceeds target,
  /// skip that branch since all operations (+ and *) only increase the value.
  ///
  /// Returns true if any operator combination produces the target value.
  bool _canMakeTarget(List<int> numbers, int target) {
    // Edge case: single number must equal target
    if (numbers.length == 1) {
      return numbers[0] == target;
    }
    final operatorCount = numbers.length - 1;
    final totalCombinations = 1 << operatorCount; // 2^(n-1)
    // Try all operator combinations
    for (var i = 0; i < totalCombinations; i++) {
      var result = numbers[0];
      var canPrune = false;
      // Evaluate left-to-right
      for (var j = 0; j < operatorCount; j++) {
        final useMultiply = (i >> j) & 1 == 1;
        if (useMultiply) {
          result *= numbers[j + 1];
        } else {
          result += numbers[j + 1];
        }
        // Early pruning: if we exceed target, this branch can't succeed
        if (result > target) {
          canPrune = true;
          break;
        }
      }
      if (!canPrune && result == target) {
        return true;
      }
    }
    return false;
  }

  /// Part 2: Determine which equations can be made true by inserting
  /// +, *, and || (concatenation) operators between numbers (evaluated left-to-right).
  /// Returns the sum of test values from equations that can be made true.
  ///
  /// Input format: Same as Part 1 - "target: num1 num2 num3 ..."
  /// Now includes concatenation operator: 12 || 345 = 12345
  ///
  /// Algorithm: Brute-force enumeration with base-3 encoding.
  /// - For n numbers, there are n-1 operator positions
  /// - With 3 operators (+, *, ||), there are 3^(n-1) combinations
  /// - Use base-3 digit extraction: each digit position represents one operator choice
  ///   - 0 = addition (+)
  ///   - 1 = multiplication (*)
  ///   - 2 = concatenation (||)
  /// - Concatenation combines digits: 12 || 345 = 12345
  /// - Evaluate each combination left-to-right without operator precedence
  ///
  /// Performance Optimizations:
  /// - Early pruning: skip branches where intermediate result exceeds target
  /// - Batch digit extraction: extract all base-3 digits at once to avoid repeated divisions
  ///
  /// Computer Science Concepts:
  /// - Brute-force search / exhaustive enumeration
  /// - Base-n number system encoding for multi-way choices
  /// - String concatenation and parsing for digit combination
  /// - Left-to-right evaluation (no operator precedence)
  /// - Branch pruning optimization
  String _solvePart2(List<String> input) {
    var totalCalibration = 0;
    for (final line in input) {
      if (line.trim().isEmpty) continue;
      // Parse "target: num1 num2 ..." format
      final parts = line.split(':');
      if (parts.length != 2) continue;
      final target = int.tryParse(parts[0].trim());
      if (target == null) continue;
      // Extract numbers from the right side of the colon
      final numbersStr = parts[1].trim().split(RegExp(r'\s+'));
      final numbers =
          numbersStr.map((s) => int.tryParse(s)).whereType<int>().toList();
      if (numbers.isEmpty) continue;
      // Check if this equation can be made true with concatenation
      if (_canMakeTargetWithConcatenation(numbers, target)) {
        totalCalibration += target;
      }
    }
    return totalCalibration.toString();
  }

  /// Checks if the target value can be achieved by inserting +, *, and ||
  /// operators between the numbers, evaluating left-to-right.
  ///
  /// Uses base-3 encoding: 0=+, 1=*, 2=||
  /// For example, with numbers [a, b, c]:
  /// - i=0 (base-3 00): a + b + c
  /// - i=1 (base-3 01): a + b * c
  /// - i=2 (base-3 02): a + b || c
  /// - i=3 (base-3 10): a * b + c
  /// - etc.
  ///
  /// Optimizations:
  /// - Early pruning: if intermediate result exceeds target, skip that branch
  ///   (all operations +, *, and || only increase the value)
  /// - Batch digit extraction: extract all base-3 digits at once to avoid
  ///   repeated divisions when checking each operator position
  ///
  /// Returns true if any operator combination produces the target value.
  bool _canMakeTargetWithConcatenation(List<int> numbers, int target) {
    // Edge case: single number must equal target
    if (numbers.length == 1) {
      return numbers[0] == target;
    }
    final operatorCount = numbers.length - 1;
    final totalCombinations = _pow(3, operatorCount); // 3^(n-1)
    // Reusable list to store extracted base-3 digits
    final operators = List<int>.filled(operatorCount, 0);
    // Try all operator combinations
    for (var i = 0; i < totalCombinations; i++) {
      // Extract all base-3 digits at once (optimization)
      _extractBase3Digits(i, operators);
      var result = numbers[0];
      var canPrune = false;
      // Evaluate left-to-right
      for (var j = 0; j < operatorCount; j++) {
        final operatorType = operators[j];
        if (operatorType == 0) {
          result += numbers[j + 1];
        } else if (operatorType == 1) {
          result *= numbers[j + 1];
        } else {
          // operatorType == 2: concatenation
          result = _concatenate(result, numbers[j + 1]);
        }
        // Early pruning: if we exceed target, this branch can't succeed
        if (result > target) {
          canPrune = true;
          break;
        }
      }
      if (!canPrune && result == target) {
        return true;
      }
    }
    return false;
  }

  /// Extracts all base-3 digits from a number into the provided list.
  ///
  /// Fills operators list with digits from least significant to most significant.
  /// For example, if number=16 (which is 121 in base-3), operators[0]=1, operators[1]=2, operators[2]=1.
  ///
  /// Optimized: extracts all digits in a single pass, avoiding repeated divisions
  /// that would occur if we called a per-digit extraction function multiple times.
  ///
  /// [number] - The number to extract digits from (in base 10)
  /// [operators] - Output list that will be filled with base-3 digits (must be pre-allocated)
  void _extractBase3Digits(int number, List<int> operators) {
    var n = number;
    for (var i = 0; i < operators.length; i++) {
      operators[i] = n % 3; // Extract least significant digit
      n ~/= 3; // Shift right by one base-3 digit
    }
  }

  /// Calculates base^exponent for integers.
  ///
  /// Simple iterative implementation suitable for small exponents.
  /// Used to calculate 3^(n-1) for determining total operator combinations.
  ///
  /// [base] - The base number (typically 3)
  /// [exponent] - The exponent (typically number of operator positions)
  /// Returns base raised to the power of exponent
  int _pow(int base, int exponent) {
    var result = 1;
    for (var i = 0; i < exponent; i++) {
      result *= base;
    }
    return result;
  }

  /// Concatenates two numbers by combining their digits.
  ///
  /// The concatenation operator (||) combines digits from left and right inputs.
  /// Examples:
  /// - concatenate(12, 345) = 12345
  /// - concatenate(15, 6) = 156
  /// - concatenate(6, 8) = 68
  ///
  /// Implementation: Converts both numbers to strings, concatenates them,
  /// then parses back to integer. This is efficient in Dart.
  ///
  /// [a] - Left number
  /// [b] - Right number
  /// Returns the concatenated number
  int _concatenate(int a, int b) {
    return int.parse('$a$b');
  }
}
