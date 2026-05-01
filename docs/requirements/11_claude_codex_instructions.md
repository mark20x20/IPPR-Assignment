# Instructions for Claude or Codex

## 1. Purpose

This document provides implementation instructions for Claude or Codex.

The goal is to generate a clean, runnable MATLAB project skeleton for the License Plate Recognition (LPR) and State Identification System (SIS).

Claude or Codex should follow all requirements, constraints, file structure, function design, development workflow, and member task documents in:

```text
docs/requirements/
docs/development/
docs/member_tasks/
```

The generated project should support both:

1. Full-pipeline execution from `main.m` and `launch_gui.m`
2. Parallel module-level development using scratch test scripts

---

## 2. Project Summary

## 2.1 Project Name

```text
License Plate Recognition and State Identification System
```

## 2.2 Main Goal

Create a MATLAB-based system that can:

1. Load a vehicle image.
2. Preprocess the image.
3. Detect the license plate region.
4. Crop the detected license plate region.
5. Prepare the plate image for OCR.
6. Segment possible character regions for visualization and OCR preparation.
7. Recognize the plate text using OCR.
8. Clean the recognized text.
9. Identify the registered Malaysian state.
10. Display the results in a GUI.
11. Save useful outputs for report and evaluation.
12. Record structured evaluation results.

---

## 3. Development Environment

Use the following environment:

```text
MATLAB R2026a
Windows
```

The project root folder is:

```text
C:\APU\IPPR\Assignment
```

Use MATLAB `.m` files.

Do not use Docker.

GitHub is used only for code sharing, version control, collaboration, and backup.

The official final submission should still be prepared according to the assignment instructions, usually as a ZIP file.

---

## 4. Strict Assignment Constraints

The following methods must not be used:

```text
TensorFlow
Haar Cascade
YOLO
Deep learning object detectors
Template matching
Pattern matching methods
```

Do not generate code that depends on these methods.

Do not use a pretrained object detector.

Do not use character recognition based on comparing characters with fixed template images.

Character segmentation may be implemented for visualization, explanation, and OCR preparation, but final text recognition should use OCR, not template-based character matching.

---

## 5. Allowed Methods

Use classical image processing and MATLAB-based methods.

Allowed or recommended MATLAB functions include:

```matlab
imread
imshow
imwrite
rgb2gray
im2gray
imresize
imadjust
histeq
adapthisteq
medfilt2
imfilter
fspecial
conv2
edge
graythresh
imbinarize
adaptthresh
strel
imdilate
imerode
imopen
imclose
imfill
bwareaopen
bwconncomp
bwlabel
regionprops
imcrop
ocr
figure
subplot
axes
uicontrol
guidata
writetable
readtable
```

OCR is allowed, but OCR should only be applied after:

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

Do not apply OCR directly to the full original image as the only processing step.

---

## 6. MATLAB Coding Rules

## 6.1 File Type

Use MATLAB `.m` files only for the first version.

The project should mainly contain:

```text
.m script files
.m function files
```

Do not generate App Designer `.mlapp` files in the first version.

Use script-based GUI components for `launch_gui.m`.

---

## 6.2 Function Name Rule

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

Function names and file names must match exactly.

---

## 6.3 Path Rule

`main.m`, `launch_gui.m`, and all scratch test scripts must include:

```matlab
addpath(genpath('src'));
```

This allows MATLAB to find all function files under `src`.

---

## 6.4 Language Rule

Use English for:

- Function names
- Variable names
- Comments
- Function headers
- README
- Documentation inside code

---

## 6.5 Code Style

Generated code should be:

- Simple
- Readable
- Beginner-friendly
- Easy to debug
- Easy to explain in the report
- Divided into small functions
- Written with clear input/output comments

Avoid overly complex syntax unless necessary.

---

## 6.6 Error Handling

Code should handle common failures gracefully.

The system should not crash when:

- The input image is missing
- The selected file is invalid
- Plate detection fails
- Bounding box is invalid
- Plate image is empty
- Character segmentation fails
- OCR is unavailable
- OCR returns empty text
- State prefix is unknown
- Output folders are missing
- Plate sample images are missing
- A module is not fully implemented yet

