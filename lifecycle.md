# The Engineering Lifecycle: From Code to Cloud

This document outlines the standard 5-Phase Lifecycle used by our engineering team. It combines **Git Flow** for branching, **Conventional Commits** for history, and **CI/CD** for automation.

---

## Phase 1: Feature Development (Active Work)

**Scenario:** We are building the new "User Dashboard" for the next release (v2.0). The codebase is currently active on `develop`.

1.  **Start:** Developer creates a new feature branch from `develop`.
    *   Command: `git checkout -b feature/user-dashboard develop`
    *   **Workflow:** `branch-policy.yml` (Checks if branch name starts with `feature/`).
2.  **Work:** Developer writes code and commits.
    *   Commit: `feat(ui): add new charts to dashboard`
    *   Commit: `test(ui): add vitest coverage`
    *   **Workflow:** None.
3.  **Review:** Developer opens a Pull Request (`feature/user-dashboard` -> `develop`).
    *   **Workflow:** `branch-policy.yml` (Checks PR title structure).
4.  **Merge:** Team approves and merges the PR.
    *   **Workflow:** `develop-ci.yml` (Runs unit tests and deploys to the **Development Server**).

---

## Phase 2: Release Stabilization (The Freeze)

**Scenario:** We have merged enough features for v2.0. It is time to stop adding new things and focus on polishing what we have.

1.  **Cut Release:** Release Manager creates the release branch.
    *   Action: Run `cut-release.yml` workflow manually.
    *   **Workflow:** `cut-release.yml` (Analyzes history, cuts `release/v2.0.0`, **AND Opens Draft PRs to `main` and `develop`**).
2.  **Stabilize:** QA Team tests the release candidate. They find a bug (e.g., "Login button is misaligned").
    *   **Workflow:** None (Manual testing).
3.  **Fix:** Developer creates a fix branch from the release branch.
    *   Command: `git checkout -b bugfix/login-align release/v2.0.0`
    *   **Workflow:** `branch-policy.yml` (Checks if branch name starts with `bugfix/`).
4.  **Merge:** Developer opens PR (`bugfix/login-align` -> `release/v2.0.0`) and merges it.
    *   **Workflow:** `branch-policy.yml` (On PR).
    *   *Note:* No CI runs on merge unless configured (standard practice reduces noise here).

---

## Phase 3: The Release (Shipping It)

**Scenario:** v2.0.0 is stable. It is time to deploy it to production and publish it to the world.

1.  **Master Merge:** Release Manager merges the **Auto-Created PR** (`release/v2.0.0` -> `main`).
    *   Title: `chore(release): v2.0.0` (Pre-filled by Bot).
    *   **Workflow:** `branch-policy.yml` (On PR).
    *   **Merge:** The code is now in the `main` branch.
2.  **Auto-Trigger:** `release-handler.yml` wakes up on the **Push to Main**.
    *   **Action:** It sees `chore(release): v2.0.0`.
    *   **Result:** It **Automatically creates and pushes the tag v2.0.0**.
    *   **Deployment:** Builds Binaries, Docker Image, Release Notes, and Deploys to Production.
3.  **Sync Merge:** Release Manager merges the **Auto-Created PR** (`release/v2.0.0` -> `develop`).
    *   Title: `chore(release): merge v2.0.0 back to develop` (Pre-filled by Bot).
    *   **Workflow:** `branch-policy.yml` (On PR).
    *   **Merge:** Triggers `develop-ci.yml` (Deploys updated code to Dev).

---

## Phase 4: Hotfix (Emergency Mode)

**Scenario:** v2.0.0 is live, but a critical database crash is affecting users. We cannot wait for v2.1.0; we need a fix *now*.

1.  **Start:** Developer creates a hotfix branch directly from `main` (the stable code).
    *   Command: `git checkout -b hotfix/db-crash main`
    *   **Workflow:** `branch-policy.yml` (Checks `hotfix/` prefix).
2.  **Fix:** Developer fixes the crash.
    *   Commit: `fix(db): increase connection timeout`
    *   **Workflow:** None.
3.  **Merge:** Developer merges `hotfix/db-crash` into **both** `main` and `develop`.
    *   Merge to `main`: **Workflow:** None (Wait for tag).
    *   Merge to `develop`: **Workflow:** `develop-ci.yml`.
4.  **Release:** Release Manager tags `main` with a **PATCH** bump.
    *   Command: `git tag v2.0.1 && git push origin v2.0.1`
    *   **Workflow:** `release-handler.yml` (Deploys Fix Immediately).

---

## Phase 5: Legacy Support (LTS)

**Scenario:** We are working on v3.0, but a large Enterprise Client is strictly stuck on v1.0. A security flaw is found in v1.0. They cannot upgrade to v2.0.

The Problem: You can't fix it on main because main might already have v2.0 code. You can't fix it on develop because that's the future.
**The Solution: Support Branch**

1.  **Setup:** We go back in time to the v1.0.0 tag and create a permanent support branch.
    *   Command: `git checkout -b support/v1.x v1.0.0`
    *   **Workflow:** `branch-policy.yml` (Checks `support/` prefix).
2.  **Fix:** Developer branches off `support/v1.x` to fix the flaw.
    *   Command: `git checkout -b bugfix/security-patch support/v1.x`
    *   **Workflow:** `branch-policy.yml` (Checks `bugfix/` prefix).
3.  **Merge:** Merge the fix back into `support/v1.x`.
    *   **Workflow:** `branch-policy.yml` (On PR).
4.  **Release:** Tag the support branch.
    *   Command: `git tag v1.0.1` (on the support branch!)
    *   **Workflow:** `release-handler.yml` (Deploys v1.0.1 artifacts).

**Key Difference** : Unlike `release/ branches` (which eventually merge into `main` and die), Support branches live forever (or until you stop supporting that version). They never merge back into `main` if `main` has moved past them significantly. They are parallel universes for old code.

---

## Reusing this Pipeline (Portability)

These workflows are designed to be "Drop-in" ready for most projects, but require 3 specific configurations when moved to a new repo:

1.  **Build Commands:**
    *   The workflows (`develop-ci.yml`, `release-handler.yml`) contain placeholder build steps (`echo "Building..."`).
    *   **Action:** Update these lines with your actual build command (e.g., `npm run build`, `mvn package`, `cargo build`).
2.  **Dockerfile:**
    *   The `release-handler.yml` assumes a `Dockerfile` exists in the project root.
    *   **Action:** Ensure a Dockerfile is present or remove the Docker step from the YAML.
3.  **GitHub Permissions:**
    *   The workflows utilize the default `GITHUB_TOKEN` to create releases and push tags.
    *   **Action:** In the new repository, go to **Settings -> Actions -> General** and ensure **"Read and write permissions"** is selected under "Workflow permissions".
