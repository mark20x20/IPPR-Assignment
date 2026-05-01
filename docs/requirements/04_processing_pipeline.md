# Processing Pipeline

## 1. Purpose

This document defines the image processing pipeline for the License Plate Recognition (LPR) and State Identification System (SIS).

The pipeline explains how the system processes an input vehicle image, detects the license plate, recognizes the plate text, and identifies the registered Malaysian state.

This document also defines how the pipeline can support parallel development. Although the final system follows a sequential pipeline, each module should be testable independently using sample images, manually cropped plate images, placeholder outputs, and scratch test scripts.

---

## 2. Overall Pipeline

```text
Input vehicle image
↓
Image acquisition
↓
Image preprocessing
↓
License plate region detection
↓
Plate cropping
↓
Plate image preparation
↓
Character segmentation
↓
Text recognition using OCR
↓
OCR text cleaning
↓
State identification
↓
Result display and output saving
```

---

## 3. Pipeline Overview

The system should follow a classical image processing approach.

The main stages are:

1. Image acquisition
2. Preprocessing
3. Plate region detection
4. Plate cropping
5. Plate image binarization and cleanup
6. Character segmentation
7. OCR-based text recognition
8. Text cleaning
9. State identification
10. GUI display
11. Output saving
12. Evaluation recording

The first version does not need perfect recognition accuracy.

The first goal is to create a complete and runnable pipeline with stable function interfaces and safe fallback outputs.

---

## 4. Sequential Dependency of the Final System

The final system has a natural sequential dependency.

```text
Member 1: Preprocessing
↓
Member 2: Plate Detection
↓
Member 3: Segmentation and Morphology
↓
Member 4: OCR, State Identification, GUI, and Evaluation
```

In the final version, each stage receives the output from the previous stage.

However, during development, this dependency can block later members if earlier modules are not completed. Therefore, the project should support parallel development.

---

## 5. Parallel Development Strategy

## 5.1 Purpose

The purpose of the parallel development strategy is to allow all members to work at the same time.

Each member should be able to test their assigned module independently, even if the previous module is incomplete.

## 5.2 Strategy

The project should use:

- Shared skeleton files
- Fixed function signatures
- Placeholder return values
- Safe fallback outputs
- Sample vehicle image
- Manually cropped plate sample images
- Individual scratch test scripts

## 5.3 Required Development Support Folders

```text
scratch/
images/test/plate_samples/
```

## 5.4 Required Scratch Test Scripts

```text
scratch/test_member1_preprocessing.m
scratch/test_member2_plate_detection.m
scratch/test_member3_segmentation.m
scratch/test_member4_recognition_gui.m
```

## 5.5 Placeholder Outputs

Incomplete or failed modules should return safe placeholder outputs.

Examples:

```matlab
plateImg = [];
plateBBox = [];
rawText = "UNKNOWN";
cleanedText = "UNKNOWN";
stateName = "UNKNOWN";
```

These outputs allow the full pipeline and GUI to keep running during early development.

---

## 6. Parallel Development Inputs by Member

## 6.1 Member 1: Dataset and Preprocessing

Member 1 can work directly from original vehicle images.

Input:

```text
images/test/sample_car.jpg
```

Main module:

```text
src/preprocessing/
```

Main functions:

```text
preprocessImage.m
convertToGray.m
enhanceContrast.m
removeNoise.m
```

Independent test script:

```text
scratch/test_member1_preprocessing.m
```

Expected output:

```text
preprocessedImg
preprocessDebug
```

---

## 6.2 Member 2: License Plate Detection

Member 2 normally uses the output from Member 1.

Final input:

```text
preprocessedImg
originalImg
```

However, if Member 1's preprocessing module is not completed, Member 2 may create a temporary grayscale image inside the scratch test script.

Temporary input strategy:

