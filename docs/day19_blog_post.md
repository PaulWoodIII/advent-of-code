# Solving Advent of Code Day 19: Linen Layout - Dynamic Programming for String Matching

## The Problem: Arranging Towels

You're at an onsen (hot spring) trying to get in for free by helping arrange towels! Each towel has a pattern of colored stripes: white (w), blue (u), black (b), red (r), or green (g). The staff has a list of desired designs (long sequences of colors) and wants to know if they can be formed by concatenating available towel patterns.

**Part 1** asks: How many designs are possible to form?

**Part 2** asks: What is the total number of different ways all designs can be formed?

## Understanding the Problem

This is a classic **string matching** problem:
- You have a set of patterns (like "r", "wr", "b", "g")
- You have desired designs (like "brwrr", "bggr")
- Can a design be formed by concatenating patterns? (Part 1)
- How many ways can it be formed? (Part 2)

For example, "brwrr" can be formed as:
- `b` + `r` + `wr` + `r`
- `br` + `wr` + `r`

This is similar to the classic "word break" problem in computer science, where you check if a string can be segmented into dictionary words.

## Part 1: Checking if Designs Can Be Formed

### The Naive Approach (and Why It Fails)

A naive approach might try to greedily match patterns from left to right:

```dart
// This doesn't work!
bool canForm(String design, List<String> patterns) {
  if (design.isEmpty) return true;
  for (final pattern in patterns) {
    if (design.startsWith(pattern)) {
      return canForm(design.substring(pattern.length), patterns);
    }
  }
  return false;
}
```

**Why this fails**: Greedy matching can miss valid solutions. For example, if we have patterns `["a", "aa"]` and design `"aaa"`, greedy matching might try `"a"` first and fail, even though `"aa"` + `"a"` works.

### The Dynamic Programming Solution

We use **dynamic programming** to check all possibilities:

```dart
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
```

**How it works**:
1. `dp[i]` represents whether the substring `design[0..i-1]` can be formed
2. Base case: `dp[0] = true` (empty string is always formable)
3. For each position `i`, check if any pattern matches ending at `i`
4. If a pattern matches AND the prefix before it is formable (`dp[start]`), then `dp[i] = true`
5. Return `dp[design.length]` (whether the entire design is formable)

**Example trace** for design `"brwrr"` with patterns `["r", "wr", "b", "g", "br"]`:

```
Position 0: dp[0] = true (empty string)
Position 1: Check "b" - matches! dp[1] = true
Position 2: Check "br" - matches! dp[2] = true
           Check "r" - matches! dp[2] = true (already true)
Position 3: Check "wr" - matches! dp[3] = true (because dp[1] is true)
Position 4: Check "r" - matches! dp[4] = true (because dp[3] is true)
Position 5: Check "r" - matches! dp[5] = true (because dp[4] is true)
Result: dp[5] = true, so "brwrr" can be formed
```

## Part 2: Counting All Ways

Part 2 asks for the **total number of ways** each design can be formed. This requires a small modification to our DP approach:

```dart
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
```

**Key difference**: Instead of setting `dp[i] = true`, we **sum** all the ways: `dp[i] += dp[start]`. This counts all possible paths to reach position `i`.

**Example trace** for design `"brwrr"`:

```
Position 0: dp[0] = 1
Position 1: "b" matches → dp[1] += dp[0] = 1
Position 2: "br" matches → dp[2] += dp[0] = 1
           "r" matches → dp[2] += dp[1] = 1 + 1 = 2
Position 3: "wr" matches → dp[3] += dp[1] = 2
Position 4: "r" matches → dp[4] += dp[3] = 2
Position 5: "r" matches → dp[5] += dp[4] = 2
Result: dp[5] = 2 ways to form "brwrr"
```

This matches the example: `"brwrr"` can be formed in 2 ways:
1. `b` + `r` + `wr` + `r`
2. `br` + `wr` + `r`

## Dart Language Features

### Records for Structured Data

We use Dart records to return multiple values from parsing:

```dart
({List<String> patterns, List<String> designs}) _parseInput(List<String> input) {
  // ...
  return (patterns: patterns, designs: designs);
}
```

Records provide type-safe, named return values without needing a separate class.

### String Manipulation

Dart's string methods make pattern matching straightforward:

```dart
design.substring(start, i) == pattern
```

The `substring` method efficiently extracts substrings for comparison.

### List Operations

Dart's collection methods simplify parsing:

```dart
final patterns = firstLine
    .split(',')
    .map((s) => s.trim())
    .where((s) => s.isNotEmpty)
    .toList();
```

This chains operations: split by comma, trim whitespace, filter empty strings, convert to list.

## Complexity Analysis

**Time Complexity**: O(D × N × M × K)
- D = number of designs
- N = average design length
- M = number of patterns
- K = average pattern length

For each design, we iterate through all positions (N), and for each position, we check all patterns (M), comparing substrings of length K.

**Space Complexity**: O(N)
- We need a DP array of size N+1 for each design
- We process designs one at a time, so space is linear in design length

## Real-World Applications

This pattern appears in many real-world problems:

1. **Text Segmentation**: Breaking text into words (e.g., "helloworld" → "hello" + "world")
2. **Code Parsing**: Parsing programming languages where tokens can overlap
3. **DNA Sequencing**: Matching DNA sequences against known patterns
4. **Spell Checking**: Checking if a word can be formed from known word parts
5. **Compression**: Finding optimal ways to represent strings using dictionary entries

## Key Insights

1. **Dynamic Programming**: When a problem has overlapping subproblems (checking prefixes multiple times), DP avoids redundant work
2. **Bottom-Up Approach**: Building solutions from smaller to larger subproblems is often clearer than top-down recursion
3. **Counting vs. Existence**: The same DP structure can answer both "can it be done?" (boolean) and "how many ways?" (counting) questions
4. **Pattern Matching**: Efficient substring comparison is key to performance

## Full Solution

The complete solution demonstrates both Part 1 (existence checking) and Part 2 (counting) using the same DP framework:

```dart
// Part 1: Check existence
bool _canFormDesign(String design, List<String> patterns) {
  final dp = List<bool>.filled(design.length + 1, false);
  dp[0] = true;
  for (var i = 1; i <= design.length; i++) {
    for (final pattern in patterns) {
      if (pattern.length <= i) {
        final start = i - pattern.length;
        if (design.substring(start, i) == pattern && dp[start]) {
          dp[i] = true;
          break;
        }
      }
    }
  }
  return dp[design.length];
}

// Part 2: Count ways
int _countWaysToFormDesign(String design, List<String> patterns) {
  final dp = List<int>.filled(design.length + 1, 0);
  dp[0] = 1;
  for (var i = 1; i <= design.length; i++) {
    for (final pattern in patterns) {
      if (pattern.length <= i) {
        final start = i - pattern.length;
        if (design.substring(start, i) == pattern) {
          dp[i] += dp[start];
        }
      }
    }
  }
  return dp[design.length];
}
```

The elegance of this solution lies in how Part 2 naturally extends Part 1: we change from tracking existence (boolean) to counting paths (integer), but the core algorithm structure remains the same.

