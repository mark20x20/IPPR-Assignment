# Member 1 Task: Dataset and Preprocessing

## 1. Purpose

This document defines the task details for Member 1.

Member 1 is responsible for dataset organization and image preprocessing for the License Plate Recognition (LPR) and State Identification System (SIS).

The goal of this task is to prepare input vehicle images and generate preprocessed images that can be used by the license plate detection module.

---

## 2. Main Responsibility

Member 1 is responsible for:

- Dataset organization
- Image acquisition support
- Dataset metadata recording
- RGB to grayscale conversion
- Contrast enhancement
- Noise reduction
- Preprocessing debug output
- Preprocessing module testing
- Preprocessing-related report content

Member 1’s output becomes the input for Member 2’s license plate detection module.

---

## 3. Assigned Folders

Member 1 should mainly work in the following folders:

```text
src/preprocessing/
images/
```

Member 1 may also update:

```text
dataset_metadata.csv
scratch/test_member1_preprocessing.m
report/figures/
```

---

## 4. Assigned Files

Member 1 is mainly responsible for the following files:

```text
src/preprocessing/preprocessImage.m
src/preprocessing/convertToGray.m
src/preprocessing/enhanceContrast.m
src/preprocessing/removeNoise.m
dataset_metadata.csv
scratch/test_member1_preprocessing.m
```

---

## 5. Related System Requirements

Member 1 is mainly related to the following system requirements:

```text
FR-01: Load Vehicle Image
FR-02: Display Original Image
FR-03: Preprocess Image
FR-12: Save Output Images
FR-15: Support Parallel Development
FR-17: Support Independent Module Testing
```

---

## 6. Related Technical Constraints

Member 1 must follow these constraints:

- Use MATLAB `.m` files.
- Use classical image processing methods.
- Use English comments and variable names.
- Do not use TensorFlow.
- Do not use Haar Cascade.
- Do not use YOLO.
- Do not use deep learning object detectors.
- Do not use template matching.
- Do not use pattern matching.
- Use relative paths where possible.
- Keep function names consistent with file names.
- Do not change agreed function signatures without team discussion.

---

## 7. Input Data

## 7.1 Main Test Image

The first test image should be:

```text
images/test/sample_car.jpg
```

This image is used for:

- Full-pipeline testing in `main.m`
- Member 1 preprocessing test
- Member 2 temporary plate detection test

---

## 7.2 Additional Dataset Folders

Member 1 may organize images in:

```text
images/raw/
images/test/success_cases/
images/test/difficult_cases/
images/test/failure_cases/
images/selected_for_report/
```

Recommended raw image folders:

```text
images/raw/car/
images/raw/motorcycle/
images/raw/bus/
images/raw/van/
images/raw/truck/
```

Core vehicle types:

```text
car
motorcycle
bus
```

Optional vehicle types:

```text
van
truck
```

---

## 8. Expected Outputs

Member 1 should produce:

```text
preprocessedImg
preprocessDebug
dataset_metadata.csv
preprocessing screenshots
```

Recommended `preprocessDebug` fields:

```matlab
preprocessDebug.grayImg
preprocessDebug.enhancedImg
preprocessDebug.filteredImg
```

These debug outputs are useful for:

- Member 2’s detection testing
- Report screenshots
- Failure analysis
- Presentation explanation

---

## 9. Required Function Signatures

Member 1 should use the following function signatures.

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

These signatures should not be changed without team discussion.

---

## 10. Function Responsibilities

## 10.1 preprocessImage.m

### Purpose

Runs the full preprocessing flow.

### Input

```text
inputImg
```

### Output

```text
preprocessedImg
debugInfo
```

### Responsibilities

- Validate input image.
- Convert image to grayscale.
- Enhance image contrast.
- Remove noise.
- Return the final preprocessed image.
- Store intermediate images in `debugInfo`.

### Internal Flow

```text
inputImg
↓
convertToGray
↓
enhanceContrast
↓
removeNoise
↓
preprocessedImg
```

### Suggested Internal Calls

