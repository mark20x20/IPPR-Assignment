# Technical Constraints

## 1. Purpose

This document defines the technical constraints, implementation rules, prohibited methods, allowed methods, development conventions, team collaboration rules, and parallel development constraints for the License Plate Recognition (LPR) and State Identification System (SIS).

The purpose of this document is to ensure that the project is implemented consistently, follows the assignment requirements, and allows all group members to work in parallel without breaking the full system pipeline.

---

## 2. Development Environment

## 2.1 Programming Language

The project should be implemented mainly in:

```text
MATLAB
```

The source code should consist mainly of:

```text
.m script files
.m function files
```

---

## 2.2 MATLAB Version

The development environment is:

```text
MATLAB R2026a
```

---

## 2.3 Operating System

The main development environment is:

```text
Windows
```

The current project root folder is:

```text
C:\APU\IPPR\Assignment
```

---

## 2.4 Docker

Docker is not required for this project.

Reasons:

- MATLAB is already installed locally.
- The project requires GUI operation.
- The project may require MATLAB license authentication.
- MATLAB image display and GUI testing are easier in the local desktop environment.
- The final submission is expected as source code, test images, report, and demonstration, not a Docker container.

---

## 2.5 GitHub

GitHub may be used for:

- Source code sharing
- Version control
- Team collaboration
- Backup
- Tracking changes

GitHub should not be treated as the final submission platform.

Final submission should still be prepared as a ZIP file for Moodle or the required submission platform.

---

## 2.6 Team Development Model

The project will use feature-based folder responsibility.

Each member should mainly edit their assigned functional folder or files.

| Member | Main Responsibility | Assigned Folder or Files |
|---|---|---|
| Member 1 | Dataset and Preprocessing | `src/preprocessing/`, `images/`, `dataset_metadata.csv` |
| Member 2 | License Plate Detection | `src/plate_detection/` |
| Member 3 | Segmentation and Morphology | `src/segmentation/` |
| Member 4 | Recognition, GUI, and Evaluation | `src/recognition/`, `src/evaluation/`, `src/utils/`, `launch_gui.m` |

This folder responsibility does not mean that the project should create member-specific source folders.  
The project should remain organized by system function, not by member name.

---

## 2.7 Parallel Development Requirement

The system follows a sequential image processing pipeline:

```text
Preprocessing
↓
Plate Detection
↓
Segmentation and Morphology
↓
OCR, State Identification, GUI, and Evaluation
```

However, group members should not wait for earlier modules to be fully completed before starting their own work.

To support parallel development, the project should include:

- Shared skeleton files
- Fixed function signatures
- Placeholder return values
- Safe fallback outputs
- Sample vehicle image
- Manually cropped plate sample images
- Individual scratch test scripts

Required support folders:

```text
scratch/
images/test/plate_samples/
```

Required scratch test scripts:

```text
scratch/test_member1_preprocessing.m
scratch/test_member2_plate_detection.m
scratch/test_member3_segmentation.m
scratch/test_member4_recognition_gui.m
```

---

## 3. MATLAB Coding Rules

## 3.1 File Format

Use MATLAB `.m` files.

The project may include:

- Script files
- Function files
- Simple GUI script files

Avoid using App Designer `.mlapp` files in the first version unless the team later decides to migrate to App Designer.

---

## 3.2 Function File Rule

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

## 3.3 MATLAB Path Rule

The main script and GUI launcher should add all source folders to the MATLAB path.

Use:

```matlab
addpath(genpath('src'));
```

This should be included in:

```text
main.m
launch_gui.m
```

Individual scratch test scripts should also include:

```matlab
addpath(genpath('src'));
```

---

## 3.4 No Python-Style Imports

Do not use Python-style import logic.

MATLAB should not be written like:

```python
from preprocessing import preprocessImage
```

Instead, use MATLAB path management:

```matlab
addpath(genpath('src'));
```

Then call functions directly:

```matlab
[preprocessedImg, debugInfo] = preprocessImage(originalImg);
```

---

## 3.5 Naming Convention

Use clear English names for:

- Functions
- Variables
- Files
- Folders
- Comments
- Documentation

Examples:

```matlab
originalImg
preprocessedImg
plateImg
recognizedText
cleanedText
stateName
plateBBox
debugInfo
```

Avoid unclear names such as:

```matlab
a
b
x1
temp2
finalfinal
```

