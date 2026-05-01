# Member 2 Task: License Plate Detection

## 1. Purpose

This document defines the task details for Member 2.

Member 2 is responsible for license plate region detection and plate cropping for the License Plate Recognition (LPR) and State Identification System (SIS).

The goal of this task is to detect the most likely license plate region from a vehicle image and return a cropped plate image that can be used by later modules.

---

## 2. Main Responsibility

Member 2 is responsible for:

- License plate region detection
- Edge detection for candidate extraction
- Morphological processing for plate region connection
- Connected component analysis
- Region property filtering
- Plate candidate selection
- Plate cropping
- Detection debug output
- Plate detection module testing
- Plate detection-related report content

Member 2’s output becomes the input for Member 3’s segmentation module and Member 4’s OCR module.

---

## 3. Assigned Folders

Member 2 should mainly work in the following folder:

```text
src/plate_detection/
```

Member 2 may also update:

```text
scratch/test_member2_plate_detection.m
output/plate_detection/
report/figures/
```

---

## 4. Assigned Files

Member 2 is mainly responsible for the following files:

```text
src/plate_detection/detectPlateRegion.m
src/plate_detection/selectPlateCandidate.m
src/plate_detection/cropPlateRegion.m
scratch/test_member2_plate_detection.m
```

---

## 5. Related System Requirements

Member 2 is mainly related to the following system requirements:

```text
FR-04: Detect License Plate Region
FR-05: Crop License Plate Region
FR-12: Save Output Images
FR-15: Support Parallel Development
FR-17: Support Independent Module Testing
```

---

## 6. Related Technical Constraints

Member 2 must follow these constraints:

- Use MATLAB `.m` files.
- Use classical image processing methods.
- Use English comments and variable names.
- Do not use TensorFlow.
- Do not use Haar Cascade.
- Do not use YOLO.
- Do not use deep learning object detectors.
- Do not use template matching.
- Do not use pattern matching.
- Do not use pretrained object detectors.
- Use relative paths where possible.
- Keep function names consistent with file names.
- Do not change agreed function signatures without team discussion.
- Return safe fallback outputs if detection fails.

---

## 7. Input Data

## 7.1 Final Pipeline Input

In the final system, Member 2 receives:

```text
preprocessedImg
originalImg
```

from Member 1’s preprocessing module.

Expected call:

```matlab
[plateImg, plateBBox, detectionDebug] = detectPlateRegion(preprocessedImg, originalImg);
```

---

## 7.2 Temporary Development Input

If Member 1’s preprocessing module is not completed, Member 2 may create a temporary grayscale image inside the scratch test script.

Example:

```matlab
originalImg = imread('images/test/sample_car.jpg');

if size(originalImg, 3) == 3
    preprocessedImg = rgb2gray(originalImg);
else
    preprocessedImg = originalImg;
end
```

This allows Member 2 to work without waiting for Member 1.

---

## 7.3 Test Images

Member 2 should mainly use:

```text
images/test/sample_car.jpg
images/test/success_cases/
images/test/difficult_cases/
images/test/failure_cases/
```

Useful detection test images include:

- Clear plate image
- Simple background image
- Complex background image
- Far-distance plate image
- Angled plate image
- Image with similar rectangular objects in the background

---

## 8. Expected Outputs

Member 2 should produce:

```text
plateImg
plateBBox
detectionDebug
```

Recommended `detectionDebug` fields:

```matlab
detectionDebug.edgeImg
detectionDebug.closedImg
detectionDebug.filledImg
detectionDebug.cleanedImg
detectionDebug.regions
detectionDebug.status
```

These outputs are useful for:

- Member 3’s segmentation testing
- Member 4’s OCR testing
- Full-pipeline testing
- Report screenshots
- Failure analysis
- Presentation explanation

---

## 9. Required Function Signatures

Member 2 should use the following function signatures.

```matlab
function [plateImg, plateBBox, debugInfo] = detectPlateRegion(preprocessedImg, originalImg)
```

```matlab
function bestBBox = selectPlateCandidate(regions, imageSize)
```

```matlab
function plateImg = cropPlateRegion(originalImg, plateBBox)
```

These signatures should not be changed without team discussion.

---

## 10. Function Responsibilities

## 10.1 detectPlateRegion.m

### Purpose

Detects and crops the most likely license plate region.

### Input

```text
preprocessedImg
originalImg
```

### Output

```text
plateImg
plateBBox
debugInfo
```

### Responsibilities

- Validate input images.
- Detect edges from the preprocessed image.
- Apply morphological operations to connect plate-like regions.
- Fill holes if needed.
- Remove small objects.
- Extract connected components.
- Measure region properties.
- Select the most likely plate candidate.
- Crop the detected plate from the original image.
- Return debug information.

### Recommended Processing Flow

