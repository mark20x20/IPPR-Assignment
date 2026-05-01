# Contributing Guide

## 1. Purpose

This document defines the collaboration rules for the License Plate Recognition (LPR) and State Identification System (SIS) project.

The purpose of this guide is to help all group members work together safely using GitHub, avoid overwriting each other's work, keep the project structure consistent, and make the final integration easier.

This project uses:

- Functional folder responsibility
- Feature branches
- Shared function signatures
- Scratch test scripts
- Safe fallback outputs

---

## 2. Project Collaboration Model

The project is divided by system function, not by member name.

Each member should mainly edit their assigned functional folder.

| Member | Main Responsibility | Assigned Folder or Files |
|---|---|---|
| Member 1 | Dataset and Preprocessing | `src/preprocessing/`, `images/`, `dataset_metadata.csv` |
| Member 2 | License Plate Detection | `src/plate_detection/` |
| Member 3 | Segmentation and Morphology | `src/segmentation/`, `images/test/plate_samples/` |
| Member 4 | Recognition, GUI, and Evaluation | `src/recognition/`, `src/evaluation/`, `src/utils/`, `launch_gui.m` |

---

## 3. Important Folder Rule

Do not create source folders based on member names.

Correct:

```text
src/preprocessing/
src/plate_detection/
src/segmentation/
src/recognition/
src/evaluation/
src/utils/
```

Incorrect:

```text
src/member1/
src/member2/
src/member3/
src/member4/
```

The project structure should stay organized by system function.

---

## 4. Git Branch Strategy

Recommended branches:

```text
main
dev
feature/preprocessing
feature/plate-detection
feature/segmentation-morphology
feature/recognition-gui-evaluation
```

Branch roles:

| Branch | Purpose |
|---|---|
| `main` | Stable final version for submission |
| `dev` | Integrated development version |
| `feature/preprocessing` | Member 1 work |
| `feature/plate-detection` | Member 2 work |
| `feature/segmentation-morphology` | Member 3 work |
| `feature/recognition-gui-evaluation` | Member 4 work |

---

## 5. Branch Names Are Not Folder Names

Branch names are only for Git version control.

Do not create folders based on branch names.

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

## 6. Recommended Merge Flow

Use this merge flow:

```text
feature branch
↓
dev
↓
main
```

Each member should work on their own feature branch.

When a feature is ready, merge it into `dev`.

Only merge `dev` into `main` when the system is stable.

Do not push directly to `main`.

---

## 7. First-Time Setup

Clone the repository:

```bash
git clone <repository-url>
cd Assignment
```

Check the current branch:

```bash
git status
```

or:

```bash
git branch
```

---

## 8. Creating the dev Branch

One person should create the `dev` branch from `main`.

```bash
git checkout main
git pull origin main
git checkout -b dev
git push -u origin dev
```

After this, all feature branches should be created from `dev`.

---

## 9. Creating Feature Branches

## 9.1 Member 1

```bash
git checkout dev
git pull origin dev
git checkout -b feature/preprocessing
git push -u origin feature/preprocessing
```

---

## 9.2 Member 2

```bash
git checkout dev
git pull origin dev
git checkout -b feature/plate-detection
git push -u origin feature/plate-detection
```

---

## 9.3 Member 3

```bash
git checkout dev
git pull origin dev
git checkout -b feature/segmentation-morphology
git push -u origin feature/segmentation-morphology
```

---

## 9.4 Member 4

```bash
git checkout dev
git pull origin dev
git checkout -b feature/recognition-gui-evaluation
git push -u origin feature/recognition-gui-evaluation
```

---

## 10. Daily Workflow

Before starting work:

```bash
git checkout <your-feature-branch>
git pull origin <your-feature-branch>
```

Example:

```bash
git checkout feature/preprocessing
git pull origin feature/preprocessing
```

After editing files:

```bash
git status
git add .
git commit -m "Describe your changes"
git push origin <your-feature-branch>
```

Example:

```bash
git add .
git commit -m "Implement preprocessing functions"
git push origin feature/preprocessing
```

---

## 11. Commit Message Rules

Commit messages should be short and clear.

Recommended format:

```text
Action + target
```

Good examples:

```text
Implement preprocessing functions
Add plate detection fallback handling
Update segmentation test script
Fix OCR unknown output handling
Add GUI status messages
Update evaluation CSV header
```

Bad examples:

```text
update
fix
final
final2
my work
```

---

## 12. Pulling Latest dev Changes

Before merging your feature branch into `dev`, update your branch with the latest `dev`.

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

If conflicts occur, resolve them carefully before pushing.

---

## 13. Pull Request Rule

When your work is ready:

1. Push your feature branch to GitHub.
2. Create a Pull Request from your feature branch to `dev`.
3. Check the changed files.
4. Confirm your scratch test script runs.
5. Ask another member to review if possible.
6. Merge into `dev`.

Example:

```text
feature/preprocessing → dev
```

Do not create a Pull Request directly to `main` unless the team agrees.

---

## 14. Files Each Member Should Mainly Edit

## 14.1 Member 1

```text
src/preprocessing/
images/
dataset_metadata.csv
scratch/test_member1_preprocessing.m
```

---

## 14.2 Member 2

```text
src/plate_detection/
scratch/test_member2_plate_detection.m
```

---

## 14.3 Member 3

```text
src/segmentation/
images/test/plate_samples/
scratch/test_member3_segmentation.m
```

---

## 14.4 Member 4

```text
src/recognition/
src/evaluation/
src/utils/
launch_gui.m
scratch/test_member4_recognition_gui.m
```

