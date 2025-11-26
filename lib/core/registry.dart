import 'dart:collection';

import 'solver.dart';

/// Maintains a registry of available Advent of Code solvers.
class SolverRegistry with IterableMixin<DaySolver> {
  final Map<String, DaySolver> _solvers = {};

  /// Registers a solver.
  void addSolver(DaySolver solver) {
    final key = _key(solver.year, solver.day);
    if (_solvers.containsKey(key)) {
      throw StateError('Solver already registered for ${solver.year}-day${solver.day}.');
    }
    _solvers[key] = solver;
  }

  /// Finds a solver by year/day or returns null if absent.
  DaySolver? find(int year, int day) => _solvers[_key(year, day)];

  /// Returns all solvers grouped by year.
  Map<int, List<DaySolver>> groupedByYear() {
    final map = <int, List<DaySolver>>{};
    for (final solver in _solvers.values) {
      map.putIfAbsent(solver.year, () => []).add(solver);
    }
    for (final entry in map.entries) {
      entry.value.sort((a, b) => a.day.compareTo(b.day));
    }
    return SplayTreeMap.of(map);
  }

  @override
  Iterator<DaySolver> get iterator => _solvers.values.iterator;

  String _key(int year, int day) => '${year}_$day';
}
