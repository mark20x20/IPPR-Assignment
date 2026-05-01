# File Structure

## 1. Purpose

This document defines the recommended file and folder structure for the License Plate Recognition (LPR) and State Identification System (SIS).

The purpose of this structure is to keep the MATLAB project organized, readable, easy to test, and easy to share with group members through GitHub.

This file structure also supports parallel development. Each group member can work on their assigned functional folder while using shared skeleton files, sample data, placeholder outputs, and scratch test scripts.

---

## 2. Project Root Folder

The project root folder is:

```text
C:\APU\IPPR\Assignment
```

All project files should be placed under this root folder.

The code should use relative paths where possible so that the project can still work if the folder is moved.

---

## 3. Recommended Project Structure

```text
Assignment/
├── main.m
├── launch_gui.m
├── README.md
├── CONTRIBUTING.md
├── results_template.csv
├── dataset_metadata.csv
├── .gitignore
│
├── docs/
│   ├── requirements/
│   │   ├── 00_project_overview.md
│   │   ├── 01_assignment_requirements.md
│   │   ├── 02_system_requirements.md
│   │   ├── 03_technical_constraints.md
│   │   ├── 04_processing_pipeline.md
│   │   ├── 05_dataset_and_testing.md
│   │   ├── 06_gui_requirements.md
│   │   ├── 07_file_structure.md
│   │   ├── 08_function_design.md
│   │   ├── 09_evaluation_plan.md
│   │   ├── 10_report_requirements.md
│   │   └── 11_claude_codex_instructions.md
│   │
│   ├── development/
│   │   ├── 00_parallel_development_plan.md
│   │   ├── 01_member_task_allocation.md
│   │   ├── 02_git_workflow.md
│   │   └── 03_integration_plan.md
│   │
│   └── member_tasks/
│       ├── member1_preprocessing.md
│       ├── member2_plate_detection.md
│       ├── member3_segmentation_morphology.md
│       └── member4_recognition_gui_eval.md
│
├── scratch/
│   ├── test_member1_preprocessing.m
│   ├── test_member2_plate_detection.m
│   ├── test_member3_segmentation.m
│   └── test_member4_recognition_gui.m
│
├── images/
│   ├── raw/
│   │   ├── car/
│   │   ├── motorcycle/
│   │   ├── bus/
│   │   ├── van/
│   │   └── truck/
│   │
│   ├── test/
│   │   ├── sample_car.jpg
│   │   ├── plate_samples/
│   │   ├── success_cases/
│   │   ├── failure_cases/
│   │   └── difficult_cases/
│   │
│   └── selected_for_report/
│
├── output/
│   ├── plate_detection/
│   ├── segmentation/
│   ├── recognition/
│   └── figures/
│
├── src/
│   ├── preprocessing/
│   │   ├── preprocessImage.m
│   │   ├── convertToGray.m
│   │   ├── enhanceContrast.m
│   │   └── removeNoise.m
│   │
│   ├── plate_detection/
│   │   ├── detectPlateRegion.m
│   │   ├── selectPlateCandidate.m
│   │   └── cropPlateRegion.m
│   │
│   ├── segmentation/
│   │   ├── binarizePlate.m
│   │   ├── cleanBinaryImage.m
│   │   └── segmentCharacters.m
│   │
│   ├── recognition/
│   │   ├── recognizePlateText.m
│   │   ├── cleanRecognizedText.m
│   │   └── identifyState.m
│   │
│   ├── evaluation/
│   │   ├── evaluateSingleImage.m
│   │   └── saveResultRow.m
│   │
│   └── utils/
│       ├── displayPipelineResults.m
│       ├── saveStepImage.m
│       └── ensureOutputFolders.m
│
└── report/
    ├── figures/
    └── tables/
```

---

## 4. Root-Level Files

## 4.1 main.m

### Purpose

`main.m` is the main script for testing the full processing pipeline.

It should be used during development to check whether the complete system can run from image loading to state identification.

### Responsibilities

- Clear workspace
- Add `src` folders to MATLAB path
- Ensure output folders exist
- Load sample image
- Run preprocessing
- Run plate detection
- Run segmentation or OCR preparation
- Run recognition
- Run state identification
- Display results

