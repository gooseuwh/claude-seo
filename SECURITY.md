# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability, please report it responsibly:

1. **Do NOT open a public issue**
2. Open a [GitHub Security Advisory](https://github.com/gooseuwh/claude-seo/security/advisories/new) on this repo
3. Or contact the maintainer directly

## Supported Versions

Only the latest version receives security updates.

## Security Practices

- No credentials or API keys are stored in this repository
- Install scripts write only to user-level directories (`~/.claude/`)
- Python dependencies install in isolated virtual environments
- SSRF protection blocks private/internal IPs in all network scripts
- DNS rebinding prevention: resolved IPs are locked in before connecting

## Data Privacy

### What data leaves your machine

**Default mode (no MCP integrations):** URLs are fetched by local Python scripts or Claude Code's built-in WebFetch. No data is sent to Anthropic or third parties beyond the target website itself.

**CSV imports (`/seo imports`):** All analysis runs locally. Your ScreamingFrog and Ahrefs export files are read from disk and analyzed in-context. No CSV data is sent externally.

**Optional MCP integrations (Ahrefs, Google Search Console, etc.):** When you configure and use MCP servers, target URLs, domains, and keywords are sent to those services' API endpoints. Their respective privacy policies apply.

### Sensitive output files

Audit report files (`FULL-AUDIT-REPORT.md`, `ACTION-PLAN.md`, `IMPORT-ANALYSIS.md`, etc.) are excluded from git commits via `.gitignore`. Treat them as confidential work product — they may contain client URLs, competitor data, or keyword strategies.

### Audit log

`~/.claude/skills/seo/audit.log` records when external API tools are called. It stores tool names and timestamps only — parameter values are SHA-256 hashed, never stored in plaintext.
