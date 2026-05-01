# Integration Plan

## 1. Purpose

This document defines the integration plan for the License Plate Recognition (LPR) and State Identification System (SIS).

The purpose of this document is to explain how individual modules developed by each member should be combined into one working MATLAB system.

The integration plan helps the team:

- Combine modules safely
- Check function compatibility
- Avoid breaking the full pipeline
- Detect errors early
- Confirm GUI operation
- Prepare outputs for evaluation and report writing

---

## 2. Integration Overview

The final system follows this pipeline:

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
Evaluation Recording
```

Each module should be developed independently first, then integrated step by step.

---

## 3. Integration Order

Recommended integration order:

```text
1. Project skeleton
2. Preprocessing
3. Plate detection
4. Segmentation and morphology
5. Recognition and state identification
6. Utilities
7. GUI
8. Evaluation
9. Final full-pipeline testing
```

This order follows the natural dependency of the system while still allowing parallel development during early implementation.

---

## 4. Integration Branch

Integration should be performed on:

```text
dev
```

Feature branches should be merged into `dev` first.

Recommended merge flow:

```text
feature branch
↓
dev
↓
main
```

Do not merge directly from a feature branch to `main`.

Only merge `dev` into `main` when the system is stable enough for backup or submission preparation.

---

## 5. Pre-Integration Requirements

Before integrating any module, confirm that:

```text
[ ] The project folder structure is correct
[ ] The module uses the agreed function signatures
[ ] The module file names match the function names
[ ] The module returns safe fallback outputs
[ ] The assigned scratch test script runs or fails safely
[ ] No prohibited methods are used
[ ] Comments and variable names are written in English
[ ] No large raw dataset or unnecessary output files are included
```

---

## 6. Core Function Signatures

The following function signatures must remain stable.

```matlab
[preprocessedImg, preprocessDebug] = preprocessImage(originalImg);

[plateImg, plateBBox, detectionDebug] = detectPlateRegion(preprocessedImg, originalImg);

[characterImages, characterBBoxes] = segmentCharacters(plateImg);

rawText = recognizePlateText(plateImg);

cleanedText = cleanRecognizedText(rawText);

stateName = identifyState(cleanedText);
```

Changing these signatures may break `main.m`, `launch_gui.m`, scratch test scripts, and evaluation functions.

Do not change core function signatures without team discussion.

---

## 7. Safe Fallback Outputs

All modules should fail safely.

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

Fallback outputs are especially important during integration because not all modules may be complete at the same time.

---

# 8. Integration Step 1: Project Skeleton

## 8.1 Purpose

The first integration step is to confirm that the basic project skeleton exists.

## 8.2 Required Files and Folders

Confirm that the following exist:

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

scratch/
images/test/
images/test/plate_samples/

src/preprocessing/
src/plate_detection/
src/segmentation/
src/recognition/
src/evaluation/
src/utils/

output/
report/
```

## 8.3 Required Scratch Scripts

```text
scratch/test_member1_preprocessing.m
scratch/test_member2_plate_detection.m
scratch/test_member3_segmentation.m
scratch/test_member4_recognition_gui.m
```

## 8.4 Skeleton Integration Check

Run:

```text
main.m
```

Expected result:

```text
main.m runs or shows a clear message about missing sample_car.jpg.
```

Run:

```text
launch_gui.m
```

Expected result:

```text
GUI opens or shows a clear error message.
```

---

# 9. Integration Step 2: Preprocessing Module

## 9.1 Owner

```text
Member 1
```

## 9.2 Files to Integrate

```text
src/preprocessing/preprocessImage.m
src/preprocessing/convertToGray.m
src/preprocessing/enhanceContrast.m
src/preprocessing/removeNoise.m
scratch/test_member1_preprocessing.m
```

## 9.3 Expected Input

```text
originalImg
```

## 9.4 Expected Output

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

## 9.5 Preprocessing Integration Test

Run:

```text
scratch/test_member1_preprocessing.m
```

Then run:

```text
main.m
```

Expected result:

```text
[ ] sample_car.jpg loads
[ ] preprocessImage runs
[ ] preprocessedImg is returned
[ ] preprocessDebug is returned
[ ] no syntax error occurs
```

## 9.6 Common Issues

