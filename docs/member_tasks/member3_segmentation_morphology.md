# Member 3 Task: Segmentation and Morphological Processing

## 1. Purpose

This document defines the task details for Member 3.

Member 3 is responsible for plate image preparation, binarization, morphological processing, and character candidate segmentation for the License Plate Recognition (LPR) and State Identification System (SIS).

The goal of this task is to prepare the cropped license plate image so that it can support OCR, visualization, report explanation, and failure analysis.

---

## 2. Main Responsibility

Member 3 is responsible for:

- Plate image binarization
- Binary image cleanup
- Morphological image processing
- Character candidate segmentation
- Character bounding box extraction
- Segmentation visualization
- Segmentation module testing
- Segmentation-related report content

Member 3’s output supports Member 4’s OCR and evaluation work.

Important note:

Character segmentation is mainly used for visualization, explanation, OCR preparation, and failure analysis.

Final text recognition should use OCR.

Character segmentation must not be used for template matching or pattern matching.

---

## 3. Assigned Folders

Member 3 should mainly work in the following folders:

```text
src/segmentation/
images/test/plate_samples/
```

Member 3 may also update:

```text
scratch/test_member3_segmentation.m
output/segmentation/
report/figures/
```

---

## 4. Assigned Files

Member 3 is mainly responsible for the following files:

```text
src/segmentation/binarizePlate.m
src/segmentation/cleanBinaryImage.m
src/segmentation/segmentCharacters.m
scratch/test_member3_segmentation.m
```

Member 3 may also help prepare manually cropped plate images in:

```text
images/test/plate_samples/
```

---

## 5. Related System Requirements

Member 3 is mainly related to the following system requirements:

```text
FR-06: Prepare Plate Image for OCR
FR-07: Segment Character Regions
FR-12: Save Output Images
FR-15: Support Parallel Development
FR-17: Support Independent Module Testing
```

---

## 6. Related Technical Constraints

Member 3 must follow these constraints:

- Use MATLAB `.m` files.
- Use classical image processing methods.
- Use English comments and variable names.
- Do not use TensorFlow.
- Do not use Haar Cascade.
- Do not use YOLO.
- Do not use deep learning object detectors.
- Do not use template matching.
- Do not use pattern matching.
- Do not use character recognition by comparing with fixed template images.
- Use relative paths where possible.
- Keep function names consistent with file names.
- Do not change agreed function signatures without team discussion.
- Return safe fallback outputs if segmentation fails.

---

## 7. Input Data

## 7.1 Final Pipeline Input

In the final system, Member 3 receives:

```text
plateImg
```

from Member 2’s plate detection module.

Expected call:

```matlab
[characterImages, characterBBoxes] = segmentCharacters(plateImg);
```

---

## 7.2 Temporary Development Input

If Member 2’s plate detection module is not completed, Member 3 should use manually cropped plate images from:

```text
images/test/plate_samples/
```

Example files:

```text
images/test/plate_samples/plate_selangor_01.jpg
images/test/plate_samples/plate_penang_01.jpg
images/test/plate_samples/plate_malacca_01.jpg
```

Example MATLAB input:

```matlab
plateImg = imread('images/test/plate_samples/plate_selangor_01.jpg');
```

This allows Member 3 to work without waiting for Member 2.

---

## 7.3 Test Plate Sample Types

Useful plate sample images include:

- Clear cropped plate
- Slightly noisy plate
- Low contrast plate
- Plate with shadow
- Plate with reflection
- Plate with touching characters
- Plate with two-row format if available
- Plate with extra background included

These samples help test whether binarization and morphological processing are stable.

---

## 8. Expected Outputs

Member 3 should produce:

```text
binaryPlateImg
cleanedImg
characterImages
characterBBoxes
```

Where:

- `binaryPlateImg` is the thresholded plate image.
- `cleanedImg` is the morphologically cleaned binary image.
- `characterImages` is a cell array of cropped character candidate images.
- `characterBBoxes` is an array of character bounding boxes.

These outputs are useful for:

- Member 4’s OCR preparation
- Report screenshots
- Failure analysis
- Presentation explanation
- Demonstrating image processing concepts

---

## 9. Required Function Signatures

Member 3 should use the following function signatures.

```matlab
function binaryPlateImg = binarizePlate(plateImg)
```

```matlab
function cleanedImg = cleanBinaryImage(binaryImg)
```

```matlab
function [characterImages, characterBBoxes] = segmentCharacters(plateImg)
```

These signatures should not be changed without team discussion.

---

## 10. Function Responsibilities

## 10.1 binarizePlate.m

### Purpose

Converts a cropped license plate image into a binary image.

### Input

```text
plateImg
```

### Output

```text
binaryPlateImg
```

### Responsibilities

- Validate input image.
- Convert RGB plate image to grayscale if needed.
- Enhance contrast if needed.
- Apply thresholding or adaptive thresholding.
- Return a binary image.
- Return empty output if the input is invalid.

### Recommended Processing Flow

```text
plateImg
↓
convert to grayscale if needed
↓
contrast enhancement if needed
↓
thresholding
↓
binaryPlateImg
```