unless they are used only in very small local contexts.

---

## 3.6 Comment Style

All code comments should be written in English.

Each function should include a header comment explaining:

- Purpose
- Input
- Output
- Main processing steps

Example:

```matlab
function grayImg = convertToGray(inputImg)
% convertToGray converts an RGB image to grayscale.
%
% Input:
%   inputImg - RGB or grayscale image
%
% Output:
%   grayImg - Grayscale image
```

---

## 3.7 Code Readability

The code should be simple and readable.

Prioritize:

- Clear logic
- Small functions
- Meaningful variable names
- Basic MATLAB syntax
- Easy debugging
- Easy explanation in the report and presentation

Avoid overly complex one-line expressions if they make the code difficult to understand.

---

## 3.8 Function Interface Stability

Function signatures should remain stable after the skeleton is created.

This allows all members to work independently without breaking the full pipeline.

Core function signatures include:

```matlab
[preprocessedImg, preprocessDebug] = preprocessImage(originalImg);
[plateImg, plateBBox, detectionDebug] = detectPlateRegion(preprocessedImg, originalImg);
[characterImages, characterBBoxes] = segmentCharacters(plateImg);
rawText = recognizePlateText(plateImg);
cleanedText = cleanRecognizedText(rawText);
stateName = identifyState(cleanedText);
```

If a function signature must be changed, the change should be discussed with all members before implementation.

---

## 3.9 Placeholder and Fallback Rule

During early development, incomplete modules should return safe placeholder or fallback values instead of causing errors.

Examples:

```matlab
plateImg = [];
plateBBox = [];
rawText = "UNKNOWN";
cleanedText = "UNKNOWN";
stateName = "UNKNOWN";
```

The first runnable version should prioritize:

- Running without syntax errors
- Keeping the pipeline connected
- Returning safe fallback values
- Allowing each member to test their module independently

Perfect accuracy is not required for the first skeleton version.

---

## 4. Prohibited Methods

The following methods must not be used in this project.

## 4.1 Haar Cascade

Do not use Haar Cascade for license plate detection.

This includes:

- Pretrained Haar Cascade models
- Cascade object detectors
- Haar-based object detection workflows

---

## 4.2 TensorFlow

Do not use TensorFlow.

This includes:

- TensorFlow models
- TensorFlow object detection
- TensorFlow-based OCR or detection pipelines

---

## 4.3 YOLO and Deep Learning Object Detectors

Do not use YOLO or other deep learning object detectors.

Avoid:

- YOLOv3
- YOLOv4
- YOLOv5
- YOLOv6
- YOLOv7
- YOLOv8
- Faster R-CNN
- SSD
- Deep learning-based plate detectors
- Any pretrained object detection model

---

## 4.4 Pattern Matching and Template Matching

Do not use pattern matching methods.

Avoid:

- Template matching
- Direct comparison with stored plate templates
- Character recognition by comparing against fixed template images
- Plate detection based on matching a predefined plate pattern image
- Any recognition method that depends on fixed character templates

Important note:

Character segmentation may be used for visualization, explanation, and OCR preparation.  
Final text recognition should use OCR, not template-based character matching.

---

## 4.5 Direct Full-Image OCR Only

Do not build the system by applying OCR directly to the full original image as the only processing step.

The system should demonstrate image processing steps before OCR.

The required flow should be:

```text
Original image
↓
Preprocessing
↓
Plate detection
↓
Plate cropping
↓
Plate image cleanup
↓
OCR
↓
Text cleaning
↓
State identification
```

---

## 5. Allowed Methods

The project may use classical image processing and computer vision techniques.

## 5.1 Image Reading and Display

Allowed functions include:

```matlab
imread
imshow
imwrite
figure
subplot
title
```

---

## 5.2 Image Conversion

Allowed functions include:

```matlab
rgb2gray
im2gray
im2double
im2uint8
```

---

## 5.3 Image Resizing

Allowed functions include:

```matlab
imresize
```

---

## 5.4 Contrast Enhancement

Allowed functions include:

```matlab
imadjust
histeq
adapthisteq
```

---

## 5.5 Noise Reduction and Spatial Filtering

Allowed functions include:

```matlab
medfilt2
imfilter
fspecial
conv2
```

Possible filters:

- Median filter
- Average filter
- Gaussian filter

---

## 5.6 Edge Detection

Allowed functions include:

