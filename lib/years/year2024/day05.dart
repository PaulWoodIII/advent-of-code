import '../../core/solver.dart';

class Year2024Day05 extends DaySolver {
  @override
  int get year => 2024;

  @override
  int get day => 5;

  @override
  String solvePart1(List<String> input) {
    return _solvePart1(input);
  }

  @override
  String solvePart2(List<String> input) {
    return _solvePart2(input);
  }

  /// Parses input into rules and updates.
  /// Rules are in format X|Y, updates are comma-separated page numbers.
  /// Input format: rules section, blank line, updates section.
  /// Note: Empty lines may be filtered by InputLoader, so we detect transition
  /// by checking if a line contains a comma (update) vs pipe (rule).
  ({List<({int before, int after})> rules, List<List<int>> updates})
      _parseInput(List<String> input) {
    final rules = <({int before, int after})>[];
    final updates = <List<int>>[];
    for (final line in input) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        continue;
      }
      // If line contains a comma, it's an update; if it contains a pipe, it's a rule
      if (trimmed.contains(',')) {
        // Parse update: comma-separated page numbers
        final pages =
            trimmed.split(',').map((s) => int.parse(s.trim())).toList();
        updates.add(pages);
      } else if (trimmed.contains('|')) {
        // Parse rule: X|Y
        final parts = trimmed.split('|');
        if (parts.length == 2) {
          final before = int.parse(parts[0]);
          final after = int.parse(parts[1]);
          rules.add((before: before, after: after));
        }
      }
    }
    return (rules: rules, updates: updates);
  }

  /// Checks if an update is correctly ordered according to the rules.
  /// An update is correctly ordered if for every rule X|Y where both X and Y
  /// are present in the update, X appears before Y in the update sequence.
  bool _isUpdateCorrectlyOrdered(
      List<int> update, List<({int before, int after})> rules) {
    // Create a map of page number to its index in the update
    final pageIndex = <int, int>{};
    for (var i = 0; i < update.length; i++) {
      pageIndex[update[i]] = i;
    }
    // Check each rule
    for (final rule in rules) {
      final beforeIndex = pageIndex[rule.before];
      final afterIndex = pageIndex[rule.after];
      // Only check rules where both pages are in the update
      if (beforeIndex != null && afterIndex != null) {
        // If before page comes after after page, the update is incorrectly ordered
        if (beforeIndex >= afterIndex) {
          return false;
        }
      }
    }
    return true;
  }

  /// Part 1: Find correctly-ordered updates and sum their middle page numbers.
  /// This puzzle teaches topological ordering validation - checking if a sequence
  /// satisfies a set of ordering constraints (precedence rules).
  String _solvePart1(List<String> input) {
    final parsed = _parseInput(input);
    final rules = parsed.rules;
    final updates = parsed.updates;
    var sum = 0;
    for (final update in updates) {
      if (_isUpdateCorrectlyOrdered(update, rules)) {
        // Find middle page number using integer division
        // For length n, index n~/2 gives the middle element (0-indexed)
        final middleIndex = update.length ~/ 2;
        sum += update[middleIndex];
      }
    }
    return sum.toString();
  }

  /// Builds a dependency graph for the given update using the rules.
  /// Returns a map where each page maps to a set of pages that must come after it.
  Map<int, Set<int>> _buildDependencyGraph(
      List<int> update, List<({int before, int after})> rules) {
    final graph = <int, Set<int>>{};
    final updateSet = update.toSet();
    // Initialize all pages in the update
    for (final page in update) {
      graph[page] = <int>{};
    }
    // Add edges based on rules (only for pages in the update)
    for (final rule in rules) {
      if (updateSet.contains(rule.before) && updateSet.contains(rule.after)) {
        graph[rule.before]!.add(rule.after);
      }
    }
    return graph;
  }

  /// Performs topological sort on an update using Kahn's algorithm.
  /// Kahn's algorithm works by repeatedly removing nodes with no incoming edges
  /// (in-degree 0) and updating the in-degrees of their neighbors.
  /// Returns the correctly ordered list of pages.
  List<int> _topologicalSort(
      List<int> update, List<({int before, int after})> rules) {
    final graph = _buildDependencyGraph(update, rules);
    // Calculate in-degrees (how many pages must come before each page)
    final inDegree = <int, int>{};
    final updateSet = update.toSet();
    for (final page in update) {
      inDegree[page] = 0;
    }
    for (final rule in rules) {
      if (updateSet.contains(rule.before) && updateSet.contains(rule.after)) {
        // All pages are initialized to 0, so we can safely increment
        inDegree[rule.after] = inDegree[rule.after]! + 1;
      }
    }
    // Kahn's algorithm: start with pages that have no dependencies
    final queue = <int>[];
    for (final page in update) {
      if (inDegree[page] == 0) {
        queue.add(page);
      }
    }
    final result = <int>[];
    while (queue.isNotEmpty) {
      // Sort queue to ensure deterministic ordering when multiple pages have no dependencies
      queue.sort();
      final current = queue.removeAt(0);
      result.add(current);
      // Reduce in-degree of pages that depend on current
      for (final dependent in graph[current]!) {
        inDegree[dependent] = inDegree[dependent]! - 1;
        if (inDegree[dependent] == 0) {
          queue.add(dependent);
        }
      }
    }
    return result;
  }

  /// Part 2: Reorder incorrectly-ordered updates and sum their middle page numbers.
  /// This puzzle teaches topological sorting - ordering elements based on precedence
  /// constraints. We use Kahn's algorithm to perform the topological sort.
  String _solvePart2(List<String> input) {
    final parsed = _parseInput(input);
    final rules = parsed.rules;
    final updates = parsed.updates;
    var sum = 0;
    for (final update in updates) {
      if (!_isUpdateCorrectlyOrdered(update, rules)) {
        // Reorder the incorrectly-ordered update using topological sort
        final ordered = _topologicalSort(update, rules);
        // Find middle page number using integer division
        final middleIndex = ordered.length ~/ 2;
        sum += ordered[middleIndex];
      }
    }
    return sum.toString();
  }
}
