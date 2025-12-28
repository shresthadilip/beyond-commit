# Beyond the Commit: Architecting Scalable Workflows

This repository contains the materials and demo scripts for the talk **"Beyond the Commit"**. It demonstrates an Industrial-Grade Git Workflow using Git Flow, Conventional Commits, Semantic Versioning, and GitHub Actions.

## 📂 Repository Contents

*   **`idea.md`**: The source material for the presentation slides.
*   **`Beyond The Commit.pptx`**: The generated PowerPoint presentation.
*   **`present.ps1`**: A terminal-based presentation tool to present `idea.md` interactively.
*   **`demo-live.ps1`**: A PowerShell script that automates the live technical demo.
*   **`.github/`**: The reference GitHub workflows used in the demo.
*   **`demo_commits.md`**: A cheat sheet of commits used during the live demo.

---

## 🚀 How to Run the Presentation

You have two options to present the slides:

### Option A: Powerpoint
Open `Beyond The Commit.pptx`. This file was auto-generated using the custom design from `engineering pipeline.pptx`.

### Option B: Terminal Mode (For the brave)
Run the PowerShell script to present directly from your terminal with ANSI formatting.
```powershell
.\present.ps1
```
*   **Controls:** Right Arrow / Enter to Next, `Q` to Quit.

---

## ⚡ How to Run the Live Demo

This script simulates a full development lifecycle (Feature -> PR -> Release) in minutes.

### Prerequisites
1.  **Git** installed.
2.  **GitHub CLI (`gh`)** installed and authenticated (`gh auth login`).

### Running the Demo
1.  Open your terminal in this directory.
2.  Run the script:
    ```powershell
    .\demo-live.ps1
    ```
3.  **Follow the Prompts:** The script is interactive. It will pause before every major action (creating branches, pushing, creating PRs) so you can explain the concept to the audience.

### What the Demo Does
1.  Creates a sandboxed folder `neuron-live-demo`.
2.  Initializes **Git Flow** (`main` / `develop`).
3.  Copies the `.github` workflows.
4.  Simulates **Feature Work** (adding Navbar, Hero section).
5.  Simulates a **Bugfix**.
6.  Triggers a **Release** (v1.1.0) which auto-generates a Changelog and Docker Image.

---

## 🛠️ The Workflows

The logic powering this pipeline is located in `.github/workflows`:

1.  **`branch-policy.yml`**: Enforces naming conventions (`feature/*`, `fix/*`) and PR title formats.
2.  **`cut-release.yml`**: Automates creating release branches and calculating SemVer.
3.  **`release-handler.yml`**: The heavy lifter. Triggered on tags to Build, Dockerize, and Publish Releases.