```matlab
edge
```

Possible methods:

- Sobel
- Canny
- Prewitt
- Roberts

---

## 5.7 Thresholding and Binarization

Allowed functions include:

```matlab
graythresh
imbinarize
adaptthresh
```

---

## 5.8 Morphological Operations

Allowed functions include:

```matlab
strel
imdilate
imerode
imopen
imclose
imfill
bwareaopen
```

These may be used for:

- Removing small noise
- Connecting broken plate edges
- Filling holes
- Cleaning segmented regions
- Improving character visibility

---

## 5.9 Connected Component Analysis

Allowed functions include:

```matlab
bwconncomp
bwlabel
regionprops
```

These may be used for:

- Finding candidate plate regions
- Extracting bounding boxes
- Measuring area
- Calculating aspect ratio
- Filtering invalid regions
- Extracting possible character regions

---

## 5.10 OCR

OCR is allowed.

Possible function:

```matlab
ocr
```

OCR should be applied to the processed license plate image, not directly to the full original vehicle image.

If OCR is unavailable or fails, the function should return:

```text
UNKNOWN
```

---

## 5.11 Rule-Based State Identification

Rule-based state identification is allowed.

The system may identify the state based on the first character or prefix of the recognized plate text.

Example:

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

If the prefix is not recognized, return:

```text
UNKNOWN
```

---

## 6. OCR Constraint

OCR may be used, but it should be used as part of the full image processing pipeline.

## 6.1 Correct OCR Usage

Recommended flow:

```text
Crop detected plate image
↓
Convert to grayscale
↓
Enhance contrast
↓
Binarize image
↓
Clean binary image
↓
Run OCR
↓
Clean OCR text
↓
Identify state
```

---

## 6.2 OCR Failure Handling

If OCR fails, the system should not crash.

Instead, return:

```text
UNKNOWN
```

Possible reasons for OCR failure:

- OCR toolbox is unavailable
- Plate image is too blurry
- Plate is too small
- Characters are not clear
- Image is overexposed or underexposed
- Plate detection failed
- Plate crop is empty
- Plate sample image is missing

---

## 7. GUI Constraint

## 7.1 GUI Requirement

A GUI is required for the project.

The GUI should display:

- Original image
- Detected plate image
- Recognized text
- Identified state
- Status message

---

## 7.2 GUI Implementation

The first version should use script-based MATLAB GUI components such as:

```matlab
figure
uicontrol
axes
imshow
guidata
```

The GUI should be launched from:

```text
launch_gui.m
```

---

## 7.3 App Designer

App Designer is not required for the first version.

The team may migrate to App Designer later if needed, but the first version should remain simple and easy to share.

---

## 7.4 GUI Placeholder Requirement

The GUI should run even if some processing modules are incomplete.

If plate detection is incomplete or fails:

```text
Detected Plate: empty image or placeholder
Recognized Text: UNKNOWN
Identified State: UNKNOWN
```

If OCR is incomplete or fails:

```text
Recognized Text: UNKNOWN
Identified State: UNKNOWN
```

This allows GUI development to proceed in parallel with image processing module development.

---

## 8. File Path Constraints

## 8.1 Use Relative Paths

Use relative paths whenever possible.

Recommended:

```matlab
imagePath = fullfile('images', 'test', 'sample_car.jpg');
```

Avoid hardcoding personal absolute paths inside reusable functions.

Not recommended:

```matlab
imagePath = 'C:\Users\Masaki\Desktop\sample_car.jpg';
```

---

## 8.2 Project Root

The expected project root is:

```text
C:\APU\IPPR\Assignment
```

However, code should still work if the project folder is moved, as long as the folder structure is preserved.

---

## 8.3 Output Folders

The system should automatically create output folders if they do not exist.

Required output folders:

```text
output/plate_detection/
output/segmentation/
output/recognition/
output/figures/
```

Additional report output folders:

```text
report/figures/
report/tables/
```

---

## 8.4 Development Sample Data Folders

The system should support the following development sample folders:

```text
images/test/sample_car.jpg
images/test/plate_samples/
```

`sample_car.jpg` is used for the first full-pipeline test.

`images/test/plate_samples/` is used for manually cropped plate samples so that Member 3 and Member 4 can test segmentation, OCR, state identification, and GUI output before plate detection is fully completed.

---

## 8.5 Scratch Test Folder

