import '../../core/solver.dart';

/// Solver for Advent of Code 2024 Day 9: Disk Fragmenter.
///
/// This puzzle involves compacting files on a disk by moving blocks
/// from the end to fill gaps, then calculating a checksum.
///
/// Part 1: Move file blocks one at a time from the end of the disk
/// to the leftmost free space block until no gaps remain, then calculate
/// the filesystem checksum.
///
/// Part 2: Move whole files at once, starting with the highest file ID,
/// moving each file to the leftmost span of free space that can fit it.
/// Each file moves at most once.
class Year2024Day09 extends DaySolver {
  @override
  int get year => 2024;

  @override
  int get day => 9;

  @override
  String solvePart1(List<String> input) {
    return _solvePart1(input);
  }

  @override
  String solvePart2(List<String> input) {
    return _solvePart2(input);
  }

  /// Part 1: Compact disk and calculate filesystem checksum.
  ///
  /// Algorithm:
  /// 1. Parse the disk map string (alternating file length and free space length)
  /// 2. Build initial disk layout as a list of file IDs or null (free space)
  /// 3. Compact by moving blocks from right to left:
  ///    - Find the rightmost file block
  ///    - Find the leftmost free space
  ///    - Move the block
  ///    - Repeat until no more moves are possible
  /// 4. Calculate checksum: sum of (position * file_id) for all file blocks
  ///
  /// Computer Science Concepts:
  /// - String parsing and digit extraction
  /// - Array/list manipulation and in-place modification
  /// - Greedy algorithm (always move rightmost block to leftmost gap)
  /// - Simulation of disk compaction process
  String _solvePart1(List<String> input) {
    if (input.isEmpty || input[0].isEmpty) {
      return '0';
    }
    final diskMap = input[0];
    // Parse disk map and build initial layout
    final disk = _buildInitialDisk(diskMap);
    // Compact the disk
    _compactDisk(disk);
    // Calculate checksum
    var checksum = 0;
    for (var i = 0; i < disk.length; i++) {
      if (disk[i] != null) {
        checksum += i * disk[i]!;
      }
    }
    return checksum.toString();
  }

  /// Builds the initial disk layout from the disk map string.
  ///
  /// The disk map alternates between file length and free space length.
  /// Returns a list where each element is either a file ID (int) or null (free space).
  List<int?> _buildInitialDisk(String diskMap) {
    final disk = <int?>[];
    var fileId = 0;
    var isFile = true;
    for (var i = 0; i < diskMap.length; i++) {
      final length = int.parse(diskMap[i]);
      if (isFile) {
        // Add file blocks
        for (var j = 0; j < length; j++) {
          disk.add(fileId);
        }
        fileId++;
      } else {
        // Add free space blocks
        for (var j = 0; j < length; j++) {
          disk.add(null);
        }
      }
      isFile = !isFile;
    }
    return disk;
  }

  /// Compacts the disk by moving blocks from right to left.
  ///
  /// Repeatedly finds the rightmost file block and moves it to the
  /// leftmost free space until no more moves are possible.
  void _compactDisk(List<int?> disk) {
    while (true) {
      // Find rightmost file block
      var rightmostFileIndex = -1;
      for (var i = disk.length - 1; i >= 0; i--) {
        if (disk[i] != null) {
          rightmostFileIndex = i;
          break;
        }
      }
      if (rightmostFileIndex == -1) {
        // No more file blocks to move
        break;
      }
      // Find leftmost free space
      var leftmostFreeIndex = -1;
      for (var i = 0; i < rightmostFileIndex; i++) {
        if (disk[i] == null) {
          leftmostFreeIndex = i;
          break;
        }
      }
      if (leftmostFreeIndex == -1) {
        // No more gaps to fill
        break;
      }
      // Move the block
      final fileId = disk[rightmostFileIndex];
      disk[rightmostFileIndex] = null;
      disk[leftmostFreeIndex] = fileId;
    }
  }

