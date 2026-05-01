# Parallel Development Plan

## 1. Purpose

This document defines the parallel development plan for the License Plate Recognition (LPR) and State Identification System (SIS).

The purpose of this document is to allow all group members to develop their assigned modules at the same time without waiting for earlier modules to be fully completed.

The final system has a sequential image processing pipeline, but the development process should support independent module testing through:

- Shared skeleton files
- Fixed function signatures
- Placeholder outputs
- Safe fallback behavior
- Sample vehicle image
- Manually cropped plate sample images
- Member-specific scratch test scripts

---

## 2. Why Parallel Development Is Needed

The final LPR and SIS system follows a pipeline structure.

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

If the team develops this pipeline strictly in order, later members may be blocked.

For example:

- Member 2 cannot fully test plate detection if preprocessing is not ready.
- Member 3 cannot fully test segmentation if plate detection is not ready.
- Member 4 cannot fully test OCR and GUI if plate cropping is not ready.

To avoid this, the project should be developed using a parallel development strategy.

---

## 3. Final Sequential Dependency

In the final system, the modules depend on each other in the following order:

```text
Member 1: Dataset and Preprocessing
↓
Member 2: License Plate Detection
↓
Member 3: Segmentation and Morphology
↓
Member 4: OCR, State Identification, GUI, and Evaluation
```

This means the final full system will use outputs from earlier modules as inputs for later modules.

However, during development, each member should use temporary inputs or placeholder outputs to work independently.

---

## 4. Parallel Development Strategy

The team should first create a complete project skeleton.

The skeleton should include:

- All required folders
- All required `.m` files
- All required function signatures
- Placeholder return values
- Scratch test scripts
- Sample image folders
- Development documents
- Member task documents

After the skeleton is created, each member can work mainly on their assigned functional folder.

---

## 5. Required Support Files and Folders

The following folders are required for parallel development:

```text
scratch/
images/test/
images/test/plate_samples/
src/preprocessing/
src/plate_detection/
src/segmentation/
src/recognition/
src/evaluation/
src/utils/
```

The following scratch test scripts are required:

```text
scratch/test_member1_preprocessing.m
scratch/test_member2_plate_detection.m
scratch/test_member3_segmentation.m
scratch/test_member4_recognition_gui.m
```

These scripts are used for independent module testing.

They are not the final system entry points.

The final system entry points are:

```text
main.m
launch_gui.m
```

---

## 6. Shared Sample Data

## 6.1 sample_car.jpg

The first full-pipeline test image should be:

```text
images/test/sample_car.jpg
```

This image is used by:

- `main.m`
- `scratch/test_member1_preprocessing.m`
- `scratch/test_member2_plate_detection.m`

This file should contain a vehicle with a visible license plate.

---

## 6.2 Manually Cropped Plate Samples

The following folder should contain manually cropped plate images:

```text
images/test/plate_samples/
```

Example files:

```text
images/test/plate_samples/plate_selangor_01.jpg
images/test/plate_samples/plate_penang_01.jpg
images/test/plate_samples/plate_malacca_01.jpg
```

These manually cropped plate samples are used by:

- Member 3 for segmentation and morphology testing
- Member 4 for OCR, state identification, GUI, and evaluation testing

This allows Member 3 and Member 4 to work before automatic plate detection is fully completed.

---

## 7. Placeholder and Fallback Output Rule

During early development, incomplete modules should return safe placeholder or fallback outputs instead of causing errors.

Recommended fallback outputs:

```matlab
plateImg = [];
plateBBox = [];
characterImages = {};
characterBBoxes = [];
rawText = "UNKNOWN";
cleanedText = "UNKNOWN";
stateName = "UNKNOWN";
```

The system should not crash when:

- Plate detection fails
- Segmentation fails
- OCR fails
- State identification fails
- Input image is missing
- Plate sample image is missing
- A module is not fully implemented yet

The first implementation should prioritize a runnable system over high accuracy.

---

## 8. Function Signature Stability

All members must keep the agreed function signatures stable.

Core function signatures:

```matlab
[preprocessedImg, preprocessDebug] = preprocessImage(originalImg);

[plateImg, plateBBox, detectionDebug] = detectPlateRegion(preprocessedImg, originalImg);

[characterImages, characterBBoxes] = segmentCharacters(plateImg);

rawText = recognizePlateText(plateImg);

cleanedText = cleanRecognizedText(rawText);

stateName = identifyState(cleanedText);
```

Function signatures should not be changed without group discussion.

Changing a function signature may break other members' modules, `main.m`, `launch_gui.m`, and evaluation scripts.

---

## 9. Member 1 Parallel Development Plan

## 9.1 Assigned Area

Member 1 is responsible for:

```text
src/preprocessing/
images/
dataset_metadata.csv
scratch/test_member1_preprocessing.m
```

## 9.2 Main Functions

```text
preprocessImage.m
convertToGray.m
enhanceContrast.m
removeNoise.m
```

## 9.3 Input

Member 1 can use:

```text
images/test/sample_car.jpg
```

## 9.4 Output

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

## 9.5 Independent Test

Member 1 should run:

```text
scratch/test_member1_preprocessing.m
```

This script should display or save:

- Original image
- Grayscale image
- Enhanced image
- Filtered image

---

## 10. Member 2 Parallel Development Plan

## 10.1 Assigned Area

Member 2 is responsible for:

```text
src/plate_detection/
scratch/test_member2_plate_detection.m
```

## 10.2 Main Functions

```text
detectPlateRegion.m
selectPlateCandidate.m
cropPlateRegion.m
```

## 10.3 Final Input

In the final system, Member 2 receives:

```text
preprocessedImg
originalImg
```

## 10.4 Temporary Input Strategy

If Member 1's preprocessing module is not completed, Member 2 may use simple grayscale conversion inside the scratch test script.

```matlab
originalImg = imread('images/test/sample_car.jpg');

if size(originalImg, 3) == 3
    preprocessedImg = rgb2gray(originalImg);
else
    preprocessedImg = originalImg;
end
```

## 10.5 Output

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

## 10.6 Independent Test

Member 2 should run:

```text
scratch/test_member2_plate_detection.m
```

This script should display or save:

- Original image
- Edge image if available
- Candidate detection result if available
- Cropped plate image or empty fallback

---

## 11. Member 3 Parallel Development Plan

## 11.1 Assigned Area

Member 3 is responsible for:

```text
src/segmentation/
images/test/plate_samples/
scratch/test_member3_segmentation.m
```

## 11.2 Main Functions

```text
binarizePlate.m
cleanBinaryImage.m
segmentCharacters.m
```

## 11.3 Final Input

In the final system, Member 3 receives:

```text
plateImg
```

from Member 2.

## 11.4 Temporary Input Strategy

If Member 2's plate detection module is not completed, Member 3 should use manually cropped plate images from:

```text
images/test/plate_samples/
```

Example:

```matlab
plateImg = imread('images/test/plate_samples/plate_selangor_01.jpg');
```

## 11.5 Output

Member 3 should produce:

```text
binaryPlateImg
cleanedImg
characterImages
characterBBoxes
```

## 11.6 Important Constraint

Character segmentation is mainly used for:

- Visualization
- Explanation
- OCR preparation
- Failure analysis

Final text recognition should use OCR.

Character segmentation must not be used for template-based character matching.

## 11.7 Independent Test

Member 3 should run:

```text
scratch/test_member3_segmentation.m
```

This script should display or save:

- Cropped plate sample
- Binary plate image
- Cleaned binary image
- Character candidate regions

---

## 12. Member 4 Parallel Development Plan

## 12.1 Assigned Area

Member 4 is responsible for:

```text
src/recognition/
src/evaluation/
src/utils/
launch_gui.m
scratch/test_member4_recognition_gui.m
```

## 12.2 Main Functions

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

## 12.3 Final Input

In the final system, Member 4 receives:

```text
plateImg
rawText
cleanedText
```

depending on the stage being tested.

## 12.4 Temporary Input Strategy

