#!/usr/bin/env dart

import 'dart:io';

void main(List<String> args) async {
  if (args.length < 2) {
    print('Usage: dart tools/scaffold_day.dart <year> <day> [--part2]');
    print('Example: dart tools/scaffold_day.dart 2024 5');
    print('         dart tools/scaffold_day.dart 2024 5 --part2');
    print('');
    print('By default, scaffolds part 1 files (example_part1, part1).');
    print('Use --part2 flag to scaffold part 2 files (example_part2, part2).');
    exit(1);
  }

  final year = int.tryParse(args[0]);
  final day = int.tryParse(args[1]);
  final scaffoldPart2 = args.contains('--part2');

  if (year == null || day == null) {
    print('Error: Year and day must be integers');
    exit(1);
  }

  if (day < 1 || day > 25) {
    print('Error: Day must be between 1 and 25');
    exit(1);
  }

  await _scaffoldDay(year, day, scaffoldPart2: scaffoldPart2);
}

Future<void> _scaffoldDay(int year, int day,
    {required bool scaffoldPart2}) async {
  final yearDir = Directory('lib/years/year$year');
  final dayFile =
      File('${yearDir.path}/day${day.toString().padLeft(2, '0')}.dart');
  final registryFile = File('${yearDir.path}/registry.dart');

  // Create year directory if it doesn't exist
  if (!await yearDir.exists()) {
    await yearDir.create(recursive: true);
  }

  // Check if day file already exists
  if (await dayFile.exists()) {
    print('Warning: ${dayFile.path} already exists. Skipping...');
  } else {
    // Create day solver file
    await dayFile.writeAsString(_dayTemplate(year, day));
    print('Created: ${dayFile.path}');
  }

  // Update registry file (only if creating new day file)
  if (!await dayFile.exists() || !await registryFile.exists()) {
    if (await registryFile.exists()) {
      await _updateRegistry(registryFile, year, day);
    } else {
      await registryFile.writeAsString(_registryTemplate(year, day));
      print('Created: ${registryFile.path}');
    }
  }

  // Update bootstrap.dart if needed (only if creating new day file)
  if (!await dayFile.exists()) {
    await _updateBootstrap(year);
  }

  // Create test file if it doesn't exist
  final testDir = Directory('test/years/year$year');
  final testFile =
      File('${testDir.path}/day${day.toString().padLeft(2, '0')}_test.dart');
  if (!await testDir.exists()) {
    await testDir.create(recursive: true);
  }
  if (!await testFile.exists()) {
    await testFile.writeAsString(_testTemplate(year, day));
    print('Created: ${testFile.path}');
  } else {
    print('Test file already exists: ${testFile.path}');
  }

  // Create input directory
  final inputDir = Directory('data/inputs/$year');
  if (!await inputDir.exists()) {
    await inputDir.create(recursive: true);
  }

  final dayStr = day.toString().padLeft(2, '0');

  if (scaffoldPart2) {
    // Scaffold part 2 files
    await _scaffoldPart2Files(inputDir, dayStr, year);
  } else {
    // Scaffold part 1 files
    await _scaffoldPart1Files(inputDir, dayStr, year, day);
  }
}

Future<void> _scaffoldPart1Files(
  Directory inputDir,
  String dayStr,
  int year,
  int day,
) async {
  final examplePart1File =
      File('${inputDir.path}/day_${dayStr}_example_part1.txt');
  final inputFile = File('${inputDir.path}/day_${dayStr}.txt');

  if (!await examplePart1File.exists()) {
    await examplePart1File.create();
    print('Created placeholder: ${examplePart1File.path}');
    print(
        '  Add the example input from part 1 of the puzzle prompt to this file');
  }

  if (!await inputFile.exists()) {
    await inputFile.create();
    print('Created placeholder: ${inputFile.path}');
    print(
        '  Add your puzzle input to this file (used by both part 1 and part 2)');
  }

  print('\nPart 1 scaffolding complete! Next steps:');
  print('1. Add the example input from part 1 to ${examplePart1File.path}');
  print('2. Add your puzzle input to ${inputFile.path}');
  print('3. Implement _solvePart1() in lib/years/year$year/day$dayStr.dart');
  print(
      '4. Update test expectations in test/years/year$year/day${dayStr}_test.dart');
  print('5. Run tests: dart test test/years/year$year/day${dayStr}_test.dart');
  print('6. Run solver: dart bin/aoc.dart --year $year --day $day');
  print('');
  print('After completing part 1, scaffold part 2 files with:');
  print('  dart tools/scaffold_day.dart $year $day --part2');
}

