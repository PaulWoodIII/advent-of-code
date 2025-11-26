import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'benchmark.dart';
import 'input_loader.dart';
import 'registry.dart';
import 'solver.dart';

/// Output format for solver results.
enum OutputFormat {
  text,
  json,
}

class SolverRunner {
  SolverRunner({
    required SolverRegistry registry,
    InputLoader? loader,
    IOSink? out,
  })  : _registry = registry,
        _loader = loader ?? InputLoader(),
        _out = out ?? stdout;

  final SolverRegistry _registry;
  final InputLoader _loader;
  final IOSink _out;

  Future<void> run({
    int? year,
    int? day,
    bool listOnly = false,
    bool benchmark = false,
    int benchmarkIterations = 100,
    bool skipWarmup = false,
    OutputFormat outputFormat = OutputFormat.text,
  }) async {
    if (listOnly) {
      _printAvailable();
      return;
    }

    if (year == null || day == null) {
      throw ArgumentError(
          'Both year and day are required unless listing solvers.');
    }

    final solver = _registry.find(year, day);
    if (solver == null) {
      throw StateError('No solver registered for $year day $day.');
    }

    final part1Lines = _loader.loadLines(
      year: year,
      day: day,
      inputType: InputType.part1,
    );
    final part2Lines = _loadPart2Input(year: year, day: day);

    if (benchmark) {
      await _runBenchmark(
        solver: solver,
        input: part1Lines,
        iterations: benchmarkIterations,
        includeWarmup: !skipWarmup,
        outputFormat: outputFormat,
      );
      return;
    }

    if (!skipWarmup) {
      await solver.warmup();
    }

    final stopwatch = Stopwatch()..start();
    final part1 = await Future.value(solver.solvePart1(part1Lines));
    final part1Time = stopwatch.elapsed;
    stopwatch.reset();

    stopwatch.start();
    final part2 = await Future.value(solver.solvePart2(part2Lines));
    final part2Time = stopwatch.elapsed;
    stopwatch.stop();

    switch (outputFormat) {
      case OutputFormat.text:
        _out.writeln('Running AoC $year Day $day');
        _out.writeln('  Part 1: $part1 (${_formatDuration(part1Time)})');
        _out.writeln('  Part 2: $part2 (${_formatDuration(part2Time)})');
      case OutputFormat.json:
        _out.writeln(jsonEncode({
          'year': year,
          'day': day,
          'part1': {'answer': part1, 'time_ms': part1Time.inMilliseconds},
          'part2': {'answer': part2, 'time_ms': part2Time.inMilliseconds},
        }));
    }
  }

  Future<void> _runBenchmark({
    required DaySolver solver,
    required List<String> input,
    required int iterations,
    required bool includeWarmup,
    required OutputFormat outputFormat,
  }) async {
    if (outputFormat == OutputFormat.text) {
      _out.writeln(
          'Benchmarking AoC ${solver.year} Day ${solver.day} ($iterations iterations)...');
    }

    final runner = BenchmarkRunner(
      solver: solver,
      input: input,
      iterations: iterations,
      includeWarmup: includeWarmup,
    );

    final result = await runner.run();

    switch (outputFormat) {
      case OutputFormat.text:
        _out.writeln('');
        _out.writeln('Benchmark Results:');
        if (result.warmupTime != null) {
          _out.writeln('  Warmup: ${_formatDuration(result.warmupTime!)}');
        }
        _out.writeln('  Part 1:');
        _out.writeln('    Mean: ${_formatDuration(result.part1Mean)}');
        _out.writeln('    Min:  ${_formatDuration(result.part1Min)}');
        _out.writeln('    Max:  ${_formatDuration(result.part1Max)}');
        _out.writeln('  Part 2:');
        _out.writeln('    Mean: ${_formatDuration(result.part2Mean)}');
        _out.writeln('    Min:  ${_formatDuration(result.part2Min)}');
        _out.writeln('    Max:  ${_formatDuration(result.part2Max)}');
        _out.writeln('  Total Mean: ${_formatDuration(result.totalMean)}');
      case OutputFormat.json:
        _out.writeln(jsonEncode(result.toJson()));
    }
  }

  void _printAvailable() {
    _out.writeln('Available solvers:');
    final grouped = _registry.groupedByYear();
    if (grouped.isEmpty) {
      _out.writeln('  <none>');
      return;
    }
    for (final entry in grouped.entries) {
      final formattedDays = entry.value
          .map((solver) => solver.day.toString().padLeft(2, '0'))
          .join(', ');
      _out.writeln('  ${entry.key}: $formattedDays');
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inMicroseconds < 1000) {
      return '${duration.inMicroseconds}μs';
    } else if (duration.inMilliseconds < 1000) {
      return '${duration.inMilliseconds}ms';
    } else {
      return '${duration.inSeconds}s ${duration.inMilliseconds % 1000}ms';
    }
  }

  /// Loads input for part 2, falling back to part1 if part2 doesn't exist.
  /// In Advent of Code, part 1 and part 2 typically use the same input data.
  List<String> _loadPart2Input({required int year, required int day}) {
    try {
      return _loader.loadLines(
        year: year,
        day: day,
        inputType: InputType.part2,
      );
    } on FileSystemException {
      // Part 2 typically uses the same input as part 1
      return _loader.loadLines(
        year: year,
        day: day,
        inputType: InputType.part1,
      );
    }
  }
}
