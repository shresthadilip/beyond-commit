# The Pulse of Production: Mastering Industrial Git & Workflow Patterns

---

## Slide Content Outline

### Title Slide

* **Title:** Beyond the Commit
* **Subtitle:** Architecting Scalable Workflows with Git Flow
* **Presented by:** [Your Name]

### Why "Industry Git" is Different

* **The Problem:** "It works on my machine" vs. "It broke the production server."
* **Key Differences:**
    * **Auditability:** Knowing *who* changed *what* and *why*.
    * **Automation:** Integrating with CI/CD pipelines.
    * **Scale:** Handling 50+ developers on a single codebase without chaos.

### The Golden Rules of Professional Git

* **Atomic Commits:** One logical change per commit (easier to revert).
* **Meaningful Messages:** Avoid "fixed bug." Use "Fix(Auth): Resolve timeout in login handler."
* **Never Commit to Main:** Protecting the "Source of Truth."
* **Pull Requests (PRs):** The gateway for peer review and quality control.

### Introduction to Git Flow

* **Definition:** A strict branching model designed around the project release.
* **The Permanent Branches:**
    * **`main`:** Production-ready code. **The Source of Truth.**
    * **`develop`:** Integration branch. **The bleeding edge of features.**
* **The Support Branches:**
    * `feature/*`: Developing new stuff.
    * `release/*`: Preparing for launch (Stabilization).
    * `hotfix/*`: Quick fixes for prod.

### Branching Policy & Restrictions

* **Strict Rules to Maintain Sanity:**
    * **Feature Branches (`feature/*`)** → Can ONLY merge into **`develop`**.
    * **Bugfix Branches (`bugfix/*`)** → Can ONLY merge into **`release/*`**.
    * **Hotfix Branches (`hotfix/*`)** → Can merge into **`main`** AND **`develop`**.
* **Why?** Prevents unstable features from leaking into release candidates or production.

### Conventional Commits - The API of History

* **The Problem:** `git log` looking like "wip", "fix", "please work".
* **The Solution:** A structured format for commit messages.
* **Format:** `<type>(<scope>): <subject>`
    * `feat(auth): add google oauth login`
    * `fix(db): resolve connection leak`
* **Crucial for PRs:** In this pipeline, **PR Titles** must follow this format because they become the final history (Squash & Merge).

### Semantic Versioning (SemVer)

* **Communicating Change through Numbers:** `MAJOR.MINOR.PATCH`
    * **MAJOR (1.0.0):** Breaking changes.
    * **MINOR (1.1.0):** New features, backwards compatible.
    * **PATCH (1.0.1):** Bug fixes, backwards compatible.

* **Commit Type to Version Mapping:**

| Type | Impact | Description |
| :--- | :--- | :--- |
| **feat** | **MINOR** 🚀 | New Feature |
| **fix** | **PATCH** 🐛 | Bug Fix |
| **perf / revert** | **PATCH** | Performance / Undo |
| **BREAKING CHANGE** | **MAJOR** 💥 | (Footer) Breaking API |
| **docs / style / test** | **None** | No Release Triggered |

### The Release Workflow (Not Every Push!)

* **Question:** "Do we release on every push to `develop`?"
* **Answer:** **NO.**
    * `develop` is for Continuous Integration (Tests, Dev Deployment).
    * **Releases are deliberate.**
* **The Flow:**
    1. **Develop**: Merge features, run tests automatically.
    2. **Freeze**: Create `release/v1.0.0` branch.
    3. **Stabilize**: Fix bugs (`bugfix/*`).
    4. **Launch**: Merge to `main`. Tag `v1.0.0`.

### CI/CD Automation "What Now?"

* **The "What Now" Phase:** What happens after we tag `v1.0.0`?
* **Release Handler Workflow:**
    * **Build Artifacts:** Create executable binaries (Linux/Windows).
    * **Dockerize:** Build and Push Docker image to Registry with tag `v1.0.0`.
    * **Publish:** Create GitHub Release with changelog and binaries.
    * **Deploy:** Update production cluster to pull `image:v1.0.0`.

### Conclusion & Q&A

* **Summary:** Git Flow + Conventional Commits + SemVer = Fully Automated, Reliable Releases.
* **Final Thought:** Automation allows us to focus on Code, not Choreography.
* **Call to Action:** Let's adopt these checks today!
