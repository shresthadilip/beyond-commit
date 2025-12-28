# Demo Script Commit Reference

This document lists the specific **Conventional Commits** used in the `demo-live.ps1` script. Use this as a cheat sheet during your presentation to explain *why* these titles matter (they generate the Changelog!).

---

## 1. Project Initialization
**Action:** creating the base `index.html`.
*   **Commit Message:** `build: initial layout`
*   **Effect:** Sets up the repo. Does not appear in "User Facing" release notes usually, but is in the history.

## 2. Feature: Navigation Bar
**Action:** Adding the `<nav>` links.
*   **Branch:** `feature/navbar`
*   **Commit Message:** `feat(ui): add global navigation bar`
*   **PR Title:** `feat(ui): add navigation`
*   **Effect:** Triggers a **MINOR** version bump (Feature). Will appear in Changelog under **🚀 Features**.

## 3. Feature: Hero Section
**Action:** Adding the big "Welcome" banner.
*   **Branch:** `feature/hero`
*   **Commit Message:** `feat(ui): add hero section with CTA`
*   **PR Title:** `feat(ui): add hero section`
*   **Effect:** Another feature. Still a **MINOR** bump.

## 4. Bugfix: Typo & Colors
**Action:** Fixing "Services" link and changing background color.
*   **Branch:** `bugfix/typo`
*   **Commit Message:** `fix(content): correct nav link and hero colors`
*   **PR Title:** `fix(content): update branding`
*   **Effect:** Triggers a **PATCH** bump (Fix). Will appear in Changelog under **🐛 Fixes**.

## 5. The Release
**Action:** The Release Manager (bot) shipping v1.1.0.
*   **Branch:** `release/v1.1.0`
*   **PR Title:** `chore(release): v1.1.0`
*   **Effect:** This tells the `release-handler.yml` that "This is a release event". It triggers the tagging and deployment.

---

### Expected Auto-Generated Changelog (v1.1.0)
When the demo finishes, the GitHub Release release should look like this:

## 🚀 Features
- feat(ui): add navigation
- feat(ui): add hero section

## 🐛 Fixes
- fix(content): update branding
