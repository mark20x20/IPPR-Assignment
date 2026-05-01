# Function Design

## 1. Purpose

This document defines the function design for the License Plate Recognition (LPR) and State Identification System (SIS).

The purpose of this document is to clarify:

- What files should be created
- What each function is responsible for
- What inputs each function receives
- What outputs each function returns
- How the functions connect to each other in the MATLAB pipeline
- How each member can test their assigned module independently
- How placeholder outputs should be handled during early development

This document also supports parallel development. Each member should be able to work on their assigned functional folder without waiting for all previous modules to be fully completed.

---

## 2. Design Principles

## 2.1 Function-Based Design

The project should be divided into multiple MATLAB function files.

Each function should have one clear responsibility.

This makes the project:

- Easier to debug
- Easier to explain in the report
- Easier to share with teammates
- Easier to modify later
- Easier to test independently

---

## 2.2 File Name and Function Name Rule

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

## 2.3 Comment and Naming Rule

All code comments, variable names, function names, and documentation should be written in English.

Recommended naming examples:

```matlab
originalImg
preprocessedImg
plateImg
binaryPlateImg
cleanedImg
rawText
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

## 2.4 Error Handling Rule

Each function should handle invalid input where necessary.

Examples:

- Empty image
- Invalid bounding box
- Failed plate detection
- OCR unavailable
- Empty OCR result
- Unknown state prefix
- Missing test image
- Missing plate sample image

The system should return `UNKNOWN`, an empty array, or an empty cell array instead of crashing.

Recommended fallback examples:

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

## 2.5 Function Interface Stability Rule

Function signatures should remain stable after the skeleton is created.

This is important because all members work on different modules in parallel.

Core function signatures:

```matlab
[preprocessedImg, preprocessDebug] = preprocessImage(originalImg);

[plateImg, plateBBox, detectionDebug] = detectPlateRegion(preprocessedImg, originalImg);

[characterImages, characterBBoxes] = segmentCharacters(plateImg);

rawText = recognizePlateText(plateImg);

cleanedText = cleanRecognizedText(rawText);

