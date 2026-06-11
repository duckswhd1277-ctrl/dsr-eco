---
name: github-issues-creator
description: Automatically create GitHub Issues in batch. Use this skill whenever the user wants to create one or more GitHub Issues, especially when they want to bulk-create issues from a list, automate issue creation as part of a workflow, or need to quickly populate a repository with multiple issues at once. Also use this when the user mentions creating issues for bugs, features, improvements, or tasks in their codebase.
---

# GitHub Issues Creator

Automatically create GitHub Issues in batch using the GitHub CLI (`gh`). This skill handles single or bulk issue creation with support for custom titles, bodies, and labels.

## When to use this skill

- **Bulk creating issues** from a list or specification
- **Automating issue creation** as part of a larger workflow
- **Creating tracked tasks** for a project (bugs, features, improvements)
- **Populating a repository** with issues from specifications or documentation
- **Standardizing issue creation** with consistent formatting and labeling

## Prerequisites

- GitHub CLI (`gh`) installed and authenticated
- Git repository with a remote GitHub origin
- Access to create issues in the target repository

## Basic usage

### Create a single issue

```
I want to create an issue in dsr-eco about fixing the mobile responsive layout.
Title: "Mobile responsive layout issues"
Body: "The dashboard doesn't display correctly on mobile devices. Need to add breakpoints for ~768px and tablet sizes."
Label: "bug"
```

### Create multiple issues at once

```
Create these 5 issues in dsr-eco:
1. Title: "Add dark mode", Body: "Support dark mode...", Label: "enhancement"
2. Title: "Performance issue", Body: "Loading is slow...", Label: "bug"
...
```

## How it works

The skill:
1. Accepts issue details (title, body, label, optional repository name)
2. Uses the `gh issue create` command to create each issue via GitHub CLI
3. Provides clear feedback on success/failure for each issue
4. Defaults to the `dsr-eco` repository if not specified
5. Supports batch creation with progress tracking

## Issue specification format

When providing issues, include these details:

- **Title** (required): One-line summary
- **Body** (required): Detailed description of the issue
- **Label** (optional): bug, enhancement, improvement, feature, documentation, etc.
- **Repository** (optional): Defaults to `dsr-eco` if not specified

## Example batch creation

```markdown
Create these issues:

1. 🐛 Fix document click handler
   Body: Document library click function is not implemented
   Label: bug

2. ⚠️ Add input validation
   Body: Form inputs need stronger validation
   Label: enhancement

3. ⚠️ Mobile responsive design
   Body: Dashboard needs mobile breakpoints
   Label: bug
```

## Output

The skill confirms each issue:
- ✅ **Success**: Shows issue URL and number
- ❌ **Failure**: Shows error message for troubleshooting

Example output:
```
[1/3] 🐛 Fix document click handler
  ✅ Created: https://github.com/user/dsr-eco/issues/15

[2/3] ⚠️ Add input validation
  ✅ Created: https://github.com/user/dsr-eco/issues/16

[3/3] 🐛 Mobile responsive design
  ✅ Created: https://github.com/user/dsr-eco/issues/17

Summary: 3/3 issues created successfully
```

## Tips

- **Batch creation efficiency**: Provide all issues at once rather than one-by-one
- **Clear labels**: Use consistent labels (bug, enhancement, feature, etc.) so issues are easy to categorize
- **Rich descriptions**: Include context, steps to reproduce (for bugs), or use cases (for features)
- **Repository scope**: If creating issues in a different repository, specify it clearly in the issue details

## Troubleshooting

- **"GitHub CLI not found"**: Install gh: `winget install github.cli` (Windows) or follow https://cli.github.com/
- **"Not authenticated"**: Run `gh auth login` to authenticate with GitHub
- **"Repository not found"**: Ensure the repository name is correct and you have access to it
- **Label doesn't exist**: Custom labels will be created if they don't exist in the repository
