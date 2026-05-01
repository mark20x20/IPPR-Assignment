# Git Workflow

## 1. Purpose

This document defines the Git and GitHub workflow for the License Plate Recognition (LPR) and State Identification System (SIS) project.

The purpose of this document is to help all group members collaborate safely without overwriting each other's work.

GitHub will be used for:

- Source code sharing
- Version control
- Team collaboration
- Backup
- Tracking changes during development

GitHub should not replace the official assignment submission.  
The final submission should still be prepared according to the assignment instructions.

---

## 2. Basic Concept

The project uses two types of separation:

1. **Functional folder responsibility**
2. **Git branch responsibility**

These are different.

Functional folder responsibility means each member mainly edits a specific project folder.

Git branch responsibility means each member works on a separate Git branch before merging changes into the shared development branch.

---

## 3. Functional Folder Responsibility

Each member should mainly edit their assigned folder or files.

| Member | Main Responsibility | Assigned Folder or Files |
|---|---|---|
| Member 1 | Dataset and Preprocessing | `src/preprocessing/`, `images/`, `dataset_metadata.csv` |
| Member 2 | License Plate Detection | `src/plate_detection/` |
| Member 3 | Segmentation and Morphology | `src/segmentation/`, `images/test/plate_samples/` |
| Member 4 | Recognition, GUI, and Evaluation | `src/recognition/`, `src/evaluation/`, `src/utils/`, `launch_gui.m` |

The source folders are divided by system function, not by member name.

Correct:

```text
src/preprocessing/
src/plate_detection/
src/segmentation/
src/recognition/
```

Incorrect:

```text
src/member1/
src/member2/
src/member3/
src/member4/
```

---

## 4. Branch Strategy

The project should use the following branches.

```text
main
dev
feature/preprocessing
feature/plate-detection
feature/segmentation-morphology
feature/recognition-gui-evaluation
```

---

## 5. Branch Roles

| Branch | Purpose |
|---|---|
| `main` | Stable final version for submission |
| `dev` | Integrated development version |
| `feature/preprocessing` | Member 1 development branch |
| `feature/plate-detection` | Member 2 development branch |
| `feature/segmentation-morphology` | Member 3 development branch |
| `feature/recognition-gui-evaluation` | Member 4 development branch |

---

## 6. Branch and Folder Separation

Branch names are not folder names.

Do not create project folders based on branch names.

Correct example:

```text
Git branch: feature/preprocessing
Assigned folder: src/preprocessing/
```

Incorrect example:

```text
Assignment/
└── feature/
    └── preprocessing/
```

All branches should use the same project folder structure.

---

## 7. Recommended Merge Flow

The recommended merge flow is:

```text
feature branch
↓
dev
↓
main
```

Each member should work on their own feature branch.

When their module is ready, they merge into `dev`.

After the full system is stable, `dev` is merged into `main`.

---

## 8. Repository Setup

## 8.1 First-Time Clone

Each member should clone the repository.

```bash
git clone <repository-url>
cd Assignment
```

Replace `<repository-url>` with the actual GitHub repository URL.

---

## 8.2 Check Current Branch

Use:

```bash
git branch
```

or:

```bash
git status
```

This confirms which branch you are currently using.

---

## 9. Creating the dev Branch

One person should create the `dev` branch from `main`.

```bash
git checkout main
git pull origin main
git checkout -b dev
git push -u origin dev
```

After this, all members should create their feature branches from `dev`.

---

## 10. Creating Feature Branches

## 10.1 Member 1 Branch

```bash
git checkout dev
git pull origin dev
git checkout -b feature/preprocessing
git push -u origin feature/preprocessing
```

---

## 10.2 Member 2 Branch

```bash
git checkout dev
git pull origin dev
git checkout -b feature/plate-detection
git push -u origin feature/plate-detection
```

---

## 10.3 Member 3 Branch

```bash
git checkout dev
git pull origin dev
git checkout -b feature/segmentation-morphology
git push -u origin feature/segmentation-morphology
```

---

## 10.4 Member 4 Branch

```bash
git checkout dev
git pull origin dev
git checkout -b feature/recognition-gui-evaluation
git push -u origin feature/recognition-gui-evaluation
```