Use `UNKNOWN` as fallback for text and state recognition failures.

Use empty arrays or empty cell arrays for unavailable image-processing outputs.

Examples:

```matlab
plateImg = [];
plateBBox = [];
characterImages = {};
characterBBoxes = [];
rawText = "UNKNOWN";
cleanedText = "UNKNOWN";
stateName = "UNKNOWN";
```

---

## 6.7 Function Interface Stability

Keep core function signatures stable after the skeleton is generated.

Core function signatures:

```matlab
[preprocessedImg, preprocessDebug] = preprocessImage(originalImg);

[plateImg, plateBBox, detectionDebug] = detectPlateRegion(preprocessedImg, originalImg);

[characterImages, characterBBoxes] = segmentCharacters(plateImg);

rawText = recognizePlateText(plateImg);

cleanedText = cleanRecognizedText(rawText);

stateName = identifyState(cleanedText);
```

Do not change these signatures unless the user explicitly requests it.

---

## 7. Parallel Development Requirements

## 7.1 Purpose

The final system follows a sequential pipeline:

```text
Preprocessing
↓
Plate Detection
↓
Segmentation and Morphology
↓
OCR, State Identification, GUI, and Evaluation
```

However, the project must support parallel development so that each group member can work independently.

---

## 7.2 Required Parallel Development Support

When generating the project skeleton, also create:

```text
scratch/
images/test/plate_samples/
docs/development/
docs/member_tasks/
```

Required scratch test scripts:

```text
scratch/test_member1_preprocessing.m
scratch/test_member2_plate_detection.m
scratch/test_member3_segmentation.m
scratch/test_member4_recognition_gui.m
```

The first version must support independent module testing.

Each member should be able to run their own scratch test script without waiting for other modules to be fully completed.

---

## 7.3 Placeholder Output Rule

Use placeholder outputs where necessary.

Examples:

```matlab
plateImg = [];
plateBBox = [];
rawText = "UNKNOWN";
cleanedText = "UNKNOWN";
stateName = "UNKNOWN";
```

The first implementation should prioritize:

1. Correct folder structure
2. Runnable code
3. Stable function interfaces
4. Safe fallback behavior
5. Independent module testing

Perfect recognition accuracy is not required in the first skeleton.

---

## 7.4 Member-Based Folder Responsibility

The project uses feature-based folder responsibility.

| Member | Main Responsibility | Assigned Folder or Files |
|---|---|---|
| Member 1 | Dataset and Preprocessing | `src/preprocessing/`, `images/`, `dataset_metadata.csv` |
| Member 2 | License Plate Detection | `src/plate_detection/` |
| Member 3 | Segmentation and Morphology | `src/segmentation/`, `images/test/plate_samples/` |
| Member 4 | Recognition, GUI, and Evaluation | `src/recognition/`, `src/evaluation/`, `src/utils/`, `launch_gui.m` |

Do not create source folders based on member names.

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

## 8. Git Workflow Requirements

## 8.1 Recommended Branches

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
| `main` | Stable final version |
| `dev` | Integrated development version |
| `feature/preprocessing` | Member 1 work |
| `feature/plate-detection` | Member 2 work |
| `feature/segmentation-morphology` | Member 3 work |
| `feature/recognition-gui-evaluation` | Member 4 work |

---

## 8.2 Branch and Folder Separation

Branch names are not folder names.

Do not change the project folder structure based on branch names.

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

All branches must use the same project folder structure.

---

## 8.3 Merge Flow

Recommended merge flow:

```text
feature branch
↓
dev
↓
main
```

Team members should not push directly to `main`.

---

## 9. Required Project Structure

Create or follow this structure:

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
│   ├── plate_detection/
│   ├── segmentation/
│   ├── recognition/
│   ├── evaluation/
│   └── utils/
│
└── report/
    ├── figures/
    └── tables/
```

---

## 10. Required Files to Generate

Generate skeleton code or files for the following.

```text
main.m
launch_gui.m
README.md
CONTRIBUTING.md
results_template.csv
dataset_metadata.csv
.gitignore

