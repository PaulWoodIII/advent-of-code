# Solving Advent of Code Day 17: Chronospatial Computer - Virtual Machine Interpreter and Backtracking

## The Problem: A 3-Bit Computer

The Historians' strange device unfolds into an entire computer! This is a 3-bit computer with three registers (A, B, C) that can hold any integer, and a program consisting of 3-bit numbers (0-7).

The computer has 8 instructions:
- **adv** (0): Divide A by 2^operand
- **bxl** (1): XOR B with literal operand
- **bst** (2): Set B to combo operand % 8
- **jnz** (3): Jump if A != 0
- **bxc** (4): XOR B with C
- **out** (5): Output combo operand % 8
- **bdv** (6): Set B to A / 2^operand
- **cdv** (7): Set C to A / 2^operand

**Part 1** asks: What does the program output when run with the given initial register values?

**Part 2** asks: What is the lowest positive initial value for register A that causes the program to output a copy of itself?

## Part 1: Building a Virtual Machine Interpreter

Part 1 is straightforward: we need to implement a virtual machine that executes the program instructions.

### Understanding Operand Types

Each instruction has an operand that can be one of two types:
- **Literal**: Operand value itself (0-3)
- **Combo**: Can be literal 0-3, or register A/B/C (4/5/6)

```dart
int _getComboValue(int operand, int a, int b, int c) {
  if (operand <= 3) {
    return operand;
  } else if (operand == 4) {
    return a;
  } else if (operand == 5) {
    return b;
  } else if (operand == 6) {
    return c;
  } else {
    throw ArgumentError('Reserved combo operand 7');
  }
}
```

### Implementing the VM

The key is to track:
- Three registers: A, B, C
- Instruction pointer (starts at 0, increments by 2 except for jumps)
- Output list (collects values from `out` instructions)

```dart
List<int> _executeProgram(List<int> program, int a, int b, int c) {
  var registerA = a;
  var registerB = b;
  var registerC = c;
  var instructionPointer = 0;
  final output = <int>[];
  
  while (instructionPointer < program.length) {
    final opcode = program[instructionPointer];
    final operand = program[instructionPointer + 1];
    var shouldIncrement = true;
    
    switch (opcode) {
      case 0: // adv
        final divisor = _getComboValue(operand, registerA, registerB, registerC);
        final power = 1 << divisor; // 2^divisor
        registerA = registerA ~/ power; // Integer division
        break;
      case 5: // out
        final value = _getComboValue(operand, registerA, registerB, registerC);
        output.add(value % 8);
        break;
      // ... other instructions
    }
    
    if (shouldIncrement) {
      instructionPointer += 2;
    }
  }
  
  return output;
}
```

## Part 2: The Challenge of Finding Self-Reproducing Programs

Part 2 is much more challenging. We need to find the lowest positive A value such that when we run the program, it outputs itself.

### The Naive Approach (And Why It's Too Slow)

The obvious approach is brute force: try A=1, then A=2, then A=3, etc., until we find one that works.

```dart
// This would work, but it's too slow!
for (var a = 1; a < huge_number; a++) {
  if (programOutputMatches(program, a)) {
    return a;
  }
}
```

The problem? The answer is **247,839,002,892,474** - that's over 247 trillion! Trying every value would take forever, even with early termination optimizations.

### The Key Insight: Work Backwards!

The breakthrough insight comes from understanding how the program processes A:

1. **A gets divided by 8 each iteration** (through the `adv` instruction)
2. **We know what outputs we need** (the program itself)
3. **We can work backwards** from the desired outputs to determine what A values could produce them

### Elegant Backtracking Solution