### Allowed MATLAB Functions

```matlab
rgb2gray
im2gray
imadjust
adapthisteq
graythresh
imbinarize
adaptthresh
imcomplement
```

### Failure Handling

If `plateImg` is empty, return:

```matlab
binaryPlateImg = [];
```

---

## 10.2 cleanBinaryImage.m

### Purpose

Cleans a binary plate image using morphological operations.

### Input

```text
binaryImg
```

### Output

```text
cleanedImg
```

### Responsibilities

- Validate binary input.
- Remove small noise.
- Fill small holes if useful.
- Apply morphological opening or closing.
- Improve character visibility.
- Return empty output if the input is invalid.

### Recommended Processing Flow

```text
binaryImg
↓
remove small components
↓
morphological open or close
↓
fill holes if needed
↓
cleanedImg
```

### Allowed MATLAB Functions

```matlab
strel
imopen
imclose
imdilate
imerode
imfill
bwareaopen
```

### Failure Handling

If `binaryImg` is empty, return:

```matlab
cleanedImg = [];
```

---

## 10.3 segmentCharacters.m

### Purpose

Segments possible character regions from a license plate image.

### Input

```text
plateImg
```

### Output

```text
characterImages
characterBBoxes
```

### Responsibilities

- Validate plate image.
- Binarize the plate image.
- Clean the binary image.
- Find connected components.
- Extract region properties.
- Filter possible character candidates.
- Sort character candidates from left to right.
- Return character candidate images and bounding boxes.
- Return safe fallback outputs if segmentation fails.

### Recommended Processing Flow

```text
plateImg
↓
binarizePlate
↓
cleanBinaryImage
↓
connected component analysis
↓
region property filtering
↓
sort left to right
↓
characterImages and characterBBoxes
```

### Internal Function Calls

```matlab
binaryPlateImg = binarizePlate(plateImg);
cleanedImg = cleanBinaryImage(binaryPlateImg);
```

### Allowed MATLAB Functions

```matlab
bwconncomp
bwlabel
regionprops
imcrop
sortrows
```

### Candidate Filtering Criteria

Possible criteria:

- Area
- Width
- Height
- Aspect ratio
- Character height relative to plate height
- Character width relative to plate width
- Bounding box position
- Removal of very small noise objects
- Removal of very large non-character regions

### Failure Handling

If no characters are detected, return:

```matlab
characterImages = {};
characterBBoxes = [];
```

---

## 11. Independent Test Script

Member 3 should use:

```text
scratch/test_member3_segmentation.m
```

This script should test:

- `binarizePlate.m`
- `cleanBinaryImage.m`
- `segmentCharacters.m`

---

## 12. Suggested Test Script Flow

```text
Clear workspace
↓
Add src folder to MATLAB path
↓
Load manually cropped plate image from images/test/plate_samples/
↓
Run binarizePlate
↓
Run cleanBinaryImage
↓
Run segmentCharacters
↓
Display cropped plate image
↓
Display binary plate image
↓
Display cleaned binary image
↓
Display character candidate boxes if available
↓
Save outputs if needed
```

Suggested MATLAB flow:

```matlab
clc;
clear;
close all;

addpath(genpath('src'));

platePath = fullfile('images', 'test', 'plate_samples', 'plate_selangor_01.jpg');

if ~isfile(platePath)
    error('Plate sample not found: %s', platePath);
end

plateImg = imread(platePath);

binaryPlateImg = binarizePlate(plateImg);
cleanedImg = cleanBinaryImage(binaryPlateImg);
[characterImages, characterBBoxes] = segmentCharacters(plateImg);

figure;
subplot(1, 3, 1);
imshow(plateImg);
title('Plate Image');

subplot(1, 3, 2);
imshow(binaryPlateImg);
title('Binary Plate');

subplot(1, 3, 3);
imshow(cleanedImg);
title('Cleaned Binary');

if ~isempty(characterBBoxes)
    figure;
    imshow(plateImg);
    title('Character Candidate Boxes');
    hold on;

    for i = 1:size(characterBBoxes, 1)
        rectangle('Position', characterBBoxes(i, :), 'EdgeColor', 'r', 'LineWidth', 1);
    end

    hold off;
else
    disp('No character candidates found. Safe fallback returned.');
end
```

---

## 13. Testing Checklist

Before merging Member 3’s work, confirm:

```text
[ ] images/test/plate_samples/ exists
[ ] at least one manually cropped plate sample exists
[ ] test_member3_segmentation.m runs
[ ] binarizePlate.m runs
[ ] cleanBinaryImage.m runs
[ ] segmentCharacters.m runs
[ ] binaryPlateImg is returned or safely empty
[ ] cleanedImg is returned or safely empty
[ ] characterImages is returned or safely empty
[ ] characterBBoxes is returned or safely empty
[ ] empty input is handled safely
[ ] no prohibited methods are used
[ ] no template matching or pattern matching is used
[ ] function signatures are unchanged
[ ] comments and variable names are in English
```

---

## 14. Output Saving

Member 3 may save useful segmentation outputs into:

```text
output/segmentation/
report/figures/
```

Useful output examples:

```text
output/segmentation/plate_selangor_01_binary.jpg
output/segmentation/plate_selangor_01_cleaned.jpg
output/segmentation/plate_selangor_01_char_candidates.jpg
```

Avoid committing large output folders to GitHub unless the team agrees.

---

## 15. Report Contribution

Member 3 should contribute to the following report sections:

- Thresholding
- Binarization
- Morphological image processing
- Connected component analysis
- Character candidate segmentation
- OCR preparation
- Segmentation success cases
- Segmentation difficult cases
- Segmentation failure cases

---

## 16. Recommended Report Figures

Member 3 should prepare figures such as:

- Cropped plate sample
- Binary plate image
- Cleaned binary image
- Character candidate bounding boxes
- Comparison of successful and failed segmentation cases

Example figure caption:

```text
Figure X. Plate image preparation process showing the cropped plate image, binary image, cleaned binary image, and extracted character candidate regions.
```

---

## 17. Success Criteria

Member 3’s task is considered successful when:

```text
[ ] binarizePlate.m runs without syntax errors
[ ] cleanBinaryImage.m runs without syntax errors
[ ] segmentCharacters.m runs without syntax errors
[ ] Binary or cleaned plate image is generated
[ ] Character candidates are returned or safely empty
[ ] The system does not crash when plateImg is empty
[ ] The output can support OCR preparation or report explanation
[ ] No template matching or pattern matching is used
```

---

## 18. Failure Case Analysis

Member 3 should keep and analyze difficult or failed segmentation cases.

Common failure causes:

- Plate crop is too blurry.
- Plate crop has low contrast.
- Plate contains strong reflection.
- Plate text is too small.
- Plate text is connected to the border.
- Thresholding removes useful character strokes.
- Morphological cleaning removes thin character parts.
- Morphological closing merges separate characters.
- Noise is detected as character candidates.
- Character candidates are not sorted correctly.
- Plate contains two-row text layout.

Example analysis sentence:

```text
In this case, the segmentation module failed because the thresholding step removed thin character strokes under low-light conditions. As a result, the connected component analysis could not identify complete character candidates.
```

Another example:

```text
The morphological closing operation connected neighboring characters too strongly, causing multiple characters to be detected as one component. This reduced the usefulness of the segmentation result for OCR preparation.
```

---

## 19. Common Problems and Fixes

| Problem | Possible Cause | Suggested Fix |
|---|---|---|
| Function not found | MATLAB path not set | Use `addpath(genpath('src'))` |
| Plate sample not found | `plate_samples/` is empty | Add cropped plate image |
| Binary image too noisy | Thresholding not suitable | Try adaptive thresholding |
| Characters disappear | Morphology too strong | Reduce structuring element size |
| Characters merge together | Closing or dilation too strong | Reduce dilation/closing strength |
| Too many small components | Noise remains | Use `bwareaopen` |
| No characters detected | Filtering too strict | Adjust size and aspect ratio filters |
| OCR still fails | Plate image quality poor | Improve binarization or use better plate crop |

---

## 20. Collaboration Notes

Member 3 should coordinate with Member 2 because segmentation depends on the cropped plate image.

Member 3 expects:

```matlab
[plateImg, plateBBox, detectionDebug] = detectPlateRegion(preprocessedImg, originalImg);
```

If Member 2’s module is incomplete, Member 3 should use manually cropped plate samples from:

```text
images/test/plate_samples/
```

Member 3 should also coordinate with Member 4 because OCR may use the plate image prepared or cleaned by the segmentation process.

However, final OCR should still be handled by Member 4.

---

## 21. Git Notes

Recommended branch for Member 3:

```text
feature/segmentation-morphology
```

Recommended main assigned folder:

```text
src/segmentation/
```

Branch names are not folder names.

Correct:

```text
Git branch: feature/segmentation-morphology
Assigned folder: src/segmentation/
```

Incorrect:

```text
Assignment/feature/segmentation-morphology/
```

---

## 22. Before Pull Request Checklist

Before creating a Pull Request to `dev`, Member 3 should check:

```text
[ ] I am on feature/segmentation-morphology
[ ] I mainly edited src/segmentation/ and related test files
[ ] I did not change core function signatures
[ ] I ran scratch/test_member3_segmentation.m
[ ] I did not commit large raw datasets
[ ] I did not commit unnecessary output files
[ ] I used English comments and variable names
[ ] I did not use template matching or pattern matching
[ ] I added useful notes or screenshots for the report if needed
```

---

## 23. Notes for Claude or Codex

When generating or editing Member 3 files:

- Use MATLAB `.m` files.
- Keep function names matched with file names.
- Use English comments and variable names.
- Keep the required function signatures.
- Add safe fallback handling for empty inputs and missing plate samples.
- Use classical image processing only.
- Do not use prohibited methods.
- Do not use template matching or pattern matching.
- Generate or update `scratch/test_member3_segmentation.m`.
- Support `images/test/plate_samples/`.
- Return `characterImages` and `characterBBoxes`.