Future<void> _scaffoldPart2Files(
  Directory inputDir,
  String dayStr,
  int year,
) async {
  final examplePart2File =
      File('${inputDir.path}/day_${dayStr}_example_part2.txt');

  if (!await examplePart2File.exists()) {
    await examplePart2File.create();
    print('Created placeholder: ${examplePart2File.path}');
    print(
        '  Add the example input from part 2 of the puzzle prompt to this file');
  } else {
    print('File already exists: ${examplePart2File.path}');
  }

  print('\nPart 2 scaffolding complete! Next steps:');
  print('1. Add the example input from part 2 to ${examplePart2File.path}');
  print(
      '2. Part 2 uses the same input file as part 1 (day_${dayStr}.txt) - no action needed');
  print('3. Implement _solvePart2() in lib/years/year$year/day$dayStr.dart');
  print('4. Update unit tests with part 2 example expectations');
}

String _dayTemplate(int year, int day) {
  final paddedDay = day.toString().padLeft(2, '0');
  return '''import '../../core/solver.dart';

class Year${year}Day$paddedDay extends DaySolver {
  @override
  int get year => $year;

  @override
  int get day => $day;

  @override
  String solvePart1(List<String> input) {
    return _solvePart1(input);
  }

  @override
  String solvePart2(List<String> input) {
    return _solvePart2(input);
  }

  /// Part 1: TODO - Implement puzzle logic.
  String _solvePart1(List<String> input) {
    // TODO: Implement puzzle logic.
    return 'unimplemented';
  }

  /// Part 2: TODO - Implement puzzle logic.
  String _solvePart2(List<String> input) {
    // TODO: Implement puzzle logic.
    return 'unimplemented';
  }
}
''';
}

String _registryTemplate(int year, int day) {
  final paddedDay = day.toString().padLeft(2, '0');
  return '''import '../../core/registry.dart';
import 'day$paddedDay.dart';

void registerYear$year(SolverRegistry registry) {
  registry
    ..addSolver(Year${year}Day$paddedDay());
}
''';
}

String _testTemplate(int year, int day) {
  final paddedDay = day.toString().padLeft(2, '0');
  final solverClass = 'Year${year}Day$paddedDay';
  return '''import 'dart:io';

import 'package:aoc_workspace/core/input_loader.dart';
import 'package:aoc_workspace/years/year$year/day$paddedDay.dart';
import 'package:test/test.dart';

void main() {
  group('$solverClass', () {
    late $solverClass solver;
    late InputLoader inputLoader;

    setUp(() {
      solver = $solverClass();
      inputLoader = InputLoader();
    });

    group('Part 1', () {
      test('solves example input correctly', () {
        final input = inputLoader.loadLines(
          year: $year,
          day: $day,
          inputType: InputType.examplePart1,
        );
        final result = solver.solvePart1(input);
        expect(result, 'TODO'); // Update with expected result from puzzle
      });

      test('solves part1 input', () {
        List<String> input;
        try {
          input = inputLoader.loadLines(
            year: $year,
            day: $day,
            inputType: InputType.part1,
          );
        } on FileSystemException {
          // Part 1 input may not exist yet
          return;
        }
        final result = solver.solvePart1(input);
        expect(result, isNotEmpty);
        expect(result, isNot('unimplemented'));
      });
    });

    group('Part 2', () {
      test('solves example input correctly', () {
        List<String> input;
        try {
          input = inputLoader.loadLines(
            year: $year,
            day: $day,
            inputType: InputType.examplePart2,
          );
        } on FileSystemException {
          // Part 2 example may not exist yet - use part1 example
          input = inputLoader.loadLines(
            year: $year,
            day: $day,
            inputType: InputType.examplePart1,
          );
        }
        final result = solver.solvePart2(input);
        expect(result, 'TODO'); // Update with expected result from puzzle
      });

      test('solves part2 input', () {
        List<String> input;
        try {
          input = inputLoader.loadLines(
            year: $year,
            day: $day,
            inputType: InputType.part2,
          );
        } on FileSystemException {
          // Input file may not exist yet
          return;
        }
        final result = solver.solvePart2(input);
        expect(result, isNotEmpty);
        expect(result, isNot('unimplemented'));
      });
    });
  });
}
''';
}

