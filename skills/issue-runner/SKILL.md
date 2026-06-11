---
name: issue-runner
description: Track, manage, and execute GitHub Issues to keep projects organized and teams aligned. Use this skill whenever the user wants to monitor issue progress, track which issues are done vs in-progress, manage issue workflows, assign issues to team members, update issue status, link issues to code changes, or orchestrate work across multiple issues. Essential for sprint planning, progress tracking, and keeping the team aligned on issue status.
---

# Issue Runner

Track, manage, and execute GitHub Issues. This skill helps monitor progress, update status, assign work, and keep teams aligned on what's being worked on and what's complete.

## When to use this skill

- **Progress tracking** - See which issues are done, in-progress, or blocked
- **Sprint planning** - Organize issues by priority and assign to team members
- **Status updates** - Update issue status as work progresses
- **Issue linking** - Connect issues to pull requests and code changes
- **Team coordination** - Assign issues and track who's working on what
- **Workflow management** - Move issues through workflows (backlog → in-progress → done)
- **Bottleneck detection** - Find blocked or stalled issues

## How it works

The skill:
1. Lists all issues in a repository
2. Groups by status (Open, In Progress, Done)
3. Shows assignee, priority, and related PRs
4. Allows status updates and assignments
5. Provides summary and metrics

## Issue status workflow

```
Backlog → In Progress → In Review → Done
  ↓          ↓            ↓
Unassigned  Assigned    Blocked (re-open)
```

## Output format

### Issue Summary
```
Repository: dsr-eco
Total Issues: 15
- Open: 8
- In Progress: 4
- Done: 3

Status breakdown:
🔴 Blocked: 2
🟡 In Progress: 4
🟢 Done: 3
```

### Issue List View
```
#1 - 🐛 Document click handler [BUG] 
     Status: Open | Assigned: @user | Priority: High
     Related PR: #123

#2 - ⚠️ Mobile responsive layout [BUG]
     Status: In Progress | Assigned: @user2 | Priority: Critical
     Related PR: #124
```

## Operations

- **View all issues** - List all issues with status and assignment
- **Update status** - Move issue through workflow
- **Assign issue** - Assign to team member
- **Add label** - Categorize by type (bug, feature, etc.)
- **Link PR** - Connect issue to pull request
- **Close issue** - Mark as complete
- **Reopen issue** - Mark as still needing work
- **View metrics** - See progress and velocity

## Tips

- **Regular updates** - Update status daily to keep team aligned
- **Clear assignments** - Ensure each issue has an owner
- **Link work** - Connect issues to PRs for traceability
- **Priority levels** - Use labels to indicate urgency
- **Team visibility** - Share status regularly with team

## Integration with other skills

Works with:
- **github-issues-creator** - Create new issues
- **issue-writer** - Write quality issues from findings
- **PR reviews** - Link issues to pull requests
