import '../../core/solver.dart';

class Year2024Day02 extends DaySolver {
  @override
  int get year => 2024;

  @override
  int get day => 2;

  @override
  String solvePart1(List<String> input) {
    return _solvePart1(input);
  }

  @override
  String solvePart2(List<String> input) {
    return _solvePart2(input);
  }

  /// Parses a report line into a list of integers.
  List<int> _parseReport(String line) {
    return line.trim().split(RegExp(r'\s+')).map((s) => int.parse(s)).toList();
  }

  /// Checks if a report is safe.
  /// A report is safe if:
  /// - All levels are either all increasing OR all decreasing
  /// - Any two adjacent levels differ by at least 1 and at most 3
  bool _isReportSafe(List<int> levels) {
    if (levels.length < 2) {
      return true;
    }
    bool? isIncreasing;
    for (var i = 0; i < levels.length - 1; i++) {
      final current = levels[i];
      final next = levels[i + 1];
      final diff = next - current;
      if (diff == 0) {
        return false;
      }
      final absDiff = diff.abs();
      if (absDiff < 1 || absDiff > 3) {
        return false;
      }
      if (isIncreasing == null) {
        isIncreasing = diff > 0;
      } else {
        if ((diff > 0) != isIncreasing) {
          return false;
        }
      }
    }
    return true;
  }

  /// Checks if a report is safe with the Problem Dampener.
  /// A report is safe if:
  /// - It's safe normally, OR
  /// - Removing any single level makes it safe
  bool _isReportSafeWithDampener(List<int> levels) {
    if (_isReportSafe(levels)) {
      return true;
    }
    for (var i = 0; i < levels.length; i++) {
      final modifiedLevels = [
        ...levels.sublist(0, i),
        ...levels.sublist(i + 1),
      ];
      if (_isReportSafe(modifiedLevels)) {
        return true;
      }
    }
    return false;
  }

  /// Part 1: Count how many reports are safe.
  String _solvePart1(List<String> input) {
    var safeCount = 0;
    for (final line in input) {
      if (line.trim().isEmpty) {
        continue;
      }
      final levels = _parseReport(line);
      if (_isReportSafe(levels)) {
        safeCount++;
      }
    }
    return safeCount.toString();
  }

  /// Part 2: Count how many reports are safe with Problem Dampener.
  /// A report is safe if it's safe normally OR can be made safe by removing one level.
  String _solvePart2(List<String> input) {
    var safeCount = 0;
    for (final line in input) {
      if (line.trim().isEmpty) {
        continue;
      }
      final levels = _parseReport(line);
      if (_isReportSafeWithDampener(levels)) {
        safeCount++;
      }
    }
    return safeCount.toString();
  }
}