stateName = identifyState(cleanedText);
```

If a function signature must be changed, the team should discuss it first.

---

## 2.6 Parallel Development Rule

The final pipeline has a sequential dependency:

```text
Preprocessing
↓
Plate Detection
↓
Segmentation and Morphology
↓
OCR, State Identification, GUI, and Evaluation
```

However, members should not be blocked while waiting for previous modules to be completed.

To support parallel development, the project should include:

- Shared skeleton files
- Fixed function signatures
- Placeholder outputs
- Safe fallback values
- Sample vehicle image
- Manually cropped plate sample images
- Scratch test scripts

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

# 3. Overall Function Flow

The complete system should follow this function flow:

```text
main.m or launch_gui.m
↓
ensureOutputFolders
↓
imread
↓
preprocessImage
↓
detectPlateRegion
↓
segmentCharacters
↓
recognizePlateText
↓
cleanRecognizedText
↓
identifyState
↓
displayPipelineResults
```

Detailed flow:

```text
Input vehicle image
↓
convertToGray
↓
enhanceContrast
↓
removeNoise
↓
detectPlateRegion
↓
selectPlateCandidate
↓
cropPlateRegion
↓
binarizePlate
↓
cleanBinaryImage
↓
segmentCharacters
↓
recognizePlateText
↓
cleanRecognizedText
↓
identifyState
↓
displayPipelineResults
```

---

# 4. Root-Level Files

---

## 4.1 main.m

## Purpose

`main.m` is the main script for testing the full pipeline with a sample image.

It is mainly used during development to check whether all functions are connected correctly.

## File Type

```text
MATLAB script
```

## Responsibilities

`main.m` should:

1. Clear the command window and workspace.
2. Close existing figures.
3. Add all `src` folders to MATLAB path.
4. Create required output folders.
5. Load one sample image.
6. Run the full LPR and SIS pipeline.
7. Display results.
8. Print recognized text and state to the Command Window.
9. Handle fallback outputs without crashing.

## Input

No direct user input.

The script should load:

```text
images/test/sample_car.jpg
```

## Output

- Displayed result figure
- Command Window output
- Optional saved output images

## Suggested Call Flow

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

## Failure Handling

If plate detection fails:

```matlab
plateImg = [];
plateBBox = [];
```

If OCR fails:

```matlab
rawText = "UNKNOWN";
cleanedText = "UNKNOWN";
stateName = "UNKNOWN";
```

`main.m` should still display the original image and final fallback result.

---

## 4.2 launch_gui.m

## Purpose

`launch_gui.m` launches the MATLAB GUI for the LPR and SIS system.

## File Type

```text
MATLAB script or main GUI function
```

## Responsibilities

`launch_gui.m` should:

1. Add all `src` folders to MATLAB path.
2. Create a GUI window.
3. Provide a Load Image button.
4. Provide a Run Recognition button.
5. Display the original image.
6. Display the detected plate image.
7. Display recognized text.
8. Display identified state.
9. Display status messages.
10. Handle errors gracefully.
11. Support placeholder outputs when some modules are incomplete.

## Input

User-selected image through GUI.

## Output

GUI display.

## Required GUI Controls

- Load Image button
- Run Recognition button
- Original image axes
- Detected plate axes
- Recognized text field
- Identified state field
- Status field

## Notes

The GUI should call the same pipeline functions used by `main.m`.

The GUI should not duplicate image processing logic inside callback functions.

---

## 4.3 README.md

## Purpose

`README.md` explains the project to teammates and reviewers.

## Responsibilities

The README should include:

- Project title
- Project objective
- Development environment
- Folder structure
- How to run `main.m`
- How to run `launch_gui.m`
- How to run scratch test scripts
- Required MATLAB toolboxes
- Notes about prohibited methods
- Basic troubleshooting

---

## 4.4 CONTRIBUTING.md

## Purpose

`CONTRIBUTING.md` explains how group members should collaborate.

## Responsibilities

The file should include:

- Git branch strategy
- Feature-based folder responsibility
- How to commit and push changes
- How to merge into `dev`
- Files that should not be committed
- Rule that branch names are not folder names
- Rule that function signatures should not be changed without discussion

---

## 4.5 results_template.csv

## Purpose

`results_template.csv` defines the structure for recording test results.

## Recommended Columns

```csv
image_name,vehicle_type,expected_text,ocr_text,expected_state,predicted_state,detection_result,ocr_result,state_result,overall_result,notes
```

The `overall_result` column should be included to keep evaluation results consistent across all documents.

---

## 4.6 dataset_metadata.csv

## Purpose

`dataset_metadata.csv` defines metadata for the dataset images.

## Recommended Columns

```csv
image_name,image_path,vehicle_type,expected_plate_text,expected_state,plate_type,distance,lighting,background,angle,source,notes
```

---

# 5. Scratch Test Files

Folder:

```text
scratch/
```

---

## 5.1 Purpose

The `scratch` folder stores member-specific test scripts.

These scripts allow each member to test their assigned module independently.

They are not the final system entry points.

The final system entry points are:

```text
main.m
launch_gui.m
```

---

## 5.2 Required Scratch Scripts

```text
scratch/test_member1_preprocessing.m
scratch/test_member2_plate_detection.m
scratch/test_member3_segmentation.m
scratch/test_member4_recognition_gui.m
```

---

## 5.3 test_member1_preprocessing.m

## Purpose

Tests the preprocessing functions independently.

## Assigned Member

```text
Member 1
```

## Related Folder

```text
src/preprocessing/
```

## Input

```text
images/test/sample_car.jpg
```

## Functions to Test

```text
preprocessImage.m
convertToGray.m
enhanceContrast.m
removeNoise.m
```

## Expected Output

- Original image
- Grayscale image
- Contrast-enhanced image
- Noise-reduced image
- `preprocessDebug`

## Suggested Flow

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
subplot(1, 3, 1);
imshow(preprocessDebug.grayImg);
title('Grayscale');

subplot(1, 3, 2);
imshow(preprocessDebug.enhancedImg);
title('Enhanced');

subplot(1, 3, 3);
imshow(preprocessedImg);
title('Preprocessed');
```

---

## 5.4 test_member2_plate_detection.m

## Purpose

Tests the plate detection functions independently.

## Assigned Member

