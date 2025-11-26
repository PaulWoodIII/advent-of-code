# Advent of Code Development Guide

## Quick Start

1. Paste your puzzle text from adventofcode.com (including `--- Day X: Title ---` header) into Cursor
2. Reference [`START_NEW_DAY.md`](START_NEW_DAY.md) for instructions
3. Cursor will scaffold, implement, and test
4. Add puzzle inputs manually
5. Run tests to verify

**Total time**: ~3-4 minutes per day

## How It Works

When you paste puzzle text and reference START_NEW_DAY.md, Cursor will:
- Extract day number from `--- Day X: Title ---` format
- Run `dart tools/scaffold_day.dart` to create files
- Review previous day solutions for patterns
- Implement the solution
- Update test expectations
- Run tests until the example passes

## Pattern Selection

Reference similar previous days:
- **Grid/2D arrays** → `day04.dart`
- **Lists/arrays** → `day02.dart`
- **Number parsing** → `day01.dart`
- **String processing** → `day03.dart`

## Files

- [`README.md`](README.md) - This file (human guide)
- [`START_NEW_DAY.md`](START_NEW_DAY.md) - LLM instructions (reference this in conversations)