Future<void> _updateRegistry(File registryFile, int year, int day) async {
  final content = await registryFile.readAsString();
  final paddedDay = day.toString().padLeft(2, '0');
  final solverClass = 'Year${year}Day$paddedDay';

  // Check if already registered
  if (content.contains(solverClass)) {
    print('Solver already registered in ${registryFile.path}');
    return;
  }

  // Add import if not present
  final importLine = "import 'day$paddedDay.dart';";
  String newContent = content;

  if (!content.contains(importLine)) {
    // Insert import after the registry import
    final registryImportIndex = content.indexOf("import 'registry.dart';");
    if (registryImportIndex != -1) {
      final insertIndex = content.indexOf('\n', registryImportIndex) + 1;
      newContent = content.substring(0, insertIndex) +
          "$importLine\n" +
          content.substring(insertIndex);
    }
  }

  // Add solver registration
  final registerFunction = 'registerYear$year';
  final addSolverLine = "    ..addSolver($solverClass());";

  if (newContent.contains(registerFunction)) {
    // Find the register function and add the solver
    final registerIndex = newContent.indexOf(registerFunction);
    final braceIndex = newContent.indexOf('{', registerIndex);
    final lastSolverIndex = newContent.lastIndexOf('..addSolver(');

    if (lastSolverIndex > braceIndex) {
      // Find the end of the last addSolver call
      final lastSolverEnd = newContent.indexOf(');', lastSolverIndex);
      if (lastSolverEnd != -1) {
        newContent = newContent.substring(0, lastSolverEnd + 2) +
            '\n$addSolverLine' +
            newContent.substring(lastSolverEnd + 2);
      }
    } else {
      // No existing solvers, add after opening brace
      final insertIndex = braceIndex + 1;
      newContent = newContent.substring(0, insertIndex) +
          '\n  registry\n$addSolverLine' +
          newContent.substring(insertIndex);
    }
  }

  await registryFile.writeAsString(newContent);
  print('Updated: ${registryFile.path}');
}

Future<void> _updateBootstrap(int year) async {
  final bootstrapFile = File('lib/bootstrap.dart');
  final content = await bootstrapFile.readAsString();
  final importName = 'y$year';
  final importLine = "import 'years/year$year/registry.dart' as $importName;";
  final registerCall = "  $importName.registerYear$year(registry);";

  String newContent = content;

  // Add import if not present
  if (!content.contains(importLine)) {
    // Find the last import and add after it
    final lastImportMatch =
        RegExp(r"import 'years/.*';").allMatches(content).lastOrNull;
    if (lastImportMatch != null) {
      final insertIndex = lastImportMatch.end;
      newContent = content.substring(0, insertIndex) +
          '\n$importLine' +
          content.substring(insertIndex);
    }
  }

  // Add register call if not present
  if (!newContent.contains(registerCall)) {
    // Find the last register call and add after it
    final lastRegisterMatch = RegExp(r"  y\d+\.registerYear\d+\(registry\);")
        .allMatches(newContent)
        .lastOrNull;
    if (lastRegisterMatch != null) {
      final insertIndex = lastRegisterMatch.end;
      newContent = newContent.substring(0, insertIndex) +
          '\n$registerCall' +
          newContent.substring(insertIndex);
    }
  }

  if (newContent != content) {
    await bootstrapFile.writeAsString(newContent);
    print('Updated: ${bootstrapFile.path}');
  }
}
