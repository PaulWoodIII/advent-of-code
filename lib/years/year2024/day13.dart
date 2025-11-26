import '../../core/solver.dart';

/// Day 13: Claw Contraption
///
/// This puzzle teaches solving systems of linear Diophantine equations:
///
/// **Part 1: Solving Linear Systems for Integer Solutions**
/// - Each machine has two buttons (A and B) that move the claw by specific amounts
/// - Button A costs 3 tokens, Button B costs 1 token
/// - Need to find non-negative integer solutions (x, y) where:
///   - a*x + b*y = target_x (X axis equation)
///   - c*x + d*y = target_y (Y axis equation)
/// - Where a = Button A X movement, b = Button B X movement
///   c = Button A Y movement, d = Button B Y movement
/// - Minimize cost = 3*x + 1*y for each winnable machine
/// - Sum costs for all winnable machines
///
/// **Key Algorithm: Solving Linear Diophantine Equations**
/// - Use elimination method to solve the system
/// - From first equation: x = (target_x - b*y) / a
/// - Substitute into second: c*(target_x - b*y)/a + d*y = target_y
/// - Rearrange: y*(d*a - c*b) = target_y*a - c*target_x
/// - So: y = (target_y*a - c*target_x) / (d*a - c*b)
/// - Then: x = (target_x - b*y) / a
/// - Check that x and y are non-negative integers
/// - Check that both equations are satisfied
///
/// **Part 2: Corrected Prize Coordinates**
/// - Due to unit conversion error, all prize coordinates are offset by 10000000000000
/// - Add this offset to X and Y coordinates before solving
/// - Same solving algorithm applies, but solutions may require many more button presses
/// - With large numbers, Dart's arbitrary-precision integers handle calculations correctly
///
/// **Key Patterns for Future Puzzles:**
/// - Parsing structured input with regex patterns
/// - Solving systems of linear equations
/// - Integer solution checking (Diophantine equations)
/// - Cost minimization problems
/// - Handling large integer arithmetic (arbitrary precision)
class Year2024Day13 extends DaySolver {
  @override
  int get year => 2024;

  @override
  int get day => 13;

  @override
  String solvePart1(List<String> input) {
    return _solvePart1(input);
  }

  @override
  String solvePart2(List<String> input) {
    return _solvePart2(input);
  }

  /// Parses a machine configuration from input lines.
  ///
  /// Expected format:
  /// Button A: X+94, Y+34
  /// Button B: X+22, Y+67
  /// Prize: X=8400, Y=5400
  ///
  /// Returns a record with button movements and prize location.
  ({int buttonAX, int buttonAY, int buttonBX, int buttonBY, int prizeX, int prizeY})?
      _parseMachine(List<String> lines, int startIndex) {
    if (startIndex + 2 >= lines.length) {
      return null;
    }
    final buttonALine = lines[startIndex].trim();
    final buttonBLine = lines[startIndex + 1].trim();
    final prizeLine = lines[startIndex + 2].trim();
    // Parse Button A: X+94, Y+34
    final buttonAPattern = RegExp(r'Button A: X\+(\d+), Y\+(\d+)');
    final buttonAMatch = buttonAPattern.firstMatch(buttonALine);
    if (buttonAMatch == null) {
      return null;
    }
    final buttonAX = int.parse(buttonAMatch.group(1)!);
    final buttonAY = int.parse(buttonAMatch.group(2)!);
    // Parse Button B: X+22, Y+67
    final buttonBPattern = RegExp(r'Button B: X\+(\d+), Y\+(\d+)');
    final buttonBMatch = buttonBPattern.firstMatch(buttonBLine);
    if (buttonBMatch == null) {
      return null;
    }
    final buttonBX = int.parse(buttonBMatch.group(1)!);
    final buttonBY = int.parse(buttonBMatch.group(2)!);
    // Parse Prize: X=8400, Y=5400
    final prizePattern = RegExp(r'Prize: X=(\d+), Y=(\d+)');
    final prizeMatch = prizePattern.firstMatch(prizeLine);
    if (prizeMatch == null) {
      return null;
    }
    final prizeX = int.parse(prizeMatch.group(1)!);
    final prizeY = int.parse(prizeMatch.group(2)!);
    return (
      buttonAX: buttonAX,
      buttonAY: buttonAY,
      buttonBX: buttonBX,
      buttonBY: buttonBY,
      prizeX: prizeX,
      prizeY: prizeY,
    );
  }

