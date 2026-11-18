# FinWise Global AI Developer Instructions

As an AI assistant working on this project, you MUST universally apply these rules to EVERY coding session, without the user needing to remind you.

## 1. Git & Branching Rules
- **NEVER** push code directly to the `main` branch.
- When starting a new task, always execute git commands to create and checkout a new branch: `feat/<JIRA-ID>-<feature-name>`.

## 2. Jira Smart Commits (CRITICAL)
- You must write commit messages using the Jira Smart Commit format so our Jira board updates automatically.
- **Format**: `<type>: [<JIRA-ID>] <Commit Description> #<transition>`
- Use `#in-progress` for ongoing work.
- Use `#done` ONLY if the feature is 100% complete.
- **Example**: `feat: [AIO-38] implement gemini scanner api #in-progress`

## 3. Workflow Enforcement
- If the user asks you to write code but does NOT provide a Jira ID (e.g., AIO-XX), you MUST ask them: "Please provide your Jira Ticket ID before I commit this code."
- Once you have the Jira ID, automatically run `git add .`, `git commit -m "..."`, and `git push -u origin <branch>`.