The project should include a scratch folder for module-level test scripts:

```text
scratch/
```

Required scratch scripts:

```text
scratch/test_member1_preprocessing.m
scratch/test_member2_plate_detection.m
scratch/test_member3_segmentation.m
scratch/test_member4_recognition_gui.m
```

These scripts are for development and module-level testing.

They are not the main final system entry point.

---

## 9. Error Handling Constraints

The system should handle common errors gracefully.

## 9.1 Missing Image

If the input image does not exist, show a clear message.

Example:

```text
Image file not found. Please place a test image in images/test/.
```

---

## 9.2 Invalid Image

If the selected file is not a valid image, show a clear error message.

---

## 9.3 Plate Detection Failure

If the plate region cannot be detected, return:

```text
UNKNOWN
```

or use a safe placeholder output for debugging.

The system should not crash.

Recommended fallback:

```matlab
plateImg = [];
plateBBox = [];
```

---

## 9.4 Invalid Bounding Box

If the bounding box is invalid, the system should avoid calling `imcrop` with invalid coordinates.

Recommended fallback:

```matlab
plateImg = [];
```

---

## 9.5 OCR Unavailable

If OCR is unavailable, return:

```text
UNKNOWN
```

The system should continue running.

---

## 9.6 Unknown State Prefix

If the recognized plate prefix is not found in the state mapping, return:

```text
UNKNOWN
```

---

## 9.7 Missing Plate Sample Images

If manually cropped plate sample images are missing, the related scratch test script should show a clear message.

Example:

```text
No plate sample images found in images/test/plate_samples/.
```

The script should not crash.

---

## 9.8 Incomplete Module Implementation

If a module is not fully implemented yet, it should return safe fallback outputs.

Examples:

```matlab
plateImg = [];
plateBBox = [];
rawText = "UNKNOWN";
cleanedText = "UNKNOWN";
stateName = "UNKNOWN";
```

---

## 10. Git and Collaboration Constraints

## 10.1 Git Usage

Git is used only for:

- Sharing code
- Version control
- Collaboration
- Backup

---

## 10.2 GitHub Repository

The GitHub repository may include:

- MATLAB source code
- Requirements documents
- README
- Small test images
- Result templates
- Scratch test scripts
- Member task documents

---

## 10.3 Files to Avoid Committing

Avoid committing:

- Large raw datasets
- Large output image folders
- Video recordings
- ZIP files
- Temporary MATLAB files
- Personal environment files

---

## 10.4 Recommended `.gitignore`

Recommended `.gitignore` contents:

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

If the team wants to share small selected test images, place them in:

```text
images/test/
images/test/plate_samples/
images/selected_for_report/
```

and keep the number of files small.

---

## 10.5 Recommended Git Branches

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
| `feature/preprocessing` | Member 1 development |
| `feature/plate-detection` | Member 2 development |
| `feature/segmentation-morphology` | Member 3 development |
| `feature/recognition-gui-evaluation` | Member 4 development |

---

## 10.6 Branch and Folder Separation

Branch names are not folder names.

Do not create folders such as:

```text
feature/preprocessing/
feature/plate-detection/
feature/segmentation-morphology/
feature/recognition-gui-evaluation/
```

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

## 10.7 Merge Flow

Recommended merge flow:

```text
feature branch
↓
dev
↓
main
```

Team members should not push directly to `main`.

Each member should work mainly on their assigned folder and merge changes into `dev` for integration testing.

---

## 11. Submission Constraints

The final submission should not rely only on GitHub.

The final submission should include a ZIP file containing:

- MATLAB source code
- GUI file
- Test images
- Dataset or selected sample images
- Output screenshots if required
- Project report
- Workload matrix if required
- Individual demonstration material if required

---

## 12. Minimum Technical Goal

The first version should be a runnable skeleton.

It must:

1. Load a sample image.
2. Add source folders to MATLAB path.
3. Run the full pipeline.
4. Display the original image.
5. Display detected or placeholder plate image.
6. Return recognized text or `UNKNOWN`.
7. Return identified state or `UNKNOWN`.
8. Avoid crashing when OCR or detection fails.
9. Provide stable function signatures for all modules.
10. Include placeholder or fallback outputs where necessary.
11. Include scratch test scripts for all members.
12. Support manually cropped plate sample images for Member 3 and Member 4.
13. Allow `launch_gui.m` to open even if some processing modules are incomplete.