Thanks to [Todd Ginsberg's elegant solution](https://github.com/tginsberg/advent-2024-kotlin/blob/main/src/main/kotlin/com/ginsberg/advent2024/Day17.kt), we can solve this deterministically using backtracking:

```dart
int? _backtrackFindA(List<int> program) {
  // Start with A=0 (after last iteration, loop exits)
  var candidates = <int>[0];

  // Work backwards through each output instruction
  final reversedProgram = program.reversed.toList();

  for (final expectedOutput in reversedProgram) {
    final nextCandidates = <int>[];

    for (final candidate in candidates) {
      // Reverse the "divide by 8" operation: multiply by 8
      final shifted = candidate * 8;

      // Try all 8 possible remainders (0-7)
      // This covers all possible A values that could produce candidate after division
      for (var remainder = 0; remainder < 8; remainder++) {
        final attempt = shifted + remainder;

        // Run the program and check if FIRST output matches
        // We're working backwards, so we only care about the first output
        final output = _executeProgram(program, attempt, 0, 0);
        if (output.isNotEmpty && output.first == expectedOutput) {
          nextCandidates.add(attempt);
        }
      }
    }

    if (nextCandidates.isEmpty) {
      return null; // No valid candidates
    }

    candidates = nextCandidates;
  }

  // Find the smallest positive A value
  return candidates.where((a) => a > 0).reduce((a, b) => a < b ? a : b);
}
```

### How It Works

1. **Start from the end**: After the last iteration, A=0 (so the loop exits)
2. **Work backwards**: For each output instruction (in reverse order):
   - Take each candidate A value
   - Multiply by 8 (reverse the division) and try all 8 possible remainders
   - Run the program with each candidate and check if the **first output** matches
   - Keep only candidates that produce the correct output
3. **Build constraints**: Each output narrows the candidate set
4. **Find the answer**: The smallest remaining candidate is our answer

### Why This Works

- **Reversing division**: If `A_new = A_old / 8`, then `A_old = A_new * 8 + remainder` where remainder ∈ [0, 7]
- **Incremental validation**: We only check the first output when working backwards (much faster than full execution)
- **Deterministic**: This approach is guaranteed to find the answer if it exists

### Complexity Analysis

- **Brute force**: O(A_max × n) where A_max ≈ 247 trillion - would take hours/days
- **Backtracking**: O(program_length × 8 × candidates) - finds answer in **1 millisecond**!

The backtracking approach is exponentially faster because:
- We only try 8 possibilities per output (not millions)
- Each output validation is fast (only check first output)
- The candidate set shrinks quickly as constraints accumulate

## Key Learnings

### Virtual Machine Implementation

This puzzle teaches us how to:
- Build a simple VM interpreter
- Handle different operand types (literal vs combo)
- Manage instruction pointer and jumps
- Collect output from execution

### Backtracking and Reverse Engineering

The real learning from Part 2 is:
- **Sometimes working backwards is easier than forwards**
- **Understanding program structure enables optimization**
- **Constraint propagation can dramatically reduce search space**
- **Elegant solutions often come from seeing the problem differently**

### Dart Language Features Used

- **Record types** for representing program state
- **Integer division** (`~/`) for truncating division
- **Bitwise operations** (XOR `^`, left shift `<<`)
- **List operations** (`reversed`, `first`, `where`, `reduce`)

## Real-World Applications

- **Compiler design**: Understanding how programs execute helps optimize compilation
- **Reverse engineering**: Working backwards from outputs to inputs
- **Constraint satisfaction**: Using constraints to narrow search spaces
- **Virtual machines**: Building interpreters for domain-specific languages

## Full Solution

The complete solution can be found in `lib/years/year2024/day17.dart`. The key functions are:
- `_executeProgram()`: Runs the VM and collects output
- `_executeAndCheckProgram()`: Optimized version that checks output incrementally
- `_backtrackFindA()`: Elegant backtracking solution (inspired by Todd Ginsberg's approach)

## Acknowledgments

Special thanks to [Todd Ginsberg](https://github.com/tginsberg/advent-2024-kotlin) for his elegant backtracking solution that inspired our implementation. His insight to work backwards from outputs and reverse the division operation made this problem solvable in milliseconds instead of hours!

## Complexity Summary

- **Part 1**: O(n) where n is program length - linear time
- **Part 2**: O(program_length × 8 × candidates) - exponential reduction from brute force
- **Space**: O(1) for Part 1, O(candidates) for Part 2 backtracking

The backtracking approach demonstrates how understanding problem structure can lead to dramatically more efficient solutions!