```text
preprocessedImg
↓
edge detection
↓
morphological closing
↓
fill holes
↓
remove small objects
↓
connected component analysis
↓
region property filtering
↓
selectPlateCandidate
↓
cropPlateRegion
↓
plateImg
```

### Allowed MATLAB Functions

```matlab
edge
strel
imclose
imdilate
imerode
imfill
bwareaopen
bwconncomp
bwlabel
regionprops
imcrop
```

### Internal Function Calls

```matlab
plateBBox = selectPlateCandidate(regions, size(preprocessedImg));
plateImg = cropPlateRegion(originalImg, plateBBox);
```

### Failure Handling

If no valid plate candidate is found, return:

```matlab
plateImg = [];
plateBBox = [];
debugInfo.status = "No valid plate candidate found.";
```

The system should not crash. Later modules should return `UNKNOWN` if the plate image is empty.

---

## 10.2 selectPlateCandidate.m

### Purpose

Selects the most likely license plate bounding box from candidate regions.

### Input

```text
regions
imageSize
```

### Output

```text
bestBBox
```

### Responsibilities

- Loop through detected region candidates.
- Extract bounding box, area, width, and height.
- Calculate aspect ratio.
- Remove invalid candidates.
- Score candidates.
- Return the best bounding box.

### Candidate Filtering Criteria

Possible criteria:

- Area is within reasonable range.
- Width is larger than height.
- Aspect ratio is plate-like.
- Bounding box is not too small.
- Bounding box is inside image boundaries.
- Candidate region is not too close to impossible dimensions.
- Candidate has a rectangular shape.

### Suggested Aspect Ratio Range

```text
2.0 to 6.0
```

This range should be tuned during testing.

### Failure Handling

If no candidate is suitable, return:

```matlab
bestBBox = [];
```

---

## 10.3 cropPlateRegion.m

### Purpose

Crops the detected plate region from the original image.

### Input

```text
originalImg
plateBBox
```

### Output

```text
plateImg
```

### Responsibilities

- Validate the bounding box.
- Check that the bounding box is not empty.
- Check that width and height are positive.
- Check that the bounding box is inside the image boundary.
- Crop the plate region using `imcrop`.
- Return empty output if the bounding box is invalid.

### Allowed MATLAB Function

```matlab
imcrop
```

### Failure Handling

If `plateBBox` is empty or invalid, return:

```matlab
plateImg = [];
```

---

## 11. Independent Test Script

Member 2 should use:

```text
scratch/test_member2_plate_detection.m
```

This script should test:

- `detectPlateRegion.m`
- `selectPlateCandidate.m`
- `cropPlateRegion.m`

---

## 12. Suggested Test Script Flow

```text
Clear workspace
↓
Add src folder to MATLAB path
↓
Load images/test/sample_car.jpg
↓
Create temporary grayscale image if preprocessing is not ready
↓
Run detectPlateRegion
↓
Display original image
↓
Display edge image if available
↓
Display detected plate or fallback message
↓
Save outputs if needed
```

Suggested MATLAB flow:

```matlab
clc;
clear;
close all;

addpath(genpath('src'));

imagePath = fullfile('images', 'test', 'sample_car.jpg');

if ~isfile(imagePath)
    error('Sample image not found: %s', imagePath);
end

originalImg = imread(imagePath);

if size(originalImg, 3) == 3
    preprocessedImg = rgb2gray(originalImg);
else
    preprocessedImg = originalImg;
end

[plateImg, plateBBox, detectionDebug] = detectPlateRegion(preprocessedImg, originalImg);

figure;
imshow(originalImg);
title('Original Image');

if isfield(detectionDebug, 'edgeImg') && ~isempty(detectionDebug.edgeImg)
    figure;
    imshow(detectionDebug.edgeImg);
    title('Edge Image');
end

if ~isempty(plateImg)
    figure;
    imshow(plateImg);
    title('Detected Plate');
else
    disp('No plate detected. Safe fallback returned.');
end
```

---

## 13. Testing Checklist

Before merging Member 2’s work, confirm:

```text
[ ] images/test/sample_car.jpg exists
[ ] test_member2_plate_detection.m runs
[ ] detectPlateRegion.m runs
[ ] selectPlateCandidate.m runs
[ ] cropPlateRegion.m runs
[ ] temporary grayscale conversion works if preprocessing is not ready
[ ] plateBBox is returned or safely empty
[ ] plateImg is returned or safely empty
[ ] detectionDebug is returned
[ ] invalid bounding boxes are handled safely
[ ] empty input is handled safely
[ ] no prohibited methods are used
[ ] no template matching or pattern matching is used
[ ] function signatures are unchanged
[ ] comments and variable names are in English
```

---

## 14. Output Saving

Member 2 may save useful detection outputs into:

```text
output/plate_detection/
report/figures/
```

Useful output examples:

