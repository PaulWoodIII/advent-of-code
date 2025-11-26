import 'dart:io';

/// Input type for different puzzle inputs.
enum InputType {
  examplePart1,
  examplePart2,
  part1,
  part2,
}

/// Reads Advent of Code input from the conventional workspace structure.
class InputLoader {
  InputLoader({Directory? root}) : _root = root ?? Directory.current;

  final Directory _root;
  final Map<String, List<String>> _cache = {};

  /// Loads the raw input file as lines for the requested year/day.
  /// Results are cached in memory for subsequent calls.
  List<String> loadLines({
    required int year,
    required int day,
    InputType inputType = InputType.part1,
    bool useCache = true,
    bool trimEmpty = true,
  }) {
    final key = _key(year, day, inputType);
    if (useCache && _cache.containsKey(key)) {
      return _cache[key]!;
    }

    final file = File(_inputPath(year: year, day: day, inputType: inputType));
    if (!file.existsSync()) {
      throw FileSystemException(
        'Missing input file: ${file.path}\n'
        'Expected file at: ${_inputPath(year: year, day: day, inputType: inputType)}\n'
        'Ensure the input file exists or fetch it using the fetch script.',
        file.path,
      );
    }

    List<String> lines;
    try {
      lines = file.readAsLinesSync();
    } on FileSystemException catch (e) {
      throw FileSystemException(
        'Failed to read input file: ${file.path}\n'
        'Error: ${e.message}',
        file.path,
        e.osError,
      );
    }

    if (trimEmpty) {
      lines = lines.where((line) => line.isNotEmpty).toList(growable: false);
    } else {
      lines = lines.toList(growable: false);
    }

    if (useCache) {
      _cache[key] = lines;
    }

    return lines;
  }

  /// Clears the input cache.
  void clearCache() {
    _cache.clear();
  }

  /// Clears cache entry for a specific year/day.
  void clearCacheEntry({
    required int year,
    required int day,
    InputType inputType = InputType.part1,
  }) {
    _cache.remove(_key(year, day, inputType));
  }

  /// Convenience method to load example input for part 1.
  List<String> loadExamplePart1({
    required int year,
    required int day,
    bool useCache = true,
    bool trimEmpty = true,
  }) {
    return loadLines(
      year: year,
      day: day,
      inputType: InputType.examplePart1,
      useCache: useCache,
      trimEmpty: trimEmpty,
    );
  }

  /// Convenience method to load example input for part 2.
  List<String> loadExamplePart2({
    required int year,
    required int day,
    bool useCache = true,
    bool trimEmpty = true,
  }) {
    return loadLines(
      year: year,
      day: day,
      inputType: InputType.examplePart2,
      useCache: useCache,
      trimEmpty: trimEmpty,
    );
  }

  String _inputPath({
    required int year,
    required int day,
    required InputType inputType,
  }) {
    final dayStr = day.toString().padLeft(2, '0');
    final suffix = switch (inputType) {
      InputType.examplePart1 => 'example_part1',
      InputType.examplePart2 => 'example_part2',
      InputType.part1 => 'part1',
      InputType.part2 => 'part2',
    };
    return '${_root.path}/data/inputs/$year/day_${dayStr}_$suffix.txt';
  }

  String _key(int year, int day, InputType inputType) =>
      '${year}_${day.toString().padLeft(2, '0')}_${inputType.name}';
}