scratch/test_member1_preprocessing.m
scratch/test_member2_plate_detection.m
scratch/test_member3_segmentation.m
scratch/test_member4_recognition_gui.m

docs/development/00_parallel_development_plan.md
docs/development/01_member_task_allocation.md
docs/development/02_git_workflow.md
docs/development/03_integration_plan.md

docs/member_tasks/member1_preprocessing.md
docs/member_tasks/member2_plate_detection.md
docs/member_tasks/member3_segmentation_morphology.md
docs/member_tasks/member4_recognition_gui_eval.md

src/preprocessing/preprocessImage.m
src/preprocessing/convertToGray.m
src/preprocessing/enhanceContrast.m
src/preprocessing/removeNoise.m

src/plate_detection/detectPlateRegion.m
src/plate_detection/selectPlateCandidate.m
src/plate_detection/cropPlateRegion.m

src/segmentation/binarizePlate.m
src/segmentation/cleanBinaryImage.m
src/segmentation/segmentCharacters.m

src/recognition/recognizePlateText.m
src/recognition/cleanRecognizedText.m
src/recognition/identifyState.m

src/evaluation/evaluateSingleImage.m
src/evaluation/saveResultRow.m

src/utils/displayPipelineResults.m
src/utils/saveStepImage.m
src/utils/ensureOutputFolders.m
```

---

## 11. First Implementation Goal

The first implementation should be a runnable skeleton.

It does not need perfect plate detection accuracy.

The first version must:

1. Run without syntax errors.
2. Load one sample image if available.
3. Show a clear error if the sample image is missing.
4. Run through all pipeline functions.
5. Display the original image.
6. Display the detected plate image or a safe placeholder.
7. Return recognized text or `UNKNOWN`.
8. Return identified state or `UNKNOWN`.
9. Open and operate a simple GUI.
10. Avoid crashing if OCR or detection fails.
11. Include scratch test scripts for all members.
12. Support manually cropped plate samples.
13. Support placeholder outputs for incomplete modules.
14. Keep all core function signatures stable.

---

## 12. main.m Requirements

`main.m` should:

1. Clear the Command Window.
2. Clear variables.
3. Close all figures.
4. Add source folders to path.
5. Ensure output folders exist.
6. Load:

```text
images/test/sample_car.jpg
```

7. If the sample image does not exist, show a clear error message.
8. Run the full pipeline:

```text
preprocessImage
detectPlateRegion
segmentCharacters
recognizePlateText
cleanRecognizedText
identifyState
displayPipelineResults
```

9. Print the recognized text and identified state to the Command Window.
10. Handle fallback outputs without crashing.

Recommended call flow:

```matlab
clc;
clear;
close all;

addpath(genpath('src'));

ensureOutputFolders();

imagePath = fullfile('images', 'test', 'sample_car.jpg');

if ~isfile(imagePath)
    error('Sample image not found: %s', imagePath);
end

originalImg = imread(imagePath);

[preprocessedImg, preprocessDebug] = preprocessImage(originalImg);

[plateImg, plateBBox, detectionDebug] = detectPlateRegion(preprocessedImg, originalImg);

[characterImages, characterBBoxes] = segmentCharacters(plateImg);

rawText = recognizePlateText(plateImg);

cleanedText = cleanRecognizedText(rawText);

stateName = identifyState(cleanedText);

fprintf('Recognized Text: %s\n', cleanedText);
fprintf('Identified State: %s\n', stateName);

