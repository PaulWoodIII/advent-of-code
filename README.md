# Advent of Code Dart Workspace

This repository provides a Dart-first developer environment for solving Advent of Code puzzles with automation, benchmarking, and AI workflow support.

## Layout

- `bin/` – CLI entry points. `aoc.dart` executes solvers.
- `lib/core/` – Shared infrastructure (registry, runner, input loading).
- `lib/years/` – Puzzle implementations grouped by year (`year2024/`, `year2025/`, ...).
- `data/inputs/<year>/` – Puzzle input files organized per year/day.
- `tools/` – Automation utilities (fetching, submission, benchmarking).
- `test/` – Unit and integration tests using `package:test`.
- `docs/` – Additional guides and AI workflow references.

## Getting Started

> Toolchain setup and automation scripts are added in later steps of this plan. After installing the Dart SDK run `dart pub get` to install dependencies.