  /// Solves the system of linear equations to find button presses.
  ///
  /// System:
  /// - a*x + b*y = target_x
  /// - c*x + d*y = target_y
  ///
  /// Where:
  /// - a = buttonAX, b = buttonBX
  /// - c = buttonAY, d = buttonBY
  /// - target_x = prizeX, target_y = prizeY
  ///
  /// Returns (x, y) if solution exists and both are non-negative integers,
  /// null otherwise.
  ({int x, int y})? _solveSystem(
    int buttonAX,
    int buttonAY,
    int buttonBX,
    int buttonBY,
    int prizeX,
    int prizeY,
  ) {
    // Using elimination method:
    // From first equation: x = (prizeX - buttonBX*y) / buttonAX
    // Substitute into second: buttonAY*(prizeX - buttonBX*y)/buttonAX + buttonBY*y = prizeY
    // Multiply by buttonAX: buttonAY*prizeX - buttonAY*buttonBX*y + buttonBY*buttonAX*y = prizeY*buttonAX
    // Rearrange: y*(buttonBY*buttonAX - buttonAY*buttonBX) = prizeY*buttonAX - buttonAY*prizeX
    // So: y = (prizeY*buttonAX - buttonAY*prizeX) / (buttonBY*buttonAX - buttonAY*buttonBX)
    final denominator = buttonBY * buttonAX - buttonAY * buttonBX;
    if (denominator == 0) {
      // System is singular (no unique solution or no solution)
      return null;
    }
    final numeratorY = prizeY * buttonAX - buttonAY * prizeX;
    if (numeratorY % denominator != 0) {
      // y is not an integer
      return null;
    }
    final y = numeratorY ~/ denominator;
    if (y < 0) {
      return null;
    }
    // Now solve for x: x = (prizeX - buttonBX*y) / buttonAX
    final numeratorX = prizeX - buttonBX * y;
    if (numeratorX % buttonAX != 0) {
      // x is not an integer
      return null;
    }
    final x = numeratorX ~/ buttonAX;
    if (x < 0) {
      return null;
    }
    // Verify the solution satisfies both equations
    if (buttonAX * x + buttonBX * y != prizeX) {
      return null;
    }
    if (buttonAY * x + buttonBY * y != prizeY) {
      return null;
    }
    return (x: x, y: y);
  }

  /// Part 1: Find minimum tokens to win all possible prizes.
  ///
  /// For each machine, solve the system of equations to find the minimum
  /// cost solution (if one exists). Sum the costs for all winnable machines.
  ///
  /// Algorithm:
  /// 1. Parse each machine configuration from input
  /// 2. Solve the system of linear equations for each machine
  /// 3. If solution exists (non-negative integers), calculate cost = 3*x + 1*y
  /// 4. Sum costs for all winnable machines
  ///
  /// Time complexity: O(machines)
  /// Space complexity: O(1)
  String _solvePart1(List<String> input) {
    var totalCost = 0;
    var index = 0;
    while (index < input.length) {
      final machine = _parseMachine(input, index);
      if (machine == null) {
        index++;
        continue;
      }
      final solution = _solveSystem(
        machine.buttonAX,
        machine.buttonAY,
        machine.buttonBX,
        machine.buttonBY,
        machine.prizeX,
        machine.prizeY,
      );
      if (solution != null) {
        // Cost: 3 tokens per A press, 1 token per B press
        final cost = 3 * solution.x + solution.y;
        totalCost += cost;
      }
      // Move to next machine (skip blank line if present)
      index += 3;
      while (index < input.length && input[index].trim().isEmpty) {
        index++;
      }
    }
    return totalCost.toString();
  }

  /// Part 2: Find minimum tokens with corrected prize coordinates.
  ///
  /// Due to a unit conversion error, every prize's X and Y position is actually
  /// 10000000000000 higher than originally measured. Add this offset to all
  /// prize coordinates before solving.
  ///
  /// Algorithm:
  /// 1. Parse each machine configuration from input
  /// 2. Add 10000000000000 to both prize X and Y coordinates
  /// 3. Solve the system of linear equations for each machine
  /// 4. If solution exists (non-negative integers), calculate cost = 3*x + 1*y
  /// 5. Sum costs for all winnable machines
  ///
  /// Note: With the large offset, solutions may require many more button presses
  /// than the original 100-press estimate, but the same solving algorithm applies.
  ///
  /// Time complexity: O(machines)
  /// Space complexity: O(1)
  String _solvePart2(List<String> input) {
    const offset = 10000000000000;
    var totalCost = 0;
    var index = 0;
    while (index < input.length) {
      final machine = _parseMachine(input, index);
      if (machine == null) {
        index++;
        continue;
      }
      // Add offset to prize coordinates
      final correctedPrizeX = machine.prizeX + offset;
      final correctedPrizeY = machine.prizeY + offset;
      final solution = _solveSystem(
        machine.buttonAX,
        machine.buttonAY,
        machine.buttonBX,
        machine.buttonBY,
        correctedPrizeX,
        correctedPrizeY,
      );
      if (solution != null) {
        // Cost: 3 tokens per A press, 1 token per B press
        final cost = 3 * solution.x + solution.y;
        totalCost += cost;
      }
      // Move to next machine (skip blank line if present)
      index += 3;
      while (index < input.length && input[index].trim().isEmpty) {
        index++;
      }
    }
    return totalCost.toString();
  }
}
