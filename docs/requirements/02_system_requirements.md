# System Requirements

## 1. Purpose

This document defines the system requirements for the License Plate Recognition (LPR) and State Identification System (SIS).

The system should load a vehicle image, detect the license plate region, recognize the plate text, identify the registered Malaysian state, and display the result through a simple GUI.

This document also defines requirements for parallel development. Each module should be testable independently so that group members can work on their assigned functional folders without waiting for all previous modules to be fully completed.

---

## 2. Functional Requirements

## FR-01: Load Vehicle Image

The system shall allow the user to load a vehicle image from the local computer.

Supported image formats may include:

- JPG
- JPEG
- PNG
- BMP

The first runnable version should use the following sample image if available:

```text
images/test/sample_car.jpg
````

---

## FR-02: Display Original Image

The system shall display the selected original vehicle image.

The original image should be shown in:

* MATLAB figure window
* GUI image display area

---

## FR-03: Preprocess Image

The system shall preprocess the input image before license plate detection.

Preprocessing may include:

* RGB to grayscale conversion
* Image resizing
* Contrast enhancement
* Histogram equalization
* Noise reduction
* Spatial filtering

Expected output:

* A preprocessed image suitable for plate detection
* Optional debug information for report screenshots and analysis

Recommended function output:

```matlab
[preprocessedImg, preprocessDebug] = preprocessImage(originalImg);
```

---

## FR-04: Detect License Plate Region

The system shall detect the most likely license plate region from the vehicle image.

The detection should use classical image processing methods, such as:

* Edge detection
* Thresholding
* Morphological operations
* Connected component analysis
* Region property filtering

The system should not use prohibited methods such as:

* Haar Cascade
* TensorFlow
* Pattern matching methods
* YOLO or deep learning object detectors

Expected output:

* License plate bounding box
* Cropped license plate image
* Detection status
* Optional debug information

Recommended function output:

```matlab
[plateImg, plateBBox, detectionDebug] = detectPlateRegion(preprocessedImg, originalImg);
```

If no valid plate region is detected, the function should return a safe fallback such as:

```matlab
plateImg = [];
plateBBox = [];
```

The system should continue running and return `UNKNOWN` for recognition and state identification if necessary.

---

## FR-05: Crop License Plate Region

The system shall crop the detected license plate region from the original image.

If a valid plate region is detected, the system should return:

* Cropped plate image
* Plate bounding box

If no valid plate region is detected, the system should return:

* Clear error or warning message
* Empty output or fallback result

The system should validate the bounding box before cropping.

---

## FR-06: Prepare Plate Image for OCR

The system shall prepare the cropped plate image before OCR.

This process may include:

* Grayscale conversion
* Contrast enhancement
* Binarization
* Noise removal
* Morphological cleaning
* Image resizing

Expected output:

* OCR-ready plate image
* Binary plate image if needed for segmentation or report screenshots

---

## FR-07: Segment Character Regions

The system should identify possible character regions from the license plate image.

This may include:

* Connected component analysis
* Character bounding box extraction
* Filtering by size and shape
* Sorting characters from left to right

This step may be used for:

* Visualization
* Analysis
* Report screenshots
* Supporting OCR preparation

Expected output:

* Character candidate images
* Character bounding boxes

Recommended function output:

```matlab
[characterImages, characterBBoxes] = segmentCharacters(plateImg);
```

Important note:

Character segmentation is mainly used for visualization, explanation, and OCR preparation. Final text recognition should use OCR, not template-based character matching.

---

## FR-08: Recognize Plate Text

The system shall recognize text from the processed license plate image using OCR.

If OCR is available, the system should attempt to extract the plate text.

If OCR is unavailable or fails, the system should return:

```text
UNKNOWN
```

Expected output:

* Raw recognized text

Recommended function output:

```matlab
rawText = recognizePlateText(plateImg);
```

OCR should be applied to the detected and processed plate image, not directly to the full original vehicle image as the only processing step.

---

## FR-09: Clean OCR Output

The system shall clean the raw OCR result before state identification.

Cleaning may include:

* Converting text to uppercase
* Removing spaces
* Removing punctuation
* Removing non-alphanumeric characters
* Removing line breaks
* Handling empty OCR output

Example:

```text
Raw OCR: B M S 8147
Cleaned Text: BMS8147
```

If the cleaned text is empty, return:

```text
UNKNOWN
```

Recommended function output:

```matlab
cleanedText = cleanRecognizedText(rawText);
```

---

## FR-10: Identify Registered State

The system shall identify the registered Malaysian state based on the plate prefix.

Example prefix mapping:

| Prefix | State           |
| ------ | --------------- |
| A      | Perak           |
| B      | Selangor        |
| J      | Johor           |
| K      | Kedah           |
| M      | Malacca         |
| N      | Negeri Sembilan |
| P      | Penang          |
| T      | Terengganu      |
| W      | Kuala Lumpur    |

If the prefix is not recognized, the system should return:

```text
UNKNOWN
```

Expected output:

* Identified state name

Recommended function output:

```matlab
stateName = identifyState(cleanedText);
```

---

## FR-11: Display Final Results

The system shall display the final results clearly.

The displayed results should include:

* Original image
* Detected license plate image
* Recognized plate text
* Identified state
* Processing status message

The result display should work even if plate detection or OCR fails.

If recognition fails, the displayed result should be:

```text
Recognized Text: UNKNOWN
Identified State: UNKNOWN
```

---

## FR-12: Save Output Images

The system should be able to save intermediate and final output images for report preparation.

Possible saved outputs include:

* Preprocessed image
* Edge detection result
* Binary image
* Cleaned binary image
* Detected plate image
* OCR-ready plate image
* Final result figure

Recommended output folders:

```text
output/plate_detection/
output/segmentation/
output/recognition/
output/figures/
```

The system should create these folders automatically if they do not exist.

---

## FR-13: Record Test Results

The system should support recording test results in a structured format.

A test result record should include:

* Image name
* Vehicle type
* Expected plate text
* OCR result
* Expected state
* Predicted state
* Detection result
* OCR result status
* State result status
* Overall result
* Notes or failure reason

Recommended format:

```text
results_template.csv
```

Recommended CSV header:

```csv
image_name,vehicle_type,expected_text,ocr_text,expected_state,predicted_state,detection_result,ocr_result,state_result,overall_result,notes
```

---

## FR-14: Provide GUI Operation

The system shall provide a simple GUI for user interaction.

The GUI should allow the user to:

* Load an image
* Run recognition
* View original image
* View detected plate
* View recognized text
* View identified state
* View status messages

The GUI should be runnable from:

```text
launch_gui.m
```

The GUI should call the same processing functions used by `main.m`.

The GUI should not duplicate image processing logic inside the GUI callbacks.

---

## FR-15: Support Parallel Development

The system shall support parallel development by allowing each module to be developed and tested independently.

This is necessary because the final system follows a sequential pipeline:

```text
Preprocessing
↓
Plate Detection
↓
Segmentation and Morphology
↓
OCR, State Identification, GUI, and Evaluation
```

However, group members should not be blocked while waiting for earlier modules to be fully completed.

The system shall support parallel development through:

* Shared skeleton files
* Fixed function signatures
* Placeholder return values
* Sample vehicle images
* Manually cropped plate sample images
* Individual scratch test scripts
* Safe fallback outputs such as `UNKNOWN` or empty arrays

Required development support folders:

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

## FR-16: Provide Placeholder and Fallback Outputs

The system shall provide safe placeholder outputs during early development.

Placeholder outputs allow later modules to be developed before earlier modules are fully completed.

Examples:

```matlab
plateImg = [];
plateBBox = [];
recognizedText = "UNKNOWN";
stateName = "UNKNOWN";
```

If a module is incomplete or fails, it should return a safe fallback output instead of stopping the entire system.

This allows:

* `main.m` to run during early development
* `launch_gui.m` to open and display fallback results
* Each member to test their own module independently

---

## FR-17: Support Independent Module Testing

Each member shall be able to test their assigned module independently.

### Member 1: Dataset and Preprocessing

Assigned test script:

```text
scratch/test_member1_preprocessing.m
```

This script should test:

* `preprocessImage.m`
* `convertToGray.m`
* `enhanceContrast.m`
* `removeNoise.m`

Input:

```text
images/test/sample_car.jpg
```

Expected output:

* Grayscale image
* Enhanced image
* Noise-reduced image
* Preprocessing debug results

---

### Member 2: License Plate Detection

Assigned test script:

```text
scratch/test_member2_plate_detection.m
```

This script should test:

* `detectPlateRegion.m`
* `selectPlateCandidate.m`
* `cropPlateRegion.m`

If Member 1's preprocessing module is not completed, this script may create a temporary grayscale image using simple grayscale conversion.

Temporary input strategy:

```matlab
originalImg = imread('images/test/sample_car.jpg');

