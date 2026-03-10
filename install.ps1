# Claude SEO Installer for Windows
# PowerShell installation script

$ErrorActionPreference = "Stop"

Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "║   Claude SEO - Installer             ║" -ForegroundColor Cyan
Write-Host "║   Claude Code SEO Skill              ║" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

function Resolve-Python {
    $pythonCmd = Get-Command -Name python -ErrorAction SilentlyContinue
    if ($null -ne $pythonCmd) {
        return @{ Exe = 'python'; Args = @() }
    }

    $pyCmd = Get-Command -Name py -ErrorAction SilentlyContinue
    if ($null -ne $pyCmd) {
        return @{ Exe = 'py'; Args = @('-3') }
    }

    return $null
}

function Invoke-External {
    param(
        [Parameter(Mandatory = $true)][string]$Exe,
        [Parameter(Mandatory = $true)][string[]]$Args,
        [switch]$Quiet
    )

    $output = & $Exe @Args 2>&1
    $exitCode = $LASTEXITCODE

    if (-not $Quiet -and $null -ne $output -and $output.Count -gt 0) {
        $output | ForEach-Object { Write-Host $_ }
    }

    return @{ ExitCode = $exitCode; Output = $output }
}

# Python is optional — enhances analysis but not required for core skill
$python = Resolve-Python
$PythonAvailable = $false