---

## 13. Final Technical Goal

The final version should:

1. Detect likely license plate regions using classical image processing.
2. Prepare the plate image for OCR.
3. Recognize plate text using OCR.
4. Identify the registered state using prefix rules.
5. Display results in a GUI.
6. Save important output images.
7. Record test results.
8. Support both successful and failed case analysis.
9. Allow each member to demonstrate their assigned contribution.
10. Support module-level testing and full-pipeline testing.
11. Provide enough outputs for report screenshots and individual presentation.

---

## 14. Member-Based Technical Responsibility

## 14.1 Member 1: Dataset and Preprocessing

Assigned folders and files:

```text
src/preprocessing/
images/
dataset_metadata.csv
scratch/test_member1_preprocessing.m
```

Main technical responsibilities:

- Organize sample images
- Prepare dataset metadata
- Convert RGB image to grayscale
- Enhance contrast
- Remove noise
- Return preprocessing debug outputs

Main function signatures:

```matlab
[preprocessedImg, preprocessDebug] = preprocessImage(originalImg);
grayImg = convertToGray(originalImg);
enhancedImg = enhanceContrast(grayImg);
filteredImg = removeNoise(enhancedImg);
```

---

## 14.2 Member 2: License Plate Detection

Assigned folders and files:

```text
src/plate_detection/
scratch/test_member2_plate_detection.m
```

Main technical responsibilities:

- Detect plate candidate regions
- Use edge detection
- Use morphological closing
- Use connected component analysis
- Use region property filtering
- Select best bounding box
- Crop plate region

Main function signatures:

```matlab
[plateImg, plateBBox, detectionDebug] = detectPlateRegion(preprocessedImg, originalImg);
bestBBox = selectPlateCandidate(regions, imageSize);
plateImg = cropPlateRegion(originalImg, plateBBox);
```

If Member 1's preprocessing module is not completed, Member 2 may use temporary grayscale conversion in the scratch test script.

---

## 14.3 Member 3: Segmentation and Morphology

Assigned folders and files:

```text
src/segmentation/
images/test/plate_samples/
scratch/test_member3_segmentation.m
```

Main technical responsibilities:

- Binarize cropped plate image
- Clean binary plate image
- Apply morphological operations
- Segment character candidates
- Produce segmentation outputs for report

Main function signatures:

```matlab
binaryPlateImg = binarizePlate(plateImg);
cleanedImg = cleanBinaryImage(binaryPlateImg);
[characterImages, characterBBoxes] = segmentCharacters(plateImg);
```

Important constraint:

Character segmentation is mainly used for visualization, explanation, and OCR preparation.  
Final text recognition should use OCR, not template-based character matching.

---

## 14.4 Member 4: Recognition, GUI, and Evaluation

Assigned folders and files:

```text
src/recognition/
src/evaluation/
src/utils/
launch_gui.m
scratch/test_member4_recognition_gui.m
```

Main technical responsibilities:

- Run OCR on processed plate image
- Clean OCR text
- Identify state from plate prefix
- Build GUI
- Display results
- Save result images
- Record evaluation results

Main function signatures:

```matlab
rawText = recognizePlateText(plateImg);
cleanedText = cleanRecognizedText(rawText);
stateName = identifyState(cleanedText);
displayPipelineResults(originalImg, plateImg, cleanedText, stateName);
saveStepImage(img, outputFolder, fileName);
ensureOutputFolders();
```

Member 4 may use manually cropped plate images or temporary OCR strings during early development.

Example temporary OCR strings:

```text
BMS8147
PAB1234
MAB5678
```

---

## 15. Notes for Claude or Codex

When generating or editing code based on this document:

- Use MATLAB `.m` files.
- Do not use Docker.
- Do not use TensorFlow, Haar Cascade, YOLO, deep learning detectors, template matching, or pattern matching.
- Use English comments and variable names.
- Use the same folder structure in all branches.
- Do not create folders based on Git branch names.
- Keep function names matched with file names.
- Keep core function signatures stable.
- Return `UNKNOWN` or empty outputs when a module fails.
- Generate scratch test scripts for independent module testing.
- Support `images/test/sample_car.jpg` for full-pipeline testing.
- Support `images/test/plate_samples/` for segmentation, OCR, and GUI development.
- The first version should be a runnable skeleton before improving accuracy.
