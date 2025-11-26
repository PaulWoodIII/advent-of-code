# Solving Advent of Code Day 11: From Exponential Explosion to Elegant Optimization

## The Problem: Plutonian Pebbles

Imagine you're observing a line of stones, each engraved with a number. Every time you blink, the stones transform according to three simple rules:

1. **Zero becomes one**: `0 → 1`
2. **Even-digit numbers split**: `125 → 12` and `5` (split in half)
3. **Otherwise multiply**: `17 → 17 × 2024 = 34408`

The puzzle asks: after 25 blinks (Part 1) or 75 blinks (Part 2), how many stones do you have?

At first glance, this seems straightforward—just simulate each blink. But there's a catch: stones can split, causing exponential growth. After 75 blinks, you might have billions of stones, making naive simulation impossible.

## The Naive Approach (And Why It Fails)

Let's start with the obvious solution:

```dart
List<int> stones = parseInput(input);
for (int blink = 0; blink < 75; blink++) {
  List<int> newStones = [];
  for (int stone in stones) {
    newStones.addAll(transformStone(stone));
  }
  stones = newStones;
}
return stones.length;
```

This works perfectly for small inputs and 25 blinks. But try 75 blinks, and you'll watch your computer's memory disappear faster than the stones multiply.

**Why?** Exponential growth. If you start with 8 stones and each blink doubles them (worst case), after 75 blinks you'd have `8 × 2^75` stones—that's approximately `3 × 10^22` stones. Even if each stone was just an integer (8 bytes), that's `2.4 × 10^23` bytes, or about 240 exabytes. Your computer doesn't have that much RAM.

## The Key Insight: Frequency Counting

Here's the crucial observation: **identical stones transform identically**. If you have three stones with the value `17`, they'll all become `34408` after one blink. There's no need to track them separately.

Instead of maintaining a list of individual stones:
```dart
[125, 17, 17, 17, 99, 99]
```

We can maintain a frequency map:
```dart
{125: 1, 17: 3, 99: 2}
```

This is the **frequency counting** pattern—a powerful optimization technique for problems with exponential growth where many states are identical.

## The Optimized Solution

Here's how we implement it in Dart:

```dart
String _simulateBlinks(List<String> input, int blinks) {
  // Parse initial stones and count frequencies
  final initialStones = input[0]
      .trim()
      .split(RegExp(r'\s+'))
      .map((s) => int.parse(s))
      .toList();
  
  // Build frequency map: stoneValue -> count
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
      
      // Multiply counts: if 3 stones of value 17 become 34408,
      // we now have 3 stones of value 34408
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
```

## Dart Language Features in Action

### 1. Type Inference with Generics

Dart's type inference shines here. Notice how we declare the map:

```dart
var frequencies = <int, int>{};
```

The `<int, int>` tells Dart this is a `Map<int, int>`, but we don't need to write `Map<int, int>` explicitly. Dart infers the type from the generic parameters. This is cleaner than:

```dart
Map<int, int> frequencies = <int, int>{};
```

### 2. Null-Aware Operators

Dart's null-aware operators make frequency counting elegant:

```dart
frequencies[stone] = (frequencies[stone] ?? 0) + 1;
```

The `??` operator returns the right-hand value if the left is null. So if `frequencies[stone]` doesn't exist (returns `null`), we use `0` instead. This is much cleaner than:

```dart
if (frequencies.containsKey(stone)) {
  frequencies[stone] = frequencies[stone]! + 1;
} else {
  frequencies[stone] = 1;
}
```

### 3. Collection Literals and Method Cascades

Dart's collection literals are concise:

```dart
final initialStones = input[0]
    .trim()
    .split(RegExp(r'\s+'))
    .map((s) => int.parse(s))
    .toList();
```

This chains operations: trim the string, split by whitespace, parse each as an integer, convert to a list. The `r'\s+'` is a raw string (the `r` prefix), which is useful for regex patterns where you don't want escape sequences interpreted.

### 4. Map Entry Iteration

Dart makes iterating over map entries clean:

```dart
for (final entry in frequencies.entries) {
  final stone = entry.key;
  final count = entry.value;
  // ...
}
```

The `.entries` property gives you an iterable of `MapEntry` objects, each with `key` and `value` properties. This is more readable than:

```dart
for (final stone in frequencies.keys) {
  final count = frequencies[stone]!;
  // ...
}
```

### 5. Final vs Var

Notice the strategic use of `final` and `var`:

- `final` for values that never change: `final stone = entry.key`
- `var` for values that change: `var frequencies = <int, int>{}`

This communicates intent: `final` tells readers "this won't be reassigned," while `var` says "this might change."

## Complexity Analysis

**Naive Approach:**
- **Time**: O(blinks × total_stones) where total_stones grows exponentially
- **Space**: O(total_stones) - storing every individual stone

**Optimized Approach:**
- **Time**: O(blinks × unique_stone_values)
- **Space**: O(unique_stone_values)

The key difference: `unique_stone_values` grows much slower than `total_stones`. In practice, even after 75 blinks, you might only have a few thousand unique values, while total stones could be in the trillions.

## The Deeper Pattern: Memoization Through Grouping

This optimization is a form of **memoization**—we're caching the result of transforming a stone value and reusing it for all stones with that value. It's similar to:

- **Hashlife** in cellular automata (memoizing cell patterns)
- **Dynamic programming** (memoizing subproblem results)
- **Frequency analysis** in compression algorithms

The general pattern: **when identical states produce identical results, group them and compute once**.

## Real-World Applications

This pattern appears in many domains:

1. **Compression**: Run-length encoding groups identical consecutive values
2. **Database optimization**: Materialized views cache expensive queries
3. **Game development**: Object pooling reuses identical game objects
4. **Distributed systems**: Consistent hashing groups similar requests

## Performance Results

On my machine:
- **Part 1 (25 blinks)**: 10ms
- **Part 2 (75 blinks)**: 20ms

The naive approach would likely take hours (if it didn't run out of memory first). The optimized approach completes in milliseconds.

## Key Takeaways

1. **Exponential growth requires exponential thinking**: When simulation becomes impossible, look for patterns that let you group identical states.

2. **Frequency counting is powerful**: If many items share the same value, track counts instead of individual items.

3. **Dart's type system helps**: Type inference, null-aware operators, and collection methods make the code cleaner and safer.

4. **Optimization is about insight, not just code**: The breakthrough wasn't writing better code—it was recognizing that identical stones transform identically.

## Conclusion

Day 11 teaches us that sometimes the best optimization isn't about making code faster—it's about recognizing when you don't need to compute something at all. By grouping identical states and computing transformations once per unique value, we turned an impossible problem into one that solves in milliseconds.

The frequency counting pattern is a valuable tool for any programmer's toolkit, especially when dealing with simulations, state machines, or any problem where exponential growth meets identical states.

---

**Full solution code**: [day11.dart](https://github.com/PaulWoodIII/advent-of-code/blob/main/lib/years/year2024/day11.dart)