```matlab
originalImg = imread('images/test/sample_car.jpg');

if size(originalImg, 3) == 3
    preprocessedImg = rgb2gray(originalImg);
else
    preprocessedImg = originalImg;
end

[plateImg, plateBBox, detectionDebug] = detectPlateRegion(preprocessedImg, originalImg);
```

Main module:

```text
src/plate_detection/
```

Main functions:

```text
detectPlateRegion.m
selectPlateCandidate.m
cropPlateRegion.m
```

Independent test script:

```text
scratch/test_member2_plate_detection.m
```

Expected output:

```text
plateImg
plateBBox
detectionDebug
```

---

## 6.3 Member 3: Segmentation and Morphology

Member 3 normally uses the cropped plate image from Member 2.

Final input:

```text
plateImg
```

However, if Member 2's plate detection module is not completed, Member 3 can use manually cropped plate images.

Temporary input folder:

```text
images/test/plate_samples/
```

Example plate sample files:

```text
images/test/plate_samples/plate_selangor_01.jpg
images/test/plate_samples/plate_penang_01.jpg
images/test/plate_samples/plate_malacca_01.jpg
```

Example test logic:

```matlab
plateImg = imread('images/test/plate_samples/plate_selangor_01.jpg');

[characterImages, characterBBoxes] = segmentCharacters(plateImg);
```

Main module:

```text
src/segmentation/
```

Main functions:

```text
binarizePlate.m
cleanBinaryImage.m
segmentCharacters.m
```

Independent test script:

```text
scratch/test_member3_segmentation.m
```

Expected output:

```text
binaryPlateImg
cleanedImg
characterImages
characterBBoxes
```

Important note:

Character segmentation is mainly used for visualization, explanation, and OCR preparation. Final text recognition should use OCR, not template-based character matching.

---

## 6.4 Member 4: Recognition, State Identification, GUI, and Evaluation

Member 4 normally uses the cropped or processed plate image from earlier modules.

Final input:

```text
plateImg
rawText
cleanedText
```

However, if earlier modules are not completed, Member 4 can use manually cropped plate images or temporary OCR strings.

Temporary plate input folder:

```text
images/test/plate_samples/
```

Temporary OCR strings:

```text
BMS8147
PAB1234
MAB5678
```

Example OCR test logic:

```matlab
plateImg = imread('images/test/plate_samples/plate_selangor_01.jpg');

rawText = recognizePlateText(plateImg);
cleanedText = cleanRecognizedText(rawText);
stateName = identifyState(cleanedText);
```

Example state identification test logic:

```matlab
rawText = "BMS8147";

cleanedText = cleanRecognizedText(rawText);
stateName = identifyState(cleanedText);
```

Main modules:

```text
src/recognition/
src/evaluation/
src/utils/
```

Root file:

```text
launch_gui.m
```

Independent test script:

```text
scratch/test_member4_recognition_gui.m
```

Expected output:

```text
rawText
cleanedText
stateName
GUI display
resultRow
```

---

## 7. Step 1: Image Acquisition

## 7.1 Purpose

Image acquisition is the first step of the pipeline.

The system loads a vehicle image from the local computer.

## 7.2 Input

Input file formats may include:

- JPG
- JPEG
- PNG
- BMP

## 7.3 MATLAB Function

Possible MATLAB function:

```matlab
originalImg = imread(imagePath);
```

## 7.4 Output

The output of this step is:

```text
originalImg
```

This image is used for:

- Displaying the original image
- Cropping the detected plate region
- Saving report screenshots
- Running module-level tests

## 7.5 First Sample Image

The first runnable version should use:

```text
images/test/sample_car.jpg
```

This file is used by:

```text
main.m
scratch/test_member1_preprocessing.m
scratch/test_member2_plate_detection.m
```

## 7.6 Error Handling

If the image file does not exist, the system should show a clear error message.

Example:

```text
Image file not found. Please place a test image in images/test/.
```

---

## 8. Step 2: Image Preprocessing