| Issue | Possible Cause | Fix |
|---|---|---|
| Function not found | `addpath(genpath('src'))` missing | Add path setup |
| Output not enough | Function returns one output only | Use `[preprocessedImg, debugInfo]` |
| Image appears too dark | Contrast method needs tuning | Adjust `imadjust` or `adapthisteq` |
| Error with RGB/grayscale | Channel check missing | Add grayscale handling |

---

# 10. Integration Step 3: Plate Detection Module

## 10.1 Owner

```text
Member 2
```

## 10.2 Files to Integrate

```text
src/plate_detection/detectPlateRegion.m
src/plate_detection/selectPlateCandidate.m
src/plate_detection/cropPlateRegion.m
scratch/test_member2_plate_detection.m
```

## 10.3 Expected Input

```text
preprocessedImg
originalImg
```

## 10.4 Expected Output

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

## 10.5 Plate Detection Integration Test

Run:

```text
scratch/test_member2_plate_detection.m
```

Then run:

```text
main.m
```

Expected result:

```text
[ ] detectPlateRegion runs
[ ] plateBBox is returned or safely empty
[ ] plateImg is returned or safely empty
[ ] detectionDebug is returned
[ ] system continues even when no plate is detected
```

## 10.6 Common Issues

| Issue | Possible Cause | Fix |
|---|---|---|
| `imcrop` error | Invalid bounding box | Validate bbox before cropping |
| Empty plate image | No valid candidate | Return safe fallback |
| Wrong region selected | Aspect ratio or area filter weak | Tune candidate filtering |
| Function output mismatch | Wrong function signature | Match agreed signature |
| Crash after failure | Missing fallback handling | Return `plateImg = []` |

---

# 11. Integration Step 4: Segmentation and Morphology Module

## 11.1 Owner

```text
Member 3
```

## 11.2 Files to Integrate

```text
src/segmentation/binarizePlate.m
src/segmentation/cleanBinaryImage.m
src/segmentation/segmentCharacters.m
scratch/test_member3_segmentation.m
```

## 11.3 Expected Input

```text
plateImg
```

## 11.4 Expected Output

```text
characterImages
characterBBoxes
```

Additional internal outputs may include:

```text
binaryPlateImg
cleanedImg
```

## 11.5 Segmentation Integration Test

Run:

```text
scratch/test_member3_segmentation.m
```

Then run:

```text
main.m
```

Expected result:

```text
[ ] binarizePlate runs
[ ] cleanBinaryImage runs
[ ] segmentCharacters runs
[ ] characterImages is returned or safely empty
[ ] characterBBoxes is returned or safely empty
[ ] no template matching is used
```

## 11.6 Important Constraint

Character segmentation is mainly used for:

```text
Visualization
Explanation
OCR preparation
Failure analysis
```

Final text recognition should use OCR.

Do not use template matching or pattern matching for final recognition.

## 11.7 Common Issues

| Issue | Possible Cause | Fix |
|---|---|---|
| Empty `plateImg` causes error | Plate detection failed | Check for empty input |
| Binary image too noisy | Threshold not suitable | Try adaptive threshold |
| Characters merged | Morphology too strong | Adjust structuring element |
| Too many components | Noise not removed | Use `bwareaopen` |
| Template matching used | Wrong recognition method | Remove template matching |

---

# 12. Integration Step 5: Recognition and State Identification

## 12.1 Owner

```text
Member 4
```

## 12.2 Files to Integrate

```text
src/recognition/recognizePlateText.m
src/recognition/cleanRecognizedText.m
src/recognition/identifyState.m
scratch/test_member4_recognition_gui.m
```

## 12.3 Expected Input

```text
plateImg
rawText
cleanedText
```

## 12.4 Expected Output

```text
rawText
cleanedText
stateName
```

## 12.5 Recognition Integration Test

Run:

```text
scratch/test_member4_recognition_gui.m
```

Then run:

```text
main.m
```

Expected result:

```text
[ ] recognizePlateText returns OCR text or UNKNOWN
[ ] cleanRecognizedText returns cleaned text or UNKNOWN
[ ] identifyState returns state name or UNKNOWN
[ ] system continues even if OCR fails
```

## 12.6 Common Issues

| Issue | Possible Cause | Fix |
|---|---|---|
| OCR unavailable | MATLAB toolbox issue | Return `UNKNOWN` safely |
| Empty OCR result | Plate crop unclear | Return `UNKNOWN` |
| Wrong state | OCR first character wrong | Explain in failure analysis |
| Text contains spaces | Cleaning incomplete | Use `regexprep` |
| Error with string/char | Type mismatch | Convert with `string()` |