if size(originalImg, 3) == 3
    preprocessedImg = rgb2gray(originalImg);
else
    preprocessedImg = originalImg;
end
```

Expected output:

* Edge or candidate debug image
* Plate bounding box or empty fallback
* Cropped plate image or empty fallback

---

### Member 3: Segmentation and Morphology

Assigned test script:

```text
scratch/test_member3_segmentation.m
```

This script should test:

* `binarizePlate.m`
* `cleanBinaryImage.m`
* `segmentCharacters.m`

Input:

```text
images/test/plate_samples/
```

This folder should contain manually cropped plate images.

Expected output:

* Binary plate image
* Cleaned binary plate image
* Character candidate regions
* Character bounding boxes

---

### Member 4: Recognition, GUI, and Evaluation

Assigned test script:

```text
scratch/test_member4_recognition_gui.m
```

This script should test:

* `recognizePlateText.m`
* `cleanRecognizedText.m`
* `identifyState.m`
* `evaluateSingleImage.m`
* `saveResultRow.m`
* `displayPipelineResults.m`
* `saveStepImage.m`
* `ensureOutputFolders.m`
* `launch_gui.m`

Input options:

```text
images/test/plate_samples/
```

or temporary OCR strings such as:

```text
BMS8147
PAB1234
MAB5678
```

Expected output:

* OCR text or `UNKNOWN`
* Cleaned OCR text
* Identified state or `UNKNOWN`
* GUI display
* Evaluation row
* Saved result if required

---

## 3. Non-Functional Requirements

## NFR-01: Usability

The system should be easy to use.

The GUI should be simple and understandable for users who are not familiar with MATLAB code.

---

## NFR-02: Maintainability

The source code should be organized into separate MATLAB function files.

Each function should have a clear responsibility.

Example modules:

* Preprocessing
* Plate detection
* Segmentation
* Recognition
* Evaluation
* Utilities

The project should follow feature-based folder responsibility:

| Member   | Main Responsibility              | Assigned Folder or Files                                            |
| -------- | -------------------------------- | ------------------------------------------------------------------- |
| Member 1 | Dataset and Preprocessing        | `src/preprocessing/`, `images/`, `dataset_metadata.csv`             |
| Member 2 | License Plate Detection          | `src/plate_detection/`                                              |
| Member 3 | Segmentation and Morphology      | `src/segmentation/`                                                 |
| Member 4 | Recognition, GUI, and Evaluation | `src/recognition/`, `src/evaluation/`, `src/utils/`, `launch_gui.m` |

---

## NFR-03: Readability

All code should be written clearly.

The project should use:

* English comments
* English variable names
* English function names
* Clear function headers

Each major function should describe:

* Purpose
* Input
* Output
* Main processing steps

---

## NFR-04: Reliability

The system should not crash when common errors occur.

The system should handle:

* Missing image files
* Invalid image files
* Failed plate detection
* Invalid bounding boxes
* OCR unavailable
* Empty OCR result
* Unknown plate prefix
* Missing manually cropped plate samples
* Missing output folders
* Incomplete module implementation during early development

---

## NFR-05: Reproducibility

The system should produce consistent results for the same input image and parameter settings.

The pipeline should be runnable from:

```text
main.m
```

The GUI should be runnable from:

```text
launch_gui.m
```

Each module test should be runnable from:

```text
scratch/test_member1_preprocessing.m
scratch/test_member2_plate_detection.m
scratch/test_member3_segmentation.m
scratch/test_member4_recognition_gui.m
```

---

## NFR-06: Compatibility

The system should be developed for:

```text
MATLAB R2026a
```

The system should run on a Windows environment.

The system should use relative paths where possible.

Example:

```matlab
imagePath = fullfile('images', 'test', 'sample_car.jpg');
```

The project should not require Docker.

---

## NFR-07: Report Support

The system should generate outputs that can be used in the project report.

Useful report materials include:

* Original input image
* Intermediate processing images
* Detected plate result
* OCR result
* GUI screenshot
* Success and failure case outputs
* Module-level test outputs
* Member-specific contribution evidence

---

## NFR-08: Extensibility

The system should be designed so that future improvements can be added easily.

Possible future extensions include:

* Better plate candidate selection
* Improved OCR preprocessing
* More state prefix mappings
* Handling angled plates
* Batch image testing
* Improved GUI design
* More detailed evaluation metrics
* Additional vehicle and plate types

---

## NFR-09: Team Collaboration

The system should support team-based development.

Team collaboration requirements:

* Each member should mainly edit their assigned functional folder.
* Function signatures should not be changed without team discussion.
* Branch names should not be used as folder names.
* GitHub may be used for code sharing and version control.
* The final submission should still be prepared as a ZIP file according to assignment requirements.

---

## 4. System Constraints

## SC-01: MATLAB-Based Implementation

The system should be implemented mainly using MATLAB `.m` files.

---

## SC-02: Classical Image Processing Approach

The system should mainly use classical image processing techniques.

Recommended techniques include:

* Grayscale conversion
* Contrast enhancement
* Spatial filtering
* Edge detection
* Thresholding
* Morphological operations
* Connected component analysis
* Region property analysis
* OCR

---

## SC-03: Prohibited Methods

The system must not use:

* Haar Cascade
* TensorFlow
* Pattern matching methods
* Template matching
* YOLO or deep learning object detectors

---

## SC-04: OCR Limitation

OCR may be used, but OCR should not be applied directly to the full original image as the only processing step.

The system should first perform:

1. Image preprocessing
2. Plate region detection
3. Plate cropping
4. Plate image cleanup

Then OCR should be applied to the processed plate image.

---

## SC-05: Function Interface Stability

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

## SC-06: Branch and Folder Separation

Git branches are used for version control only.

Branch names must not be used as project folder names.

Correct example:

```text
Branch: feature/preprocessing
Assigned folder: src/preprocessing/
```

Incorrect example:

```text
Assignment/
└── feature/
    └── preprocessing/