```text
Member 2
```

## Related Folder

```text
src/plate_detection/
```

## Input

```text
images/test/sample_car.jpg
```

## Functions to Test

```text
detectPlateRegion.m
selectPlateCandidate.m
cropPlateRegion.m
```

## Temporary Input Strategy

If Member 1's preprocessing module is not completed, this test script may create a temporary grayscale image.

```matlab
originalImg = imread('images/test/sample_car.jpg');

if size(originalImg, 3) == 3
    preprocessedImg = rgb2gray(originalImg);
else
    preprocessedImg = originalImg;
end
```

## Expected Output

- Edge image or candidate image
- Plate bounding box or empty fallback
- Cropped plate image or empty fallback
- `detectionDebug`

## Suggested Flow

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

if ~isempty(plateImg)
    figure;
    imshow(plateImg);
    title('Detected Plate');
else
    disp('No plate detected. Safe fallback returned.');
end
```

---

## 5.5 test_member3_segmentation.m

## Purpose

Tests the segmentation and morphology functions independently.

## Assigned Member

```text
Member 3
```

## Related Folder

```text
src/segmentation/
```

## Input

```text
images/test/plate_samples/
```

## Functions to Test

```text
binarizePlate.m
cleanBinaryImage.m
segmentCharacters.m
```

## Expected Output

- Binary plate image
- Cleaned binary image
- Character candidate images
- Character bounding boxes

## Suggested Flow

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
```

---

## 5.6 test_member4_recognition_gui.m

## Purpose

Tests recognition, state identification, GUI-related utilities, and evaluation functions independently.

## Assigned Member

```text
Member 4
```

## Related Folders

```text
src/recognition/
src/evaluation/
src/utils/
```

## Related Root File

```text
launch_gui.m
```

## Input

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

## Functions to Test

```text
recognizePlateText.m
cleanRecognizedText.m
identifyState.m
displayPipelineResults.m
saveStepImage.m
ensureOutputFolders.m
evaluateSingleImage.m
saveResultRow.m
```

## Expected Output

- OCR text or `UNKNOWN`
- Cleaned text
- Identified state or `UNKNOWN`
- Display output
- Evaluation row if needed
- GUI launch test

## Suggested Flow

```matlab
clc;
clear;
close all;

addpath(genpath('src'));

ensureOutputFolders();

rawText = "BMS8147";

cleanedText = cleanRecognizedText(rawText);
stateName = identifyState(cleanedText);

fprintf('Cleaned Text: %s\n', cleanedText);
fprintf('State Name: %s\n', stateName);

platePath = fullfile('images', 'test', 'plate_samples', 'plate_selangor_01.jpg');

if isfile(platePath)
    plateImg = imread(platePath);
    rawOcrText = recognizePlateText(plateImg);
    cleanedOcrText = cleanRecognizedText(rawOcrText);
    stateFromOcr = identifyState(cleanedOcrText);

    figure;
    imshow(plateImg);
    title("Plate OCR Test: " + cleanedOcrText + " / " + stateFromOcr);
else
    disp('No plate sample found. OCR image test skipped.');
end
```

---

# 6. Preprocessing Functions

Folder:

```text
src/preprocessing/
```

Assigned member:

```text
Member 1
```

---

## 6.1 preprocessImage.m

## Purpose

Runs the full preprocessing flow for an input image.

## Function Signature

```matlab
function [preprocessedImg, debugInfo] = preprocessImage(inputImg)
```

## Input

| Name | Type | Description |
|---|---|---|
| `inputImg` | image matrix | Original RGB or grayscale image |

## Output

| Name | Type | Description |
|---|---|---|
| `preprocessedImg` | image matrix | Image prepared for plate detection |
| `debugInfo` | struct | Intermediate preprocessing results |

## Responsibilities

- Validate input image
- Convert image to grayscale
- Enhance image contrast
- Remove noise
- Store intermediate results in `debugInfo`

## Internal Function Calls

```matlab
grayImg = convertToGray(inputImg);
enhancedImg = enhanceContrast(grayImg);
filteredImg = removeNoise(enhancedImg);
```

## Debug Information

Recommended `debugInfo` fields:

```matlab
debugInfo.grayImg
debugInfo.enhancedImg
debugInfo.filteredImg
```

## Failure Handling

If input image is empty:

```matlab
preprocessedImg = [];
debugInfo.errorMessage = "Input image is empty.";
```

---

## 6.2 convertToGray.m

## Purpose

Converts an RGB image to grayscale.

If the input image is already grayscale, it returns the image unchanged.

## Function Signature

```matlab
function grayImg = convertToGray(inputImg)
```

## Input

| Name | Type | Description |
|---|---|---|
| `inputImg` | image matrix | RGB or grayscale image |

## Output

| Name | Type | Description |
|---|---|---|
| `grayImg` | image matrix | Grayscale image |

## Responsibilities

- Check the number of image channels
- Convert RGB image using `rgb2gray` or `im2gray`
- Return grayscale image

## Suggested Logic

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

## 6.3 enhanceContrast.m

## Purpose

Improves image contrast before plate detection.

## Function Signature

```matlab
function enhancedImg = enhanceContrast(grayImg)
```

## Input

| Name | Type | Description |
|---|---|---|
| `grayImg` | image matrix | Grayscale image |

## Output

| Name | Type | Description |
|---|---|---|
| `enhancedImg` | image matrix | Contrast-enhanced image |

## Responsibilities

- Improve contrast
- Make plate edges and characters more visible
- Prepare image for edge detection and thresholding

## Possible MATLAB Functions

```matlab
imadjust
histeq
adapthisteq
```

## Suggested Initial Method

Use `imadjust` for the first version because it is simple and stable.

## Failure Handling

If input is empty:

```matlab
enhancedImg = [];
```

---

## 6.4 removeNoise.m

## Purpose

Reduces noise from the grayscale image.

## Function Signature

```matlab
function filteredImg = removeNoise(grayImg)
```

## Input

| Name | Type | Description |
|---|---|---|
| `grayImg` | image matrix | Grayscale or enhanced image |

## Output

| Name | Type | Description |
|---|---|---|
| `filteredImg` | image matrix | Noise-reduced image |

## Responsibilities

- Reduce small noise
- Preserve useful edges
- Prepare image for plate detection

## Possible MATLAB Functions

```matlab
medfilt2
imfilter
fspecial
```

## Suggested Initial Method

Use median filtering:

```matlab
filteredImg = medfilt2(grayImg, [3 3]);
```

## Failure Handling

If input is empty:

```matlab
filteredImg = [];
```

---

# 7. Plate Detection Functions

Folder:

```text
src/plate_detection/
```

Assigned member:

```text
Member 2
```

---

## 7.1 detectPlateRegion.m

## Purpose

Detects the most likely license plate region from a vehicle image.

## Function Signature

```matlab
function [plateImg, plateBBox, debugInfo] = detectPlateRegion(preprocessedImg, originalImg)
```

## Input

| Name | Type | Description |
|---|---|---|
| `preprocessedImg` | image matrix | Preprocessed grayscale image |
| `originalImg` | image matrix | Original vehicle image |

## Output

| Name | Type | Description |
|---|---|---|
| `plateImg` | image matrix | Cropped license plate image |
| `plateBBox` | numeric array | Bounding box of detected plate |
| `debugInfo` | struct | Intermediate detection results |

## Responsibilities

- Validate input
- Detect edges
- Apply morphological operations
- Remove small objects
- Find connected components
- Extract region properties
- Select best plate candidate
- Crop plate region