---

## 11. Daily Work Flow

Each member should follow this flow when starting work.

```bash
git checkout <your-feature-branch>
git pull origin <your-feature-branch>
```

Example for Member 1:

```bash
git checkout feature/preprocessing
git pull origin feature/preprocessing
```

Then edit the assigned files.

After editing, check the changes:

```bash
git status
```

Add and commit the changes:

```bash
git add .
git commit -m "Implement preprocessing functions"
```

Push the branch:

```bash
git push origin <your-feature-branch>
```

Example:

```bash
git push origin feature/preprocessing
```

---

## 12. Commit Message Rule

Commit messages should be short and clear.

Recommended format:

```text
Action + target
```

Examples:

```text
Implement preprocessing functions
Add plate detection fallback handling
Update segmentation test script
Fix OCR unknown output handling
Add GUI status messages
Update evaluation CSV header
```

Avoid unclear commit messages such as:

```text
update
fix
final
final2
my work
```

---

## 13. Pulling Latest dev Changes into a Feature Branch

Before merging into `dev`, it is recommended to update your feature branch with the latest `dev`.

```bash
git checkout dev
git pull origin dev
git checkout <your-feature-branch>
git merge dev
```

Example:

```bash
git checkout dev
git pull origin dev
git checkout feature/preprocessing
git merge dev
```

If there are conflicts, resolve them carefully before pushing.

---

## 14. Merging Feature Branch into dev

When a member finishes a task:

1. Push the feature branch to GitHub.
2. Create a Pull Request from the feature branch to `dev`.
3. Review changed files.
4. Confirm the module runs.
5. Merge into `dev`.

Example merge direction:

```text
feature/preprocessing → dev
```

Do not merge directly into `main`.

---

## 15. Merging dev into main

Only merge `dev` into `main` when:

- The full pipeline runs
- The GUI opens
- Major errors are fixed
- The team agrees that the version is stable
- The version is suitable for backup or submission preparation

Merge direction:

```text
dev → main
```

---

## 16. Files Each Member Should Mainly Edit

## 16.1 Member 1

```text
src/preprocessing/
images/
dataset_metadata.csv
scratch/test_member1_preprocessing.m
```

---

## 16.2 Member 2

```text
src/plate_detection/
scratch/test_member2_plate_detection.m
```

---

## 16.3 Member 3

```text
src/segmentation/
images/test/plate_samples/
scratch/test_member3_segmentation.m
```

---

## 16.4 Member 4

```text
src/recognition/
src/evaluation/
src/utils/
launch_gui.m
scratch/test_member4_recognition_gui.m
```

---

## 17. Shared Files That Require Discussion

The following files may affect multiple members.

Edit these carefully and discuss changes if needed.

```text
main.m
launch_gui.m
README.md
CONTRIBUTING.md
results_template.csv
dataset_metadata.csv
.gitignore
docs/requirements/
docs/development/
docs/member_tasks/
```

Especially be careful with:

```text
main.m
launch_gui.m
core function signatures
results_template.csv
```

Changing these files may affect the full system.

---

## 18. Files That Should Usually Not Be Committed

Avoid committing:

```text
output/
report/figures/
images/raw/
large datasets
video recordings
ZIP files
MATLAB temporary files
```

Recommended `.gitignore` entries:

```gitignore
# MATLAB temporary and autosave files
*.asv
*.m~
*.slxc

# MATLAB data and figure files
*.mat
*.fig

# Output folders
output/
report/figures/

# Large image datasets
images/raw/

# Video recordings
*.mp4
*.mov
*.avi
*.mkv

# Archives
*.zip
*.rar
*.7z

# OS files
.DS_Store
Thumbs.db
```

Small selected test images may be committed if the team needs them for shared testing.

Recommended shared small image folders:

```text
images/test/
images/test/plate_samples/
images/selected_for_report/
```

---

## 19. Before Pushing Checklist

Before pushing your work, check:

```text
[ ] I am on my feature branch.
[ ] I edited mainly my assigned files.
[ ] I did not change function signatures without discussion.
[ ] I did not use prohibited methods.
[ ] I did not commit large datasets or output folders.
[ ] My code uses English comments and variable names.
[ ] My scratch test script runs or fails safely.
[ ] My module returns safe fallback values if input is invalid.
```