### Expected Sample Image

The first runnable version should use:

```text
images/test/sample_car.jpg
```

If `sample_car.jpg` does not exist, `main.m` should show a clear error message.

---

## 4.2 launch_gui.m

### Purpose

`launch_gui.m` is the entry point for the graphical user interface.

### Responsibilities

- Create GUI window
- Load user-selected image
- Run the full LPR and SIS pipeline
- Display original image
- Display detected plate
- Display recognized text
- Display identified state
- Display processing status
- Handle fallback outputs such as `UNKNOWN`

### Notes

The GUI should call functions from `src`.

It should not duplicate the processing logic inside GUI callbacks.

---

## 4.3 README.md

### Purpose

`README.md` explains the project for group members and markers.

### Recommended Contents

- Project title
- Project objective
- Development environment
- Folder structure
- How to run `main.m`
- How to run `launch_gui.m`
- Required MATLAB toolboxes
- Notes about prohibited methods
- Notes about OCR usage
- Notes about GitHub usage
- Team member responsibilities, if needed

---

## 4.4 CONTRIBUTING.md

### Purpose

`CONTRIBUTING.md` defines collaboration rules for group members.

### Recommended Contents

- Branch strategy
- Feature-based folder responsibility
- How to create a feature branch
- How to commit and push changes
- How to merge into `dev`
- Files that should not be edited without discussion
- Files that should not be committed
- Requirement to keep comments and variable names in English
- Requirement to run relevant tests before merging

### Important Rule

Branch names are not folder names.

For example:

```text
Git branch: feature/preprocessing
Assigned folder: src/preprocessing/
```

Do not create project folders such as:

```text
Assignment/feature/preprocessing/
```

---

## 4.5 results_template.csv

### Purpose

`results_template.csv` provides a template for recording experimental results.

### Recommended Columns

```csv
image_name,vehicle_type,expected_text,ocr_text,expected_state,predicted_state,detection_result,ocr_result,state_result,overall_result,notes
```

The `overall_result` column should be included to keep evaluation records consistent with the evaluation plan.

---

## 4.6 dataset_metadata.csv

### Purpose

`dataset_metadata.csv` stores information about test images.

### Recommended Columns

```csv
image_name,image_path,vehicle_type,expected_plate_text,expected_state,plate_type,distance,lighting,background,angle,source,notes
```

This file should also include manually cropped plate samples when they are used for segmentation or OCR testing.

---

## 4.7 .gitignore

### Purpose

`.gitignore` prevents unnecessary files from being committed to GitHub.

### Recommended Contents

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

---

## 5. docs Folder

## 5.1 Purpose

The `docs` folder stores project planning, requirement, development, and member task documents.

These documents should be used as context when asking Claude or Codex to generate code.

---

## 5.2 docs/requirements Folder

This folder stores all requirement and design documents.

Required files:

```text
00_project_overview.md
01_assignment_requirements.md
02_system_requirements.md
03_technical_constraints.md
04_processing_pipeline.md
05_dataset_and_testing.md
06_gui_requirements.md
07_file_structure.md
08_function_design.md
09_evaluation_plan.md
10_report_requirements.md
11_claude_codex_instructions.md
```

### Purpose

These files define:

- Project overview
- Assignment requirements
- System requirements
- Technical constraints
- Processing pipeline
- Dataset and testing plan
- GUI requirements
- File structure
- Function design
- Evaluation plan
- Report requirements
- Claude or Codex instructions

---

## 5.3 docs/development Folder

This folder stores team development process documents.

Required files:

```text
00_parallel_development_plan.md
01_member_task_allocation.md
02_git_workflow.md
03_integration_plan.md
```

### 00_parallel_development_plan.md

Explains how the team can develop modules in parallel using:

- Shared skeleton files
- Fixed function signatures
- Placeholder outputs
- Sample images
- Manually cropped plate samples
- Scratch test scripts

### 01_member_task_allocation.md

Defines the responsibility of each group member.

### 02_git_workflow.md