## Suggested Processing Steps

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
regionprops
↓
selectPlateCandidate
↓
cropPlateRegion
```

## Possible MATLAB Functions

```matlab
edge
strel
imclose
imfill
bwareaopen
bwconncomp
regionprops
```

## Internal Function Calls

```matlab
plateBBox = selectPlateCandidate(regions, size(preprocessedImg));
plateImg = cropPlateRegion(originalImg, plateBBox);
```

## Debug Information

Recommended `debugInfo` fields:

```matlab
debugInfo.edgeImg
debugInfo.closedImg
debugInfo.filledImg
debugInfo.cleanedImg
debugInfo.regions
```

## Failure Handling

If no valid plate candidate is found:

```matlab
plateImg = [];
plateBBox = [];
debugInfo.status = "No valid plate candidate found.";
```

The recognition stage should later return `UNKNOWN`.

---

## 7.2 selectPlateCandidate.m

## Purpose

Selects the most likely license plate candidate from detected regions.

## Function Signature

```matlab
function bestBBox = selectPlateCandidate(regions, imageSize)
```

## Input

| Name | Type | Description |
|---|---|---|
| `regions` | struct array | Region properties from `regionprops` |
| `imageSize` | numeric array | Size of the image |

## Output

| Name | Type | Description |
|---|---|---|
| `bestBBox` | numeric array | Best bounding box candidate |

## Responsibilities

- Loop through candidate regions
- Filter invalid regions
- Calculate aspect ratio
- Score candidates
- Return best candidate bounding box

## Candidate Filtering Criteria

Possible criteria:

- Area is within reasonable range
- Width is larger than height
- Aspect ratio is plate-like
- Bounding box is not too small
- Bounding box is inside image boundaries

## Suggested Aspect Ratio Range

```text
2.0 to 6.0
```

## Suggested Output When Failed

```matlab
bestBBox = [];
```

---

## 7.3 cropPlateRegion.m

## Purpose

Crops the detected plate region from the original image.

## Function Signature

```matlab
function plateImg = cropPlateRegion(originalImg, plateBBox)
```

## Input

| Name | Type | Description |
|---|---|---|
| `originalImg` | image matrix | Original vehicle image |
| `plateBBox` | numeric array | Bounding box `[x y width height]` |

## Output

| Name | Type | Description |
|---|---|---|
| `plateImg` | image matrix | Cropped plate image |

## Responsibilities

- Validate bounding box
- Ensure bounding box is inside image boundary
- Crop the plate region
- Return empty image if invalid

## Possible MATLAB Function

```matlab
imcrop
```

## Failure Handling

If `plateBBox` is empty or invalid:

```matlab
plateImg = [];
```

---

# 8. Segmentation Functions

Folder:

```text
src/segmentation/
```

Assigned member:

```text
Member 3
```

---

## 8.1 binarizePlate.m

## Purpose

Converts the cropped license plate image into a binary image.

## Function Signature

```matlab
function binaryPlateImg = binarizePlate(plateImg)
```

## Input

| Name | Type | Description |
|---|---|---|
| `plateImg` | image matrix | Cropped license plate image |

## Output

| Name | Type | Description |
|---|---|---|
| `binaryPlateImg` | logical matrix | Binary plate image |

## Responsibilities

- Convert plate image to grayscale
- Enhance contrast if necessary
- Apply thresholding
- Return binary image

## Possible MATLAB Functions

```matlab
rgb2gray
im2gray
graythresh
imbinarize
adaptthresh
```

## Failure Handling

If `plateImg` is empty:

```matlab
binaryPlateImg = [];
```

---

## 8.2 cleanBinaryImage.m

## Purpose

Cleans a binary image using morphological operations.

## Function Signature

```matlab
function cleanedImg = cleanBinaryImage(binaryImg)
```

## Input

| Name | Type | Description |
|---|---|---|
| `binaryImg` | logical matrix | Binary image |

## Output

| Name | Type | Description |
|---|---|---|
| `cleanedImg` | logical matrix | Cleaned binary image |

## Responsibilities

- Remove small noise
- Fill holes
- Apply morphological opening or closing
- Improve character visibility

## Possible MATLAB Functions

```matlab
strel
imopen
imclose
imfill
bwareaopen
```

## Failure Handling

If `binaryImg` is empty:

```matlab
cleanedImg = [];
```

---

## 8.3 segmentCharacters.m

## Purpose

Segments possible character regions from the license plate image.

## Function Signature

```matlab
function [characterImages, characterBBoxes] = segmentCharacters(plateImg)
```

## Input

| Name | Type | Description |
|---|---|---|
| `plateImg` | image matrix | Cropped plate image |

## Output

| Name | Type | Description |
|---|---|---|
| `characterImages` | cell array | Cropped character candidates |
| `characterBBoxes` | numeric array | Character bounding boxes |

## Responsibilities

- Binarize plate image
- Clean binary image
- Find connected components
- Extract region properties
- Filter possible character regions
- Sort characters from left to right
- Return character images and bounding boxes

## Internal Function Calls

```matlab
binaryPlateImg = binarizePlate(plateImg);
cleanedImg = cleanBinaryImage(binaryPlateImg);
```

## Possible MATLAB Functions

```matlab
bwconncomp
regionprops
imcrop
sortrows
```

## Failure Handling

If no characters are detected:

```matlab
characterImages = {};
characterBBoxes = [];
```

## Important Note

The project may still use OCR for final text recognition.

Character segmentation is useful for visualization, explanation, OCR preparation, and failure analysis.

Character segmentation should not be used for template-based character matching.

Final text recognition should use OCR, not template matching or pattern matching.

---

# 9. Recognition Functions

Folder:

```text
src/recognition/
```

Assigned member:

```text
Member 4
```

---

## 9.1 recognizePlateText.m

## Purpose

Recognizes license plate text using OCR.

## Function Signature

```matlab
function rawText = recognizePlateText(plateImg)
```

## Input

| Name | Type | Description |
|---|---|---|
| `plateImg` | image matrix | Cropped or processed license plate image |

## Output

| Name | Type | Description |
|---|---|---|
| `rawText` | string | Raw OCR output |

## Responsibilities

- Validate input image
- Prepare image for OCR if needed
- Check OCR availability
- Run OCR
- Return raw OCR text
- Handle OCR failure

## Possible MATLAB Function

```matlab
ocr
```

## Failure Handling

If OCR is unavailable, fails, or returns empty text:

```matlab
rawText = "UNKNOWN";
```

## Important Rule

OCR should be applied to the detected plate image, not directly to the full original vehicle image.

---

## 9.2 cleanRecognizedText.m

## Purpose

Cleans raw OCR text.

## Function Signature

```matlab
function cleanedText = cleanRecognizedText(rawText)
```

## Input

| Name | Type | Description |
|---|---|---|
| `rawText` | string or char | Raw OCR output |

## Output

| Name | Type | Description |
|---|---|---|
| `cleanedText` | string | Cleaned plate text |

## Responsibilities

- Convert text to uppercase
- Remove spaces
- Remove line breaks
- Remove punctuation
- Keep only alphanumeric characters
- Return `UNKNOWN` if result is empty

## Possible MATLAB Functions

```matlab
upper
regexprep
strtrim
string
```

## Example

```text
Raw text:
"B M S 8147"

