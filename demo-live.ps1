# ========================================================
#  LIVE ENGINEERING PIPELINE DEMO SCRIPT (ENHANCED)
# ========================================================
# Purpose: Builds a Landing Page to generate a rich Release Note.
# Requires: Git, GitHub CLI (gh) authenticated.

function Pause-Step {
    param($Message)
    Write-Host "`n========================================================" -ForegroundColor Cyan
    Write-Host "STEP: $Message" -ForegroundColor Yellow
    Write-Host "========================================================" -ForegroundColor Cyan
    Read-Host "Press Enter to execute..."
}

function Create-Html {
    param($Content)
    Set-Content -Path "index.html" -Value $Content
}

# --------------------------------------------------------
# 0. SETUP & INITIALIZATION
# --------------------------------------------------------
$ProjectName = "neuron-live-demo"
$ScriptPath = $PSScriptRoot
$TargetDir = Join-Path $ScriptPath $ProjectName

Write-Host "Checking Pre-requisites..."
gh auth status
if ($LASTEXITCODE -ne 0) {
    Write-Host "`n❌ ERROR: You are not logged into GitHub CLI." -ForegroundColor Red
    Write-Host "ACTION REQUIRED: Run 'gh auth login' in your terminal." -ForegroundColor Red
    exit
}

Pause-Step "SETUP: Creating Project Folder '$ProjectName'"

# 1. Create Project Folder
if (Test-Path $TargetDir) {
    Write-Host "Cleaning up old demo folder..."
    Remove-Item -Path $TargetDir -Recurse -Force
}
New-Item -Path $TargetDir -ItemType Directory | Out-Null
Set-Location $TargetDir
Write-Host "Entered directory: $TargetDir"

# 2. Git Init & Flow Init
Write-Host "Initializing Git..."
git init
git commit --allow-empty -m "chore: initial commit"


Pause-Step "SETUP: Run 'git flow init'"
Write-Host "Running 'git flow init'..."
git flow init -d

# 3. Copy Workflows
Pause-Step "SETUP: Copy .github Workflows"
Write-Host "Copying .github workflows from parent..."
Copy-Item -Path (Join-Path $ScriptPath ".github") -Destination "." -Recurse
Write-Host "✅ Workflows copied."

# Now we are on 'develop' automatically.
# Create basic HTML
$BaseHTML = @"
<!DOCTYPE html>
<html>
<head><title>Neuron App</title></head>
<body>
    <h1>Welcome to Neuron</h1>
    <p>Loading...</p>
</body>
</html>
"@
Create-Html $BaseHTML

# Create Dockerfile for the Release Handler
$DockerfileContent = @"
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
"@
Set-Content -Path "Dockerfile" -Value $DockerfileContent
Write-Host "Created Dockerfile."

# CRITICAL: We must add the workflows (.github) so the pipeline actually runs!
Pause-Step "SETUP: Initial Commit (Base + Workflows)"
git add index.html Dockerfile .github
git commit -m "build: initial layout and workflows"
git push origin develop
Write-Host "✅ Base project pushed to develop (Workflows are now active)."


# --------------------------------------------------------
# PHASE 1: FEATURE FRENZY (Populating the Changelog)
# --------------------------------------------------------

# --- FEATURE 1: NAVBAR ---
Pause-Step "PHASE 1.1: Feature - Add Navbar"
git checkout -b feature/navbar develop

$NavHTML = @"
<!DOCTYPE html>
<html>
<head><title>Neuron App</title></head>
<body>
    <nav>
        <a href='#'>Home</a> | <a href='#'>Features</a> | <a href='#'>Pricing</a>
    </nav>
    <h1>Welcome to Neuron</h1>
    <p>Loading...</p>
</body>
</html>
"@
Create-Html $NavHTML

git add index.html
git commit -m "feat(ui): add global navigation bar"
git push origin feature/navbar

git push origin feature/navbar

Pause-Step "ACTION: Create PR for Navbar"
Write-Host "Creating PR via GH CLI..."
gh pr create --base develop --head feature/navbar --title "feat(ui): add navigation" --body "Added responsive navbar"
Pause-Step "Merge Navbar PR (Simulated)"
# In a real demo you'd merge on GitHub. We simulate local merge to keep script moving.
git checkout develop
git merge feature/navbar
git push origin develop