```

The folder structure should remain consistent across all branches.

---

## 5. Minimum Working Version

The first runnable version should be able to:

1. Load one sample image.
2. Display the original image.
3. Run the full processing pipeline.
4. Return a detected or placeholder plate image.
5. Return recognized text or `UNKNOWN`.
6. Return identified state or `UNKNOWN`.
7. Display the result in MATLAB.
8. Avoid crashing when OCR or detection fails.
9. Provide stable function signatures for all modules.
10. Include placeholder or fallback outputs where necessary.
11. Include independent scratch test scripts for all members.
12. Include manually cropped plate sample support for Member 3 and Member 4.

The first runnable version does not need perfect plate detection or OCR accuracy.

The main goal is to make the full project structure runnable and ready for parallel development.

---

## 6. Expected Final Version

The final version should be able to:

1. Load different vehicle images.
2. Detect likely license plate regions.
3. Prepare the detected plate for OCR.
4. Recognize plate text.
5. Identify the registered state.
6. Display results in a GUI.
7. Save output images for report use.
8. Record experimental results.
9. Support analysis of both successful and failed cases.
10. Allow each member to demonstrate their assigned contribution.
11. Support module-level testing and full-pipeline testing.
12. Provide enough outputs for report screenshots and individual presentation.

---

## 7. Member-Based System Responsibility Summary

## Member 1: Dataset and Preprocessing

Assigned folders and files:

```text
src/preprocessing/
images/
dataset_metadata.csv
scratch/test_member1_preprocessing.m
```

Related requirements:

* FR-01: Load Vehicle Image
* FR-03: Preprocess Image
* FR-12: Save Output Images
* FR-15: Support Parallel Development
* FR-17: Support Independent Module Testing

Main outputs:

* `preprocessedImg`
* `preprocessDebug`
* Dataset metadata
* Preprocessing screenshots

---

## Member 2: License Plate Detection

Assigned folders and files:

```text
src/plate_detection/
scratch/test_member2_plate_detection.m
```

Related requirements:

* FR-04: Detect License Plate Region
* FR-05: Crop License Plate Region
* FR-12: Save Output Images
* FR-15: Support Parallel Development
* FR-17: Support Independent Module Testing

Main outputs:

* `plateImg`
* `plateBBox`
* `detectionDebug`
* Plate detection screenshots

---

## Member 3: Segmentation and Morphological Processing

Assigned folders and files:

```text
src/segmentation/
images/test/plate_samples/
scratch/test_member3_segmentation.m
```

Related requirements:

* FR-06: Prepare Plate Image for OCR
* FR-07: Segment Character Regions
* FR-12: Save Output Images
* FR-15: Support Parallel Development
* FR-17: Support Independent Module Testing

Main outputs:

* `binaryPlateImg`
* `cleanedImg`
* `characterImages`
* `characterBBoxes`
* Segmentation screenshots

---

## Member 4: Recognition, GUI, and Evaluation

Assigned folders and files:

```text
src/recognition/
src/evaluation/
src/utils/
launch_gui.m
scratch/test_member4_recognition_gui.m
```

Related requirements:

* FR-08: Recognize Plate Text
* FR-09: Clean OCR Output
* FR-10: Identify Registered State
* FR-11: Display Final Results
* FR-12: Save Output Images
* FR-13: Record Test Results
* FR-14: Provide GUI Operation
* FR-15: Support Parallel Development
* FR-17: Support Independent Module Testing

Main outputs:

* `rawText`
* `cleanedText`
* `stateName`
* GUI display
* Evaluation CSV
* Final result screenshots