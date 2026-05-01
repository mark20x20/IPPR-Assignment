# Member Task Allocation

## 1. Purpose

This document defines the task allocation for the License Plate Recognition (LPR) and State Identification System (SIS).

The purpose of this document is to clearly explain:

- Which member is responsible for each system module
- Which folders and files each member should mainly edit
- What each member should implement
- What each member should test
- What each member should prepare for the report
- How the members should collaborate without blocking each other

The project uses a feature-based folder responsibility model.

This means the source code is divided by system function, not by member name.

---

## 2. Overall Member Allocation

| Member | Main Responsibility | Assigned Folder or Files |
|---|---|---|
| Member 1 | Dataset and Preprocessing | `src/preprocessing/`, `images/`, `dataset_metadata.csv` |
| Member 2 | License Plate Detection | `src/plate_detection/` |
| Member 3 | Segmentation and Morphology | `src/segmentation/`, `images/test/plate_samples/` |
| Member 4 | Recognition, GUI, and Evaluation | `src/recognition/`, `src/evaluation/`, `src/utils/`, `launch_gui.m` |

---

## 3. Development Model

The final system follows this sequential pipeline:

```text
Image Acquisition
↓
Preprocessing
↓
License Plate Detection
↓
Plate Cropping
↓
Segmentation and Morphology
↓
OCR
↓
Text Cleaning
↓
State Identification
↓
GUI Output
↓
Evaluation
```

However, members should develop modules in parallel.

To make parallel development possible, the project uses:

- Shared skeleton files
- Fixed function signatures
- Placeholder outputs
- Safe fallback values
- Sample vehicle image
- Manually cropped plate sample images
- Scratch test scripts

---

## 4. Important Collaboration Rules

All members should follow these rules:

1. Work mainly inside the assigned functional folder.
2. Do not rename function files without discussion.
3. Do not change agreed function signatures without discussion.
4. Use English comments and variable names.
5. Return safe fallback outputs when a function fails.
6. Do not use prohibited methods.
7. Run the assigned scratch test script before merging.
8. Keep the project folder structure unchanged.
9. Do not create source folders based on member names.
10. Do not create folders based on Git branch names.

---

## 5. Prohibited Methods Reminder

The following methods must not be used:

```text
TensorFlow
Haar Cascade
YOLO
Deep learning object detectors
Template matching
Pattern matching methods
```

Character segmentation may be used for visualization, explanation, and OCR preparation.

Final text recognition should use OCR, not template-based character matching.

---

# 6. Member 1: Dataset and Preprocessing

## 6.1 Main Responsibility

Member 1 is responsible for preparing the image input and preprocessing stage.

This module prepares the vehicle image before license plate detection.

---

## 6.2 Assigned Folders and Files

Assigned folders:

```text
src/preprocessing/
images/
```

Assigned files:

```text
src/preprocessing/preprocessImage.m
src/preprocessing/convertToGray.m
src/preprocessing/enhanceContrast.m
src/preprocessing/removeNoise.m
dataset_metadata.csv
scratch/test_member1_preprocessing.m
```

---

## 6.3 Related System Requirements

Member 1 is mainly related to:

```text
FR-01: Load Vehicle Image
FR-02: Display Original Image
FR-03: Preprocess Image
FR-12: Save Output Images
FR-15: Support Parallel Development
FR-17: Support Independent Module Testing
```

---

## 6.4 Main Implementation Tasks

Member 1 should implement or prepare:

- Image loading support for sample images
- Dataset organization
- Dataset metadata recording
- RGB to grayscale conversion
- Contrast enhancement
- Noise reduction
- Preprocessing debug output
- Preprocessing test script

---

## 6.5 Main Functions

Member 1 should implement the following functions:

```text
preprocessImage.m
convertToGray.m
enhanceContrast.m
removeNoise.m
```

---

## 6.6 Required Function Signatures

```matlab
function [preprocessedImg, debugInfo] = preprocessImage(inputImg)
```

```matlab
function grayImg = convertToGray(inputImg)
```