# --- FEATURE 2: HERO SECTION ---
Pause-Step "PHASE 1.2: Feature - Add Hero Section"
git checkout -b feature/hero develop

$HeroHTML = @"
<!DOCTYPE html>
<html>
<head><title>Neuron App</title></head>
<body>
    <nav>
        <a href='#'>Home</a> | <a href='#'>Features</a> | <a href='#'>Pricing</a>
    </nav>
    <div class='hero' style='background: #eee; padding: 50px;'>
        <h1>Welcome to Neuron</h1>
        <p>The Future of AI Engineering</p>
        <button>Get Started</button>
    </div>
</body>
</html>
"@
Create-Html $HeroHTML

git add index.html
git commit -m "feat(ui): add hero section with CTA"
git push origin feature/hero

git push origin feature/hero

Pause-Step "ACTION: Create PR for Hero Section"
Write-Host "Creating PR via GH CLI..."
gh pr create --base develop --head feature/hero --title "feat(ui): add hero section" --body "Added hero banner"
Pause-Step "Merge Hero PR (Simulated)"
git checkout develop
git merge feature/hero
git push origin develop


# --- FIX 1: TYPO ---
Pause-Step "PHASE 1.3: Bugfix - Fix Typo"
git checkout -b bugfix/typo develop

# Simulate a fix (assume we had a typo, just updating content)
$FixHTML = @"
<!DOCTYPE html>
<html>
<head><title>Neuron App</title></head>
<body>
    <nav>
        <a href='#'>Home</a> | <a href='#'>Services</a> | <a href='#'>Pricing</a>
    </nav>
    <div class='hero' style='background: #333; color: white; padding: 50px;'>
        <h1>Welcome to Neuron</h1>
        <p>The Future of AI Engineering</p>
        <button>Get Started Now</button>
    </div>
</body>
</html>
"@
Create-Html $FixHTML

git add index.html
git commit -m "fix(content): correct nav link and hero colors"
git push origin bugfix/typo

git push origin bugfix/typo

Pause-Step "ACTION: Create PR for Bugfix"
gh pr create --base develop --head bugfix/typo --title "fix(content): update branding" --body "Fixed typos and colors"
Pause-Step "Merge Fix PR (Simulated)"
git checkout develop
git merge bugfix/typo
git push origin develop


# --------------------------------------------------------
# PHASE 2: THE RELEASE
# --------------------------------------------------------
Pause-Step "PHASE 2: Cut Release (The Magic Moment)"
Write-Host "Now we simulate the 'Cut Release' workflow."
Write-Host "We have 2 Features and 1 Fix. SemVer should detect MINOR bump."

# Simulate the Bot
git checkout -b release/v1.1.0 develop
git push origin release/v1.1.0
Write-Host "✅ Branch release/v1.1.0 created"

Write-Host "✅ Branch release/v1.1.0 created"

Pause-Step "ACTION: Auto-Create Release PRs"
gh pr create --base main --head release/v1.1.0 --title "chore(release): v1.1.0" --body "Release Candidate v1.1.0"
gh pr create --base develop --head release/v1.1.0 --title "chore(release): merge v1.1.0 back to develop" --body "Sync"

Write-Host "✅ PRs Created! Go check GitHub!"

# --------------------------------------------------------
# PHASE 3: SHIPPING
# --------------------------------------------------------
Pause-Step "PHASE 3: Ship It (Tagging)"
Write-Host "Assume you merged the PR to main."
Write-Host "Simulating the Tag push..."

git checkout main
git merge release/v1.1.0
git tag v1.1.0
git push origin v1.1.0

Write-Host "`n🎉 DEMO COMPLETE!" -ForegroundColor Cyan
Write-Host "Check the 'Releases' tab in GitHub 30 seconds from now."
Write-Host "You should see a release with:"
Write-Host " - 🚀 feat(ui): add navigation"
Write-Host " - 🚀 feat(ui): add hero section"
Write-Host " - 🐛 fix(content): update branding"