Explains the GitHub workflow, branch roles, and merge rules.

### 03_integration_plan.md

Defines how individual modules are integrated and tested.

---

## 5.4 docs/member_tasks Folder

This folder stores detailed task documents for each member.

Required files:

```text
member1_preprocessing.md
member2_plate_detection.md
member3_segmentation_morphology.md
member4_recognition_gui_eval.md
```

### Purpose

Each member task document should include:

- Assigned folders
- Assigned files
- Related system requirements
- Main responsibilities
- Input and output format
- Required function signatures
- Independent test script
- Expected result
- Report contribution hints

---

## 6. scratch Folder

## 6.1 Purpose

The `scratch` folder stores individual test scripts for module-level development.

These scripts allow each member to test their assigned module independently.

The files in this folder are for development and testing, not the main final system entry point.

---

## 6.2 Required Scratch Files

```text
scratch/test_member1_preprocessing.m
scratch/test_member2_plate_detection.m
scratch/test_member3_segmentation.m
scratch/test_member4_recognition_gui.m
```

---

## 6.3 test_member1_preprocessing.m

### Purpose

Tests the preprocessing module independently.

### Related Folder

```text
src/preprocessing/
```

### Expected Input

```text
images/test/sample_car.jpg
```

### Expected Output

- Grayscale image
- Enhanced image
- Filtered image
- Preprocessing debug results

---

## 6.4 test_member2_plate_detection.m

### Purpose

Tests the plate detection module independently.

### Related Folder

```text
src/plate_detection/
```

### Expected Input

```text
images/test/sample_car.jpg
```

### Temporary Input Strategy

If preprocessing is not ready, this script may use simple grayscale conversion.

```matlab
originalImg = imread('images/test/sample_car.jpg');

if size(originalImg, 3) == 3
    preprocessedImg = rgb2gray(originalImg);
else
    preprocessedImg = originalImg;
end
```

### Expected Output

- Edge image or candidate debug image
- Plate bounding box or empty fallback
- Cropped plate image or empty fallback

---

## 6.5 test_member3_segmentation.m

### Purpose

Tests segmentation and morphology independently.

### Related Folder

```text
src/segmentation/
```

### Expected Input

```text
images/test/plate_samples/
```

### Expected Output

- Binary plate image
- Cleaned binary plate image
- Character candidate images
- Character bounding boxes

---

## 6.6 test_member4_recognition_gui.m

### Purpose

Tests recognition, state identification, GUI-related utilities, and evaluation independently.

### Related Folders

```text
src/recognition/
src/evaluation/
src/utils/
```

### Related Root File

```text
launch_gui.m
```

### Expected Input

```text
images/test/plate_samples/
```

or temporary OCR strings such as:

```text
BMS8147
PAB1234
MAB5678
WXY5678
```

### Expected Output

- OCR text or `UNKNOWN`
- Cleaned OCR text
- Identified state or `UNKNOWN`
- Result display
- Evaluation row if needed
- GUI launch test

---

## 7. images Folder

## 7.1 Purpose

The `images` folder stores vehicle images used for development, testing, module-level tests, and report screenshots.

---

## 7.2 images/raw

### Purpose

Stores original collected images.

### Recommended Subfolders

```text
images/raw/car/
images/raw/motorcycle/
images/raw/bus/
images/raw/van/
images/raw/truck/
```

### Notes

Large raw image datasets should usually not be committed to GitHub.

---

## 7.3 images/test

### Purpose

Stores images used for system testing and early development.

### Recommended Structure

```text
images/test/
├── sample_car.jpg
├── plate_samples/
├── success_cases/
├── failure_cases/
└── difficult_cases/
```

---

## 7.4 images/test/sample_car.jpg

### Purpose

`sample_car.jpg` is the first sample image used for initial full-pipeline testing.

It is used by:

```text
main.m
scratch/test_member1_preprocessing.m
scratch/test_member2_plate_detection.m
```

For the first runnable version, `images/test/sample_car.jpg` may be placed directly under `images/test/`.

After the system becomes stable, final test images should be organized into:

```text
images/test/success_cases/
images/test/failure_cases/
images/test/difficult_cases/
```

---

## 7.5 images/test/plate_samples

### Purpose

This folder stores manually cropped license plate images.

It supports parallel development before automatic plate detection is fully completed.

This folder is mainly used by:

- Member 3 for segmentation and morphology testing
- Member 4 for OCR, state identification, GUI, and evaluation testing

Example files:

```text
images/test/plate_samples/plate_selangor_01.jpg
images/test/plate_samples/plate_penang_01.jpg
images/test/plate_samples/plate_malacca_01.jpg
```

---

## 7.6 images/test/success_cases

### Purpose

Stores images that are expected to work well.

Examples:

- Clear car plate image
- Good lighting
- Simple background
- Front-facing plate

---

## 7.7 images/test/failure_cases

### Purpose

Stores images where the system fails or is expected to fail.

Failure cases are important for critical analysis.

Examples:

- Very small plate
- Strong reflection
- Blurry image
- Wrong region detected
- OCR returns incorrect text

---

## 7.8 images/test/difficult_cases

### Purpose

Stores challenging images that may produce partial success.

Examples:

- Angled plate
- Low light
- Complex background
- Shadow on plate
- Far distance image

---

## 7.9 images/selected_for_report

### Purpose

Stores images selected for the final report.

This folder should include representative examples such as:

- Successful detection cases
- OCR success cases
- Failure cases
- Difficult lighting cases
- Different vehicle types
- Different state plates
- GUI output examples if needed

---

## 8. output Folder

## 8.1 Purpose

The `output` folder stores generated results and intermediate processing images.

The system should automatically create this folder and its subfolders if they do not exist.

---

## 8.2 output/plate_detection

### Purpose

Stores outputs related to license plate detection.

Examples:

```text
car_selangor_close_01_detected.jpg
car_selangor_close_01_bbox.jpg
```

---

## 8.3 output/segmentation

### Purpose

Stores outputs related to binarization, segmentation, and morphological cleaning.

Examples:

```text
car_selangor_close_01_binary.jpg
car_selangor_close_01_cleaned.jpg
car_selangor_close_01_characters.jpg
```

---

## 8.4 output/recognition

### Purpose

Stores outputs related to OCR and recognition preparation.

Examples:

```text
car_selangor_close_01_ocr_ready.jpg
car_selangor_close_01_plate_crop.jpg
```

---

## 8.5 output/figures

### Purpose

Stores final figures and screenshots for the report.

Examples:

```text
car_selangor_close_01_final_result.jpg
car_selangor_close_01_pipeline_steps.jpg
```

---

## 9. src Folder

## 9.1 Purpose

The `src` folder stores all reusable MATLAB function files.

Each function should have a clear responsibility.

The `src` folder is divided by system function, not by member name.

---

## 9.2 MATLAB Path Rule

`main.m`, `launch_gui.m`, and scratch test scripts should include:

```matlab
addpath(genpath('src'));
```

This allows MATLAB to call all functions inside the `src` folder.

---

## 9.3 Function File Rule

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

---

## 9.4 Feature-Based Folder Responsibility

The project uses feature-based folder responsibility.

| Member | Main Responsibility | Assigned Folder or Files |
|---|---|---|
| Member 1 | Dataset and Preprocessing | `src/preprocessing/`, `images/`, `dataset_metadata.csv` |
| Member 2 | License Plate Detection | `src/plate_detection/` |
| Member 3 | Segmentation and Morphology | `src/segmentation/` |
| Member 4 | Recognition, GUI, and Evaluation | `src/recognition/`, `src/evaluation/`, `src/utils/`, `launch_gui.m` |

This does not mean that new member-specific source folders should be created.

Correct structure:

```text
src/preprocessing/
src/plate_detection/
src/segmentation/
src/recognition/
```

Incorrect structure:

```text
src/member1/
src/member2/
src/member3/
src/member4/
```

---

## 10. src/preprocessing

## 10.1 Purpose

This folder contains functions for preparing the image before plate detection.

---

## 10.2 Assigned Member

```text
Member 1
```

---

## 10.3 Required Files