```matlab
function enhancedImg = enhanceContrast(grayImg)
```

```matlab
function filteredImg = removeNoise(grayImg)
```

---

## 6.7 Input

Member 1 mainly uses:

```text
images/test/sample_car.jpg
images/test/success_cases/
images/test/difficult_cases/
images/raw/
```

Main input variable:

```text
originalImg
```

---

## 6.8 Output

Member 1 should produce:

```text
preprocessedImg
preprocessDebug
```

Recommended debug fields:

```matlab
preprocessDebug.grayImg
preprocessDebug.enhancedImg
preprocessDebug.filteredImg
```

---

## 6.9 Independent Test Script

Member 1 should use:

```text
scratch/test_member1_preprocessing.m
```

This script should test:

- `preprocessImage.m`
- `convertToGray.m`
- `enhanceContrast.m`
- `removeNoise.m`

---

## 6.10 Expected Test Result

Member 1 should confirm that:

```text
[ ] sample_car.jpg can be loaded
[ ] grayscale image is generated
[ ] contrast-enhanced image is generated
[ ] noise-reduced image is generated
[ ] debugInfo is returned
[ ] no syntax error occurs
```

---

## 6.11 Report Contribution

Member 1 should contribute to report sections about:

- Dataset collection
- Image acquisition
- Preprocessing
- Grayscale conversion
- Contrast enhancement
- Noise reduction
- Image condition analysis
- Preprocessing success and failure examples

Recommended report figures:

- Original image
- Grayscale image
- Enhanced image
- Filtered image

---

# 7. Member 2: License Plate Detection

## 7.1 Main Responsibility

Member 2 is responsible for detecting and cropping the license plate region from the vehicle image.

This is the main region-of-interest extraction stage.

---

## 7.2 Assigned Folders and Files

Assigned folder:

```text
src/plate_detection/
```

Assigned files:

```text
src/plate_detection/detectPlateRegion.m
src/plate_detection/selectPlateCandidate.m
src/plate_detection/cropPlateRegion.m
scratch/test_member2_plate_detection.m
```

---

## 7.3 Related System Requirements

Member 2 is mainly related to:

```text
FR-04: Detect License Plate Region
FR-05: Crop License Plate Region
FR-12: Save Output Images
FR-15: Support Parallel Development
FR-17: Support Independent Module Testing
```

---

## 7.4 Main Implementation Tasks

Member 2 should implement:

- Edge detection for plate candidate extraction
- Morphological closing or related operations
- Connected component analysis
- Region property extraction
- Plate candidate filtering
- Best bounding box selection
- Plate cropping
- Detection debug output

---

## 7.5 Main Functions

Member 2 should implement the following functions:

```text
detectPlateRegion.m
selectPlateCandidate.m
cropPlateRegion.m
```

---

## 7.6 Required Function Signatures

```matlab
function [plateImg, plateBBox, debugInfo] = detectPlateRegion(preprocessedImg, originalImg)
```

```matlab
function bestBBox = selectPlateCandidate(regions, imageSize)
```

```matlab
function plateImg = cropPlateRegion(originalImg, plateBBox)
```

---

## 7.7 Input

In the final pipeline, Member 2 receives:

```text
preprocessedImg
originalImg
```

If Member 1's preprocessing is not complete, Member 2 may use temporary grayscale conversion inside the scratch test script.

Example:

```matlab
originalImg = imread('images/test/sample_car.jpg');

if size(originalImg, 3) == 3
    preprocessedImg = rgb2gray(originalImg);
else
    preprocessedImg = originalImg;
end
```

---

## 7.8 Output

Member 2 should produce:

```text
plateImg
plateBBox
detectionDebug
```

Recommended debug fields:

```matlab
detectionDebug.edgeImg
detectionDebug.closedImg
detectionDebug.filledImg
detectionDebug.cleanedImg
detectionDebug.regions
```

---

## 7.9 Independent Test Script

Member 2 should use:

```text
scratch/test_member2_plate_detection.m
```

This script should test:

- `detectPlateRegion.m`
- `selectPlateCandidate.m`
- `cropPlateRegion.m`

---

## 7.10 Expected Test Result

Member 2 should confirm that:

```text
[ ] sample_car.jpg can be loaded
[ ] temporary grayscale input works if needed
[ ] edge or candidate image is generated
[ ] plateBBox is returned or safely empty
[ ] plateImg is returned or safely empty
[ ] detectionDebug is returned
[ ] no syntax error occurs
```

---

## 7.11 Report Contribution

Member 2 should contribute to report sections about:

- License plate detection
- Edge detection
- Candidate region extraction
- Region property filtering
- Aspect ratio filtering
- Plate cropping
- Plate detection failure analysis

Recommended report figures:

- Preprocessed image
- Edge image
- Candidate region image
- Bounding box result
- Cropped plate image

---

# 8. Member 3: Segmentation and Morphology

## 8.1 Main Responsibility

Member 3 is responsible for plate image preparation, binarization, morphological processing, and character candidate segmentation.

This module supports OCR preparation, visualization, and report explanation.

---

## 8.2 Assigned Folders and Files

Assigned folders:

```text
src/segmentation/
images/test/plate_samples/
```

Assigned files:

```text
src/segmentation/binarizePlate.m
src/segmentation/cleanBinaryImage.m
src/segmentation/segmentCharacters.m
scratch/test_member3_segmentation.m
```

---

## 8.3 Related System Requirements

Member 3 is mainly related to:

```text
FR-06: Prepare Plate Image for OCR
FR-07: Segment Character Regions
FR-12: Save Output Images
FR-15: Support Parallel Development
FR-17: Support Independent Module Testing
```

---

## 8.4 Main Implementation Tasks

Member 3 should implement:

- Plate image grayscale conversion if needed
- Plate binarization
- Binary image cleaning
- Morphological opening or closing
- Noise removal
- Character candidate extraction
- Character bounding box sorting
- Segmentation visualization

---

## 8.5 Main Functions

Member 3 should implement the following functions:

```text
binarizePlate.m
cleanBinaryImage.m
segmentCharacters.m
```

---

## 8.6 Required Function Signatures

```matlab
function binaryPlateImg = binarizePlate(plateImg)
```

```matlab
function cleanedImg = cleanBinaryImage(binaryImg)
```

```matlab
function [characterImages, characterBBoxes] = segmentCharacters(plateImg)
```

---

## 8.7 Input

In the final pipeline, Member 3 receives:

```text
plateImg
```

If Member 2's plate detection is not complete, Member 3 should use manually cropped plate samples from:

```text
images/test/plate_samples/
```

Example:

```text
images/test/plate_samples/plate_selangor_01.jpg
images/test/plate_samples/plate_penang_01.jpg
images/test/plate_samples/plate_malacca_01.jpg
```

---

## 8.8 Output

Member 3 should produce:

```text
binaryPlateImg
cleanedImg
characterImages
characterBBoxes
```

---

## 8.9 Important Constraint

Character segmentation is mainly used for:

- Visualization
- Explanation
- OCR preparation
- Failure analysis

Final text recognition should use OCR.

Character segmentation must not be used for template matching or pattern matching.

---

## 8.10 Independent Test Script

Member 3 should use:

```text
scratch/test_member3_segmentation.m
```

This script should test:

- `binarizePlate.m`
- `cleanBinaryImage.m`
- `segmentCharacters.m`

---

## 8.11 Expected Test Result

Member 3 should confirm that:

```text
[ ] images/test/plate_samples/ exists
[ ] at least one plate sample exists
[ ] binaryPlateImg is generated or safely empty
[ ] cleanedImg is generated or safely empty
[ ] characterImages is returned or safely empty
[ ] characterBBoxes is returned or safely empty
[ ] no template matching is used
[ ] no syntax error occurs
```

---

## 8.12 Report Contribution

Member 3 should contribute to report sections about:

- Thresholding
- Binarization
- Morphological image processing
- Connected component analysis for characters
- Character segmentation for visualization
- Segmentation failure analysis
- How segmentation can support OCR preparation

Recommended report figures:

- Cropped plate sample
- Binary plate image
- Cleaned binary image
- Character candidate visualization

---

# 9. Member 4: Recognition, GUI, and Evaluation

## 9.1 Main Responsibility

Member 4 is responsible for OCR, OCR text cleaning, state identification, GUI, utilities, and evaluation result recording.

This module produces the final user-visible system output.

---

## 9.2 Assigned Folders and Files

Assigned folders:

```text
src/recognition/
src/evaluation/
src/utils/
```

Assigned root file:

```text
launch_gui.m
```

Assigned files:

```text
src/recognition/recognizePlateText.m
src/recognition/cleanRecognizedText.m
src/recognition/identifyState.m
src/evaluation/evaluateSingleImage.m
src/evaluation/saveResultRow.m
src/utils/displayPipelineResults.m
src/utils/saveStepImage.m
src/utils/ensureOutputFolders.m
launch_gui.m
scratch/test_member4_recognition_gui.m
```

---

## 9.3 Related System Requirements

Member 4 is mainly related to:

```text
FR-08: Recognize Plate Text
FR-09: Clean OCR Output
FR-10: Identify Registered State
FR-11: Display Final Results
FR-12: Save Output Images
FR-13: Record Test Results
FR-14: Provide GUI Operation
FR-15: Support Parallel Development
FR-17: Support Independent Module Testing
```

---

## 9.4 Main Implementation Tasks

Member 4 should implement:

- OCR execution
- OCR fallback handling
- OCR text cleaning
- State prefix mapping
- GUI image loading
- GUI recognition execution
- GUI status messages
- Result display
- Output folder creation
- Image saving utilities
- Evaluation row generation
- CSV result saving

---

## 9.5 Main Functions

Member 4 should implement the following functions:

```text
recognizePlateText.m
cleanRecognizedText.m
identifyState.m
evaluateSingleImage.m
saveResultRow.m
displayPipelineResults.m
saveStepImage.m
ensureOutputFolders.m
launch_gui.m
```

---

## 9.6 Required Function Signatures

```matlab
function rawText = recognizePlateText(plateImg)
```

```matlab
function cleanedText = cleanRecognizedText(rawText)
```

```matlab
function stateName = identifyState(cleanedText)
```

```matlab
function resultRow = evaluateSingleImage(imagePath, expectedText, expectedState, vehicleType)
```

```matlab
function saveResultRow(resultRow, csvPath)
```

```matlab
function displayPipelineResults(originalImg, plateImg, recognizedText, stateName)
```

```matlab
function saveStepImage(img, outputFolder, fileName)
```

```matlab
function ensureOutputFolders()
```

---

## 9.7 Input

In the final pipeline, Member 4 receives:

```text
plateImg
rawText
cleanedText
```

If earlier modules are not complete, Member 4 may use manually cropped plate samples from:

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

---

## 9.8 Output

Member 4 should produce:

```text
rawText
cleanedText
stateName
resultRow
GUI display
saved output images
evaluation CSV
```

---

## 9.9 Independent Test Script

Member 4 should use:

```text
scratch/test_member4_recognition_gui.m
```

This script should test:

- `recognizePlateText.m`
- `cleanRecognizedText.m`
- `identifyState.m`
- `displayPipelineResults.m`
- `evaluateSingleImage.m`
- `saveResultRow.m`
- `ensureOutputFolders.m`
- `launch_gui.m`

---

## 9.10 Expected Test Result

Member 4 should confirm that:

```text
[ ] OCR returns text or UNKNOWN
[ ] cleanRecognizedText runs
[ ] identifyState returns a state or UNKNOWN
[ ] displayPipelineResults handles empty plateImg safely
[ ] ensureOutputFolders creates output folders
[ ] evaluateSingleImage returns a structured result
[ ] saveResultRow can save or append CSV rows
[ ] launch_gui.m opens
[ ] GUI displays UNKNOWN safely when recognition fails
[ ] no syntax error occurs
```