displayPipelineResults(originalImg, plateImg, cleanedText, stateName);
```

---

## 13. GUI Requirements

`launch_gui.m` should create a simple script-based MATLAB GUI.

Do not use App Designer in the first version.

The GUI should include:

- Load Image button
- Run Recognition button
- Original image display area
- Detected plate display area
- Recognized text field
- Identified state field
- Status message field

Recommended components:

```matlab
figure
uicontrol
axes
imshow
guidata
```

The GUI should allow this workflow:

```text
Open GUI
↓
Load Image
↓
Display Original Image
↓
Run Recognition
↓
Display Detected Plate
↓
Display Recognized Text
↓
Display Identified State
↓
Display Status Message
```

The GUI should call the same pipeline functions as `main.m`.

Do not duplicate image processing logic inside GUI callbacks.

The GUI should support fallback outputs such as:

```text
Recognized Text: UNKNOWN
Identified State: UNKNOWN
```

The GUI should not crash when `plateImg` is empty.

---

## 14. Scratch Test Script Requirements

## 14.1 test_member1_preprocessing.m

This script should test:

```text
src/preprocessing/
```

Required functions:

```text
preprocessImage.m
convertToGray.m
enhanceContrast.m
removeNoise.m
```

Input:

```text
images/test/sample_car.jpg
```

Expected output:

- Grayscale image
- Enhanced image
- Filtered image
- `preprocessDebug`

---

## 14.2 test_member2_plate_detection.m

This script should test:

```text
src/plate_detection/
```

Required functions:

```text
detectPlateRegion.m
selectPlateCandidate.m
cropPlateRegion.m
```

Input:

```text
images/test/sample_car.jpg
```

If preprocessing is not completed, this script may use temporary grayscale conversion:

```matlab
originalImg = imread('images/test/sample_car.jpg');

if size(originalImg, 3) == 3
    preprocessedImg = rgb2gray(originalImg);
else
    preprocessedImg = originalImg;
end
```

Expected output:

- Edge image or candidate debug image
- Plate bounding box or empty fallback
- Cropped plate image or empty fallback
- `detectionDebug`

---

## 14.3 test_member3_segmentation.m

This script should test:

```text
src/segmentation/
```

Required functions:

```text
binarizePlate.m
cleanBinaryImage.m
segmentCharacters.m
```

Input:

```text
images/test/plate_samples/
```

Expected output:

- Binary plate image
- Cleaned binary image
- Character candidate images
- Character bounding boxes

---

## 14.4 test_member4_recognition_gui.m

This script should test:

```text
src/recognition/
src/evaluation/
src/utils/
launch_gui.m
```

Required functions:

```text
recognizePlateText.m
cleanRecognizedText.m
identifyState.m
evaluateSingleImage.m
saveResultRow.m
displayPipelineResults.m
saveStepImage.m
ensureOutputFolders.m
```

Input:

```text
images/test/plate_samples/
```

or temporary OCR strings:

```text
BMS8147
PAB1234
MAB5678
WXY5678
```

Expected output:

- OCR text or `UNKNOWN`
- Cleaned text
- Identified state or `UNKNOWN`
- Evaluation result row if needed
- GUI launch test

---

## 15. Function Requirements

## 15.1 preprocessImage.m

Purpose:

- Run the full preprocessing flow.

Inputs:

```text
inputImg
```

Outputs:

```text
preprocessedImg
debugInfo
```

Responsibilities:

- Validate input.
- Convert to grayscale.
- Enhance contrast.
- Remove noise.
- Store intermediate results in `debugInfo`.

Internal calls:

```matlab
grayImg = convertToGray(inputImg);
enhancedImg = enhanceContrast(grayImg);
filteredImg = removeNoise(enhancedImg);
```

If input is empty:

```matlab
preprocessedImg = [];
debugInfo.errorMessage = "Input image is empty.";
```

---

## 15.2 convertToGray.m

Purpose:

- Convert RGB image to grayscale.
- Return unchanged image if already grayscale.

Suggested logic:

```matlab
if isempty(inputImg)
    grayImg = [];
    return;
end

if size(inputImg, 3) == 3
    grayImg = rgb2gray(inputImg);
else
    grayImg = inputImg;