```matlab
grayImg = convertToGray(inputImg);
enhancedImg = enhanceContrast(grayImg);
filteredImg = removeNoise(enhancedImg);
```

### Failure Handling

If the input image is empty, return:

```matlab
preprocessedImg = [];
debugInfo.errorMessage = "Input image is empty.";
```

---

## 10.2 convertToGray.m

### Purpose

Converts RGB image to grayscale.

If the image is already grayscale, return it unchanged.

### Input

```text
inputImg
```

### Output

```text
grayImg
```

### Suggested Logic

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

### Allowed MATLAB Functions

```matlab
rgb2gray
im2gray
```

---

## 10.3 enhanceContrast.m

### Purpose

Improves image contrast before plate detection.

### Input

```text
grayImg
```

### Output

```text
enhancedImg
```

### Allowed MATLAB Functions

```matlab
imadjust
histeq
adapthisteq
```

### Suggested First Version

Use `imadjust` first because it is simple and stable.

```matlab
enhancedImg = imadjust(grayImg);
```

### Failure Handling

If input is empty, return:

```matlab
enhancedImg = [];
```

---

## 10.4 removeNoise.m

### Purpose

Reduces image noise while preserving useful edges.

### Input

```text
grayImg
```

or:

```text
enhancedImg
```

### Output

```text
filteredImg
```

### Allowed MATLAB Functions

```matlab
medfilt2
imfilter
fspecial
```

### Suggested First Version

Use median filtering:

```matlab
filteredImg = medfilt2(grayImg, [3 3]);
```

### Failure Handling

If input is empty, return:

```matlab
filteredImg = [];
```

---

## 11. Independent Test Script

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

## 12. Suggested Test Script Flow

```text
Clear workspace
↓
Add src folder to MATLAB path
↓
Load images/test/sample_car.jpg
↓
Run preprocessImage
↓
Display original image
↓
Display grayscale image
↓
Display enhanced image
↓
Display filtered image
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

[preprocessedImg, preprocessDebug] = preprocessImage(originalImg);

figure;
subplot(2, 2, 1);
imshow(originalImg);
title('Original Image');

subplot(2, 2, 2);
imshow(preprocessDebug.grayImg);
title('Grayscale Image');

subplot(2, 2, 3);
imshow(preprocessDebug.enhancedImg);
title('Enhanced Image');

subplot(2, 2, 4);
imshow(preprocessedImg);
title('Preprocessed Image');
```

---

## 13. Testing Checklist

Before merging Member 1’s work, confirm:

```text
[ ] images/test/sample_car.jpg exists
[ ] test_member1_preprocessing.m runs
[ ] preprocessImage.m runs
[ ] convertToGray.m runs
[ ] enhanceContrast.m runs
[ ] removeNoise.m runs
[ ] preprocessedImg is returned
[ ] preprocessDebug is returned
[ ] grayscale image is generated
[ ] enhanced image is generated
[ ] filtered image is generated
[ ] empty input is handled safely
[ ] no prohibited methods are used
[ ] function signatures are unchanged
[ ] comments and variable names are in English
```

---

## 14. Dataset Metadata Responsibility

Member 1 should help maintain:

```text
dataset_metadata.csv
```

Recommended header:

```csv
image_name,image_path,vehicle_type,expected_plate_text,expected_state,plate_type,distance,lighting,background,angle,source,notes
```

Example row:

```csv
car_selangor_close_01.jpg,images/test/success_cases/car_selangor_close_01.jpg,car,BMS8147,Selangor,standard,close,daylight,simple,front,self-captured,clear plate
```

For manually cropped plate samples:

```csv
plate_selangor_01.jpg,images/test/plate_samples/plate_selangor_01.jpg,plate_sample,BMS8147,Selangor,standard,unknown,unknown,unknown,front,self-captured,manually cropped plate sample
```

---

## 15. Image Organization Responsibility

Member 1 should help organize images into:

```text
images/raw/
images/test/
images/test/success_cases/
images/test/difficult_cases/
images/test/failure_cases/
images/selected_for_report/
```

