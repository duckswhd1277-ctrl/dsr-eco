---
name: issue-writer
description: Validate code changes and write comprehensive GitHub Issues from code review findings. Use this skill whenever you've found bugs to report, need to create issues from code review findings, want to validate changes before issue creation, or need to ensure issue quality with detailed descriptions, reproduction steps, acceptance criteria, and expected vs actual behavior. Also use when documenting bugs discovered during testing or code inspection.
---

# Issue Writer

Validate code changes and write high-quality GitHub Issues with comprehensive descriptions, reproduction steps, and acceptance criteria. This skill transforms code review findings and bug discoveries into well-structured issues.

## When to use this skill

- **Bug discovery during code review** - Found issues that need to be reported
- **Testing findings** - Bugs discovered during manual or automated testing
- **Quality validation** - Ensure issues have enough detail for developers to fix
- **Issue standardization** - Consistent format across all issues in the repository
- **Complex bug reports** - Issues requiring reproduction steps and environment details
- **Acceptance criteria** - Defining clear requirements for issue resolution

## How it works

The skill:
1. Analyzes code changes or bug descriptions provided
2. Validates the issue quality and completeness
3. Structures the issue with complete details
4. Generates a GitHub-ready issue format

## Issue structure

```markdown
## Problem
[Clear description of the issue]

## Steps to Reproduce
1. First step
2. Second step
3. Expected result vs actual result

## Current Behavior
[What is actually happening]

## Expected Behavior
[What should happen]

## Environment
- Device/Browser: [e.g., Chrome on Windows]
- Version: [e.g., v1.0.0]

## Acceptance Criteria
- [ ] Criteria 1
- [ ] Criteria 2

## Related Code
[File paths or links to relevant code]
```

## Validation checklist

The skill ensures issues include:
- ✅ Clear title and description
- ✅ Reproduction steps (for bugs)
- ✅ Expected vs actual behavior
- ✅ Environment information
- ✅ Acceptance criteria
- ✅ Code references
- ✅ Appropriate label

Ready to be created with github-issues-creator skill.