end
```

---

## 15.3 enhanceContrast.m

Purpose:

- Improve image contrast.

Recommended first method:

```matlab
enhancedImg = imadjust(grayImg);
```

Optionally use:

```matlab
histeq
adapthisteq
```

If input is empty:

```matlab
enhancedImg = [];
```

---

## 15.4 removeNoise.m

Purpose:

- Reduce noise while preserving useful edges.

Recommended first method:

```matlab
filteredImg = medfilt2(grayImg, [3 3]);
```

If input is empty:

```matlab
filteredImg = [];
```

---

## 15.5 detectPlateRegion.m

Purpose:

- Detect and crop the most likely license plate region.

Inputs:

```text
preprocessedImg
originalImg
```

Outputs:

```text
plateImg
plateBBox
debugInfo
```

Recommended processing:

```text
Edge detection
↓
Morphological closing
↓
Fill holes
↓
Remove small objects
↓
Connected component analysis
↓
Region property filtering
↓
Select best candidate
↓
Crop plate region
```

Possible functions:

```matlab
edge
strel
imclose
imfill
bwareaopen
bwconncomp
regionprops
```

If no valid candidate is found:

```matlab
plateImg = [];
plateBBox = [];
```

The first skeleton may return a central crop as a temporary placeholder, but it must clearly mark it as placeholder logic.

---

## 15.6 selectPlateCandidate.m

Purpose:

- Select the most likely license plate bounding box from detected regions.

Inputs:

```text
regions
imageSize
```

Output:

```text
bestBBox
```

Candidate filtering may use:

- Area
- Width
- Height
- Aspect ratio
- Bounding box validity
- Rectangular shape

Suggested aspect ratio range:

```text
2.0 to 6.0
```

If no candidate is found:

```matlab
bestBBox = [];
```

---

## 15.7 cropPlateRegion.m

Purpose:

- Crop the detected plate region from the original image.

Inputs:

```text
originalImg
plateBBox
```

Output:

```text
plateImg
```

Use:

```matlab
imcrop
```

Check bounding box validity before cropping.

If invalid:

```matlab
plateImg = [];
```

---

## 15.8 binarizePlate.m

Purpose:

- Convert the cropped plate image into a binary image.

Input:

```text
plateImg
```

Output:

```text
binaryPlateImg
```

Possible functions:

```matlab
rgb2gray
graythresh
imbinarize
adaptthresh
```

If input is empty:

```matlab
binaryPlateImg = [];
```

---

## 15.9 cleanBinaryImage.m

Purpose:

- Clean binary image using morphological operations.

Input:

```text
binaryImg
```

Output:

```text
cleanedImg
```

Possible functions:

```matlab
imopen
imclose
imfill
bwareaopen
strel
```

If input is empty:

```matlab
cleanedImg = [];
```

---

## 15.10 segmentCharacters.m

Purpose:

- Segment possible character regions from the license plate image.

Inputs:

```text
plateImg
```

Outputs:

```text
characterImages
characterBBoxes
```

Recommended process:

```text
Binarize plate
↓
Clean binary image
↓
Find connected components
↓
Filter possible character regions
↓
Sort from left to right
```

Internal calls:

```matlab
binaryPlateImg = binarizePlate(plateImg);
cleanedImg = cleanBinaryImage(binaryPlateImg);
```

If no characters are found:

```matlab
characterImages = {};
characterBBoxes = [];
```

Important note:

Character segmentation is mainly used for visualization, explanation, and OCR preparation.

Final text recognition should use OCR, not template-based character matching.

---

## 15.11 recognizePlateText.m

Purpose:

- Recognize text from the detected plate image using OCR.

Input:

```text
plateImg
```

Output:

```text
rawText
```

Use OCR if available:

```matlab
ocr
```

If OCR is unavailable, fails, or returns empty text:

```matlab
rawText = "UNKNOWN";
```

Do not apply OCR directly to the full original image.

---

## 15.12 cleanRecognizedText.m

Purpose:

- Clean OCR output.

Input:

```text
rawText
```

Output:

```text
cleanedText
```

Cleaning operations:

- Convert to uppercase
- Remove spaces
- Remove line breaks
- Remove punctuation
- Keep only alphanumeric characters

If result is empty:

```matlab
cleanedText = "UNKNOWN";
```

---

## 15.13 identifyState.m

Purpose:

- Identify registered Malaysian state from plate prefix.

Input:

```text
cleanedText
```

Output:

```text
stateName
```

Implement at least this mapping:

| Prefix | State |
|---|---|
| A | Perak |
| B | Selangor |
| J | Johor |
| K | Kedah |
| M | Malacca |
| N | Negeri Sembilan |
| P | Penang |
| T | Terengganu |
| W | Kuala Lumpur |

If prefix is unknown:

```matlab
stateName = "UNKNOWN";
```

---

## 15.14 evaluateSingleImage.m

Purpose:

- Run the full pipeline on one image and return an evaluation result.

Inputs:

```text
imagePath
expectedText
expectedState
vehicleType
```

Output:

```text
resultRow
```

The result should include:

- Image name
- Vehicle type
- Expected text
- OCR text
- Expected state
- Predicted state
- Detection result
- OCR result
- State result
- Overall result
- Notes

Required output fields:

```text
image_name
vehicle_type
expected_text
ocr_text
expected_state
predicted_state
detection_result
ocr_result
state_result
overall_result
notes
```

---

## 15.15 saveResultRow.m

Purpose:

- Save or append one evaluation row to a CSV file.

Inputs:

```text
resultRow
csvPath
```

Use:

```matlab
writetable
readtable
```

Expected CSV header:

```csv
image_name,vehicle_type,expected_text,ocr_text,expected_state,predicted_state,detection_result,ocr_result,state_result,overall_result,notes
```

---

## 15.16 displayPipelineResults.m

Purpose:

- Display final pipeline results.

Inputs:

```text
originalImg
plateImg
recognizedText
stateName
```

Display:

- Original image
- Detected plate image
- Recognized text
- Identified state

Handle empty plate image gracefully.

---

## 15.17 saveStepImage.m

Purpose:

- Save intermediate or final images.

Inputs:

```text
img
outputFolder
fileName
```

Use:

```matlab
imwrite
```

Create the output folder if needed.

Do nothing if the image is empty.

---

## 15.18 ensureOutputFolders.m

Purpose:

- Create required output folders.

Create:

```text
output/plate_detection/
output/segmentation/
output/recognition/
output/figures/
report/figures/
report/tables/
```

Use:

```matlab
exist
mkdir
```

---

## 16. State Identification Mapping

Implement at least the following mapping:

```text
A -> Perak
B -> Selangor
J -> Johor
K -> Kedah
M -> Malacca
N -> Negeri Sembilan
P -> Penang
T -> Terengganu
W -> Kuala Lumpur
```

If the first character is not found in the mapping, return:

```text
UNKNOWN
```

---

## 17. Error Handling Requirements

Use safe fallback behavior.

## 17.1 Missing Image

If the image does not exist:

```text
Show clear error message.
Stop processing safely.
```

## 17.2 Empty Plate Image

If plate detection fails:

```matlab
plateImg = [];
rawText = "UNKNOWN";
cleanedText = "UNKNOWN";
stateName = "UNKNOWN";
```

## 17.3 Segmentation Failure

If segmentation fails:

```matlab
characterImages = {};
characterBBoxes = [];
```

## 17.4 OCR Failure

If OCR fails:

```matlab
rawText = "UNKNOWN";
cleanedText = "UNKNOWN";
stateName = "UNKNOWN";
```

## 17.5 Unknown Prefix

If prefix is not recognized:

```matlab
stateName = "UNKNOWN";
```

## 17.6 Missing Plate Sample

If no plate sample exists:

```text
Show clear message.
Skip plate-sample-based test safely.
```

---

## 18. CSV File Requirements

## 18.1 results_template.csv

Create this file with the following header:

```csv
image_name,vehicle_type,expected_text,ocr_text,expected_state,predicted_state,detection_result,ocr_result,state_result,overall_result,notes
```

---

## 18.2 dataset_metadata.csv

Create this file with the following header:

```csv
image_name,image_path,vehicle_type,expected_plate_text,expected_state,plate_type,distance,lighting,background,angle,source,notes
```

---

## 19. .gitignore Requirements

Create `.gitignore` with:

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

---

## 20. README.md Requirements

Create `README.md` with:

- Project title
- Project overview
- Development environment
- Folder structure
- How to run `main.m`
- How to run `launch_gui.m`
- How to run scratch test scripts
- Required image location
- Required plate sample location
- Notes about prohibited methods
- Troubleshooting section

---

## 21. CONTRIBUTING.md Requirements

Create `CONTRIBUTING.md` with:

- Branch strategy
- Feature-based folder responsibility
- How to create feature branches
- How to commit and push changes
- How to merge into `dev`
- Rule that branch names are not folder names
- Rule that source folders are divided by system function, not by member name
- Rule that function signatures should not be changed without discussion
- Files that should not be committed

---

## 22. Development Document Requirements

Create the following files:

```text
docs/development/00_parallel_development_plan.md
docs/development/01_member_task_allocation.md
docs/development/02_git_workflow.md
docs/development/03_integration_plan.md
```

These files should explain:

- How to develop modules in parallel
- Which member owns each functional folder
- How to use Git branches
- How to integrate modules into `dev`
- How to test the full pipeline after integration

---

## 23. Member Task Document Requirements

Create the following files:

```text
docs/member_tasks/member1_preprocessing.md
docs/member_tasks/member2_plate_detection.md
docs/member_tasks/member3_segmentation_morphology.md
docs/member_tasks/member4_recognition_gui_eval.md
```

Each member task file should include:

- Assigned folders
- Assigned files
- Related system requirements
- Main responsibilities
- Input and output format
- Required function signatures
- Independent scratch test script
- Expected result
- Report contribution hints

---

## 24. Output Format for Claude or Codex

When generating code, output each file separately.

Use this format:

```text
File: main.m
```

Then provide the complete code.

Example:

```text
File: src/preprocessing/preprocessImage.m
```

Then provide the complete code.

Do not skip files.

Do not provide partial code unless explicitly asked.

For documentation files, use the same format:

```text
File: docs/development/00_parallel_development_plan.md
```

Then provide the complete Markdown content.

---

## 25. Implementation Priority

Follow this priority order:

1. Correct folder structure
2. Runnable `main.m`
3. Runnable `launch_gui.m`
4. Scratch test scripts for each member
5. Function name and file name consistency
6. Stable function signatures
7. Safe fallback behavior
8. Clear comments
9. Simple placeholder logic where needed
10. Basic image processing pipeline
11. OCR support with fallback
12. Evaluation CSV support
13. Member task documents
14. Git workflow documentation

---

## 26. First Prompt Recommendation

When starting implementation, use this instruction:

```text
Using the requirement documents in docs/requirements, docs/development, and docs/member_tasks, create the full MATLAB project skeleton for the License Plate Recognition and State Identification System.

