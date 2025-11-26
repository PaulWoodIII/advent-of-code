/// Common collection helpers shared across Advent of Code solutions.
class CollectionUtils {
  const CollectionUtils._();

  /// Splits the iterable into chunks of [size].
  static Iterable<List<T>> chunked<T>(Iterable<T> source, int size) sync* {
    if (size <= 0) {
      throw ArgumentError.value(size, 'size', 'must be positive');
    }
    final current = <T>[];
    for (final value in source) {
      current.add(value);
      if (current.length == size) {
        yield List.unmodifiable(current);
        current.clear();
      }
    }
    if (current.isNotEmpty) {
      yield List.unmodifiable(current);
    }
  }
}