---

## 9.11 Report Contribution

Member 4 should contribute to report sections about:

- OCR
- OCR text cleaning
- State identification
- GUI implementation
- Evaluation procedure
- Experimental results
- Evaluation table
- OCR failure analysis
- State identification failure analysis

Recommended report figures and tables:

- OCR-ready plate image
- OCR output example
- State identification example
- GUI screenshot
- Evaluation result table
- Failure analysis table

---

# 10. Shared Responsibilities

All members are responsible for:

- Keeping code readable
- Using English variable names and comments
- Testing assigned modules
- Recording success and failure cases
- Providing screenshots for the report
- Helping with final integration
- Helping with final presentation or demonstration
- Reviewing the final report for consistency

---

## 11. Shared Files That Require Care

The following files may affect multiple members:

```text
main.m
launch_gui.m
results_template.csv
dataset_metadata.csv
README.md
CONTRIBUTING.md
.gitignore
```

Editing these files should be discussed with the team if the change affects other members.

---

## 12. Integration Responsibility

Although each member owns a module, final integration is a team responsibility.

Recommended integration order:

```text
1. Preprocessing
2. Plate Detection
3. Segmentation and Morphology
4. Recognition and State Identification
5. GUI
6. Evaluation
```

After integration, run:

```text
main.m
launch_gui.m
```

Each member should help fix issues related to their assigned module.

---

## 13. Member Deliverables Summary

| Member | Main Deliverables |
|---|---|
| Member 1 | Preprocessing functions, dataset metadata, preprocessing outputs |
| Member 2 | Plate detection functions, cropped plate outputs, detection analysis |
| Member 3 | Segmentation functions, binary/cleaned images, character candidate outputs |
| Member 4 | OCR functions, state identification, GUI, evaluation CSV, utilities |

---

## 14. Final Checklist by Member

## 14.1 Member 1 Checklist

```text
[ ] Dataset images are organized
[ ] dataset_metadata.csv is updated
[ ] preprocessImage.m works
[ ] convertToGray.m works
[ ] enhanceContrast.m works
[ ] removeNoise.m works
[ ] test_member1_preprocessing.m runs
[ ] Preprocessing output screenshots are prepared
```

---

## 14.2 Member 2 Checklist

```text
[ ] detectPlateRegion.m works or returns safe fallback
[ ] selectPlateCandidate.m works or returns safe fallback
[ ] cropPlateRegion.m works or returns safe fallback
[ ] test_member2_plate_detection.m runs
[ ] Plate detection output screenshots are prepared
[ ] Detection failure case is analyzed
```

---

## 14.3 Member 3 Checklist

```text
[ ] plate_samples folder contains at least one cropped plate image
[ ] binarizePlate.m works or returns safe fallback
[ ] cleanBinaryImage.m works or returns safe fallback
[ ] segmentCharacters.m works or returns safe fallback
[ ] test_member3_segmentation.m runs
[ ] Segmentation output screenshots are prepared
[ ] No template matching is used
```

---

## 14.4 Member 4 Checklist

```text
[ ] recognizePlateText.m works or returns UNKNOWN
[ ] cleanRecognizedText.m works
[ ] identifyState.m works or returns UNKNOWN
[ ] evaluateSingleImage.m returns structured result
[ ] saveResultRow.m saves CSV rows
[ ] displayPipelineResults.m handles empty plate image
[ ] ensureOutputFolders.m creates folders
[ ] launch_gui.m opens
[ ] test_member4_recognition_gui.m runs
[ ] GUI screenshots are prepared
```

---

## 15. Notes for Claude or Codex

When generating or modifying project files based on this allocation:

- Do not create member-based source folders.
- Keep source folders divided by system function.
- Keep branch names separate from folder names.
- Generate scratch test scripts for each member.
- Keep function signatures stable.
- Return safe fallback values when a module fails.
- Use English comments and variable names.
- Do not use prohibited methods.
- Make the first skeleton runnable before improving accuracy.