Cleaned text:
"BMS8147"
```

## Failure Handling

If input is empty:

```matlab
cleanedText = "UNKNOWN";
```

---

## 9.3 identifyState.m

## Purpose

Identifies the registered Malaysian state based on the plate prefix.

## Function Signature

```matlab
function stateName = identifyState(cleanedText)
```

## Input

| Name | Type | Description |
|---|---|---|
| `cleanedText` | string | Cleaned plate text |

## Output

| Name | Type | Description |
|---|---|---|
| `stateName` | string | Identified state name |

## Responsibilities

- Validate cleaned text
- Extract first character or prefix
- Match prefix with state mapping
- Return state name
- Return `UNKNOWN` if prefix is not recognized

## Example Mapping

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

## Example

```text
Input:
BMS8147

Prefix:
B

Output:
Selangor
```

## Failure Handling

If input is empty, `UNKNOWN`, or not recognized:

```matlab
stateName = "UNKNOWN";
```

---

# 10. Evaluation Functions

Folder:

```text
src/evaluation/
```

Assigned member:

```text
Member 4
```

---

## 10.1 evaluateSingleImage.m

## Purpose

Runs the full pipeline on one test image and compares the result with expected values.

## Function Signature

```matlab
function resultRow = evaluateSingleImage(imagePath, expectedText, expectedState, vehicleType)
```

## Input

| Name | Type | Description |
|---|---|---|
| `imagePath` | string or char | Path to test image |
| `expectedText` | string | Expected plate text |
| `expectedState` | string | Expected registered state |
| `vehicleType` | string | Vehicle type |

## Output

| Name | Type | Description |
|---|---|---|
| `resultRow` | table or struct | Evaluation result |

## Responsibilities

- Load image
- Run full pipeline
- Compare OCR result with expected text
- Compare predicted state with expected state
- Record detection result
- Record OCR result
- Record state result
- Record overall result
- Record notes if failure occurs

## Suggested Output Fields

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

## Failure Handling

If the image cannot be loaded, return a result row with:

```text
detection_result = Failure
ocr_result = UNKNOWN
state_result = UNKNOWN
overall_result = Failure
```

---

## 10.2 saveResultRow.m

## Purpose

Saves or appends one evaluation result to a CSV file.

## Function Signature

```matlab
function saveResultRow(resultRow, csvPath)
```

## Input

| Name | Type | Description |
|---|---|---|
| `resultRow` | table or struct | Evaluation result |
| `csvPath` | string or char | Path to CSV file |

## Output

None.

## Responsibilities

- Create CSV file if it does not exist
- Append result row if file exists
- Preserve column structure

## Expected CSV Columns

```csv
image_name,vehicle_type,expected_text,ocr_text,expected_state,predicted_state,detection_result,ocr_result,state_result,overall_result,notes
```

## Possible MATLAB Functions

```matlab
writetable
readtable
```

---

# 11. Utility Functions

Folder:

```text
src/utils/
```

Assigned member:

```text
Member 4
```

---

## 11.1 displayPipelineResults.m

## Purpose

Displays the final pipeline results.

## Function Signature

```matlab
function displayPipelineResults(originalImg, plateImg, recognizedText, stateName)
```

## Input

| Name | Type | Description |
|---|---|---|
| `originalImg` | image matrix | Original vehicle image |
| `plateImg` | image matrix | Detected license plate image |
| `recognizedText` | string | Cleaned recognized plate text |
| `stateName` | string | Identified state |

## Output

Figure display.

## Responsibilities

- Display original image
- Display detected plate image
- Display recognized text
- Display identified state
- Handle empty plate image

## Suggested Display

```text
Original Image
Detected Plate
Recognized Text
Identified State
```

## Possible MATLAB Functions

```matlab
figure
subplot
imshow
title
```

## Failure Handling

If `plateImg` is empty, display a placeholder message or skip the plate image safely.

---

## 11.2 saveStepImage.m

## Purpose

Saves an intermediate or final image to the output folder.

## Function Signature

```matlab
function saveStepImage(img, outputFolder, fileName)
```

## Input

| Name | Type | Description |
|---|---|---|
| `img` | image matrix | Image to save |
| `outputFolder` | string or char | Folder path |
| `fileName` | string or char | Output file name |

## Output

None.

## Responsibilities

- Check if image is empty
- Create output folder if needed
- Save image using `imwrite`
- Avoid crashing on invalid input

## Possible MATLAB Function

```matlab
imwrite
```

---

## 11.3 ensureOutputFolders.m

## Purpose

Creates required output folders if they do not exist.

## Function Signature

```matlab
function ensureOutputFolders()
```

## Input

None.

## Output

None.

## Responsibilities

Create the following folders if they do not exist:

```text
output/plate_detection/
output/segmentation/
output/recognition/
output/figures/
report/figures/
report/tables/
```

## Possible MATLAB Functions

```matlab
exist
mkdir
```

---

# 12. Function Dependency Map

## 12.1 Main Pipeline Dependencies

```text
main.m
├── ensureOutputFolders
├── preprocessImage
│   ├── convertToGray
│   ├── enhanceContrast
│   └── removeNoise
├── detectPlateRegion
│   ├── selectPlateCandidate
│   └── cropPlateRegion
├── segmentCharacters
│   ├── binarizePlate
│   └── cleanBinaryImage
├── recognizePlateText
├── cleanRecognizedText
├── identifyState
└── displayPipelineResults
```

---

## 12.2 GUI Dependencies

```text
launch_gui.m
├── preprocessImage
├── detectPlateRegion
├── segmentCharacters
├── recognizePlateText
├── cleanRecognizedText
├── identifyState
└── displayPipelineResults
```

---

## 12.3 Evaluation Dependencies

```text
evaluateSingleImage
├── preprocessImage
├── detectPlateRegion
├── segmentCharacters
├── recognizePlateText
├── cleanRecognizedText
├── identifyState
└── saveResultRow
```

---

## 12.4 Scratch Test Dependencies

```text
scratch/test_member1_preprocessing.m
├── preprocessImage
├── convertToGray
├── enhanceContrast
└── removeNoise
```

```text
scratch/test_member2_plate_detection.m
├── detectPlateRegion
├── selectPlateCandidate
└── cropPlateRegion
```

```text
scratch/test_member3_segmentation.m
├── binarizePlate
├── cleanBinaryImage
└── segmentCharacters
```

```text
scratch/test_member4_recognition_gui.m
├── recognizePlateText
├── cleanRecognizedText
├── identifyState
├── displayPipelineResults
├── evaluateSingleImage
└── saveResultRow
```

---

# 13. Member-Based Function Responsibility

## 13.1 Member 1: Dataset and Preprocessing

Assigned folders and files:

```text
src/preprocessing/
images/
dataset_metadata.csv
scratch/test_member1_preprocessing.m
```

Main functions:

```text
preprocessImage.m
convertToGray.m
enhanceContrast.m
removeNoise.m
```

Main outputs:

```text
preprocessedImg
preprocessDebug
```

---

## 13.2 Member 2: License Plate Detection

Assigned folders and files:

```text
src/plate_detection/
scratch/test_member2_plate_detection.m
```

Main functions:

```text
detectPlateRegion.m
selectPlateCandidate.m
cropPlateRegion.m
```

Main outputs:

```text
plateImg
plateBBox
detectionDebug
```

---

## 13.3 Member 3: Segmentation and Morphology

Assigned folders and files:

```text
src/segmentation/
images/test/plate_samples/
scratch/test_member3_segmentation.m
```

Main functions:

```text
binarizePlate.m
cleanBinaryImage.m
segmentCharacters.m
```

Main outputs:

```text
binaryPlateImg
cleanedImg
characterImages
characterBBoxes
```

---

## 13.4 Member 4: Recognition, GUI, and Evaluation

Assigned folders and files:

```text
src/recognition/
src/evaluation/
src/utils/
launch_gui.m
scratch/test_member4_recognition_gui.m
```

Main functions:

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

Main outputs:

```text
rawText
cleanedText
stateName
resultRow
GUI display
```

---

# 14. Minimum Runnable Skeleton Behavior

The first generated version should behave as follows:

1. `main.m` runs without syntax errors.
2. `launch_gui.m` opens without crashing.
3. The project adds the `src` folder to MATLAB path.
4. The project checks for `images/test/sample_car.jpg`.
5. If the image exists, it loads and displays it.
6. Each function returns a valid placeholder or real output.
7. If plate detection is not implemented yet, the system can return a central crop or empty result with a warning.
8. If OCR fails, the system returns `UNKNOWN`.
9. If state identification fails, the system returns `UNKNOWN`.
10. The final results are displayed without crashing.
11. Each member can run their own scratch test script.
12. Manually cropped plate samples can be used for segmentation and OCR testing.

---

# 15. Final Function Design Goal

The final version should support:

- Real plate candidate detection
- Cropped plate extraction
- Plate image cleanup
- Character candidate segmentation for visualization
- OCR-based text recognition
- Rule-based Malaysian state identification
- GUI display
- Result saving
- Evaluation table generation
- Success and failure case analysis
- Member-level module testing
- Full-pipeline testing

---

# 16. Notes for Claude or Codex

When generating code based on this function design:

- Create each file separately.
- Use the exact file names listed in this document.
- Make sure function names match file names.
- Use MATLAB `.m` syntax.
- Use English comments.
- Use English variable names.
- Keep functions simple and readable.
- Add input validation where necessary.
- Do not use TensorFlow, Haar Cascade, YOLO, deep learning detectors, template matching, or pattern matching.
- Use OCR only after plate detection and plate preprocessing.
- Character segmentation should be used for visualization, explanation, and OCR preparation.
- Make the first version runnable even if some functions contain placeholder logic.
- Return `UNKNOWN` when OCR or state identification fails.
- Return empty arrays or empty cell arrays when image processing outputs are unavailable.
- Generate scratch test scripts for independent member testing.
- Support `images/test/sample_car.jpg`.
- Support `images/test/plate_samples/`.
- Do not change core function signatures unless requested.