if ($null -ne $python) {
    try {
        $pythonVersion = & $python.Exe @($python.Args + @('--version')) 2>&1
        Write-Host "✓ $pythonVersion detected (enhanced mode)" -ForegroundColor Green
        $PythonAvailable = $true
    } catch {
        Write-Host "⚠  Python found but could not execute — skipping enhanced features." -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠  Python not found — running in core mode (no HTML parsing or screenshots)" -ForegroundColor Yellow
    Write-Host "   Install Python 3.10+ to enable: fetch_page, parse_html, screenshots, CSV analysis" -ForegroundColor Gray
    Write-Host "   https://python.org/" -ForegroundColor Gray
}

try {
    git --version | Out-Null
    Write-Host "✓ Git detected" -ForegroundColor Green
} catch {
    Write-Host "✗ Git is required but not installed." -ForegroundColor Red
    exit 1
}

# Set paths
$SkillDir = "$env:USERPROFILE\.claude\skills\seo"
$AgentDir = "$env:USERPROFILE\.claude\agents"
$RepoUrl = "https://github.com/gooseuwh/claude-seo"

# Create directories
New-Item -ItemType Directory -Force -Path $SkillDir | Out-Null
New-Item -ItemType Directory -Force -Path $AgentDir | Out-Null

# Clone to temp directory
$TempDir = Join-Path $env:TEMP "claude-seo-install"
if (Test-Path $TempDir) {
    Remove-Item -Recurse -Force $TempDir
}

$keepTemp = ($env:CLAUDE_SEO_KEEP_TEMP -eq '1')

try {
    Write-Host "↓ Downloading Claude SEO..." -ForegroundColor Yellow
    $clone = Invoke-External -Exe 'git' -Args @('clone','--depth','1',$RepoUrl,$TempDir) -Quiet
    if ($clone.ExitCode -ne 0) {
        throw "git clone failed. Output:`n$($clone.Output -join "`n")"
    }

    # Copy skill files
    Write-Host "→ Installing skill files..." -ForegroundColor Yellow
    $skillSource = Join-Path $TempDir 'seo'
    if (-not (Test-Path $skillSource)) {
        $skillSource = Join-Path $TempDir 'skills\seo'
    }
    if (-not (Test-Path $skillSource)) {
        throw "Could not find skill source folder in repo clone."
    }
    Copy-Item -Recurse -Force (Join-Path $skillSource '*') $SkillDir

    # Copy sub-skills
    $SkillsPath = "$TempDir\skills"
    if (Test-Path $SkillsPath) {
        Get-ChildItem -Directory $SkillsPath | ForEach-Object {
            $target = "$env:USERPROFILE\.claude\skills\$($_.Name)"
            New-Item -ItemType Directory -Force -Path $target | Out-Null
            Copy-Item -Recurse -Force "$($_.FullName)\*" $target
        }
    }

    # Copy schema templates
    $SchemaPath = "$TempDir\schema"
    if (Test-Path $SchemaPath) {
        $SkillSchema = "$SkillDir\schema"
        New-Item -ItemType Directory -Force -Path $SkillSchema | Out-Null
        Copy-Item -Recurse -Force "$SchemaPath\*" $SkillSchema
    }

    # Copy reference docs
    $PdfPath = "$TempDir\pdf"
    if (Test-Path $PdfPath) {
        $SkillPdf = "$SkillDir\pdf"
        New-Item -ItemType Directory -Force -Path $SkillPdf | Out-Null
        Copy-Item -Recurse -Force "$PdfPath\*" $SkillPdf
    }

    # Copy agents
    Write-Host "→ Installing subagents..." -ForegroundColor Yellow
    $AgentsPath = Join-Path $TempDir 'agents'
    if (Test-Path $AgentsPath) {
        Copy-Item -Force (Join-Path $AgentsPath '*.md') $AgentDir -ErrorAction SilentlyContinue
    }

    # Copy shared scripts
    $ScriptsPath = "$TempDir\scripts"
    if (Test-Path $ScriptsPath) {
        $SkillScripts = "$SkillDir\scripts"
        New-Item -ItemType Directory -Force -Path $SkillScripts | Out-Null
        Copy-Item -Recurse -Force "$ScriptsPath\*" $SkillScripts
    }

    # Copy hooks
    $HooksPath = "$TempDir\hooks"
    if (Test-Path $HooksPath) {
        $SkillHooks = "$SkillDir\hooks"
        New-Item -ItemType Directory -Force -Path $SkillHooks | Out-Null
        Copy-Item -Recurse -Force "$HooksPath\*" $SkillHooks
    }

    # Copy requirements.txt to skill dir for retry
    $reqFile = Join-Path $TempDir 'requirements.txt'
    $installedReqFile = Join-Path $SkillDir 'requirements.txt'
    if (Test-Path $reqFile) {
        Copy-Item -Force $reqFile $installedReqFile
    }

    # Install Python dependencies (only if Python available)
    if ($PythonAvailable) {
        Write-Host "→ Installing Python dependencies..." -ForegroundColor Yellow
        if (Test-Path $reqFile) {
            try {
                $pip = Invoke-External -Exe $python.Exe -Args @($python.Args + @('-m','pip','install','-q','-r',$reqFile)) -Quiet
                if ($pip.ExitCode -ne 0) {
                    throw ($pip.Output -join "`n")
                }
            } catch {
                Write-Host "  ⚠  Could not auto-install Python packages." -ForegroundColor Yellow
                Write-Host "  Try: $($python.Exe) $($python.Args -join ' ') -m pip install -r `"$installedReqFile`"" -ForegroundColor Yellow
            }
        } else {
            Write-Host "  ⚠  No requirements.txt found; skipping Python dependency install." -ForegroundColor Yellow
        }

        # Optional: Install Playwright browsers
        Write-Host "→ Installing Playwright browsers (optional, for visual analysis)..." -ForegroundColor Yellow
        try {
            $pw = Invoke-External -Exe $python.Exe -Args @($python.Args + @('-m','playwright','install','chromium')) -Quiet
            if ($pw.ExitCode -ne 0) {
                throw ($pw.Output -join "`n")
            }
        } catch {
            Write-Host "  ⚠  Playwright install failed. Visual analysis will use WebFetch fallback." -ForegroundColor Yellow
        }
    } else {
        Write-Host "→ Skipping Python dependencies (Python not available)" -ForegroundColor Yellow
        Write-Host "  To add later: pip install -r `"$installedReqFile`"" -ForegroundColor Gray
    }
} catch {
    Write-Host ""
    Write-Host "✗ Installation failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($keepTemp -and (Test-Path $TempDir)) {
        Write-Host "Temp dir kept at: $TempDir" -ForegroundColor Yellow
    }
    throw
} finally {
    if (-not $keepTemp -and (Test-Path $TempDir)) {
        Remove-Item -Recurse -Force $TempDir
    }
}

Write-Host ""
Write-Host "✓ Claude SEO installed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Usage:" -ForegroundColor Cyan
Write-Host "  1. Start Claude Code:  claude"
Write-Host "  2. Run commands:       /seo audit https://example.com"
Write-Host ""
if ($PythonAvailable) {
    Write-Host "Mode: Enhanced (Python available — HTML parsing, screenshots, CSV analysis)" -ForegroundColor Green
} else {
    Write-Host "Mode: Core (Python not found — uses built-in WebFetch and file reading)" -ForegroundColor Yellow
    Write-Host "      Install Python 3.10+ and re-run to enable enhanced features." -ForegroundColor Gray
}
