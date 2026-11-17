# AGENTS.md

Trackerslist aggregates BitTorrent tracker lists from multiple sources and verifies them with concurrent DNS/TCP/UDP checks. See [README.md](README.md) for output file descriptions.

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

## Documentation format

Family-wide Markdown rules, shared verbatim across all ZJ projects:

- **Language**: AGENTS.md, AUDIT.md, DESIGN.md and other agent-facing docs are English; README.md is Chinese (human-facing). Keep literal UI strings and code identifiers verbatim.
- **AGENTS.md skeleton** — generic sections first, then project; omit sections that don't apply, keep the order:
  `# AGENTS.md` → 1–2 sentence intro (what the project is + key doc links) → Behavioral Guidelines → Git commit convention → Documentation format → Project → Commands → Architecture → Conventions (Gotchas as a subsection) → project-specific sections → Key Docs.
- **README.md skeleton**: `# <project>` → badge block → one-line positioning + stack + key links → 特性 → 快速开始 → 配置 / 用法 → 文档 → License (omit as needed).
- **README badges** (shields.io, after the title, in order): Version (only where a real version exists, linked to the repo's GitHub releases), License (Apache 2.0 with Commons Clause — every project), primary-language badge (Go / TypeScript / Bash / Python / Docker), Biome for TypeScript projects; pure data/config repos get License only. Version links use the real GitHub repo name.
- **Formatting**: ATX headings (`#`), never skip a level; code fences always carry a language tag (`bash`, `go`, `json`, `text` for trees); tables for structured reference; no decorative emoji in headings or bullets; bold for key terms only.

## Project

Trackerslist fetches tracker lists from public sources, normalizes and deduplicates them, verifies reachability concurrently, and publishes verified/excluded/combined lists plus aria2 (comma-separated) variants. Updated daily via GitHub Actions.

## Commands

```bash
# Full build: fetch, analyse, verify, write all six output files
python3 build.py
```

Importable stages for testing:
```bash
python3 -c "import build; print(len(build.analyse_data(build.get_data())))"
```

## Architecture

1. `get_data()` downloads five URL groups in parallel and concatenates them.
2. `analyse_data()` sanitizes lines (`tr -cd "[:alnum:]-./:_\n"`, lowercase, strip `.php`), keeps URLs matching the tracker regex, and assigns default ports to portless URLs.
3. `verify()` runs per tracker in a 64-worker thread pool: DNS A/AAAA resolution, TCP connect to the tracker port, UDP probe via `nmap -sU` for udp trackers and port 6969.
4. `output_data()` writes sorted unique `dist/{tracker,exclude,combine}.txt` and `*_aria2.txt`.

## Conventions

### Python (build.py)
1. snake_case functions/variables, UPPER_SNAKE_CASE constants
2. 4-space indentation, stdlib only except `nmap` for UDP probes
3. Downloads go through `download()` so tests can inject fixtures

### Gotchas
- A portless `udp://host/announce` feeds **both** the udp (:6969) and nossl (:80) normalization pipelines, like the original parallel greps — do not collapse them into elif.
- The `/announce` → `:port/announce` substitution is anchored to end-of-line: `http://announce.example/announce` contains `/announce` twice, an unanchored replace corrupts it.
- TCP verification is a real connect to the tracker port (the original only checked nmap host discovery, i.e. ping). Trackers on hosts that are up but with a closed port are now excluded — this is intentional.
- UDP verification still uses `nmap -sU` and greps "Host is up", matching the original semantics.
- Protocol normalization by port (80/8080 → http/ws, 443/8443 → https/wss, 6969 → http/ws) happens before verification.

### Data Files
- `custom/{http,udp,ws}.txt` — custom seed lists (fetched from main via URL)
- Outputs: `dist/tracker.txt`, `dist/exclude.txt`, `dist/combine.txt` and `dist/*_aria2.txt` (comma-separated, trailing newline)

## Dependencies

- Python 3.9+ (stdlib only)
- `nmap` for UDP probes (`sudo apt install nmap` in CI)

## Key Docs

- [README.md](README.md) — output file descriptions (Chinese)