## 8.1 Purpose

Preprocessing improves image quality before plate detection.

Vehicle images may contain:

- Noise
- Low contrast
- Uneven lighting
- Shadows
- Reflections
- Complex backgrounds

Preprocessing helps make the plate area easier to detect.

## 8.2 Input

```text
originalImg
```

## 8.3 Possible Operations

Preprocessing may include:

- RGB to grayscale conversion
- Image resizing
- Contrast enhancement
- Histogram equalization
- Noise reduction
- Spatial filtering

## 8.4 MATLAB Functions

Possible MATLAB functions:

```matlab
rgb2gray
im2gray
imresize
imadjust
histeq
adapthisteq
medfilt2
imfilter
fspecial
```

## 8.5 Recommended Processing Flow

```text
Original image
↓
Convert to grayscale
↓
Enhance contrast
↓
Remove noise
↓
Return preprocessed image
```

## 8.6 Example Logic

```matlab
grayImg = convertToGray(originalImg);
enhancedImg = enhanceContrast(grayImg);
preprocessedImg = removeNoise(enhancedImg);
```

## 8.7 Recommended Function Call

```matlab
[preprocessedImg, preprocessDebug] = preprocessImage(originalImg);
```

## 8.8 Output

```text
preprocessedImg
preprocessDebug
```

The preprocessed image is used for plate detection.

The debug information may include:

```text
preprocessDebug.grayImg
preprocessDebug.enhancedImg
preprocessDebug.filteredImg
```

## 8.9 Parallel Development Note

If the complete preprocessing function is not ready, Member 2 may use simple grayscale conversion temporarily.

```matlab
if size(originalImg, 3) == 3
    preprocessedImg = rgb2gray(originalImg);
else
    preprocessedImg = originalImg;
end
```

---

## 9. Step 3: License Plate Region Detection

## 9.1 Purpose

This step detects the most likely license plate region from the vehicle image.

The system should use classical image processing techniques, not deep learning or pattern matching.

## 9.2 Input

```text
preprocessedImg
originalImg
```

## 9.3 Detection Strategy

License plates usually have the following visual properties:

- Rectangular shape
- Strong edges
- High contrast between text and background
- Horizontal structure
- Character-like components inside the region

These properties can be used to find plate candidates.

## 9.4 Possible Operations

Possible operations include:

1. Edge detection
2. Morphological closing
3. Hole filling
4. Small object removal
5. Connected component analysis
6. Region property extraction
7. Candidate filtering
8. Best candidate selection

## 9.5 MATLAB Functions

Possible MATLAB functions:

```matlab
edge
strel
imclose
imdilate
imerode
imfill
bwareaopen
bwconncomp
regionprops
```

## 9.6 Recommended Detection Flow

```text
Preprocessed image
↓
Detect edges
↓
Apply morphological closing
↓
Fill holes
↓
Remove small components
↓
Find connected components
↓
Measure region properties
↓
Filter by area and aspect ratio
↓
Select best plate candidate
↓
Crop plate region
```

## 9.7 Candidate Filtering Criteria

Candidate regions may be filtered using:

- Area
- Width
- Height
- Aspect ratio
- Bounding box size
- Rectangular shape
- Position in the image
- Edge density

## 9.8 Aspect Ratio

License plates are usually wider than they are tall.

A possible aspect ratio range may be:

```text
2.0 to 6.0
```

This value should be adjusted through testing.

## 9.9 Recommended Function Call

```matlab
[plateImg, plateBBox, detectionDebug] = detectPlateRegion(preprocessedImg, originalImg);
```

## 9.10 Output

This step should return:

```text
plateImg
plateBBox
detectionDebug
```

Where:

- `plateImg` is the cropped plate image.
- `plateBBox` is the bounding box of the detected region.
- `detectionDebug` stores intermediate images or values for debugging and report screenshots.

Possible debug fields:

```text
detectionDebug.edgeImg
detectionDebug.closedImg
detectionDebug.filledImg
detectionDebug.cleanedImg
detectionDebug.candidateRegions
```

## 9.11 Failure Handling

If no valid plate candidate is found, the system should:

- Return `plateImg = []`
- Return `plateBBox = []`
- Return `UNKNOWN` for recognition result later
- Return `UNKNOWN` for state later
- Avoid crashing
- Optionally return a placeholder image for debugging

## 9.12 Parallel Development Note

If preprocessing is incomplete, Member 2 can use a temporary grayscale input.

If plate detection is incomplete, later modules should use manually cropped plate images from:

```text
images/test/plate_samples/
```

---

## 10. Step 4: Plate Cropping

## 10.1 Purpose

After detecting the plate bounding box, the system crops the plate region from the original image.

The original image should be used for cropping to preserve image quality.

## 10.2 Input

```text
originalImg
plateBBox
```

## 10.3 MATLAB Function

Possible MATLAB function:

```matlab
plateImg = imcrop(originalImg, plateBBox);
```

## 10.4 Output

```text
plateImg
```

## 10.5 Error Handling

Before cropping, the system should check that:

- The bounding box is not empty.
- The bounding box is inside the image boundary.
- Width and height are positive.
- The bounding box values are valid numbers.

If the bounding box is invalid, return an empty output or fallback result instead of crashing.

Recommended fallback:

```matlab
plateImg = [];
```

---

## 11. Step 5: Plate Image Preparation

## 11.1 Purpose

The cropped plate image must be prepared before OCR.

Raw cropped plate images may still contain:

- Noise
- Low contrast
- Shadows
- Plate borders
- Background artifacts
- Uneven lighting

This step improves the readability of the plate text.

## 11.2 Input

```text
plateImg
```

## 11.3 Possible Operations

Possible operations include:

- Grayscale conversion
- Contrast enhancement
- Binarization
- Inversion if necessary
- Morphological cleaning
- Noise removal
- Resizing

## 11.4 MATLAB Functions

Possible MATLAB functions:

```matlab
rgb2gray
im2gray
imadjust
adapthisteq
graythresh
imbinarize
imcomplement
imopen
imclose
imfill
bwareaopen
imresize
```

## 11.5 Recommended Flow

```text
Cropped plate image
↓
Convert to grayscale
↓
Enhance contrast
↓
Binarize image
↓
Clean binary image
↓
Resize if needed
↓
Return OCR-ready image
```

## 11.6 Output

```text
ocrReadyPlateImg
binaryPlateImg
```

The OCR-ready image is used for text recognition.

The binary image may also be used for character segmentation and report screenshots.

## 11.7 Failure Handling

If `plateImg` is empty, this step should return empty output and avoid crashing.

---

## 12. Step 6: Character Segmentation

## 12.1 Purpose

Character segmentation identifies possible character regions from the plate image.

This step is useful for:

- Visualizing how the text is separated
- Supporting OCR preparation
- Explaining the process in the report
- Analyzing OCR failures

## 12.2 Input

```text
plateImg
```

or:

```text
binaryPlateImg
```

depending on the function design.

## 12.3 Possible Operations

Possible operations include:

- Connected component analysis
- Bounding box extraction
- Filtering by area
- Filtering by height and width
- Removing non-character regions
- Sorting character candidates from left to right

## 12.4 MATLAB Functions

Possible MATLAB functions:

```matlab
bwconncomp
regionprops
bwareaopen
sortrows
imcrop
```

## 12.5 Recommended Flow

```text
Cropped plate image
↓
Binarize plate
↓
Clean binary image
↓
Find connected components
↓
Measure bounding boxes
↓
Filter invalid components
↓
Sort remaining components from left to right
↓
Return character candidates
```

## 12.6 Recommended Function Call

```matlab
[characterImages, characterBBoxes] = segmentCharacters(plateImg);
```

