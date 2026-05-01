# Evaluation Plan

## 1. Purpose

This document defines the evaluation plan for the License Plate Recognition (LPR) and State Identification System (SIS).

The purpose of evaluation is to check whether the system can:

- Detect license plate regions correctly
- Crop detected license plate regions clearly
- Prepare license plate images for OCR
- Recognize license plate text using OCR
- Identify the registered Malaysian state
- Handle different vehicle types and image conditions
- Provide useful results for the project report
- Support module-level testing during parallel development
- Support critical analysis of both successful and failed cases

This document also defines member-based evaluation responsibilities so that each group member can evaluate their assigned module independently.

---

## 2. Evaluation Objectives

The evaluation should answer the following questions:

1. Can the system detect the correct license plate region?
2. Can the system crop the plate region clearly?
3. Can the system prepare the plate image for OCR?
4. Can OCR recognize the plate text correctly?
5. Can the system identify the correct registered state?
6. Under what conditions does the system work well?
7. Under what conditions does the system fail?
8. Which module caused the failure?
9. What improvements are needed for future work?
10. Can each member demonstrate their assigned contribution?

---

## 3. Evaluation Scope

The evaluation should cover:

- Image loading
- Image preprocessing
- Plate detection
- Plate cropping
- Plate image preprocessing
- Character segmentation for visualization and OCR preparation
- OCR text recognition
- OCR text cleaning
- State identification
- GUI output
- Evaluation result recording
- Module-level testing
- Failure case analysis

The evaluation should include both easy and difficult images.

---

## 4. Evaluation Dataset

## 4.1 Required Image Types

The test dataset should include multiple vehicle types.

Core vehicle types:

- Car
- Motorcycle
- Bus

Optional additional vehicle types:

- Van
- Truck

At minimum, the evaluation should include at least two different vehicle types.

---

## 4.2 Required Plate Variations

Where possible, the evaluation should include different plate types or state representations.

Examples:

- Standard state plates
- Special series plates
- Two-row plates
- Military plates
- Diplomatic plates
- Special status plates

The first version may focus mainly on standard Malaysian state plates.

---

## 4.3 Required Image Conditions

The evaluation should include different image conditions.

### Distance

- Close
- Medium
- Far

### Lighting

- Bright daylight
- Low light
- Shadow
- Reflection
- Indoor parking light

### Background

- Simple background
- Complex background
- Roadside background
- Parking area
- Background with similar rectangular objects

### Angle

- Front view
- Slight side angle
- Tilted plate
- Strong angle

---

## 4.4 Development Sample Data

For parallel development, the evaluation should also use development sample data.

Required development samples:

```text
images/test/sample_car.jpg
images/test/plate_samples/
```

### sample_car.jpg

This image is used for initial full-pipeline testing.

It is used by:

```text
main.m
scratch/test_member1_preprocessing.m
scratch/test_member2_plate_detection.m
```

### plate_samples

This folder contains manually cropped plate images.

It is used by:

- Member 3 for segmentation and morphology testing
- Member 4 for OCR and state identification testing

Example files:

```text
images/test/plate_samples/plate_selangor_01.jpg
images/test/plate_samples/plate_penang_01.jpg
images/test/plate_samples/plate_malacca_01.jpg
```

---

## 5. Evaluation Metrics

## 5.1 Plate Detection Result

This metric checks whether the system detects the correct license plate region.

Use one of the following labels:

```text
Success
Partial Success
Failure
```

### Success

The correct license plate region is detected and cropped clearly.

### Partial Success

The plate is detected, but:

- The crop includes too much background
- Part of the plate is missing
- The crop is slightly tilted or unclear
- The result is still somewhat usable

### Failure

The system:

- Detects the wrong region
- Does not detect any plate
- Crops an unreadable region
- Returns an empty plate image
- Crashes or stops processing

The system should avoid crashing. If detection fails, it should return:

```matlab
plateImg = [];
plateBBox = [];
```

---

## 5.2 OCR Result

This metric checks whether the recognized text matches the expected plate text.

Use one of the following labels:

```text
Correct
Partial
Incorrect
UNKNOWN
```

### Correct

OCR output matches the expected plate text.

Example:

```text
Expected: BMS8147
OCR:      BMS8147
```

### Partial

OCR output contains some correct characters but is not fully correct.

Example:

```text
Expected: BMS8147
OCR:      BMS8I47
```

### Incorrect

OCR output is mostly wrong.

Example:

```text
Expected: BMS8147
OCR:      8N581A
```

### UNKNOWN

OCR fails or returns no useful text.

---

## 5.3 State Identification Result

This metric checks whether the predicted state matches the expected state.

Use one of the following labels:

```text
Correct
Incorrect
UNKNOWN
```

### Correct

The predicted state is the same as the expected state.

Example:

```text
Expected State: Selangor
Predicted State: Selangor
```

### Incorrect

The predicted state is different from the expected state.

Example:

```text
Expected State: Selangor
Predicted State: Penang
```

### UNKNOWN

The system cannot identify the state.

---

## 5.4 Segmentation Result

This metric checks whether the system can prepare the plate image and identify possible character regions.

Use one of the following labels:

```text
Useful
Partially Useful
Not Useful
UNKNOWN
```

### Useful

The binary plate image and character candidate regions are clear enough for visualization and OCR preparation.

### Partially Useful

Some character candidates are detected, but the result contains noise, missing characters, or extra regions.

### Not Useful

The segmentation result is too noisy or fails to separate useful character regions.

### UNKNOWN

The plate image is empty or segmentation cannot run.

Important note:

Character segmentation is mainly used for visualization, explanation, and OCR preparation. Final text recognition should use OCR, not template-based character matching.

---

## 5.5 GUI Result

This metric checks whether the GUI works correctly.

Use one of the following labels:

```text
Works
Partially Works
Fails
```

### Works

The GUI loads an image, runs recognition, displays outputs, and does not crash.

### Partially Works

The GUI opens and displays some results, but some outputs are missing or unclear.

### Fails

The GUI does not open, crashes, or cannot run the basic workflow.

---

## 5.6 Overall Result

The overall result summarizes the full system output.

Use one of the following labels:

```text
Success
Partial Success
Failure
```

### Success

A test case is considered successful when:

- Plate detection is successful
- OCR is correct or sufficiently accurate
- State identification is correct
- GUI displays the result properly

### Partial Success

A test case is considered partially successful when:

- Plate detection is partially successful
- OCR is partially correct
- State identification is still correct

or:

- Plate detection is correct
- OCR has minor mistakes
- State identification fails due to OCR error

or:

- The system runs end-to-end but some intermediate results are not ideal

### Failure

A test case is considered failed when:

- Plate detection fails
- OCR fails completely
- State identification is incorrect or unknown
- The system cannot produce a meaningful result
- The GUI crashes or cannot display the result

---

## 6. Optional Quantitative Metrics

The first version can use qualitative labels.

If time allows, the following quantitative metrics may also be calculated.

---

## 6.1 Plate Detection Accuracy

```text
Plate Detection Accuracy = Number of Successful Plate Detections / Total Number of Test Images
```

Example:

```text
Successful detections: 8
Total images: 10

Plate Detection Accuracy = 8 / 10 = 80%
```

---

## 6.2 State Identification Accuracy

```text
State Identification Accuracy = Number of Correct State Predictions / Total Number of Test Images
```

Example:

```text
Correct state predictions: 7
Total images: 10

State Identification Accuracy = 7 / 10 = 70%
```

---

## 6.3 OCR Exact Match Accuracy

```text
OCR Exact Match Accuracy = Number of Exactly Correct OCR Results / Total Number of Test Images
```

Example:

```text
Exact OCR matches: 5
Total images: 10

OCR Exact Match Accuracy = 5 / 10 = 50%
```

---

## 6.4 OCR Character-Level Accuracy

If expected plate text is available, character-level accuracy may be estimated.

```text
Character-Level Accuracy = Number of Correct Characters / Total Number of Characters
```

Example:

```text
Expected: BMS8147
OCR:      BMS8I47

Correct characters: 6
Total characters: 7

Character-Level Accuracy = 6 / 7 = 85.7%
```

This metric is optional.

---

## 6.5 Module-Level Success Count

For development and contribution tracking, each member may record how many test cases worked for their module.

Example:

```text
Member 1 preprocessing useful outputs: 5 / 6 images
Member 2 successful plate detections: 4 / 6 images
Member 3 useful segmentation outputs: 3 / 5 plate samples
Member 4 correct state identifications: 4 / 5 OCR strings
```

