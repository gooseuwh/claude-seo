# Claude SEO Toolkit (Modified Version)

## ⚠️ Notice

This repository is a modified distribution of the original Claude SEO toolkit created by AgriciDaniel.

The structure and concept are based on the upstream project, but installation instructions, tooling flow, and documentation have been adapted for this version.

**Original project:** [https://github.com/AgriciDaniel](https://github.com/AgriciDaniel)

---

## Installation

Use Git Bash (recommended)

Run the modified installer:

```bash
curl -fsSL [https://raw.githubusercontent.com/gooseuwh/claude-seo/main/install.sh](https://raw.githubusercontent.com/gooseuwh/claude-seo/main/install.sh) | bash
```

This installs the Claude SEO skill into your local Claude Code environment.

**Installed location:** `~/.claude/skills/seo`

---

## Quick Start

Launch Claude Code:

```bash
claude
```

Run common SEO commands:

```bash
# Run a full site audit
/seo audit [https://example.com](https://example.com)

# Analyze a single page
/seo page [https://example.com/about](https://example.com/about)

# Check schema markup
/seo schema [https://example.com](https://example.com)

# Generate a sitemap
/seo sitemap generate

# Optimize for AI search
/seo geo [https://example.com](https://example.com)

# /seo audit — full site audit using parallel subagents
```

---

## Commands

| Command | Description |
| :--- | :--- |
| `/seo audit` | Full website audit with parallel subagent delegation |
| `/seo page` | Deep single-page analysis |
| `/seo sitemap` | Analyze existing XML sitemap |
| `/seo sitemap generate` | Generate new sitemap |
| `/seo schema` | Detect, validate, and generate Schema.org markup |
| `/seo images` | Image optimization analysis |
| `/seo technical` | Technical SEO audit (8 categories) |
| `/seo content` | E-E-A-T and content quality analysis |
| `/seo geo` | Generative Engine Optimization (AI search) |
| `/seo plan` | Strategic SEO planning |
| `/seo programmatic` | Programmatic SEO analysis |
| `/seo competitor-pages` | Competitor comparison page generation |
| `/seo hreflang` | Hreflang / international SEO audit |

---

## Programmatic SEO

`/seo programmatic [url|plan]`

Build large-scale SEO page systems from structured datasets.

**Capabilities:**
* Analyze programmatic pages for thin content
* Detect keyword cannibalization
* Plan URL template structures
* Internal linking automation
* Canonical strategy
* Index-bloat protection

**Quality limits:**
* ⚠️ **Warning:** 100+ pages
* 🛑 **Hard Stop:** 500+ pages without audit

---

## Competitor Comparison Pages

`/seo competitor-pages [url|generate]`

Generate high-converting comparison pages.

**Includes:**
* Feature comparison tables
* Product schema markup
* Conversion-focused layouts
* Comparison intent keyword targeting
* Fair competitor representation guidelines

---

## Hreflang / International SEO

`/seo hreflang [url]`

Validate and generate hreflang tags.

**Supports:**
* HTML
* HTTP headers
* XML sitemaps

**Checks include:**
* Self-referencing tags
* Return tags
* x-default
* ISO language / region validation

---

## Features

### Core Web Vitals

| Metric | Target |
| :--- | :--- |
| LCP | < 2.5s |
| INP | < 200ms |
| CLS | < 0.1 |

**Note:**
* INP replaced FID on March 12, 2024
* FID removed from Chrome tools on Sept 9, 2024

### E-E-A-T Analysis

Updated to September 2025 Quality Rater Guidelines.

**Evaluates:**
* Experience
* Expertise
* Authoritativeness
* Trustworthiness

**Signals analyzed include:**
* author credentials
* contact details
* transparency signals
* industry recognition

### Schema Markup

**Supported detection formats:**
* JSON-LD (recommended)
* Microdata
* RDFa

**Deprecation awareness:**

| Schema Type | Status |
| :--- | :--- |
| HowTo | Deprecated (Sept 2023) |
| FAQ | Restricted to gov/health (Aug 2023) |
| SpecialAnnouncement | Deprecated (July 2025) |

### AI Search Optimization (GEO)

**Supports optimization for:**
* Google AI Overviews
* ChatGPT web search
* Perplexity
* AI-powered search assistants

### Quality Gates

**Automatic safeguards:**
* Warning at 30+ location pages
* Hard stop at 50+ location pages
* Thin content detection
* Doorway page prevention

---

## Architecture

```text
~/.claude/skills/seo/       # Main skill
~/.claude/skills/seo-*/     # Sub-skills
~/.claude/agents/seo-*.md   # Subagents
```

### Video & Live Schema

**Additional schema support:**
* VideoObject
* BroadcastEvent
* Clip
* SeekToAction
* SoftwareSourceCode

See `schema/templates.json` for ready-to-use JSON-LD snippets.

---

## Recently Added

* Programmatic SEO skill
* Competitor comparison page generator
* Hreflang validation
* Video & live schema support
* SEO quick-reference guide

---

## Requirements

* Python 3.8+
* Claude Code CLI
* Optional: Playwright (screenshots)

---

## Uninstall

```bash
curl -fsSL [https://raw.githubusercontent.com/gooseuwh/claude-seo/main/uninstall.sh](https://raw.githubusercontent.com/gooseuwh/claude-seo/main/uninstall.sh) | bash
```

---

## MCP Integrations

Supports MCP servers for live SEO data, including:
* Ahrefs MCP
* Semrush
* Google Search Console
* PageSpeed Insights
* DataForSEO

See: `docs/MCP-INTEGRATION.md`

---

## Extensions

Optional extensions allow integration with external SEO APIs via MCP servers.

---

## Documentation

* `docs/INSTALLATION.md`
* `docs/COMMANDS.md`
* `docs/ARCHITECTURE.md`
* `docs/MCP-INTEGRATION.md`
* `docs/TROUBLESHOOTING.md`

---

## License

MIT License — see LICENSE for full details.

---

## Attribution

This project is based on the original Claude SEO toolkit created by:  
**AgriciDaniel** [https://github.com/AgriciDaniel](https://github.com/AgriciDaniel)

This repository contains modifications, additional documentation, and adapted installation instructions maintained by the current repository owner.