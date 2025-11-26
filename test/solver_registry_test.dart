import 'package:aoc_workspace/core/registry.dart';
import 'package:aoc_workspace/core/solver.dart';
import 'package:test/test.dart';

class _FakeSolver extends DaySolver {
  _FakeSolver(this.year, this.day);

  @override
  final int year;

  @override
  final int day;

  @override
  String solvePart1(List<String> input) => 'a';

  @override
  String solvePart2(List<String> input) => 'b';
}

void main() {
  group('SolverRegistry', () {
    test('stores and retrieves solvers by year/day', () {
      final registry = SolverRegistry();
      final solver = _FakeSolver(2024, 1);
      registry.addSolver(solver);

      expect(registry.find(2024, 1), same(solver));
    });

    test('throws when registering duplicate solver', () {
      final registry = SolverRegistry();
      registry.addSolver(_FakeSolver(2024, 1));

      expect(
        () => registry.addSolver(_FakeSolver(2024, 1)),
        throwsA(isA<StateError>()),
      );
    });
  });
}