This metric is optional but useful for individual contribution evidence.

---

## 7. Test Result Table

The evaluation results should be recorded in a structured table.

Recommended file:

```text
results_template.csv
```

Recommended columns:

```csv
image_name,vehicle_type,expected_text,ocr_text,expected_state,predicted_state,detection_result,ocr_result,state_result,overall_result,notes
```

---

## 8. Test Result Table Description

| Column Name | Description |
|---|---|
| image_name | Test image file name |
| vehicle_type | Car, motorcycle, bus, etc. |
| expected_text | Actual plate text if known |
| ocr_text | Recognized text from OCR |
| expected_state | Actual registered state |
| predicted_state | State predicted by the system |
| detection_result | Success, Partial Success, or Failure |
| ocr_result | Correct, Partial, Incorrect, or UNKNOWN |
| state_result | Correct, Incorrect, or UNKNOWN |
| overall_result | Success, Partial Success, or Failure |
| notes | Observations or failure reasons |

---

## 9. Example Test Result Table

| Image Name | Vehicle Type | Expected Text | OCR Text | Expected State | Predicted State | Detection Result | OCR Result | State Result | Overall Result | Notes |
|---|---|---|---|---|---|---|---|---|---|
| car_selangor_close_01.jpg | Car | BMS8147 | BMS8147 | Selangor | Selangor | Success | Correct | Correct | Success | Clear front-facing plate |
| motorcycle_penang_angle_01.jpg | Motorcycle | PAB1234 | PA81234 | Penang | Penang | Partial Success | Partial | Correct | Partial Success | OCR confused B and 8 |
| bus_kualalumpur_far_01.jpg | Bus | WXY5678 | UNKNOWN | Kuala Lumpur | UNKNOWN | Failure | UNKNOWN | UNKNOWN | Failure | Plate too small and blurry |

---

## 10. Module-Level Evaluation Table

During parallel development, each member may also use a module-level evaluation table.

Recommended columns:

```csv
member,module,test_input,expected_output,actual_output,result,notes
```

Example:

| Member | Module | Test Input | Expected Output | Actual Output | Result | Notes |
|---|---|---|---|---|---|---|
| Member 1 | Preprocessing | sample_car.jpg | Clear grayscale/enhanced image | Enhanced image generated | Success | Contrast improved |
| Member 2 | Plate Detection | sample_car.jpg | Plate bounding box | Empty bbox | Failure | Background too complex |
| Member 3 | Segmentation | plate_selangor_01.jpg | Character candidates | 6 candidates | Partial Success | One character merged |
| Member 4 | State Identification | BMS8147 | Selangor | Selangor | Success | Prefix B matched |

This table is optional but useful for reporting individual contributions.

---

## 11. Evaluation Procedure

Each test image should be evaluated using the same pipeline.

---

## 11.1 Step-by-Step Full Pipeline Evaluation

```text
Select test image
↓
Record expected plate text and state
↓
Load image into the system
↓
Run preprocessing
↓
Run plate detection
↓
Run plate cropping
↓
Run plate preparation
↓
Run segmentation if needed
↓
Run OCR
↓
Clean OCR text
↓
Run state identification
↓
Display result
↓
Record outputs
↓
Assign result labels
↓
Write notes and failure reasons
```

---

## 11.2 Evaluation Using main.m

For initial testing, use:

```text
main.m
```

This is suitable for:

- Single image testing
- Debugging pipeline functions
- Saving intermediate outputs
- Checking whether the pipeline runs
- Checking fallback behavior

---

## 11.3 Evaluation Using GUI

For demonstration and final screenshots, use:

```text
launch_gui.m
```

This is suitable for:

- Showing system usability
- Demonstrating final prototype
- Capturing GUI screenshots for the report
- Individual presentation recording
- Showing both success and failure cases

---

## 11.4 Evaluation Using evaluateSingleImage.m

For structured evaluation, use:

```text
src/evaluation/evaluateSingleImage.m
```

This function should:

1. Load a test image.
2. Run the full pipeline.
3. Compare outputs with expected values.
4. Return a structured result row.

The result row should include:

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

---

## 11.5 Evaluation Using Scratch Test Scripts

For module-level testing during parallel development, use:

```text
scratch/test_member1_preprocessing.m
scratch/test_member2_plate_detection.m
scratch/test_member3_segmentation.m
scratch/test_member4_recognition_gui.m
```

These scripts allow each member to test their own module independently.

---

## 12. Member-Based Evaluation Responsibility

Each member should evaluate their assigned module and provide at least one success case and one difficult or failure case.

---

## 12.1 Member 1: Dataset and Preprocessing

Assigned folders and files:

```text
src/preprocessing/
images/
dataset_metadata.csv
scratch/test_member1_preprocessing.m
```

Evaluation focus:

- Image loading
- Grayscale conversion
- Contrast enhancement
- Noise reduction
- Preprocessing debug outputs
- Effect of lighting and noise

Recommended test inputs:

```text
images/test/sample_car.jpg
images/test/success_cases/
images/test/difficult_cases/
```

Member 1 should provide:

- At least one successful preprocessing example
- At least one difficult preprocessing example
- Screenshots of grayscale, enhanced, and filtered images
- Notes about how preprocessing affects plate detection

---

## 12.2 Member 2: Plate Detection

Assigned folders and files:

```text
src/plate_detection/
scratch/test_member2_plate_detection.m
```

Evaluation focus:

- Edge detection result
- Candidate region extraction
- Region property filtering
- Bounding box selection
- Plate cropping
- Detection failure reasons

Recommended test inputs:

```text
images/test/sample_car.jpg
images/test/success_cases/
images/test/difficult_cases/
images/test/failure_cases/
```

Member 2 should provide:

- At least one successful plate detection example
- At least one failed or difficult plate detection example
- Bounding box or cropped plate screenshots
- Notes about false candidates or missed plates

---

## 12.3 Member 3: Segmentation and Morphology

Assigned folders and files:

```text
src/segmentation/
images/test/plate_samples/
scratch/test_member3_segmentation.m
```

Evaluation focus:

- Plate binarization
- Morphological cleanup
- Character candidate extraction
- Quality of binary and cleaned images
- Segmentation failure reasons

Recommended test inputs:

```text
images/test/plate_samples/
```

Member 3 should provide:

- At least one useful segmentation example
- At least one failed or difficult segmentation example
- Binary image screenshots
- Cleaned image screenshots
- Character candidate visualization if possible

Important note:

Character segmentation is for visualization, explanation, and OCR preparation. It should not be evaluated as template-based character recognition.

---

## 12.4 Member 4: Recognition, GUI, and Evaluation

Assigned folders and files:

```text
src/recognition/
src/evaluation/
src/utils/
launch_gui.m
scratch/test_member4_recognition_gui.m
```

Evaluation focus:

- OCR result
- OCR text cleaning
- State prefix mapping
- GUI output
- Evaluation CSV recording
- Handling of `UNKNOWN` output

Recommended test inputs:

```text
images/test/plate_samples/
images/test/success_cases/
images/test/failure_cases/
```

Temporary OCR strings may also be used:

```text
BMS8147
PAB1234
MAB5678
WXY5678
```

Member 4 should provide:

- At least one successful OCR/state identification example
- At least one OCR or state identification failure example
- GUI screenshot
- Example result row
- Notes about OCR errors and prefix-based state identification

---

## 13. Success Case Analysis

For each successful case, explain why the system worked well.

Possible reasons:

- Plate was clearly visible
- Plate had high contrast
- Vehicle was close to the camera
- Lighting was good
- Background was simple
- Plate was nearly horizontal
- Characters were clear
- Morphological processing cleaned the plate well
- OCR received a clear plate image
- State prefix was recognized correctly

---

## 14. Partial Success Analysis

For partial success cases, explain what worked and what did not.

Possible examples:

- Plate detection was correct, but OCR misread some characters
- Plate was cropped but included extra background
- State identification was correct even though the full OCR text was not perfect
- OCR recognized letters but failed on numbers
- Segmentation worked, but character boundaries were not clean
- GUI displayed output, but the detected plate image was not clear

---

## 15. Failure Case Analysis

Failure cases are important for the report.

Do not delete failed cases.

Each failure case should be analyzed critically.

Possible failure reasons:

- Plate was too small
- Plate was blurred
- Plate was angled
- Plate was partially hidden
- Image lighting was too dark
- Strong reflection appeared on the plate
- Background contained similar rectangular objects
- Wrong region was selected as the plate
- Edge detection produced too many false regions
- Morphological processing removed useful plate information
- OCR could not read the text
- OCR confused similar characters
- State prefix was not recognized
- A module returned a fallback value because it was not fully implemented