```text
output/plate_detection/car_selangor_close_01_edge.jpg
output/plate_detection/car_selangor_close_01_candidates.jpg
output/plate_detection/car_selangor_close_01_bbox.jpg
output/plate_detection/car_selangor_close_01_plate_crop.jpg
```

Avoid committing large output folders to GitHub unless the team agrees.

---

## 15. Report Contribution

Member 2 should contribute to the following report sections:

- License plate detection
- Edge detection
- Morphological processing for candidate extraction
- Connected component analysis
- Region property filtering
- Aspect ratio filtering
- Plate candidate selection
- Plate cropping
- Plate detection success cases
- Plate detection failure cases

---

## 16. Recommended Report Figures

Member 2 should prepare figures such as:

- Preprocessed image
- Edge detection image
- Morphological closing result
- Candidate region image
- Original image with bounding box
- Cropped plate image
- Detection failure example

Example figure caption:

```text
Figure X. License plate detection process showing edge detection, candidate region extraction, and final cropped plate result.
```

---

## 17. Success Criteria

Member 2’s task is considered successful when:

```text
[ ] detectPlateRegion.m runs without syntax errors
[ ] Candidate regions can be generated
[ ] selectPlateCandidate.m returns a valid bbox or safe empty result
[ ] cropPlateRegion.m returns a cropped image or safe empty result
[ ] The system does not crash when no plate is detected
[ ] Member 3 can use plateImg for segmentation when detection succeeds
[ ] Member 4 can use plateImg for OCR when detection succeeds
```

---

## 18. Failure Case Analysis

Member 2 should keep and analyze failure cases.

Common failure causes:

- Plate is too small.
- Plate is blurry.
- Plate is angled.
- Plate has low contrast.
- Background contains similar rectangular objects.
- Edge detection produces too many false regions.
- Morphological processing connects unrelated objects.
- Candidate filtering is too strict.
- Candidate filtering is too loose.
- Bounding box includes too much background.
- Bounding box cuts off part of the plate.

Example analysis sentence:

```text
In this case, the plate detection module selected a wrong rectangular region because the background contained a sign with a similar shape to the license plate. This caused the later OCR stage to return UNKNOWN.
```

---

## 19. Common Problems and Fixes

| Problem | Possible Cause | Suggested Fix |
|---|---|---|
| Function not found | MATLAB path not set | Use `addpath(genpath('src'))` |
| `imcrop` error | Invalid bounding box | Validate bbox before cropping |
| No plate detected | Candidate filtering too strict | Adjust area or aspect ratio thresholds |
| Wrong region detected | Candidate filtering too loose | Improve scoring or region filtering |
| Too many regions | Noise remains after edge detection | Use morphological cleaning or area filtering |
| Plate crop too large | Bounding box includes background | Tune candidate selection |
| Plate crop too small | Bounding box cuts plate | Add margin or adjust filtering |
| Later OCR returns UNKNOWN | Crop is unclear or empty | Improve detection and crop quality |

---

## 20. Collaboration Notes

Member 2 should coordinate with Member 1 because plate detection depends on preprocessing output.

Member 2 expects:

```matlab
[preprocessedImg, preprocessDebug] = preprocessImage(originalImg);
```

Member 2 should coordinate with Member 3 and Member 4 because they depend on:

```matlab
[plateImg, plateBBox, detectionDebug] = detectPlateRegion(preprocessedImg, originalImg);
```

If detection is incomplete, Member 3 and Member 4 can use manually cropped plate samples from:

```text
images/test/plate_samples/
```

However, the final system should use automatic plate detection as part of the full pipeline.

---

## 21. Git Notes

Recommended branch for Member 2:

```text
feature/plate-detection
```

Recommended main assigned folder:

```text
src/plate_detection/
```

Branch names are not folder names.

Correct:

```text
Git branch: feature/plate-detection
Assigned folder: src/plate_detection/
```

Incorrect:

```text
Assignment/feature/plate-detection/
```

---

## 22. Before Pull Request Checklist

Before creating a Pull Request to `dev`, Member 2 should check:

```text
[ ] I am on feature/plate-detection
[ ] I mainly edited src/plate_detection/ and related test files
[ ] I did not change core function signatures
[ ] I ran scratch/test_member2_plate_detection.m
[ ] I did not commit large raw datasets
[ ] I did not commit unnecessary output files
[ ] I used English comments and variable names
[ ] I added useful notes or screenshots for the report if needed
```

---

## 23. Notes for Claude or Codex

When generating or editing Member 2 files:

- Use MATLAB `.m` files.
- Keep function names matched with file names.
- Use English comments and variable names.
- Keep the required function signatures.
- Add safe fallback handling for empty inputs and invalid bounding boxes.
- Use classical image processing only.
- Do not use prohibited methods.
- Do not use template matching or pattern matching.
- Generate or update `scratch/test_member2_plate_detection.m`.
- Support `images/test/sample_car.jpg`.
- Return `plateImg`, `plateBBox`, and `debugInfo`.