```text
preprocessImage.m
convertToGray.m
enhanceContrast.m
removeNoise.m
```

---

## 10.4 File Responsibilities

### preprocessImage.m

Runs the full preprocessing flow.

Recommended function signature:

```matlab
function [preprocessedImg, debugInfo] = preprocessImage(inputImg)
```

### convertToGray.m

Converts RGB images to grayscale.

### enhanceContrast.m

Improves contrast using methods such as `imadjust`, `histeq`, or `adapthisteq`.

### removeNoise.m

Reduces image noise using filters such as median or Gaussian filtering.

---

## 11. src/plate_detection

## 11.1 Purpose

This folder contains functions for detecting and cropping license plate regions.

---

## 11.2 Assigned Member

```text
Member 2
```

---

## 11.3 Required Files

```text
detectPlateRegion.m
selectPlateCandidate.m
cropPlateRegion.m
```

---

## 11.4 File Responsibilities

### detectPlateRegion.m

Runs the full plate detection process.

It may use:

- Edge detection
- Morphological operations
- Connected component analysis
- Region property filtering

Recommended function signature:

```matlab
function [plateImg, plateBBox, debugInfo] = detectPlateRegion(preprocessedImg, originalImg)
```

### selectPlateCandidate.m

Selects the most likely plate candidate from detected regions.

### cropPlateRegion.m

Crops the detected plate region from the original image.

---

## 12. src/segmentation

## 12.1 Purpose

This folder contains functions for preparing the plate image and segmenting possible character regions.

---

## 12.2 Assigned Member

```text
Member 3
```

---

## 12.3 Required Files

```text
binarizePlate.m
cleanBinaryImage.m
segmentCharacters.m
```

---

## 12.4 File Responsibilities

### binarizePlate.m

Converts the cropped plate image into a binary image.

### cleanBinaryImage.m

Cleans binary image noise using morphological operations.

### segmentCharacters.m

Finds possible character regions using connected components.

Recommended function signature:

```matlab
function [characterImages, characterBBoxes] = segmentCharacters(plateImg)
```

Important note:

Character segmentation is mainly used for visualization, explanation, and OCR preparation.

Final text recognition should use OCR, not template-based character matching.

---

## 13. src/recognition

## 13.1 Purpose

This folder contains functions for OCR and state identification.

---

## 13.2 Assigned Member

```text
Member 4
```

---

## 13.3 Required Files

```text
recognizePlateText.m
cleanRecognizedText.m
identifyState.m
```

---

## 13.4 File Responsibilities

### recognizePlateText.m

Recognizes license plate text using OCR.

If OCR fails, it should return:

```text
UNKNOWN
```

### cleanRecognizedText.m

Cleans raw OCR output.

### identifyState.m

Identifies the registered state based on the plate prefix.

---

## 14. src/evaluation

## 14.1 Purpose

This folder contains functions for testing and saving evaluation results.

---

## 14.2 Assigned Member

```text
Member 4
```

---

## 14.3 Required Files

```text
evaluateSingleImage.m
saveResultRow.m
```

---

## 14.4 File Responsibilities

### evaluateSingleImage.m

Runs the pipeline for one test image and compares the result with expected values.

### saveResultRow.m

Saves or appends a result row to a CSV file.

---

## 15. src/utils

## 15.1 Purpose

This folder contains utility functions used by multiple parts of the system.

---

## 15.2 Assigned Member

```text
Member 4
```

Member 4 is the main owner, but other members may use utility functions.

---

## 15.3 Required Files

```text
displayPipelineResults.m
saveStepImage.m
ensureOutputFolders.m
```

---

## 15.4 File Responsibilities

### displayPipelineResults.m

Displays original image, detected plate, recognized text, and identified state.

### saveStepImage.m

Saves intermediate or final images to the output folder.

### ensureOutputFolders.m

Creates required output folders if they do not exist.

---

## 16. report Folder

## 16.1 Purpose

The `report` folder stores materials used for the final project report.

---

## 16.2 report/figures

Stores figures and screenshots for the report.

Examples:

- Processing pipeline screenshots
- GUI screenshots
- Success case images
- Failure case images
- Member-specific output evidence

