# Solving Advent of Code Day 13: Claw Contraption - Linear Diophantine Equations

## The Problem: Arcade Claw Machines

You've discovered an arcade with unusual claw machines. Instead of a joystick, each machine has two buttons labeled A and B. Worse, you can't just play—it costs 3 tokens to press button A and 1 token to press button B.

Each button moves the claw by a specific amount:
- Button A: moves X+94 units right, Y+34 units forward
- Button B: moves X+22 units right, Y+67 units forward

To win a prize, the claw must be positioned exactly at the prize's location (X=8400, Y=5400). You need to find the minimum number of tokens to spend to win as many prizes as possible.

**Part 1** asks: What's the fewest tokens needed to win all possible prizes?

**Part 2** adds a twist: Due to a unit conversion error, every prize's position is actually 10,000,000,000,000 units higher on both axes. With this correction, what's the fewest tokens needed?

## Understanding the Problem

This is a classic **system of linear Diophantine equations** problem. For each machine, we need to find non-negative integers `x` (A presses) and `y` (B presses) such that:

```
a*x + b*y = target_x
c*x + d*y = target_y
```

Where:
- `a` = Button A X movement
- `b` = Button B X movement  
- `c` = Button A Y movement
- `d` = Button B Y movement
- `target_x` = Prize X coordinate
- `target_y` = Prize Y coordinate

And we want to minimize: `cost = 3*x + 1*y`

## Part 1: Solving Linear Systems

Let's start by understanding how to solve this system of equations.

### The Naive Approach (Why It Fails)

A naive approach might try all combinations of button presses:

```dart
// This would be too slow!
for (var x = 0; x < 100; x++) {
  for (var y = 0; y < 100; y++) {
    if (buttonAX * x + buttonBX * y == prizeX &&
        buttonAY * x + buttonBY * y == prizeY) {
      // Found solution!
    }
  }
}
```

But the puzzle hints that solutions might require more than 100 presses, and with large numbers in Part 2, brute force becomes impractical.

### The Mathematical Approach: Elimination Method

We can solve this system algebraically using the **elimination method**:

**Step 1:** Solve for `y` using elimination:
- From the first equation: `x = (target_x - b*y) / a`
- Substitute into the second equation: `c*(target_x - b*y)/a + d*y = target_y`
- Multiply by `a`: `c*target_x - c*b*y + d*a*y = target_y*a`
- Rearrange: `y*(d*a - c*b) = target_y*a - c*target_x`
- So: `y = (target_y*a - c*target_x) / (d*a - c*b)`

**Step 2:** Solve for `x`:
- `x = (target_x - b*y) / a`

**Step 3:** Check that both `x` and `y` are non-negative integers and satisfy both equations.

### Implementation

Here's how we implement this in Dart:

```dart
({int x, int y})? _solveSystem(
  int buttonAX,
  int buttonAY,
  int buttonBX,
  int buttonBY,
  int prizeX,
  int prizeY,
) {
  // Calculate denominator: d*a - c*b
  final denominator = buttonBY * buttonAX - buttonAY * buttonBX;
  
  // Check if system is singular (no unique solution)
  if (denominator == 0) {
    return null;
  }
  
  // Calculate numerator for y: target_y*a - c*target_x
  final numeratorY = prizeY * buttonAX - buttonAY * prizeX;
  
  // Check if y is an integer
  if (numeratorY % denominator != 0) {
    return null;
  }
  
  final y = numeratorY ~/ denominator;
  
  // Check if y is non-negative
  if (y < 0) {
    return null;
  }
  
  // Solve for x: x = (target_x - b*y) / a
  final numeratorX = prizeX - buttonBX * y;
  
  // Check if x is an integer
  if (numeratorX % buttonAX != 0) {
    return null;
  }
  
  final x = numeratorX ~/ buttonAX;
  
  // Check if x is non-negative
  if (x < 0) {
    return null;
  }
  
  // Verify solution satisfies both equations
  if (buttonAX * x + buttonBX * y != prizeX) {
    return null;
  }
  if (buttonAY * x + buttonBY * y != prizeY) {
    return null;
  }
  
  return (x: x, y: y);
}
```

