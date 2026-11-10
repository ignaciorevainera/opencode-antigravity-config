---
name: writing-commits
description: Analyzes staged files and creates segmented, well-scoped commits following Conventional Commits format. Use this skill whenever the user asks to commit changes, stage and commit, write commit messages, or split changes into multiple commits. Also trigger when the user says things like "hacé el commit", "commitea los cambios", "separame los commits", "quiero commitear", or describes a set of changes that should be committed. Never commit automatically — only when the user explicitly requests it.
---

# Git Commit

A skill for analyzing staged changes and producing segmented, meaningful commits that follow Conventional Commits conventions.

## Workflow

1. Run `git diff --cached --name-only` to list all staged files. Never write a commit message without reading the actual diff first.
2. Run `git diff --cached` to read the full staged diff and understand what each file contains.
3. Group files by logical change. A component refactor, a config update, a style fix, a migration, and a dependency bump are separate commits even if all files are staged simultaneously.
4. Run `git reset HEAD` to unstage everything.
5. For each logical group, stage the relevant files and commit them in sequence.
6. Never run `git push`. Staging, grouping, and committing are within scope. Pushing is always left to the user.

## Commit Message Format

Every commit message must follow this structure exactly:

```
type(scope): description
```

- The description is lowercase, imperative mood, no period at the end.
- The entire message must be in English — never in any other language regardless of what language the user writes in.
- The scope is optional but strongly preferred when the change is localized to a component, route, directory, or feature area.
- Never use generic scopes like `misc`, `various`, `updates`, or `changes`. If no specific scope applies, omit it entirely.

## Types

| Type       | Use when                                                                    |
| ---------- | --------------------------------------------------------------------------- |
| `feat`     | New functionality visible to the user or consumer                           |
| `fix`      | Corrects a bug or broken behavior                                           |
| `style`    | Whitespace, formatting, class order, visual cleanup — no logic change       |
| `refactor` | Restructures code without changing behavior or adding features              |
| `chore`    | Config files, tooling, dependencies, gitignore, scripts, non-source changes |
| `docs`     | Markdown files, comments, or documentation only                             |
| `test`     | Adds or modifies tests with no production code change                       |
| `perf`     | Measurable performance improvement                                          |
| `build`    | Build system, bundler config, or compilation output                         |
| `ci`       | CI/CD pipeline configuration                                                |

## Examples

```
feat(auth): add session expiry check
fix(form): prevent double submit on slow network
style(navbar): align logo to baseline
refactor(lib): extract token validation to separate function
chore(deps): upgrade drizzle-orm to 0.30
chore: add .env.example to gitignore
docs(readme): update local setup instructions
test(auth): add missing logout edge case
```

## Rules

- Never describe what file changed — describe what the commit does. `update Navbar.astro` is not valid. `fix(navbar): remove duplicate import` is valid.
- Never use `git commit -m` with a message not derived from reading the actual diff.
- Never invent or guess what a file contains — read the diff before writing the message.
- Never include `WIP`, `temp`, `test commit`, `minor`, `small fix`, or any non-descriptive filler.
- Never add a commit body or footer unless there is a breaking change. Breaking changes require `BREAKING CHANGE:` in the footer with a one-line explanation of what breaks and the migration path.
- Never run `git push` under any circumstances.