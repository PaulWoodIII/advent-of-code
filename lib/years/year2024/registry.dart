import '../../core/registry.dart';
import 'day01.dart';
import 'day02.dart';
import 'day03.dart';
import 'day04.dart';
import 'day05.dart';
import 'day06.dart';
import 'day07.dart';
import 'day08.dart';

void registerYear2024(SolverRegistry registry) {
  registry
    ..addSolver(Year2024Day01())
    ..addSolver(Year2024Day02())
    ..addSolver(Year2024Day03())
    ..addSolver(Year2024Day04())
    ..addSolver(Year2024Day05())
    ..addSolver(Year2024Day06())
    ..addSolver(Year2024Day07())
    ..addSolver(Year2024Day08());
}