Follow the file structure exactly.

Generate all required .m files, README.md, CONTRIBUTING.md, .gitignore, results_template.csv, dataset_metadata.csv, scratch test scripts, development documents, and member task documents.

The first version must be runnable from main.m and launch_gui.m, even if some logic is placeholder-based.

The first version must also allow each member to run their own scratch test script independently.

Do not use TensorFlow, Haar Cascade, YOLO, deep learning detectors, template matching, or pattern matching.

Use English comments and clear MATLAB function headers.

Keep the core function signatures stable.

Return UNKNOWN or empty outputs when processing fails.

Do not create folders based on Git branch names.
```

---

## 27. Final Notes

Claude or Codex should not change the project scope unless requested.

The generated code should support future implementation of the full LPR and SIS system.

The first version should prioritize correctness, clarity, maintainability, and parallel development over advanced accuracy.

The final project should remain consistent with the assignment requirements and the MATLAB image processing topics covered in class.

Important final reminders:

- Use MATLAB `.m` files.
- Do not use Docker.
- Do not use prohibited methods.
- Use OCR only after plate detection and preprocessing.
- Use character segmentation only for visualization, explanation, and OCR preparation.
- Keep source folders organized by system function, not member name.
- Keep branch names separate from folder names.
- Generate scratch test scripts.
- Support `images/test/sample_car.jpg`.
- Support `images/test/plate_samples/`.
- Include `overall_result` in evaluation outputs.
- Keep comments and variable names in English.