## 12.7 Output

```text
characterImages
characterBBoxes
```

## 12.8 Important Note

The final recognition may still use OCR.

Character segmentation is included to support the image processing pipeline and provide explainable intermediate results.

Character segmentation should not be used for template-based character matching.

Final text recognition should use OCR, not template matching or pattern matching.

## 12.9 Parallel Development Note

If plate detection is not ready, Member 3 should use manually cropped plate images from:

```text
images/test/plate_samples/
```

---

## 13. Step 7: Text Recognition Using OCR

## 13.1 Purpose

OCR is used to recognize text from the processed license plate image.

## 13.2 Input

```text
ocrReadyPlateImg
```

or:

```text
plateImg
```

depending on which version gives better OCR performance.

## 13.3 MATLAB Function

Possible MATLAB function:

```matlab
ocrResult = ocr(ocrReadyPlateImg);
```

## 13.4 Recommended Function Call

```matlab
rawText = recognizePlateText(plateImg);
```

## 13.5 Output

```text
rawText
```

## 13.6 OCR Failure Handling

If OCR is unavailable or fails, the system should return:

```text
UNKNOWN
```

The system should not crash.

## 13.7 OCR Usage Rule

OCR should not be applied directly to the full original image as the only method.

OCR should be applied after:

1. Preprocessing
2. Plate detection
3. Plate cropping
4. Plate image cleanup

## 13.8 Parallel Development Note

If plate detection or segmentation is incomplete, Member 4 can use manually cropped plate images from:

```text
images/test/plate_samples/
```

Member 4 may also test state identification with temporary OCR strings such as:

```text
BMS8147
PAB1234
MAB5678
```

---

## 14. Step 8: OCR Text Cleaning

## 14.1 Purpose

Raw OCR output may contain spaces, symbols, line breaks, or incorrect formatting.

This step cleans the OCR result before state identification.

## 14.2 Input

```text
rawText
```

## 14.3 Cleaning Operations

Cleaning may include:

- Convert to uppercase
- Remove spaces
- Remove line breaks
- Remove punctuation
- Remove non-alphanumeric characters
- Trim unnecessary characters

## 14.4 Example

```text
Raw OCR output:
"B M S 8147"

Cleaned output:
"BMS8147"
```

## 14.5 Possible MATLAB Functions

Possible MATLAB functions:

```matlab
upper
regexprep
strtrim
string
```

## 14.6 Recommended Function Call

```matlab
cleanedText = cleanRecognizedText(rawText);
```

## 14.7 Output

```text
cleanedText
```

If the cleaned text is empty, return:

```text
UNKNOWN
```

---

## 15. Step 9: State Identification

## 15.1 Purpose

The system identifies the registered Malaysian state based on the license plate prefix.

## 15.2 Input

```text
cleanedText
```

## 15.3 Prefix-Based Rule

The system checks the first character or prefix of the cleaned plate text.

Example:

```text
BMS8147 → B → Selangor
MAB1234 → M → Malacca
PEN1234 → P → Penang
```

## 15.4 Example Mapping

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

## 15.5 Recommended Function Call

```matlab
stateName = identifyState(cleanedText);
```

## 15.6 Output

```text
stateName
```

If the prefix is unknown, return:

```text
UNKNOWN
```

## 15.7 Parallel Development Note

State identification can be tested before OCR is fully completed by using temporary OCR strings.

Example:

```matlab
rawText = "BMS8147";
cleanedText = cleanRecognizedText(rawText);
stateName = identifyState(cleanedText);
```

---

## 16. Step 10: Result Display

## 16.1 Purpose

The system displays the processing results for the user.

## 16.2 Displayed Items

The system should display:

- Original image
- Detected plate image
- Recognized plate text
- Identified state
- Status message

## 16.3 Display Methods

For script-based testing, use:

```matlab
figure
subplot
imshow
title
```

For GUI, use:

```matlab
figure
axes
uicontrol
imshow
guidata
```

## 16.4 Recommended Function Call

```matlab
displayPipelineResults(originalImg, plateImg, cleanedText, stateName);
```

## 16.5 Output

The displayed output should help with:

- Debugging
- Report screenshots
- Presentation demonstration
- Individual contribution explanation

## 16.6 Failure Display

If recognition fails, display:

```text
Recognized Text: UNKNOWN
Identified State: UNKNOWN
```

The GUI and result display should not crash when `plateImg` is empty.

---

## 17. Step 11: Output Saving

## 17.1 Purpose

The system should save important intermediate and final outputs for report preparation.

## 17.2 Possible Saved Outputs

The system may save:

- Original image with detected bounding box
- Preprocessed image
- Edge image
- Binary image
- Cleaned binary image
- Cropped plate image
- OCR-ready plate image
- Final result figure

## 17.3 Recommended Output Folders

```text
output/plate_detection/
output/segmentation/
output/recognition/
output/figures/
report/figures/
report/tables/
```

## 17.4 MATLAB Function

Possible MATLAB function:

```matlab
imwrite
```

The system should create output folders automatically if they do not exist.

## 17.5 Recommended Utility Functions

```matlab
ensureOutputFolders();
saveStepImage(img, outputFolder, fileName);
```

---

## 18. Step 12: Evaluation Recording

## 18.1 Purpose

Evaluation recording helps organize test results for the project report.

## 18.2 Recorded Items

Each test result should include:

- Image name
- Vehicle type
- Expected plate text
- OCR result
- Expected state
- Predicted state
- Detection result
- OCR result status
- State result status
- Overall result
- Notes

## 18.3 Recommended Output File

```text
results_template.csv
```

## 18.4 Recommended CSV Header

```csv
image_name,vehicle_type,expected_text,ocr_text,expected_state,predicted_state,detection_result,ocr_result,state_result,overall_result,notes
```

## 18.5 Example Table

| Image Name | Vehicle Type | Expected Text | OCR Text | Expected State | Predicted State | Detection Result | OCR Result | State Result | Overall Result | Notes |
|---|---|---|---|---|---|---|---|---|---|

---

## 19. Main Script Flow

The `main.m` script should follow this structure:

```text
Clear workspace
↓
Add src folder to MATLAB path
↓
Ensure output folders exist
↓
Load sample image
↓
Preprocess image
↓
Detect plate region
↓
Segment or prepare plate
↓
Recognize text
↓
Clean OCR text
↓
Identify state
↓
Display results
```

Example call flow:

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

displayPipelineResults(originalImg, plateImg, cleanedText, stateName);
```

---

## 20. GUI Pipeline Flow

The `launch_gui.m` file should follow this logic:

```text
Create GUI window
↓
User loads image
↓
Display original image
↓
User clicks Run Recognition
↓
Run full pipeline
↓
Display detected plate
↓
Display recognized text
↓
Display identified state
↓
Display status message
```

The GUI should call the same pipeline functions used by `main.m`.

The GUI should not duplicate image processing logic inside callback functions.

---

## 21. Scratch Test Script Flow

## 21.1 Member 1 Scratch Test Flow

Script:

```text
scratch/test_member1_preprocessing.m
```

Flow:

```text
Load sample_car.jpg
↓
Run preprocessImage
↓
Display grayscale / enhanced / filtered images
↓
Save debug outputs if needed
```

---

## 21.2 Member 2 Scratch Test Flow

Script:

```text
scratch/test_member2_plate_detection.m
```

Flow:

```text
Load sample_car.jpg
↓
Create temporary grayscale image if preprocessing is unavailable
↓
Run detectPlateRegion
↓
Display detected plate or fallback result
```

---

## 21.3 Member 3 Scratch Test Flow

Script:

```text
scratch/test_member3_segmentation.m
```

Flow:

```text
Load manually cropped plate image from images/test/plate_samples/
↓
Run binarizePlate
↓
Run cleanBinaryImage
↓
Run segmentCharacters
↓
Display binary, cleaned, and character candidate results
```

---

## 21.4 Member 4 Scratch Test Flow

Script:

```text
scratch/test_member4_recognition_gui.m
```

Flow:

```text
Load manually cropped plate image or use temporary OCR string
↓
Run recognizePlateText
↓
Run cleanRecognizedText
↓
Run identifyState
↓
Test displayPipelineResults
↓
Test evaluation row if needed
↓
Open or test launch_gui.m
```

---

## 22. Debug Information

Each major function may return debug information.

Examples:

```text
preprocessDebug.grayImg
preprocessDebug.enhancedImg
preprocessDebug.filteredImg