### Parsing the Input

The input format is structured, so we use regex patterns to parse each machine:

```dart
({int buttonAX, int buttonAY, int buttonBX, int buttonBY, int prizeX, int prizeY})?
    _parseMachine(List<String> lines, int startIndex) {
  final buttonALine = lines[startIndex].trim();
  final buttonBLine = lines[startIndex + 1].trim();
  final prizeLine = lines[startIndex + 2].trim();
  
  // Parse Button A: X+94, Y+34
  final buttonAPattern = RegExp(r'Button A: X\+(\d+), Y\+(\d+)');
  final buttonAMatch = buttonAPattern.firstMatch(buttonALine);
  // ... similar parsing for Button B and Prize
  
  return (
    buttonAX: buttonAX,
    buttonAY: buttonAY,
    buttonBX: buttonBX,
    buttonBY: buttonBY,
    prizeX: prizeX,
    prizeY: prizeY,
  );
}
```

### Putting It All Together

For Part 1, we iterate through all machines, solve each system, and sum the costs:

```dart
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
```

## Part 2: Handling Large Numbers

Part 2 introduces a unit conversion error: every prize's position is actually 10,000,000,000,000 units higher. This means we need to add this offset before solving.

The good news: Dart's integers are **arbitrary precision**, so we don't need to worry about overflow! The same algorithm works perfectly:

```dart
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
      final cost = 3 * solution.x + solution.y;
      totalCost += cost;
    }
    
    index += 3;
    while (index < input.length && input[index].trim().isEmpty) {
      index++;
    }
  }
  
  return totalCost.toString();
}
```

## Key Insights

### 1. Diophantine Equations

This puzzle teaches **Diophantine equations**—equations where we seek integer solutions. The key insight is that not all systems have integer solutions, and we need to check:
- That the denominator divides the numerator (integer division)
- That both `x` and `y` are non-negative
- That the solution actually satisfies both equations

### 2. Arbitrary Precision Arithmetic

Dart's `int` type is arbitrary precision, meaning it can handle numbers of any size without overflow. This is crucial for Part 2, where numbers become very large (10 trillion + original values).

### 3. System Solving Techniques

The elimination method is a fundamental technique for solving systems of linear equations. Understanding this mathematical approach allows us to solve problems efficiently without brute force.

### 4. Verification is Important

Even after calculating `x` and `y`, we verify that they satisfy both original equations. This catches any rounding errors or edge cases.

## Complexity Analysis

- **Time Complexity:** O(machines) - We process each machine once, and solving each system is O(1)
- **Space Complexity:** O(1) - We only store a few variables regardless of input size

The algorithm is very efficient because we solve each system algebraically rather than searching through possibilities.

## Real-World Applications

Linear Diophantine equations appear in many real-world problems:
- **Resource allocation**: Finding integer combinations of resources to meet requirements
- **Scheduling**: Finding integer time slots that satisfy constraints
- **Cryptography**: Many cryptographic algorithms rely on Diophantine equations
- **Optimization**: Finding integer solutions to optimization problems

## Dart Language Features Used

1. **Records**: Used for structured return types `({int x, int y})` and machine configuration
2. **Regex Patterns**: `RegExp` for parsing structured input
3. **Arbitrary Precision Integers**: Dart's `int` handles large numbers seamlessly
4. **Integer Division**: `~/` operator for integer division
5. **Modulo Operator**: `%` for checking divisibility

## Conclusion

Day 13 teaches us to recognize when a problem can be solved mathematically rather than through brute force. By understanding linear Diophantine equations and the elimination method, we can solve this puzzle efficiently even with very large numbers.

The key takeaway: **Sometimes the best algorithm is the one that uses mathematics to avoid searching.**

## Full Solution Code

See the complete implementation in `lib/years/year2024/day13.dart`.