Recommended first minimum image:

```text
images/test/sample_car.jpg
```

Recommended final test categories:

```text
success_cases
difficult_cases
failure_cases
```

---

## 16. Output Saving

Member 1 may save useful preprocessing outputs into:

```text
output/figures/
report/figures/
```

or, if preprocessing-specific output organization is needed:

```text
output/segmentation/
```

However, avoid committing large output folders to GitHub unless the team agrees.

---

## 17. Report Contribution

Member 1 should contribute to the following report sections:

- Dataset collection
- Image acquisition
- Preprocessing
- Grayscale conversion
- Contrast enhancement
- Noise reduction
- Spatial filtering
- Image condition analysis
- Preprocessing success cases
- Preprocessing difficult or failure cases

---

## 18. Recommended Report Figures

Member 1 should prepare figures such as:

- Original image
- Grayscale image
- Contrast-enhanced image
- Noise-reduced image
- Comparison of before and after preprocessing

Example figure caption:

```text
Figure X. Preprocessing results showing the original image, grayscale conversion, contrast enhancement, and noise-reduced output.
```

---

## 19. Success Criteria

Member 1’s task is considered successful when:

```text
[ ] Vehicle image can be loaded
[ ] Image can be converted to grayscale
[ ] Contrast enhancement runs without error
[ ] Noise reduction runs without error
[ ] preprocessedImg is returned
[ ] preprocessDebug contains useful intermediate images
[ ] Member 2 can use preprocessedImg for plate detection
```

---

## 20. Common Problems and Fixes

| Problem | Possible Cause | Suggested Fix |
|---|---|---|
| Image not found | `sample_car.jpg` missing | Place image in `images/test/sample_car.jpg` |
| Function not found | MATLAB path not set | Use `addpath(genpath('src'))` |
| RGB/grayscale error | Channel check missing | Check `size(inputImg, 3)` |
| Image too dark | Contrast enhancement weak | Try `adapthisteq` or adjust `imadjust` |
| Too much noise remains | Filter too weak | Try median filter or Gaussian filter |
| Edges become too blurred | Filter too strong | Use smaller filter size |
| Output missing debug fields | `debugInfo` not assigned | Store intermediate outputs in struct |

---

## 21. Collaboration Notes

Member 1 should coordinate with Member 2 because plate detection depends on preprocessing output.

Member 2 expects:

```matlab
[preprocessedImg, preprocessDebug] = preprocessImage(originalImg);
```

Therefore, Member 1 should not change this output format without discussion.

If preprocessing is incomplete, Member 2 can temporarily use grayscale conversion, but the final system should call `preprocessImage`.

---

## 22. Git Notes

Recommended branch for Member 1:

```text
feature/preprocessing
```

Recommended main assigned folder:

```text
src/preprocessing/
```

Branch names are not folder names.

Correct:

```text
Git branch: feature/preprocessing
Assigned folder: src/preprocessing/
```

Incorrect:

```text
Assignment/feature/preprocessing/
```

---

## 23. Before Pull Request Checklist

Before creating a Pull Request to `dev`, Member 1 should check:

```text
[ ] I am on feature/preprocessing
[ ] I mainly edited src/preprocessing/ and related dataset files
[ ] I did not change core function signatures
[ ] I ran scratch/test_member1_preprocessing.m
[ ] I did not commit large raw datasets
[ ] I did not commit unnecessary output files
[ ] I used English comments and variable names
[ ] I added useful notes or screenshots for the report if needed
```

---

## 24. Notes for Claude or Codex

When generating or editing Member 1 files:

- Use MATLAB `.m` files.
- Keep function names matched with file names.
- Use English comments and variable names.
- Keep the required function signatures.
- Add safe fallback handling for empty inputs.
- Use classical image processing only.
- Do not use prohibited methods.
- Generate or update `scratch/test_member1_preprocessing.m`.
- Support `images/test/sample_car.jpg`.
- Return `preprocessedImg` and `debugInfo`.