---

## 16. Module-Based Failure Analysis

When a test case fails, identify which stage most likely caused the failure.

| Failed Stage | Possible Cause | Example Note |
|---|---|---|
| Preprocessing | Poor contrast or excessive noise | Low-light image remained unclear after enhancement |
| Plate Detection | Wrong candidate region selected | Background rectangle was detected as plate |
| Plate Cropping | Bounding box too large or too small | Crop included too much background |
| Segmentation | Characters merged or disappeared | Morphological cleaning removed thin strokes |
| OCR | Characters misread | OCR confused B and 8 |
| State Identification | Wrong first character | OCR changed B to P, causing wrong state |
| GUI | Output not displayed | Empty image was not handled correctly |

This table can be used in the discussion and critical analysis sections of the report.

---

## 17. OCR Error Analysis

OCR may produce incorrect results because some characters look similar.

Common OCR confusion examples:

| Actual Character | Misread As |
|---|---|
| 0 | O |
| O | 0 |
| 1 | I |
| I | 1 |
| 5 | S |
| S | 5 |
| 8 | B |
| B | 8 |
| 2 | Z |
| Z | 2 |

These errors should be discussed when OCR output affects state identification.

---

## 18. State Identification Analysis

State identification depends heavily on the first character or prefix of the recognized plate text.

---

## 18.1 Correct State Identification

Example:

```text
OCR Text: BMS8147
Prefix: B
Predicted State: Selangor
```

---

## 18.2 Incorrect State Identification

Example:

```text
Expected Text: BMS8147
OCR Text: PMS8147
Expected State: Selangor
Predicted State: Penang
```

In this case, OCR misread the first character, which caused the wrong state prediction.

---

## 18.3 UNKNOWN State

Example:

```text
OCR Text: UNKNOWN
Predicted State: UNKNOWN
```

This may happen when:

- OCR fails
- Plate detection fails
- The prefix is not in the mapping table
- The text is empty after cleaning

---

## 19. GUI Evaluation

The GUI should also be evaluated.

Check whether:

- The GUI opens successfully
- Image loading works
- Original image is displayed
- Run Recognition button works
- Detected plate is displayed or failure is handled
- Recognized text is displayed
- Identified state is displayed
- Status messages are clear
- The GUI does not crash when recognition fails
- The GUI can display `UNKNOWN` when OCR or state identification fails

---

## 20. Evaluation Checklist

For each full-pipeline test image, check the following:

```text
[ ] Image loads correctly
[ ] Original image is displayed
[ ] Preprocessing runs
[ ] Plate detection runs
[ ] Plate crop is generated or failure is handled
[ ] Segmentation runs or safely returns empty output
[ ] OCR runs or returns UNKNOWN
[ ] OCR text is cleaned
[ ] State identification runs
[ ] Result is displayed
[ ] Result is recorded
[ ] Failure reason is noted if needed
```

---

## 21. Module-Level Evaluation Checklist

## 21.1 Member 1 Checklist

```text
[ ] sample_car.jpg exists
[ ] preprocessImage runs
[ ] grayscale image is generated
[ ] enhanced image is generated
[ ] filtered image is generated
[ ] preprocessDebug is returned
[ ] preprocessing screenshots are available
```

---

## 21.2 Member 2 Checklist

```text
[ ] sample_car.jpg exists
[ ] temporary grayscale conversion works if preprocessing is not ready
[ ] detectPlateRegion runs
[ ] plateBBox is returned or safely empty
[ ] plateImg is returned or safely empty
[ ] detectionDebug is returned
[ ] detection screenshots are available
```

---

## 21.3 Member 3 Checklist

```text
[ ] images/test/plate_samples/ exists
[ ] at least one cropped plate sample exists
[ ] binarizePlate runs
[ ] cleanBinaryImage runs
[ ] segmentCharacters runs
[ ] characterImages and characterBBoxes are returned or safely empty
[ ] segmentation screenshots are available
```

---

## 21.4 Member 4 Checklist

