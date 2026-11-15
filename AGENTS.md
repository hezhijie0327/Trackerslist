# AGENTS.md

Trackerslist maintains and aggregates BitTorrent tracker lists from various sources, using bash scripts and automated GitHub Actions to update the lists daily. See [README.md](README.md) for output file descriptions.

## HANDOVER.md

When a multi-step task is interrupted, write progress to `HANDOVER.md` so the next session can pick up where you left off. Include: what was done, what remains, key decisions made, and the next concrete step. Delete the file when the task is complete.

## Behavioral Guidelines

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

### 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them — don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

### 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

### 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it — don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

### 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

**Additional rules:**
- Be concise in output but thorough in reasoning.
- Do not re-read files you have already read.
- User instructions always override this file.
- Don't wrestle with indentation in the Edit tool — focus on logic, let the project's formatter fix formatting. Use `sed` or `python3` freely when the Edit tool struggles with whitespace.

## Git commit convention

Every commit subject starts with a type prefix — `feat` / `fix` / `chore` / `docs` / `revert` / `refactor` / `perf` / `test` / `build` — optionally scoped: `fix(toolbar): ...`. Subject: imperative, lowercase start, no trailing period, aim ≤ 72 chars; detail goes in the body after a blank line (why, not what); breaking changes take `!` before the colon or a `BREAKING CHANGE:` body footer. Never rewrite pushed history.

- Commit incrementally — one logical change per commit, after lint and tests pass. Present changes for review before committing.
- PRs: link the issue, summarize the change and verification (tests/benchmarks), and include config/log/pprof evidence for bug fixes.

### Co-Author Format

- Always add co-author information. If closing an issue in commit text, verify against `main` first: `gh issue view <issue-id>`.
- Only ONE co-author line is allowed. If multiple agents contributed, aggregate into ONE entry.

Format: `Co-authored-by: <AgentName> <Email>`

Valid examples (choose EXACTLY ONE):

```
Co-authored-by: ZCode <noreply@z.ai>
```

### Commit Messages

- Use conventional commits format: `type(scope): description`
- Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`
- Example: `feat(script): add IPv6 support to tracker validation`

### Branching

- Main branch: `main`
- Feature branches: `feature/description`
- Fix branches: `fix/description`

## Documentation format

Family-wide Markdown rules, shared verbatim across all ZJ projects:

- **Language**: AGENTS.md, AUDIT.md, DESIGN.md and other agent-facing docs are English; README.md is Chinese (human-facing). Keep literal UI strings and code identifiers verbatim.
- **AGENTS.md skeleton** — generic sections first, then project; omit sections that don't apply, keep the order:
  `# AGENTS.md` → 1–2 sentence intro (what the project is + key doc links) → Behavioral Guidelines → Git commit convention → Documentation format → Project → Commands → Architecture → Conventions (Gotchas as a subsection) → project-specific sections → Key Docs.
- **README.md skeleton**: `# <project>` → badge block → one-line positioning + stack + key links → 特性 → 快速开始 → 配置 / 用法 → 文档 → License (omit as needed).
- **README badges** (shields.io, after the title, in order): Version (only where a real version exists, linked to the repo's GitHub releases), License (Apache 2.0 with Commons Clause — every project), primary-language badge (Go / TypeScript / Bash / Python / Docker), Biome for TypeScript projects; pure data/config repos get License only. Version links use the real GitHub repo name.
- **Formatting**: ATX headings (`#`), never skip a level; code fences always carry a language tag (`bash`, `go`, `json`, `text` for trees); tables for structured reference; no decorative emoji in headings or bullets; bold for key terms only.

## Project

This repository maintains and aggregates BitTorrent tracker lists from various sources. It contains scripts to fetch, validate, and combine tracker lists into standardized formats. The project uses bash scripting and automated GitHub Actions to update the tracker lists daily.

## Commands

### Main Build Process
- `bash release.sh` - The main build command that fetches, processes, and outputs all tracker lists
- The script creates combined, verified, and excluded tracker lists in multiple formats

### GitHub Actions
- Automated builds run daily via GitHub Actions at midnight UTC
- Manual builds can be triggered via "workflow_dispatch" in GitHub Actions UI
- Build process installs dependencies and executes the release.sh script

## Conventions

### Bash Scripting

#### Formatting
- Use 4-space indentation (not tabs)
- Maximum line length: 120 characters
- Include function headers with brief descriptions
- Use uppercase for global constants and arrays

#### Naming Conventions
- Functions: `PascalCase` with descriptive names (e.g., `GetData`, `AnalyseData`)
- Variables: `snake_case` for local variables (e.g., `tracker_list`)
- Arrays: `snake_case` with plural names (e.g., `tracker_list_http`)
- Constants: `UPPER_SNAKE_CASE`

#### Error Handling
- Check command exit codes after critical operations
- Use `set -e` to exit on errors in critical sections
- Validate inputs before processing

### Data Files

#### Format Standards
- Tracker URLs must follow pattern: `protocol://domain:port/announce`
- Accepted protocols: `http`, `https`, `udp`, `ws`, `wss`
- Domain must resolve to a valid IP address
- Port must be within valid range (1-65535)

#### File Organization
- `data/` directory contains protocol-specific seed data
- Root directory contains output files:
  - `trackerslist_tracker.txt` - Verified trackers
  - `trackerslist_exclude.txt` - Invalid trackers
  - `trackerslist_combine.txt` - All trackers
  - `*_aria2.txt` - Comma-separated versions for aria2

## Testing

### Testing Individual Components
Since this project primarily uses bash scripts without a formal test suite, testing is done by:

1. **Running the release script manually:**
   ```bash
   bash release.sh
   ```

2. **Validating output files:**
   - Check `trackerslist_tracker.txt` contains valid tracker URLs
   - Verify `trackerslist_exclude.txt` contains invalid/unreachable trackers
   - Ensure `trackerslist_combine.txt` contains all trackers
   - Validate aria2 format files have proper comma separation

3. **Manual URL validation:**
   ```bash
   # Check if trackers follow the expected format
   grep -E '^(http|https|udp|ws|wss):[\/]{2}.*:[0-9]{1,5}/announce$' trackerslist_tracker.txt
   ```

## Dependencies

### System Requirements
- Bash shell
- `curl` for fetching remote data
- `nmap` for network validation
- `dig` for DNS resolution

### GitHub Actions
- Runs on `ubuntu-latest` 
- Installs `nmap` via apt before running the build

## Workflow for Making Changes

1. Modify the `release.sh` script or data files as needed
2. Test locally with `bash release.sh`
3. Verify output files are correctly formatted
4. Commit changes with conventional commit message
5. Push to trigger GitHub Actions for full validation
6. Review Actions output to ensure build succeeds

## Common Issues

- Network timeouts when fetching remote tracker lists
- Invalid tracker URLs in source data
- DNS resolution failures for tracker domains
- Port accessibility issues during validation

## Security Considerations

- Only fetch tracker URLs from trusted sources
- Validate all input data before processing
- Avoid executing any code from fetched tracker lists
- Sanitize URLs before DNS/network operations
