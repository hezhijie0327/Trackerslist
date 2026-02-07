# Trackerslist Project Guide for Agentic Coding

## Project Overview
This repository maintains and aggregates BitTorrent tracker lists from various sources. It contains scripts to fetch, validate, and combine tracker lists into standardized formats. The project uses bash scripting and automated GitHub Actions to update the tracker lists daily.

## Build Commands

### Main Build Process
- `bash release.sh` - The main build command that fetches, processes, and outputs all tracker lists
- The script creates combined, verified, and excluded tracker lists in multiple formats

### GitHub Actions
- Automated builds run daily via GitHub Actions at midnight UTC
- Manual builds can be triggered via "workflow_dispatch" in GitHub Actions UI
- Build process installs dependencies and executes the release.sh script

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

## Code Style Guidelines

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

### Git Workflow

#### Commit Messages
- Use conventional commits format: `type(scope): description`
- Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`
- Example: `feat(script): add IPv6 support to tracker validation`

#### Branching
- Main branch: `main`
- Feature branches: `feature/description`
- Fix branches: `fix/description`

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