```text
[ ] images/test/plate_samples/ exists or temporary OCR strings are available
[ ] recognizePlateText returns text or UNKNOWN
[ ] cleanRecognizedText runs
[ ] identifyState returns state or UNKNOWN
[ ] launch_gui.m opens
[ ] displayPipelineResults works
[ ] result row can be generated
[ ] saveResultRow works if needed
```

---

## 22. Minimum Evaluation Requirement

The minimum evaluation should include:

- At least one working sample image for initial testing
- At least one manually cropped plate sample for segmentation and OCR testing
- Multiple images for final evaluation
- At least two vehicle types if possible
- At least three plate/state variations if possible
- At least one difficult or failed case for critical analysis
- At least one module-level test result from each member

---

## 23. Recommended Final Evaluation Set

Recommended final evaluation set:

| Category | Recommended Count |
|---|---:|
| Clear car plates | 3 to 5 |
| Motorcycle plates | 2 to 4 |
| Bus plates | 2 to 3 |
| Optional van or truck plates | 1 to 3 |
| Low light or shadow images | 2 to 3 |
| Angled or far plates | 2 to 3 |
| Manually cropped plate samples | 3 to 5 |
| Failure cases | 2 to 3 |

The exact number may depend on group size and available data.

---

## 24. Report Figures for Evaluation

The following figures are useful for the report:

- Original image
- Grayscale or preprocessed image
- Edge detection result
- Morphological processing result
- Detected plate bounding box
- Cropped plate image
- Binary plate image
- Cleaned binary image
- Character candidate visualization
- OCR-ready plate image
- Final GUI output
- Failure case examples

---

## 25. Output Files for Evaluation

Evaluation-related outputs should be saved in:

```text
output/plate_detection/
output/segmentation/
output/recognition/
output/figures/
report/figures/
report/tables/
```

---

## 26. Saving Evaluation Results

Evaluation results should be saved in CSV format.

Recommended file:

```text
results_template.csv
```

or:

```text
report/tables/evaluation_results.csv
```

The system may use:

```text
saveResultRow.m
```

to append new results.

Recommended CSV header:

```csv
image_name,vehicle_type,expected_text,ocr_text,expected_state,predicted_state,detection_result,ocr_result,state_result,overall_result,notes
```

---

## 27. Future Improvement Analysis

The evaluation should lead to future improvement suggestions.

Possible improvements include:

- Improve plate candidate filtering
- Tune aspect ratio thresholds
- Use adaptive thresholding
- Improve contrast enhancement
- Improve morphological cleaning
- Increase plate image resolution before OCR
- Add better handling for angled plates
- Expand state prefix mapping
- Add batch testing
- Improve GUI feedback
- Test with larger and more diverse datasets
- Improve result recording and visualization
- Improve module-level test coverage

---

## 28. Evaluation Limitations

The report should mention limitations honestly.

Possible limitations:

- Small dataset size
- Limited vehicle types
- Limited plate variations
- OCR dependency
- Difficulty with angled plates
- Difficulty with low-light images
- Difficulty with highly reflective plates
- Difficulty with complex backgrounds
- Manual parameter tuning
- Initial placeholder logic during early development
- Limited manually cropped plate samples

---

## 29. Final Evaluation Goal

The final evaluation should show:

1. The system can process vehicle images end-to-end.
2. The system can detect license plate regions in suitable images.
3. The system can prepare detected plate images for OCR.
4. The system can recognize plate text using OCR in clear cases.
5. The system can identify states based on plate prefixes.
6. The GUI can display results clearly.
7. The system has limitations under difficult conditions.
8. The failure analysis explains why errors occur.
9. Each member can demonstrate their assigned module contribution.
10. The future work section proposes realistic improvements.

---

## 30. Notes for Claude or Codex

When generating evaluation-related code:

- Create `evaluateSingleImage.m`.
- Create `saveResultRow.m`.
- Use the same pipeline functions as `main.m`.
- Do not duplicate image processing logic.
- Return structured results.
- Include `overall_result` in the result row.
- Handle detection failure.
- Handle segmentation failure.
- Handle OCR failure.
- Return `UNKNOWN` when recognition fails.
- Save results in CSV format if possible.
- Keep comments and variable names in English.
- Support `results_template.csv`.
- Support `report/tables/evaluation_results.csv` if needed.
- Support scratch test scripts for module-level testing.
- Do not use TensorFlow, Haar Cascade, YOLO, template matching, or pattern matching.
