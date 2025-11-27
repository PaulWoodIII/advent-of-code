# Starting a New Day - Instructions

This project provides a Dart-first solving of  Advent of Code puzzles with automation, benchmarking, and AI workflow support.

## Project Details

- **GitHub Repository**: `https://github.com/PaulWoodIII/advent-of-code.git`
- **Linear Team**: `PaulWoodWare`
- **Linear Project**: `Advent of Code`

**Important**: When creating or updating Linear issues, ensure they are linked to the correct GitHub repository above to prevent misattribution to other repositories.

This prompt is used on a puzzle by puzzle basis, given a new Advent of Code puzzle do the following tasks with the human developer's assistance


1. Extract the day number from `--- Day X: Title ---` header.

1. Name this `Chat Day X 2024` based on the year we are working on

1. Confirm the year with the developer. If the year is not clear from context (puzzle source, conversation, or project state), ask the developer: "What year is this puzzle for?" Do not assume - always confirm before running any scripts.

1. Search Linear for an existing issue for this day:
   - Search Linear issues in the "Advent of Code" project for a title matching `Day X` (where X is the day number)
   - If an existing issue is found, use that issue ID and skip to step 5
   - If no existing issue is found, create a new Linear issue:
     - Title: `Day X` (just the day number, no puzzle title)
     - Team: "PaulWoodWare"
     - Project: "Advent of Code" (ensure the issue is linked to the correct GitHub repository: `https://github.com/PaulWoodIII/advent-of-code.git`)
     - Description: Include the puzzle description or link to the puzzle page
     - Assign to: "me" (the developer)
     - Status: Will default to "Todo"
   - Save the issue ID for status updates throughout the workflow

1. Review previous solutions in `lib/years/year2024/` or `lib/years/year2025/` depending on what year you are working on:
   - `day01.dart` - number parsing
   - `day02.dart` - list processing
   - `day03.dart` - string processing
   - `day04.dart` - grid/2D arrays
   Reference the most similar day for patterns, please note that advent of code is a learning tool where new puzzles build on what has been learned in previous puzzles. Documentation in our solve code will help us develop future days faster. 

1. Run scaffold: `dart tools/scaffold_day.dart [YEAR] X` (use the confirmed year, not a placeholder)
   Creates solver, test, and input placeholder files. Follow the printed instructions (from scaffold output) to add inputs to the new example file.

1. Update Linear issue status to "In Progress":
   - Use the Linear issue ID from step 4
   - Update the issue state to "In Progress"
   - This marks the day as actively being worked on

1. Implement `_solvePart1()` using patterns from similar previous days.

1. Update test: Replace `'TODO'` in `test/years/year[YEAR]/dayXX_test.dart` with expected result from the puzzle example.

1. Run tests and make edits until example passes: `dart test test/years/year[YEAR]/dayXX_test.dart`

1. Once the example works as expected, ask the developer to add their specific input file into the new txt file in `data/inputs`

1. Verify: `dart bin/aoc.dart --year [YEAR] --day X` where X is the current day and [YEAR] is the confirmed year.
     Inform the developer of the solution result. Ask the developer for Part Two assuming a positive result.

1. If the solution fails the developer will inform you of it and work with you to debug the solution, if not the developer will place Part Two into the conversation

1. Run: `dart tools/scaffold_day.dart [YEAR] X --part2`, then implement `_solvePart2()` using the Part Two puzzle description. Keep each solve function separate so that our tests continue to work as expected.

If the prompt includes any new example cases, create new files the same naming convention the scaffold has already created for the part one but ending with part2.text instead.

1. Inform the developer of our part two solution. 

1. Review and document your work, tests, and files. Add documentation so that future days know what computer science concept was learned in this puzzle so future runs of this process can use a similar solution. This creates a great flywheel effect of learning and development.

1. Create a blog post in `docs/dayXX_blog_post.md` (where XX is the day number with zero-padding):
   - Write for an audience who may be new to Dart and is following along with Advent of Code
   - Explain the problem in an accessible way
   - Show the naive approach (if applicable) and why it works or fails
   - Explain the key insights and algorithm clearly
   - Highlight Dart language features used in the solution
   - Include code examples with explanations
   - Discuss complexity analysis and real-world applications
   - Reference the full solution code at the end
   - Follow the format of existing blog posts (e.g., `docs/day11_blog_post.md`, `docs/day12_blog_post.md`)

1. After the developer confirms the day's work is complete, commit and push the changes:
   - Stage all changes: `git add .`
   - Write a thoughtful commit message focused on Day X that includes:
     - The day number and puzzle title (extracted from puzzle description)
     - Key algorithms or concepts used
     - Brief summary of the solution approach
     - **Important**: Do NOT include the actual solution values (answer numbers) in the commit message
     - Example: `git commit -m "Day X: Puzzle Title - Algorithm/Concept Used\n\nBrief description of solution approach and key insights."`
   - (Optional) Create a pull request to test the "In Review" workflow:
     - Create a branch: `git checkout -b day-[YEAR]-[X]`
     - Commit the changes on the branch
     - Push the branch: `git push origin day-[YEAR]-[X]`
     - Create a PR via GitHub (or ask the developer to create one)
     - Update Linear issue status to "In Review"
     - After PR is merged (or if skipping PR), proceed to push to main
   - Push to GitHub: `git push origin main` (or merge the PR if using PR workflow)
   - Update Linear issue status to "Done":
     - Use the Linear issue ID from step 4
     - Update the issue state to "Done"
   - Confirm the push was successful and provide the commit hash to the developer.