detectionDebug.edgeImg
detectionDebug.closedImg
detectionDebug.filledImg
detectionDebug.cleanedImg
detectionDebug.candidateRegions
```

Debug information is useful for:

- Troubleshooting
- Report screenshots
- Explaining the pipeline
- Analyzing failure cases
- Showing individual member contributions

---

## 23. Failure Handling in Pipeline

The pipeline should handle failures gracefully.

## 23.1 Image Loading Failure

If the image cannot be loaded:

```text
Stop processing and show clear error message.
```

## 23.2 Plate Detection Failure

If plate detection fails:

```matlab
plateImg = [];
plateBBox = [];
rawText = "UNKNOWN";
cleanedText = "UNKNOWN";
stateName = "UNKNOWN";
```

## 23.3 Segmentation Failure

If segmentation fails:

```matlab
characterImages = {};
characterBBoxes = [];
```

The system may still attempt OCR using the cropped plate image if available.

## 23.4 OCR Failure

If OCR fails:

```matlab
rawText = "UNKNOWN";
cleanedText = "UNKNOWN";
stateName = "UNKNOWN";
```

## 23.5 State Identification Failure

If the prefix is not recognized:

```matlab
stateName = "UNKNOWN";
```

## 23.6 Missing Plate Sample Images

If manually cropped plate sample images are missing:

```text
No plate sample images found in images/test/plate_samples/.
```

The relevant scratch test script should stop safely without crashing.

---

## 24. Minimum Working Pipeline

The first working version should be able to:

1. Load a sample image.
2. Display the original image.
3. Run all pipeline functions.
4. Return a detected or placeholder plate image.
5. Return recognized text or `UNKNOWN`.
6. Return state name or `UNKNOWN`.
7. Display results without crashing.
8. Keep all core function signatures stable.
9. Provide scratch test scripts for all members.
10. Support manually cropped plate samples for segmentation and OCR testing.
11. Allow GUI development with placeholder outputs.

The first working version does not need perfect accuracy.

The priority is to make the project runnable and suitable for parallel development.

---

## 25. Final Pipeline Goal

The final version should be able to:

1. Load different vehicle images.
2. Detect likely license plate regions.
3. Crop the detected plate region.
4. Prepare the plate image for OCR.
5. Recognize plate text.
6. Clean OCR output.
7. Identify the registered state.
8. Display results in GUI.
9. Save important output images.
10. Record experimental results.
11. Support experimental testing and failure analysis.
12. Allow each member to demonstrate their assigned contribution.

---

## 26. Notes for Implementation

- Use relative paths whenever possible.
- Keep each function small and clear.
- Do not use TensorFlow, Haar Cascade, YOLO, or pattern matching.
- Do not use template matching for character recognition.
- OCR is allowed, but only after plate detection and preprocessing.
- Character segmentation is for visualization, explanation, and OCR preparation.
- The system should be explainable in the report.
- The pipeline should reflect the image processing concepts covered in class.
- Each module should return safe fallback outputs if processing fails.
- The first version should prioritize stable structure and parallel development over accuracy.
- Do not change core function signatures without team discussion.
