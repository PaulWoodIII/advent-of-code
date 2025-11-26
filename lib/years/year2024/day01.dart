import '../../core/solver.dart';

class Year2024Day01 extends DaySolver {
  @override
  int get year => 2024;

  @override
  int get day => 1;

  @override
  String solvePart1(List<String> input) {
    return _solvePart1(input);
  }

  @override
  String solvePart2(List<String> input) {
    return _solvePart2(input);
  }

  /// Parses input into left and right lists.
  ({List<int> leftList, List<int> rightList}) _parseInput(List<String> input) {
    final leftList = <int>[];
    final rightList = <int>[];
    for (final line in input) {
      final parts = line.trim().split(RegExp(r'\s+'));
      if (parts.length >= 2) {
        leftList.add(int.parse(parts[0]));
        rightList.add(int.parse(parts[1]));
      }
    }
    return (leftList: leftList, rightList: rightList);
  }

  /// Part 1: Pair smallest numbers and calculate total distance.
  String _solvePart1(List<String> input) {
    final parsed = _parseInput(input);
    final leftList = parsed.leftList;
    final rightList = parsed.rightList;
    leftList.sort();
    rightList.sort();
    var totalDistance = 0;
    for (var i = 0; i < leftList.length; i++) {
      final distance = (leftList[i] - rightList[i]).abs();
      totalDistance += distance;
    }
    return totalDistance.toString();
  }

  /// Part 2: Calculate similarity score.
  /// For each number in the left list, count how many times it appears
  /// in the right list. Multiply the left number by that count and add
  /// to the total similarity score.
  String _solvePart2(List<String> input) {
    final parsed = _parseInput(input);
    final leftList = parsed.leftList;
    final rightList = parsed.rightList;
    final rightCounts = <int, int>{};
    for (final num in rightList) {
      rightCounts[num] = (rightCounts[num] ?? 0) + 1;
    }
    var totalSimilarity = 0;
    for (final num in leftList) {
      final count = rightCounts[num] ?? 0;
      totalSimilarity += num * count;
    }
    return totalSimilarity.toString();
  }
}
