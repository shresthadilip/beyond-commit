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

# 0. SETUP & INITIALIZATION
# --------------------------------------------------------
$ProjectName = "beyond-commit-live-demo"
$ScriptPath = $PSScriptRoot

Write-Host "Checking Pre-requisites..."
gh auth status
if ($LASTEXITCODE -ne 0) {
    Write-Host "`n❌ ERROR: You are not logged into GitHub CLI." -ForegroundColor Red
    Write-Host "ACTION REQUIRED: Run 'gh auth login' in your terminal." -ForegroundColor Red
    exit
}

# Get Current GitHub User
$CurrentUser = gh api user --jq .login
$FullRepoName = "$CurrentUser/$ProjectName"

Pause-Step "SETUP: Reset & Create Repo '$FullRepoName'"

# 1. Cleanup & Create
# Check if remote repo exists
if (gh repo view $FullRepoName 2>$null) {
    Write-Host "Remote repo '$FullRepoName' already exists." -ForegroundColor Yellow
    $Existing = Read-Host "Delete and recreate? [Y/n]"
    if ($Existing -eq '' -or $Existing -eq 'y') {
        gh repo delete $FullRepoName --yes
    } else {
        Write-Host "Exiting to prevent overwrite."
        exit
    }
}

# Remove local folder if exists
$TargetDir = Join-Path $ScriptPath $ProjectName
if (Test-Path $TargetDir) {
    Write-Host "Removing existing local folder..."
    Remove-Item -Path $TargetDir -Recurse -Force
}

# Create and Clone
Write-Host "Creating repository on GitHub (with README)..."
gh repo create $ProjectName --public --add-readme

Write-Host "Cloning repository (using custom host for certs)..."
git clone "git@pasa.github.com:$FullRepoName.git"

Set-Location $TargetDir
Write-Host "Entered directory: $TargetDir"

# 2. Git Init & Flow Init
Write-Host "Initializing Git Flow..."
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

Write-Host "Configuring repository settings (Default: develop, Auto-Delete Heads)..."
gh repo edit $FullRepoName --default-branch develop --delete-branch-on-merge

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





# --------------------------------------------------------
# PHASE 2: THE RELEASE
# --------------------------------------------------------
Pause-Step "PHASE 2: Cut Release (The Magic Moment)"
Write-Host "Now we simulate the 'Cut Release' workflow."
Write-Host "We have 2 Features and 1 Fix. SemVer should detect MINOR bump."

# --------------------------------------------------------
# PHASE 2: CUT RELEASE (Workflow Trigger)
# --------------------------------------------------------
Pause-Step "ACTION: Go to GitHub Actions -> Run 'Cut Release' workflow manually"
Write-Host "Waiting for you to run the workflow..."
Write-Host "Once the workflow completes, press Enter to continue."
Read-Host "Press Enter after the workflow has created the release branch..."

Write-Host "Fetching latest branches from remote..."
git fetch origin --prune

# Find the latest release branch
$ReleaseBranch = git branch -r --list "origin/release/v*" | Sort-Object -Descending | Select-Object -First 1
if ($null -eq $ReleaseBranch) {
    Write-Host "❌ No release branch found! Did the workflow run?" -ForegroundColor Red
    exit
}
$ReleaseBranch = $ReleaseBranch.Trim() -replace "origin/", ""
$VersionTag = $ReleaseBranch -replace "release/", ""

Write-Host "✅ Detected Release Branch: $ReleaseBranch (Tag: $VersionTag)"

# --- BUGFIX ON RELEASE BRANCH ---
Pause-Step "PHASE 2.1: Late Bugfix (Stabilization)"
Write-Host "Simulating a bug found during Release QA..."

# 1. Create Bugfix Branch
git checkout -b bugfix/release-polish $ReleaseBranch

# 2. Apply Fix
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
git push origin bugfix/release-polish

# 3. Create PR
Pause-Step "ACTION: Create PR for Release Polish"
gh pr create --base $ReleaseBranch --head bugfix/release-polish --title "fix(content): release branding polish" --body "Fixing typos for release"

# 4. Merge PR (Simulated)
Pause-Step "ACTION: Merge Release Polish PR (Simulated)"
git checkout $ReleaseBranch
git merge bugfix/release-polish
git push origin $ReleaseBranch
Write-Host "✅ Bugfix merged into release branch."

Pause-Step "ACTION: Create Release PR (to main)"
gh pr create --base main --head $ReleaseBranch --title "chore(release): $VersionTag" --body "Release Candidate $VersionTag"

Pause-Step "ACTION: Create Sync PR (to develop)"
gh pr create --base develop --head $ReleaseBranch --title "chore(release): merge $VersionTag back to develop" --body "Sync"

Write-Host "✅ PRs Created! Go check GitHub!"

# --------------------------------------------------------
# MERGE PRs (Simulated "Manager Approval")
# --------------------------------------------------------
Pause-Step "ACTION: Merge Release PR (to main)"
$MainPR = gh pr list --head $ReleaseBranch --base main --json number --jq '.[0].number'
if ($MainPR) {
    Write-Host "Merging PR #$MainPR to main..."
    gh pr merge $MainPR --merge --delete-branch=false
} else {
    Write-Host "❌ Could not find Release PR to main." -ForegroundColor Red
}

Pause-Step "ACTION: Merge Sync PR (to develop)"
$DevPR = gh pr list --head $ReleaseBranch --base develop --json number --jq '.[0].number'
if ($DevPR) {
    Write-Host "Merging PR #$DevPR to develop..."
    gh pr merge $DevPR --merge --delete-branch=false
} else {
    Write-Host "❌ Could not find Sync PR to develop." -ForegroundColor Red
}

# --------------------------------------------------------
# PHASE 3: SHIPPING
# --------------------------------------------------------
Pause-Step "PHASE 3: Ship It (Tagging)"
Write-Host "PRs match merged. Fetching latest main..."

git checkout main
git pull origin main
git tag $VersionTag
git push origin $VersionTag

Write-Host "`n🎉 DEMO COMPLETE!" -ForegroundColor Cyan
Write-Host "Check the 'Releases' tab in GitHub 30 seconds from now."
Write-Host "You should see a release with:"
Write-Host " - 🚀 feat(ui): add navigation"
Write-Host " - 🚀 feat(ui): add hero section"
Write-Host " - 🐛 fix(content): update branding"

# --------------------------------------------------------
# CLEANUP
# --------------------------------------------------------
Write-Host "`n========================================================" -ForegroundColor Cyan
Write-Host "CLEANUP PHASE" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
$Cleanup = Read-Host "Do you want to delete the demo repository (local & remote) to save space? [y/N]"
if ($Cleanup -eq 'y') {
    Write-Host "Deleting remote repository '$FullRepoName'..."
    gh repo delete $FullRepoName --yes
    
    Write-Host "Deleting local directory..."
    Set-Location $ScriptPath
    Remove-Item -Path $TargetDir -Recurse -Force
    Write-Host "✅ Cleanup complete. All traces removed."
} else {
    Write-Host "Cleanup skipped. Repo '$FullRepoName' and folder '$TargetDir' preserved."
}