---

## 20. Before Pull Request Checklist

Before creating a Pull Request to `dev`, check:

```text
[ ] My branch is updated with the latest dev.
[ ] My assigned scratch test script runs.
[ ] There are no syntax errors.
[ ] The function names match the file names.
[ ] The agreed function signatures are unchanged.
[ ] Fallback outputs work.
[ ] The changed files are relevant to my task.
[ ] No large or unnecessary files are included.
```

---

## 21. After Merging into dev Checklist

After merging into `dev`, the team should check:

```text
[ ] main.m runs or fails with a clear message.
[ ] launch_gui.m opens.
[ ] sample_car.jpg can be loaded if available.
[ ] The pipeline reaches the final output or safe fallback.
[ ] UNKNOWN is displayed when recognition fails.
[ ] No missing path error occurs.
[ ] No prohibited method was added.
```

---

## 22. Common Git Commands

## 22.1 Check Status

```bash
git status
```

---

## 22.2 Check Branches

```bash
git branch
```

To show remote branches:

```bash
git branch -a
```

---

## 22.3 Switch Branch

```bash
git checkout <branch-name>
```

Example:

```bash
git checkout dev
```

---

## 22.4 Create Branch

```bash
git checkout -b <branch-name>
```

Example:

```bash
git checkout -b feature/preprocessing
```

---

## 22.5 Add Files

```bash
git add .
```

Or add a specific file:

```bash
git add src/preprocessing/preprocessImage.m
```

---

## 22.6 Commit

```bash
git commit -m "Your commit message"
```

---

## 22.7 Push

```bash
git push origin <branch-name>
```

---

## 22.8 Pull

```bash
git pull origin <branch-name>
```

---

## 23. Handling Merge Conflicts

Merge conflicts may happen if two people edit the same file.

Common conflict files may include:

```text
main.m
launch_gui.m
results_template.csv
README.md
```

To reduce conflicts:

- Edit mainly your assigned folder.
- Discuss before editing shared files.
- Pull latest changes regularly.
- Keep commits small.
- Do not reformat large files unnecessarily.

If a conflict happens:

1. Open the conflicted file.
2. Look for conflict markers:

```text
<<<<<<< HEAD
your version
=======
other version
>>>>>>> branch-name
```

3. Choose the correct combined version.
4. Remove the conflict markers.
5. Save the file.
6. Run tests if possible.
7. Add and commit the resolved file.

```bash
git add <resolved-file>
git commit -m "Resolve merge conflict"
```

---

## 24. Function Signature Rule

Core function signatures must remain stable.

```matlab
[preprocessedImg, preprocessDebug] = preprocessImage(originalImg);

[plateImg, plateBBox, detectionDebug] = detectPlateRegion(preprocessedImg, originalImg);

[characterImages, characterBBoxes] = segmentCharacters(plateImg);

rawText = recognizePlateText(plateImg);

cleanedText = cleanRecognizedText(rawText);

stateName = identifyState(cleanedText);
```

Changing these signatures may break other modules.

Do not change them without discussion.

---

## 25. Safe Fallback Rule

Each module should fail safely.

Recommended fallback values:

```matlab
plateImg = [];
plateBBox = [];
characterImages = {};
characterBBoxes = [];
rawText = "UNKNOWN";
cleanedText = "UNKNOWN";
stateName = "UNKNOWN";
```

This allows the full pipeline and GUI to continue running during development.

---

## 26. Final Submission Note

GitHub is for collaboration and backup.

The official final submission should be prepared separately according to the assignment instructions.

The final submission package may include:

```text
Project report
MATLAB source code
GUI file
Test images
Selected dataset images
Evaluation results
Workload matrix
Individual demo material
```

---

## 27. Notes for Claude or Codex

When generating or modifying files based on this workflow:

- Do not create folders based on branch names.
- Do not create source folders based on member names.
- Keep the same project structure across all branches.
- Keep core function signatures stable.
- Include `CONTRIBUTING.md`.
- Include scratch test scripts.
- Use English comments and variable names.
- Do not commit or generate unnecessary large output files.
