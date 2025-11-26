import 'package:args/args.dart';

import 'package:aoc_workspace/bootstrap.dart';
import 'package:aoc_workspace/core/run.dart';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag(
      'list',
      abbr: 'l',
      help: 'List available solvers',
      negatable: false,
    )
    ..addOption(
      'year',
      abbr: 'y',
      help: 'Target puzzle year',
    )
    ..addOption(
      'day',
      abbr: 'd',
      help: 'Target puzzle day (1-25)',
    )
    ..addFlag(
      'benchmark',
      abbr: 'b',
      help: 'Run benchmark instead of solving once',
      negatable: false,
    )
    ..addOption(
      'iterations',
      abbr: 'i',
      help: 'Number of iterations for benchmarking',
      defaultsTo: '100',
    )
    ..addFlag(
      'skip-warmup',
      help: 'Skip warmup phase',
      negatable: false,
    )
    ..addOption(
      'format',
      abbr: 'f',
      help: 'Output format: text or json',
      allowed: ['text', 'json'],
      defaultsTo: 'text',
    );

  final results = parser.parse(arguments);
  final runner = createRunner();

  final listOnly = results['list'] as bool;
  final year = _parseInt(results['year']);
  final day = _parseInt(results['day']);
  final benchmark = results['benchmark'] as bool;
  final iterations = _parseInt(results['iterations']) ?? 100;
  final skipWarmup = results['skip-warmup'] as bool;
  final formatStr = results['format'] as String;
  final outputFormat = formatStr == 'json'
      ? OutputFormat.json
      : OutputFormat.text;

  await runner.run(
    year: year,
    day: day,
    listOnly: listOnly,
    benchmark: benchmark,
    benchmarkIterations: iterations,
    skipWarmup: skipWarmup,
    outputFormat: outputFormat,
  );
}

int? _parseInt(Object? value) {
  if (value == null) return null;
  final parsed = int.tryParse(value.toString());
  if (parsed == null) {
    throw FormatException('Expected integer but got "$value"');
  }
  return parsed;
}