---

## 16.3 report/tables

Stores result tables and analysis tables.

Examples:

- Experimental result table
- Failure analysis table
- Contribution matrix draft

---

## 17. GitHub Usage

## 17.1 Purpose

GitHub is used only for:

- Sharing source code
- Version control
- Collaboration
- Backup

GitHub should not replace the official assignment submission.

---

## 17.2 Files Suitable for GitHub

Recommended files to commit:

```text
main.m
launch_gui.m
README.md
CONTRIBUTING.md
results_template.csv
dataset_metadata.csv
.gitignore
docs/
src/
scratch/
small selected test images if needed
small plate sample images if needed
```

---

## 17.3 Files Usually Not Suitable for GitHub

Avoid committing:

```text
output/
images/raw/
report/figures/
large datasets
video recordings
ZIP files
MATLAB temporary files
```

---

## 17.4 Git Branches

Recommended branches:

```text
main
dev
feature/preprocessing
feature/plate-detection
feature/segmentation-morphology
feature/recognition-gui-evaluation
```

### Branch Roles

| Branch | Purpose |
|---|---|
| `main` | Stable final version |
| `dev` | Integrated development version |
| `feature/preprocessing` | Member 1 work |
| `feature/plate-detection` | Member 2 work |
| `feature/segmentation-morphology` | Member 3 work |
| `feature/recognition-gui-evaluation` | Member 4 work |

---

## 17.5 Branch and Folder Separation

Git branch names are not project folder names.

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

The project folder structure should remain the same across all branches.

---

## 18. Final Submission Structure

The final submission ZIP should include:

```text
MATLAB source code
GUI file
Test images
Selected dataset images
Project report
Experimental outputs if required
Workload matrix
Individual demonstration material if required
```

GitHub should not replace the official Moodle or assignment submission.

---

## 19. First Version Minimum Structure

For the first runnable version, at minimum create:

```text
Assignment/
├── main.m
├── launch_gui.m
├── README.md
├── results_template.csv
├── dataset_metadata.csv
├── .gitignore
│
├── scratch/
│   ├── test_member1_preprocessing.m
│   ├── test_member2_plate_detection.m
│   ├── test_member3_segmentation.m
│   └── test_member4_recognition_gui.m
│
├── images/
│   └── test/
│       ├── sample_car.jpg
│       └── plate_samples/
│
├── src/
│   ├── preprocessing/
│   ├── plate_detection/
│   ├── segmentation/
│   ├── recognition/
│   ├── evaluation/
│   └── utils/
│
└── output/
```

The first version only needs enough data and code to confirm that:

- `main.m` can run.
- `launch_gui.m` can open.
- Each scratch test script can run or fail safely.
- Each module can return fallback outputs if it is not fully implemented.

---

## 20. Minimum Parallel Development Structure

For parallel development, the following must exist:

```text
scratch/
images/test/sample_car.jpg
images/test/plate_samples/
src/preprocessing/
src/plate_detection/
src/segmentation/
src/recognition/
src/evaluation/
src/utils/
```

This allows:

- Member 1 to test preprocessing
- Member 2 to test plate detection with a temporary grayscale image
- Member 3 to test segmentation using manually cropped plate images
- Member 4 to test OCR, state identification, GUI, and evaluation using plate samples or temporary OCR strings

---

## 21. Notes for Claude or Codex

When generating code, follow this file structure exactly unless there is a clear reason to change it.

Important rules:

- Use MATLAB `.m` files.
- Keep function names matched with file names.
- Use relative paths.
- Use `addpath(genpath('src'))`.
- Create `scratch/` test scripts.
- Support `images/test/sample_car.jpg`.
- Support `images/test/plate_samples/`.
- Do not use Docker.
- Do not use TensorFlow, Haar Cascade, YOLO, template matching, or pattern matching.
- Keep all comments and variable names in English.
- Do not create member-specific source folders such as `src/member1/`.
- Do not create folders based on Git branch names.
- Keep the same folder structure across all branches.
- Return `UNKNOWN` or empty outputs when processing fails.