---

# 13. Integration Step 6: Utilities

## 13.1 Owner

```text
Member 4
```

## 13.2 Files to Integrate

```text
src/utils/displayPipelineResults.m
src/utils/saveStepImage.m
src/utils/ensureOutputFolders.m
```

## 13.3 Expected Behavior

Utilities should:

```text
[ ] Display original image and plate result
[ ] Handle empty plate image safely
[ ] Save images only when valid
[ ] Create output folders when missing
```

## 13.4 Utility Integration Test

Run:

```text
main.m
```

Expected result:

```text
[ ] output folders are created
[ ] final result is displayed
[ ] empty outputs do not crash the display
```

---

# 14. Integration Step 7: GUI

## 14.1 Owner

```text
Member 4
```

## 14.2 Files to Integrate

```text
launch_gui.m
```

## 14.3 Expected Behavior

The GUI should:

```text
[ ] Open successfully
[ ] Load an image
[ ] Display the original image
[ ] Run the pipeline
[ ] Display detected plate or fallback
[ ] Display recognized text or UNKNOWN
[ ] Display state or UNKNOWN
[ ] Show clear status messages
[ ] Stay open after errors
```

## 14.4 GUI Integration Test

Run:

```text
launch_gui.m
```

Test workflow:

```text
Open GUI
↓
Load Image
↓
Run Recognition
↓
Check Original Image Display
↓
Check Detected Plate Display
↓
Check Recognized Text
↓
Check State
↓
Check Status Message
```

## 14.5 Common Issues

| Issue | Possible Cause | Fix |
|---|---|---|
| GUI cannot find functions | Path not added | Use `addpath(genpath('src'))` |
| GUI crashes on empty plate | Missing empty check | Add fallback display |
| Button does nothing | Callback error | Check callback function |
| Image not displayed | Axes not selected | Use `axes(...)` before `imshow` |
| Status not updated | Handle not stored | Use `guidata` correctly |

---

# 15. Integration Step 8: Evaluation

## 15.1 Owner

```text
Member 4
```

## 15.2 Files to Integrate

```text
src/evaluation/evaluateSingleImage.m
src/evaluation/saveResultRow.m
results_template.csv
```

## 15.3 Expected Output Fields

Evaluation result rows should include:

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

## 15.4 Evaluation Integration Test

Run an evaluation test with one image.

Expected result:

```text
[ ] evaluateSingleImage runs
[ ] resultRow contains all required fields
[ ] overall_result is included
[ ] saveResultRow creates or appends CSV
[ ] failure cases are recorded safely
```

## 15.5 Common Issues

| Issue | Possible Cause | Fix |
|---|---|---|
| Missing `overall_result` | Old CSV header | Update results template |
| CSV write error | Type mismatch | Convert struct/table consistently |
| Missing notes | Failure not handled | Add failure notes |
| Evaluation crashes | Pipeline error not caught | Add try-catch |

---

# 16. Full Pipeline Test

After all modules are integrated, run:

```text
main.m
```

The full pipeline should confirm:

```text
[ ] Source path is added
[ ] Output folders are created
[ ] Sample image loads
[ ] Preprocessing runs
[ ] Plate detection runs
[ ] Segmentation runs or fails safely
[ ] OCR runs or returns UNKNOWN
[ ] Text cleaning runs
[ ] State identification runs
[ ] Final result is displayed
[ ] No unexpected crash occurs
```

---

# 17. Full GUI Test

After the full pipeline test, run:

```text
launch_gui.m
```

The GUI should confirm:

```text
[ ] GUI opens
[ ] Load Image button works
[ ] Run Recognition button works
[ ] Original image is displayed
[ ] Detected plate is displayed or handled safely
[ ] Recognized text is displayed
[ ] Identified state is displayed
[ ] Status message is clear
[ ] GUI does not crash when recognition fails
```

---

# 18. Module-Level Test Checklist

Before final testing, each member should run their own scratch test.

```text
[ ] Member 1 ran scratch/test_member1_preprocessing.m
[ ] Member 2 ran scratch/test_member2_plate_detection.m
[ ] Member 3 ran scratch/test_member3_segmentation.m
[ ] Member 4 ran scratch/test_member4_recognition_gui.m
```

---

# 19. Test Data Checklist

Confirm that test data exists.