If earlier modules are not completed, Member 4 may use manually cropped plate images from:

```text
images/test/plate_samples/
```

Member 4 may also use temporary OCR strings for state identification testing.

Examples:

```text
BMS8147
PAB1234
MAB5678
WXY5678
```

## 12.5 Output

Member 4 should produce:

```text
rawText
cleanedText
stateName
resultRow
GUI display
```

## 12.6 Independent Test

Member 4 should run:

```text
scratch/test_member4_recognition_gui.m
```

This script should test:

- OCR
- OCR text cleaning
- State identification
- Result display
- Evaluation row generation
- GUI launch behavior

---

## 13. Integration Strategy

Each member should first test their own module independently.

After a module works independently, it should be integrated into the full pipeline.

Recommended integration order:

```text
1. Preprocessing
2. Plate Detection
3. Segmentation and Morphology
4. OCR and State Identification
5. GUI
6. Evaluation
```

After each integration step, the team should run:

```text
main.m
```

After GUI-related updates, the team should run:

```text
launch_gui.m
```

---

## 14. Git Branch Strategy

Recommended Git branches:

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

Important rule:

Branch names are not folder names.

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

---

## 15. Merge Flow

Recommended merge flow:

```text
feature branch
↓
dev
↓
main
```

Each member should work mainly on their assigned feature branch and assigned functional folder.

Before merging into `dev`, the member should:

1. Run their scratch test script.
2. Confirm there are no syntax errors.
3. Confirm fallback outputs work.
4. Confirm function signatures were not changed.
5. Commit only relevant files.
6. Avoid committing large raw datasets or output images.

---

## 16. Integration Checklist

Before integrating a module into `dev`, check:

```text
[ ] The assigned scratch test script runs.
[ ] The function names match the file names.
[ ] The function signatures match the agreed design.
[ ] The function returns safe fallback outputs when input is invalid.
[ ] The code uses English comments and variable names.
[ ] No prohibited methods are used.
[ ] No large raw dataset is committed.
[ ] No output folder is committed unless specifically needed.
```

After merging into `dev`, check:

```text
[ ] main.m runs.
[ ] launch_gui.m opens.
[ ] sample_car.jpg can be loaded.
[ ] The pipeline reaches the final output.
[ ] UNKNOWN is displayed when recognition fails.
[ ] No missing path error occurs.
```

---

## 17. Expected First Development Milestone

The first milestone is not high accuracy.

The first milestone is a runnable skeleton.

The skeleton should:

1. Have the complete folder structure.
2. Include all required `.m` files.
3. Include all scratch test scripts.
4. Include placeholder outputs.
5. Run from `main.m`.
6. Open from `launch_gui.m`.
7. Return `UNKNOWN` when recognition fails.
8. Allow each member to test their module independently.

---

## 18. Expected Final Development Goal

The final system should:

1. Load vehicle images.
2. Preprocess images.
3. Detect likely license plate regions.
4. Crop detected plate regions.
5. Prepare plate images for OCR.
6. Segment possible character regions for explanation.
7. Recognize plate text using OCR.
8. Clean OCR output.
9. Identify registered Malaysian state.
10. Display results in a GUI.
11. Save outputs for report use.
12. Record evaluation results.
13. Support success and failure analysis.
14. Allow each member to demonstrate their contribution.

---

## 19. Notes for Claude or Codex

When generating or modifying the project:

- Create the shared skeleton first.
- Keep all core function signatures stable.
- Use placeholder outputs for incomplete functions.
- Generate scratch test scripts for each member.
- Support `images/test/sample_car.jpg`.
- Support `images/test/plate_samples/`.
- Do not use TensorFlow, Haar Cascade, YOLO, deep learning detectors, template matching, or pattern matching.
- Use OCR only after plate detection and plate image preprocessing.
- Use character segmentation only for visualization, explanation, and OCR preparation.
- Do not create folders based on Git branch names.
- Do not create source folders based on member names.
- Keep comments and variable names in English.
- Prioritize a runnable skeleton before improving accuracy.
