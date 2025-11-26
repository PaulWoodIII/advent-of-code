import '../../core/solver.dart';

class Year2024Day03 extends DaySolver {
  @override
  int get year => 2024;

  @override
  int get day => 3;

  @override
  String solvePart1(List<String> input) {
    return _solvePart1(input);
  }

  @override
  String solvePart2(List<String> input) {
    return _solvePart2(input);
  }

  /// Part 1: Find all valid mul(X,Y) instructions and sum their results.
  /// Valid mul instructions must match exactly: mul( followed by 1-3 digits,
  /// comma, 1-3 digits, closing parenthesis.
  String _solvePart1(List<String> input) {
    // Combine all input lines into a single string
    final memory = input.join('');
    // Regex pattern: mul( followed by 1-3 digits, comma, 1-3 digits, closing paren
    final pattern = RegExp(r'mul\((\d{1,3}),(\d{1,3})\)');
    var total = 0;
    for (final match in pattern.allMatches(memory)) {
      final x = int.parse(match.group(1)!);
      final y = int.parse(match.group(2)!);
      total += x * y;
    }
    return total.toString();
  }

  /// Part 2: Find all valid mul(X,Y) instructions and sum their results,
  /// but only process mul instructions that are enabled.
  /// - do() enables future mul instructions
  /// - don't() disables future mul instructions
  /// - Only the most recent do() or don't() applies
  /// - At the beginning, mul instructions are enabled
  String _solvePart2(List<String> input) {
    // Combine all input lines into a single string
    final memory = input.join('');
    // Find all relevant patterns: do(), don't(), and mul(X,Y)
    // We need to process them in order based on their position
    final doPattern = RegExp(r'do\(\)');
    final dontPattern = RegExp(r"don't\(\)");
    final mulPattern = RegExp(r'mul\((\d{1,3}),(\d{1,3})\)');
    // Collect all matches with their positions
    final List<({int position, String type, int? x, int? y})> matches = [];
    for (final match in doPattern.allMatches(memory)) {
      matches.add((position: match.start, type: 'do', x: null, y: null));
    }
    for (final match in dontPattern.allMatches(memory)) {
      matches.add((position: match.start, type: "don't", x: null, y: null));
    }
    for (final match in mulPattern.allMatches(memory)) {
      matches.add((
        position: match.start,
        type: 'mul',
        x: int.parse(match.group(1)!),
        y: int.parse(match.group(2)!),
      ));
    }
    // Sort by position to process in order
    matches.sort((a, b) => a.position.compareTo(b.position));
    // Process matches in order, tracking enabled state
    var enabled = true;
    var total = 0;
    for (final match in matches) {
      if (match.type == 'do') {
        enabled = true;
      } else if (match.type == "don't") {
        enabled = false;
      } else if (match.type == 'mul' && enabled) {
        total += match.x! * match.y!;
      }
    }
    return total.toString();
  }
}