```text
[ ] images/test/sample_car.jpg exists
[ ] images/test/plate_samples/ exists
[ ] At least one manually cropped plate sample exists
[ ] Success cases are prepared
[ ] Difficult cases are prepared
[ ] Failure cases are prepared if possible
[ ] dataset_metadata.csv is updated
```

---

# 20. Output Checklist

Confirm that output files can be generated or saved.

```text
[ ] output/plate_detection/ exists
[ ] output/segmentation/ exists
[ ] output/recognition/ exists
[ ] output/figures/ exists
[ ] report/figures/ exists
[ ] report/tables/ exists
[ ] Evaluation CSV can be saved
```

---

# 21. Final Integration Checklist

Before considering the integrated system complete, check:

```text
[ ] main.m runs from the project root
[ ] launch_gui.m opens from the project root
[ ] addpath(genpath('src')) is included where needed
[ ] Function names match file names
[ ] Core function signatures are stable
[ ] Safe fallback outputs are implemented
[ ] UNKNOWN is displayed when OCR or state identification fails
[ ] Empty image outputs do not crash the system
[ ] results_template.csv includes overall_result
[ ] No TensorFlow, Haar Cascade, YOLO, template matching, or pattern matching is used
[ ] English comments and variable names are used
[ ] Report screenshots can be produced
```

---

# 22. Troubleshooting Guide

## 22.1 Function Not Found

Possible cause:

```text
src folder was not added to MATLAB path.
```

Fix:

```matlab
addpath(genpath('src'));
```

---

## 22.2 Sample Image Not Found

Possible cause:

```text
images/test/sample_car.jpg does not exist.
```

Fix:

```text
Place a sample image at images/test/sample_car.jpg.
```

---

## 22.3 Plate Sample Not Found

Possible cause:

```text
images/test/plate_samples/ is empty.
```

Fix:

```text
Add manually cropped plate images to images/test/plate_samples/.
```

---

## 22.4 Output Folder Error

Possible cause:

```text
Output folders do not exist.
```

Fix:

```matlab
ensureOutputFolders();
```

---

## 22.5 GUI Opens but Buttons Fail

Possible cause:

```text
Callback error or missing function path.
```

Fix:

```text
Check callback code.
Check addpath(genpath('src')).
Check Command Window error message.
```

---

## 22.6 OCR Error

Possible cause:

```text
OCR toolbox is unavailable or plate image is unclear.
```

Fix:

```text
Return UNKNOWN safely.
Improve OCR preprocessing later.
```

---

## 22.7 CSV Save Error

Possible cause:

```text
resultRow format does not match CSV header.
```

Fix:

```text
Ensure resultRow includes all expected fields.
Ensure overall_result is included.
```

---

# 23. Integration Milestones

## Milestone 1: Skeleton Integration

Goal:

```text
Folder structure and all placeholder files exist.
```

Success criteria:

```text
main.m runs or shows clear missing image message.
launch_gui.m opens or shows clear fallback behavior.
```

---

## Milestone 2: Module Integration

Goal:

```text
Each module works independently with scratch test scripts.
```

Success criteria:

```text
All scratch test scripts run or fail safely.
```

---

## Milestone 3: Full Pipeline Integration

Goal:

```text
main.m runs from image loading to state identification.
```

Success criteria:

```text
The system displays final result or UNKNOWN fallback without crashing.
```

---

## Milestone 4: GUI Integration

Goal:

```text
GUI can load image and run recognition.
```

Success criteria:

```text
GUI displays original image, plate result or fallback, OCR text, state, and status.
```

---

## Milestone 5: Evaluation Integration

Goal:

```text
Evaluation result can be recorded.
```

Success criteria:

```text
evaluateSingleImage and saveResultRow can generate or append evaluation rows.
```

---

## Milestone 6: Final Testing

Goal:

```text
System can support report screenshots and demonstration.
```

Success criteria:

```text
Success, difficult, and failure cases can be demonstrated and analyzed.
```

---

# 24. Notes for Claude or Codex

When generating or modifying files based on this integration plan:

- Keep the folder structure unchanged.
- Do not create folders based on branch names.
- Do not create source folders based on member names.
- Keep all core function signatures stable.
- Make each module return safe fallback outputs.
- Use `UNKNOWN` for recognition or state failures.
- Use empty arrays for image-processing failures.
- Use English comments and variable names.
- Do not use prohibited methods.
- Ensure `main.m`, `launch_gui.m`, and scratch tests include `addpath(genpath('src'))`.
- Ensure `results_template.csv` includes `overall_result`.
