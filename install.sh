#!/usr/bin/env bash
set -euo pipefail

# Claude SEO Installer
# Wraps everything in main() to prevent partial execution on network failure

main() {
    SKILL_DIR="${HOME}/.claude/skills/seo"
    AGENT_DIR="${HOME}/.claude/agents"
    REPO_URL="https://github.com/gooseuwh/claude-seo"

    echo "════════════════════════════════════════"
    echo "║   Claude SEO - Installer             ║"
    echo "║   Claude Code SEO Skill              ║"
    echo "════════════════════════════════════════"
    echo ""

    # Check prerequisites
    command -v git >/dev/null 2>&1 || { echo "✗ Git is required but not installed."; exit 1; }

    # Python is optional — enhances analysis but not required for core skill
    PYTHON_AVAILABLE=0
    if command -v python3 >/dev/null 2>&1; then
        PYTHON_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
        PYTHON_OK=$(python3 -c 'import sys; print(1 if sys.version_info >= (3, 10) else 0)')
        if [ "${PYTHON_OK}" = "1" ]; then
            echo "✓ Python ${PYTHON_VERSION} detected (enhanced mode)"
            PYTHON_AVAILABLE=1
        else
            echo "⚠  Python ${PYTHON_VERSION} found — 3.10+ recommended for enhanced features"
            echo "   Core SEO analysis will still work using built-in tools."
        fi
    else
        echo "⚠  Python not found — running in core mode (no HTML parsing or screenshots)"
        echo "   Install Python 3.10+ to enable: fetch_page, parse_html, screenshots, CSV analysis"
        echo "   https://python.org/"
    fi

    # Create directories
    mkdir -p "${SKILL_DIR}"
    mkdir -p "${AGENT_DIR}"

    # Clone or update
    TEMP_DIR=$(mktemp -d)
    trap "rm -rf ${TEMP_DIR}" EXIT

    echo "↓ Downloading Claude SEO..."
    git clone --depth 1 "${REPO_URL}" "${TEMP_DIR}/claude-seo" 2>/dev/null

    # Copy skill files
    echo "→ Installing skill files..."
    cp -r "${TEMP_DIR}/claude-seo/seo/"* "${SKILL_DIR}/"

    # Copy sub-skills
    if [ -d "${TEMP_DIR}/claude-seo/skills" ]; then
        for skill_dir in "${TEMP_DIR}/claude-seo/skills"/*/; do
            skill_name=$(basename "${skill_dir}")
            target="${HOME}/.claude/skills/${skill_name}"
            mkdir -p "${target}"
            cp -r "${skill_dir}"* "${target}/"
        done
    fi

    # Copy schema templates
    if [ -d "${TEMP_DIR}/claude-seo/schema" ]; then
        mkdir -p "${SKILL_DIR}/schema"
        cp -r "${TEMP_DIR}/claude-seo/schema/"* "${SKILL_DIR}/schema/"
    fi

    # Copy reference docs
    if [ -d "${TEMP_DIR}/claude-seo/pdf" ]; then
        mkdir -p "${SKILL_DIR}/pdf"
        cp -r "${TEMP_DIR}/claude-seo/pdf/"* "${SKILL_DIR}/pdf/"
    fi

    # Copy agents
    echo "→ Installing subagents..."
    cp -r "${TEMP_DIR}/claude-seo/agents/"*.md "${AGENT_DIR}/" 2>/dev/null || true

    # Copy shared scripts
    if [ -d "${TEMP_DIR}/claude-seo/scripts" ]; then
        mkdir -p "${SKILL_DIR}/scripts"
        cp -r "${TEMP_DIR}/claude-seo/scripts/"* "${SKILL_DIR}/scripts/"
    fi

    # Copy hooks
    if [ -d "${TEMP_DIR}/claude-seo/hooks" ]; then
        mkdir -p "${SKILL_DIR}/hooks"
        cp -r "${TEMP_DIR}/claude-seo/hooks/"* "${SKILL_DIR}/hooks/"
        chmod +x "${SKILL_DIR}/hooks/"*.sh 2>/dev/null || true
        chmod +x "${SKILL_DIR}/hooks/"*.py 2>/dev/null || true
    fi

    # Copy requirements.txt to skill dir so users can retry later
    cp "${TEMP_DIR}/claude-seo/requirements.txt" "${SKILL_DIR}/requirements.txt" 2>/dev/null || true

    # Install Python dependencies (only if Python available)
    VENV_DIR="${SKILL_DIR}/.venv"
    if [ "${PYTHON_AVAILABLE}" = "1" ]; then
        echo "→ Installing Python dependencies..."
        if python3 -m venv "${VENV_DIR}" 2>/dev/null; then
            "${VENV_DIR}/bin/pip" install --quiet -r "${TEMP_DIR}/claude-seo/requirements.txt" 2>/dev/null && \
                echo "  ✓ Installed in venv at ${VENV_DIR}" || \
                echo "  ⚠  Venv pip install failed. Run: ${VENV_DIR}/bin/pip install -r ${SKILL_DIR}/requirements.txt"
        else
            pip3 install --quiet --user -r "${TEMP_DIR}/claude-seo/requirements.txt" 2>/dev/null || \
            echo "  ⚠  Could not auto-install. Run: pip3 install --user -r ${SKILL_DIR}/requirements.txt"
        fi

        # Optional: Install Playwright browsers (for screenshot analysis)
        echo "→ Installing Playwright browsers (optional, for visual analysis)..."
        if [ -f "${VENV_DIR}/bin/playwright" ]; then
            "${VENV_DIR}/bin/python" -m playwright install chromium 2>/dev/null || \
            echo "  ⚠  Playwright install failed. Visual analysis will use WebFetch fallback."
        else
            python3 -m playwright install chromium 2>/dev/null || \
            echo "  ⚠  Playwright install failed. Visual analysis will use WebFetch fallback."
        fi
    else
        echo "→ Skipping Python dependencies (Python not available)"
        echo "  To add later: pip3 install -r ${SKILL_DIR}/requirements.txt"
    fi

    echo ""
    echo "✓ Claude SEO installed successfully!"
    echo ""
    echo "Usage:"
    echo "  1. Start Claude Code:  claude"
    echo "  2. Run commands:       /seo audit https://example.com"
    echo ""
    if [ "${PYTHON_AVAILABLE}" = "1" ]; then
        echo "Mode: Enhanced (Python available — HTML parsing, screenshots, CSV analysis)"
    else
        echo "Mode: Core (Python not found — uses built-in WebFetch and file reading)"
        echo "      Install Python 3.10+ and re-run to enable enhanced features."
    fi
    echo ""
    echo "To uninstall: curl -fsSL ${REPO_URL}/raw/main/uninstall.sh | bash"
}

main "$@"
