# Rule: Persistent Development Logging

## Summary
Every time Antigravity (or any other AI agent) performs a task or modifies files in this project, it MUST record the activity in `DEVELOPMENT_LOG.md`.

## Detailed Instructions
1.  **File Location**: `DEVELOPMENT_LOG.md` (Project Root).
2.  **When to Update**: After completing any task or making non-trivial changes.
3.  **Format**:
    - Use a header for the date: `## [YYYY-MM-DD]`.
    - Group activities under "Task" headers.
    - Include:
        - **Objective**: What was the user's goal?
        - **Action**: What did the agent do? (List files changed or commands run).
        - **Status**: Current state of the task (Completed, In Progress, etc.).
4.  **Purpose**: To ensure that the state of the project and the context of previous AI interactions are preserved for future sessions.
