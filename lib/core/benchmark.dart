import 'dart:async';
import 'dart:io';

import 'solver.dart';

/// Results from benchmarking a solver.
class BenchmarkResult {
  BenchmarkResult({
    required this.year,
    required this.day,
    required this.part1Times,
    required this.part2Times,
    required this.warmupTime,
  });

  final int year;
  final int day;
  final List<Duration> part1Times;
  final List<Duration> part2Times;
  final Duration? warmupTime;

  Duration get part1Mean => _mean(part1Times);
  Duration get part1Min => _min(part1Times);
  Duration get part1Max => _max(part1Times);

  Duration get part2Mean => _mean(part2Times);
  Duration get part2Min => _min(part2Times);
  Duration get part2Max => _max(part2Times);

  Duration get totalMean => Duration(
        microseconds: (part1Mean.inMicroseconds + part2Mean.inMicroseconds) ~/ 2,
      );

  Map<String, dynamic> toJson() => {
        'year': year,
        'day': day,
        'part1': {
          'mean_ms': part1Mean.inMilliseconds,
          'min_ms': part1Min.inMilliseconds,
          'max_ms': part1Max.inMilliseconds,
          'iterations': part1Times.length,
        },
        'part2': {
          'mean_ms': part2Mean.inMilliseconds,
          'min_ms': part2Min.inMilliseconds,
          'max_ms': part2Max.inMilliseconds,
          'iterations': part2Times.length,
        },
        if (warmupTime != null) 'warmup_ms': warmupTime!.inMilliseconds,
      };

  static Duration _mean(List<Duration> durations) {
    if (durations.isEmpty) return Duration.zero;
    final total = durations.fold<int>(
      0,
      (sum, d) => sum + d.inMicroseconds,
    );
    return Duration(microseconds: total ~/ durations.length);
  }

  static Duration _min(List<Duration> durations) {
    if (durations.isEmpty) return Duration.zero;
    return durations.reduce((a, b) => a < b ? a : b);
  }

  static Duration _max(List<Duration> durations) {
    if (durations.isEmpty) return Duration.zero;
    return durations.reduce((a, b) => a > b ? a : b);
  }
}

/// Runs performance benchmarks on a solver.
class BenchmarkRunner {
  BenchmarkRunner({
    required DaySolver solver,
    required List<String> input,
    int iterations = 100,
    bool includeWarmup = true,
  })  : _solver = solver,
        _input = input,
        _iterations = iterations,
        _includeWarmup = includeWarmup;

  final DaySolver _solver;
  final List<String> _input;
  final int _iterations;
  final bool _includeWarmup;

  /// Runs the benchmark and returns results.
  Future<BenchmarkResult> run() async {
    Duration? warmupTime;
    if (_includeWarmup) {
      final stopwatch = Stopwatch()..start();
      await _solver.warmup();
      stopwatch.stop();
      warmupTime = stopwatch.elapsed;
    }

    final part1Times = <Duration>[];
    final part2Times = <Duration>[];

    for (var i = 0; i < _iterations; i++) {
      // Benchmark part 1
      final stopwatch1 = Stopwatch()..start();
      await _solver.solvePart1(_input);
      stopwatch1.stop();
      part1Times.add(stopwatch1.elapsed);

      // Benchmark part 2
      final stopwatch2 = Stopwatch()..start();
      await _solver.solvePart2(_input);
      stopwatch2.stop();
      part2Times.add(stopwatch2.elapsed);
    }

    return BenchmarkResult(
      year: _solver.year,
      day: _solver.day,
      part1Times: part1Times,
      part2Times: part2Times,
      warmupTime: warmupTime,
    );
  }

  /// Writes benchmark results to a file in JSON format.
  static Future<void> writeJson(
    BenchmarkResult result,
    String filePath,
  ) async {
    final file = File(filePath);
    await file.create(recursive: true);
    await file.writeAsString(
      '${result.toJson()}\n',
      mode: FileMode.append,
    );
  }

  /// Writes benchmark results to a file in CSV format.
  static Future<void> writeCsv(
    BenchmarkResult result,
    String filePath,
  ) async {
    final file = File(filePath);
    final exists = await file.exists();
    final sink = file.openWrite(mode: FileMode.append);

    if (!exists) {
      // Write header
      sink.writeln(
        'year,day,part,mean_ms,min_ms,max_ms,iterations,warmup_ms',
      );
    }

    final warmupMs = result.warmupTime?.inMilliseconds ?? '';

    sink.writeln(
      '${result.year},${result.day},1,'
      '${result.part1Mean.inMilliseconds},'
      '${result.part1Min.inMilliseconds},'
      '${result.part1Max.inMilliseconds},'
      '${result.part1Times.length},$warmupMs',
    );

    sink.writeln(
      '${result.year},${result.day},2,'
      '${result.part2Mean.inMilliseconds},'
      '${result.part2Min.inMilliseconds},'
      '${result.part2Max.inMilliseconds},'
      '${result.part2Times.length},$warmupMs',
    );

    await sink.close();
  }
}