  /// Part 2: Compact disk by moving whole files and calculate checksum.
  ///
  /// Algorithm:
  /// 1. Parse the disk map string and build initial disk layout
  /// 2. Find all files and their positions/sizes
  /// 3. Process files in decreasing order of file ID (highest first):
  ///    - For each file, find the leftmost contiguous free space that can fit it
  ///    - If such space exists and is to the left of the file, move the entire file
  ///    - Each file moves at most once
  /// 4. Calculate checksum: sum of (position * file_id) for all file blocks
  ///
  /// Computer Science Concepts:
  /// - String parsing and digit extraction
  /// - Array/list manipulation and in-place modification
  /// - Greedy algorithm (move files in order, always to leftmost fitting space)
  /// - Contiguous span detection
  /// - File-level compaction vs block-level compaction
  String _solvePart2(List<String> input) {
    if (input.isEmpty || input[0].isEmpty) {
      return '0';
    }
    final diskMap = input[0];
    // Parse disk map and build initial layout
    final disk = _buildInitialDisk(diskMap);
    // Compact by moving whole files
    _compactDiskByFiles(disk);
    // Calculate checksum
    var checksum = 0;
    for (var i = 0; i < disk.length; i++) {
      if (disk[i] != null) {
        checksum += i * disk[i]!;
      }
    }
    return checksum.toString();
  }

  /// Compacts the disk by moving whole files.
  ///
  /// Processes files in decreasing order of file ID (highest first).
  /// For each file, finds the leftmost contiguous free space that can fit it
  /// and moves the entire file there if such space exists to the left of the file.
  void _compactDiskByFiles(List<int?> disk) {
    // Find all files and their positions
    final files = <_FileInfo>[];
    var currentFileId = -1;
    var fileStart = -1;
    for (var i = 0; i < disk.length; i++) {
      final fileId = disk[i];
      if (fileId != null) {
        if (fileId != currentFileId) {
          // New file started
          if (currentFileId != -1) {
            // Save previous file
            files.add(_FileInfo(
              id: currentFileId,
              start: fileStart,
              length: i - fileStart,
            ));
          }
          currentFileId = fileId;
          fileStart = i;
        }
      } else {
        // Free space
        if (currentFileId != -1) {
          // Save previous file
          files.add(_FileInfo(
            id: currentFileId,
            start: fileStart,
            length: i - fileStart,
          ));
          currentFileId = -1;
        }
      }
    }
    // Save last file if exists
    if (currentFileId != -1) {
      files.add(_FileInfo(
        id: currentFileId,
        start: fileStart,
        length: disk.length - fileStart,
      ));
    }
    // Process files in decreasing order of file ID
    files.sort((a, b) => b.id.compareTo(a.id));
    for (final file in files) {
      // Find leftmost contiguous free space that can fit this file
      final targetStart = _findLeftmostFreeSpace(disk, file.length, file.start);
      if (targetStart != -1) {
        // Move the file
        _moveFile(disk, file.start, file.length, targetStart);
      }
    }
  }

  /// Finds the leftmost contiguous free space that can fit a file of given length.
  ///
  /// Only considers free space to the left of [maxPosition].
  /// Returns the start index of the free space, or -1 if none found.
  int _findLeftmostFreeSpace(List<int?> disk, int length, int maxPosition) {
    var consecutiveFree = 0;
    var start = -1;
    for (var i = 0; i < maxPosition; i++) {
      if (disk[i] == null) {
        if (consecutiveFree == 0) {
          start = i;
        }
        consecutiveFree++;
        if (consecutiveFree >= length) {
          return start;
        }
      } else {
        consecutiveFree = 0;
        start = -1;
      }
    }
    return -1;
  }

  /// Moves a file from [sourceStart] to [targetStart].
  ///
  /// Assumes both locations have enough space and the file is contiguous.
  void _moveFile(List<int?> disk, int sourceStart, int length, int targetStart) {
    // Get the file ID
    final fileId = disk[sourceStart];
    // Clear source location
    for (var i = 0; i < length; i++) {
      disk[sourceStart + i] = null;
    }
    // Write to target location
    for (var i = 0; i < length; i++) {
      disk[targetStart + i] = fileId;
    }
  }
}

/// Represents information about a file on the disk.
class _FileInfo {
  final int id;
  final int start;
  final int length;

  _FileInfo({
    required this.id,
    required this.start,
    required this.length,
  });
}