---

## 15. Shared Files That Require Discussion

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

Changing these files may break the full pipeline.

---

## 16. Function Signature Rule

Core function signatures must remain stable.

```matlab
[preprocessedImg, preprocessDebug] = preprocessImage(originalImg);

[plateImg, plateBBox, detectionDebug] = detectPlateRegion(preprocessedImg, originalImg);

[characterImages, characterBBoxes] = segmentCharacters(plateImg);

rawText = recognizePlateText(plateImg);

cleanedText = cleanRecognizedText(rawText);

stateName = identifyState(cleanedText);
```

Do not change these function signatures without team discussion.

---

## 17. File Name and Function Name Rule

Each MATLAB function file must follow this rule:

```text
File name = Function name
```

Example:

```text
preprocessImage.m
```

must contain:

```matlab
function [preprocessedImg, debugInfo] = preprocessImage(inputImg)
```

If the file name and function name do not match, MATLAB may not find or run the function correctly.

---

## 18. MATLAB Path Rule

The following files should include:

```matlab
addpath(genpath('src'));
```

Required files:

```text
main.m
launch_gui.m
scratch/test_member1_preprocessing.m
scratch/test_member2_plate_detection.m
scratch/test_member3_segmentation.m
scratch/test_member4_recognition_gui.m
```

This allows MATLAB to find all functions under `src`.

---

## 19. Safe Fallback Rule

Each module should fail safely instead of crashing.

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

This allows the full pipeline and GUI to continue running even when a module fails.

---

## 20. Prohibited Methods

Do not use:

```text
TensorFlow
Haar Cascade
YOLO
Deep learning object detectors
Template matching
Pattern matching methods
```

Do not use pretrained object detectors.

Do not use character recognition based on comparing characters with fixed template images.

Character segmentation may be used for visualization, explanation, and OCR preparation.

Final text recognition should use OCR.

---

## 21. OCR Rule

OCR is allowed, but it should be applied after:

```text
Image preprocessing
↓
Plate region detection
↓
Plate cropping
↓
Plate image cleanup
↓
OCR
```

Do not build the system by applying OCR directly to the full original image as the only processing step.

---

## 22. Code Style Rules

All code should use:

- English comments
- English variable names
- English function names
- Clear function headers
- Simple and readable logic

Avoid unclear names such as:

```matlab
a
b
x1
temp2
finalfinal
```

Use names such as:

```matlab
originalImg
preprocessedImg
plateImg
plateBBox
rawText
cleanedText
stateName
debugInfo
```

---

## 23. Scratch Test Scripts

Each member should run their own scratch test script before creating a Pull Request.

```text
scratch/test_member1_preprocessing.m
scratch/test_member2_plate_detection.m
scratch/test_member3_segmentation.m
scratch/test_member4_recognition_gui.m
```

These scripts are for module-level testing.

They are not the final system entry points.

Final system entry points:

```text
main.m
launch_gui.m
```

---

## 24. Before Pushing Checklist

Before pushing your work, check:

```text
[ ] I am on my feature branch.
[ ] I mainly edited my assigned files.
[ ] I did not change core function signatures without discussion.
[ ] I did not use prohibited methods.
[ ] I did not commit large datasets or output folders.
[ ] My code uses English comments and variable names.
[ ] My scratch test script runs or fails safely.
[ ] My module returns safe fallback values if input is invalid.
```

---

## 25. Before Pull Request Checklist

Before creating a Pull Request to `dev`, check:

```text
[ ] My branch is updated with the latest dev.
[ ] My assigned scratch test script runs.
[ ] There are no syntax errors.
[ ] Function names match file names.
[ ] Core function signatures are unchanged.
[ ] Fallback outputs work.
[ ] Changed files are relevant to my task.
[ ] No large or unnecessary files are included.
```

---

## 26. After Merging into dev Checklist

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

## 27. Files That Should Usually Not Be Committed

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

## 28. Handling Merge Conflicts

Merge conflicts may happen if two members edit the same file.

Common conflict files:

```text
main.m
launch_gui.m
results_template.csv
README.md
dataset_metadata.csv
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

## 29. Common Git Commands

## 29.1 Check Status

```bash
git status
```

---

## 29.2 Check Branches

```bash
git branch
```

Remote branches:

```bash
git branch -a
```

---

## 29.3 Switch Branch

```bash
git checkout <branch-name>
```

Example:

```bash
git checkout dev
```

---

## 29.4 Create Branch

```bash
git checkout -b <branch-name>
```

Example:

```bash
git checkout -b feature/preprocessing
```

---

## 29.5 Add Files

```bash
git add .
```

Or add a specific file:

```bash
git add src/preprocessing/preprocessImage.m
```

---

## 29.6 Commit

```bash
git commit -m "Your commit message"
```

---

## 29.7 Push

```bash
git push origin <branch-name>
```

Example:

```bash
git push origin feature/preprocessing
```

---

## 29.8 Pull

```bash
git pull origin <branch-name>
```

Example:

```bash
git pull origin dev
```

---

## 30. Final Submission Note

GitHub is only for collaboration and backup.

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

## 31. Notes for Claude or Codex

When generating or modifying files based on this contributing guide:

- Do not create folders based on branch names.
- Do not create source folders based on member names.
- Keep the same project structure across all branches.
- Keep core function signatures stable.
- Include scratch test scripts.
- Use English comments and variable names.
- Do not generate unnecessary large output files.
- Do not use prohibited methods.
- Make the first skeleton runnable before improving accuracy.
