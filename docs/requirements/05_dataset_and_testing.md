## 1. Purpose

This document defines the dataset preparation and testing plan for the License Plate Recognition (LPR) and State Identification System (SIS).

The purpose of this document is to make sure that test images are collected, organized, named, and evaluated consistently.

The dataset and testing plan should support:

- License plate detection testing
- OCR text recognition testing
- State identification testing
- Module-level testing
- Parallel development
- Experimental result tables
- Failure case analysis
- Report and presentation preparation

---

## 2. Dataset Objective

The dataset should include vehicle images that allow the system to test whether it can:

1. Detect the license plate region.
2. Crop the plate correctly.
3. Prepare the plate image for OCR.
4. Recognize the license plate text.
5. Identify the registered Malaysian state.
6. Handle different vehicle types and image conditions.
7. Support independent testing for each member's assigned module.
8. Support both full-pipeline testing and module-level testing.

---

## 3. Dataset Sources

Images may be collected from the following sources:

- Public image datasets
- Online image sources
- Self-captured vehicle photos
- Group member collected images

All external image sources should be recorded for citation or acknowledgement in the report.

If self-captured images are used, avoid including unnecessary personal information.

---

## 4. Image Collection Rules

## 4.1 Use Relevant Vehicle Images

Images should contain visible vehicle license plates.

Core vehicle types:

- Car
- Motorcycle
- Bus

Optional additional vehicle types:

- Van
- Truck

At minimum, each group member should prepare images covering at least two vehicle types if possible.

---

## 4.2 Use Malaysian Plate Images Where Possible

Since the system identifies Malaysian registered states, Malaysian number plates should be prioritized.

Useful examples include:

- Selangor plates
- Malacca plates
- Penang plates
- Terengganu plates
- Kuala Lumpur plates
- Johor plates
- Perak plates
- Kedah plates
- Negeri Sembilan plates

---

## 4.3 Include Different Plate Variations

Where possible, include different plate representations such as:

- Standard state plates
- Special series plates
- Two-row plates
- Military plates
- Diplomatic plates
- Special status plates

The first implementation may focus mainly on standard state plates, but the report should clearly mention the selected scope.

---

## 4.4 Avoid Irrelevant Images

Avoid images where:

- No license plate is visible.
- The plate is fully covered.
- The plate text is unreadable even for a human.
- The image is too low quality to be useful.
- The vehicle is not relevant to the project scope.

However, difficult images can be kept as failure cases if they are useful for critical analysis.

---

## 5. Required Image Variety

The dataset should include images with different conditions.

## 5.1 Vehicle Type Variety

Core categories:

```text
Car
Motorcycle
Bus
```

Optional categories:

```text
Van
Truck
```

Example:

| Vehicle Type | Purpose |
|---|---|
| Car | Main testing category |
| Motorcycle | Required variation |
| Bus | Larger vehicle and plate placement variation |
| Van | Optional additional test |
| Truck | Optional additional test |

---

## 5.2 Distance Variety

The dataset should include images captured at different distances.

Examples:

- Close distance
- Medium distance
- Far distance

| Distance | Description |
|---|---|
| Close | Plate is large and clear |
| Medium | Plate is visible but smaller |
| Far | Plate is small and difficult to read |

---

## 5.3 Lighting Variety

The dataset should include different lighting conditions.

Examples:

- Bright daylight
- Low light
- Shadow
- Reflection
- Indoor parking lighting
- Overexposed image

| Lighting Condition | Expected Challenge |
|---|---|
| Bright daylight | Usually easier |
| Low light | OCR may fail |
| Shadow | Plate region may be unclear |
| Reflection | Characters may be distorted |
| Indoor lighting | Uneven brightness |

---

## 5.4 Background Variety

The dataset should include different background conditions.

Examples:

- Simple background
- Complex road background
- Parking area
- Urban street
- Background with other rectangular objects

| Background Type | Expected Challenge |
|---|---|
| Simple | Easier detection |
| Complex | More false candidates |
| Parking area | Multiple vehicles may appear |
| Urban road | More noise and objects |
| Similar rectangles | Wrong region may be selected |

---

## 5.5 Angle Variety

The dataset should include different plate angles where possible.

Examples:

- Front view
- Slight side angle
- Tilted plate
- Angled vehicle view

| Angle Type | Expected Challenge |
|---|---|
| Front view | Easier detection and OCR |
| Slight angle | Plate shape may be distorted |
| Strong angle | OCR and bounding box may fail |
| Tilted plate | Requires better preprocessing |

---

## 6. Dataset Folder Structure

Use the following folder structure.

```text
images/
├── raw/
│   ├── car/
│   ├── motorcycle/
│   ├── bus/
│   ├── van/
│   └── truck/
│
├── test/
│   ├── sample_car.jpg
│   ├── plate_samples/
│   ├── success_cases/
│   ├── failure_cases/
│   └── difficult_cases/
│
└── selected_for_report/
```

---

## 7. Folder Descriptions

## 7.1 images/raw

This folder stores original collected images.

Subfolders should be organized by vehicle type.

Example:

```text
images/raw/car/
images/raw/motorcycle/
images/raw/bus/
```

Large raw image datasets should usually not be committed to GitHub.

---

## 7.2 images/test

This folder stores images used for system testing.

Recommended structure:

```text
images/test/sample_car.jpg
images/test/plate_samples/
images/test/success_cases/
images/test/failure_cases/
images/test/difficult_cases/
```

### sample_car.jpg

`sample_car.jpg` is the first sample image used for initial full-pipeline testing.

It is used by:

```text
main.m
scratch/test_member1_preprocessing.m
scratch/test_member2_plate_detection.m
```

For the first runnable version, `images/test/sample_car.jpg` may be placed directly under `images/test/`.

After the system becomes stable, final test images should be organized into:

```text
images/test/success_cases/
images/test/failure_cases/
images/test/difficult_cases/
```

---

## 7.3 images/test/plate_samples

This folder stores manually cropped license plate images.

These images are used for parallel development before automatic plate detection is fully completed.

This folder is mainly used by:

- Member 3 for segmentation and morphological processing
- Member 4 for OCR, state identification, GUI, and evaluation testing

Example files:

```text
images/test/plate_samples/plate_selangor_01.jpg
images/test/plate_samples/plate_penang_01.jpg
images/test/plate_samples/plate_malacca_01.jpg
```

These manually cropped plate images allow Member 3 and Member 4 to work without waiting for Member 2's plate detection module to be completed.

---

## 7.4 images/test/success_cases

This folder stores images that are expected to work well.

Examples:

- Clear car plate image
- Good lighting
- Simple background
- Front-facing plate

---

## 7.5 images/test/failure_cases

This folder stores images where the system fails or is expected to fail.

Failure cases are important for critical analysis.

Examples:

- Very small plate
- Strong reflection
- Blurry image
- Wrong region detected
- OCR returns incorrect text

---

## 7.6 images/test/difficult_cases

This folder stores challenging images that may produce partial success.

Examples:

- Angled plate
- Low light
- Complex background
- Shadow on plate
- Far distance image

---

## 7.7 images/selected_for_report

This folder stores selected images that will be used in the final report.

These images should include:

- Representative success cases
- Representative failure cases
- Different vehicle types
- Different plate states
- Different image conditions
- GUI output examples if needed

---

## 8. Development Sample Data

For parallel development, the project should include small sample data for module-level testing.

Required sample files or folders:

```text
images/test/sample_car.jpg
images/test/plate_samples/
```

## 8.1 sample_car.jpg

This image is used for the first runnable version of `main.m`.

It is also used by Member 1 and Member 2 for early module testing.

## 8.2 plate_samples

This folder contains manually cropped license plate images.

These images are used by:

- Member 3 for segmentation and morphology testing
- Member 4 for OCR and state identification testing

Example:

```text
images/test/plate_samples/plate_selangor_01.jpg
images/test/plate_samples/plate_penang_01.jpg
images/test/plate_samples/plate_malacca_01.jpg
```

## 8.3 Temporary OCR Strings

For early testing of state identification, Member 4 may use temporary OCR strings.

Examples:

```text
BMS8147
PAB1234
MAB5678
WXY5678
```

These are useful when OCR or plate detection is not fully completed yet.

---

## 9. Image Naming Convention

Use clear and descriptive image names.

Recommended format:

```text
vehicle_state_condition_number.extension
```

Example:

```text
car_selangor_close_01.jpg
car_malacca_daylight_01.jpg
motorcycle_terengganu_angle_01.jpg
bus_penang_far_01.jpg
car_kualalumpur_shadow_01.jpg
```

For manually cropped plate samples, use:

```text
plate_state_number.extension
```

Example:

```text
plate_selangor_01.jpg
plate_penang_01.jpg
plate_malacca_01.jpg
```

---

## 10. Naming Components

## 10.1 Vehicle Type

Examples:

```text
car
motorcycle
bus
van
truck
```

## 10.2 State

Examples:

```text
selangor
malacca
penang
terengganu
kualalumpur
johor
perak
kedah
negerisembilan
unknown
```

## 10.3 Condition

Examples:

```text
close
medium
far
daylight
lowlight
shadow
reflection
angle
complexbg
```

## 10.4 Number

Use two-digit numbering.

Examples:

```text
01
02
03
```

---

## 11. Example File Names

```text
car_selangor_close_01.jpg
car_selangor_shadow_02.jpg
car_malacca_daylight_01.jpg
motorcycle_penang_angle_01.jpg
motorcycle_terengganu_lowlight_02.jpg
bus_kualalumpur_far_01.jpg
van_johor_complexbg_01.jpg
plate_selangor_01.jpg
plate_penang_01.jpg
plate_malacca_01.jpg
```

---

## 12. Dataset Metadata

A metadata file should be created to describe the test images.

Recommended file:

```text
dataset_metadata.csv
```

Recommended columns:

| Column Name | Description |
|---|---|
| image_name | Image file name |
| image_path | Relative path to image |
| vehicle_type | Vehicle type |
| expected_plate_text | Actual plate text if known |
| expected_state | Actual registered state |
| plate_type | Standard, special, military, etc. |
| distance | Close, medium, far |
| lighting | Daylight, lowlight, shadow, reflection |
| background | Simple, complex, parking, road |
| angle | Front, side, tilted |
| source | Self-captured, dataset, website |
| notes | Additional information |

---

## 13. Example Metadata Row

```csv
image_name,image_path,vehicle_type,expected_plate_text,expected_state,plate_type,distance,lighting,background,angle,source,notes
car_selangor_close_01.jpg,images/test/success_cases/car_selangor_close_01.jpg,car,BMS8147,Selangor,standard,close,daylight,simple,front,self-captured,clear plate
```

Example for a manually cropped plate sample:

```csv
image_name,image_path,vehicle_type,expected_plate_text,expected_state,plate_type,distance,lighting,background,angle,source,notes
plate_selangor_01.jpg,images/test/plate_samples/plate_selangor_01.jpg,plate_sample,BMS8147,Selangor,standard,unknown,unknown,unknown,front,self-captured,manually cropped plate sample
```

---

## 14. Testing Scope

## 14.1 Minimum Testing Scope

The minimum testing set should include:

- At least two vehicle types
- At least three to four plate/state variations
- Both easy and difficult images
- At least one failure or difficult case for analysis
- At least one manually cropped plate sample for segmentation and OCR testing

---

## 14.2 Recommended Testing Scope

Recommended test set:

| Category | Recommended Count |
|---|---:|
| Car images | 5 to 10 |
| Motorcycle images | 3 to 5 |
| Bus images | 2 to 3 |
| Optional van or truck images | 1 to 3 |
| Manually cropped plate samples | 3 to 5 |
| Easy success cases | 3 to 5 |
| Difficult cases | 3 to 5 |
| Failure cases | 2 to 3 |

---

## 14.3 Selected Report Images

For the final report, select approximately:

- 3 to 5 successful examples
- 2 to 3 failed or difficult examples
- At least 2 vehicle types
- At least 3 state or plate variations if available
- 1 to 2 manually cropped plate samples if useful for explaining segmentation or OCR

---

## 15. Member-Based Dataset Responsibility

## 15.1 Member 1: Dataset and Preprocessing

Member 1 should prepare and organize:

```text
images/test/sample_car.jpg
images/raw/
dataset_metadata.csv
```

Member 1 should ensure that basic test images are available for the full pipeline and preprocessing tests.

Member 1 should also record metadata such as:

- Image name
- Image path
- Vehicle type
- Expected plate text if known
- Expected state if known
- Lighting condition
- Distance
- Background
- Source

---

## 15.2 Member 2: Plate Detection

Member 2 should use:

```text
images/test/sample_car.jpg
images/test/success_cases/
images/test/difficult_cases/
```

Member 2 should identify images suitable for plate detection testing.

Useful detection test images include:

- Clear rectangular plates
- Complex backgrounds
- Similar rectangular objects
- Different distances
- Different angles

---

## 15.3 Member 3: Segmentation and Morphology

Member 3 should use:

```text
images/test/plate_samples/
```

Member 3 should prepare or request manually cropped plate samples if automatic plate detection is not ready.

Useful segmentation test images include:

- Clear cropped plate
- Slightly noisy plate
- Low contrast plate
- Plate with touching characters
- Plate with reflection or shadow

---

## 15.4 Member 4: OCR, State Identification, GUI, and Evaluation

Member 4 should use:

```text
images/test/plate_samples/
images/test/success_cases/
images/test/failure_cases/
results_template.csv
```

Member 4 may also use temporary OCR strings for state identification testing.

Examples:

```text
BMS8147
PAB1234
MAB5678
WXY5678
```

Member 4 should help prepare:

- OCR test results
- State identification results
- GUI screenshots
- Evaluation CSV rows

---

## 16. Testing Procedure

Each test image should be processed using the same pipeline.

## 16.1 Full Pipeline Testing Steps

```text
Load test image
↓
Run preprocessing
↓
Run plate detection
↓
Crop plate region
↓
Prepare plate image
↓
Run OCR
↓
Clean OCR output
↓
Identify state
↓
Record result
```

---

## 16.2 Module-Level Testing Steps

Module-level testing is used during parallel development.

### Member 1 Test

```text
Load sample_car.jpg
↓
Run preprocessImage
↓
Display grayscale / enhanced / filtered images
↓
Save preprocessing debug outputs if needed
```

### Member 2 Test

```text
Load sample_car.jpg
↓
Use preprocessImage or temporary grayscale conversion
↓
Run detectPlateRegion
↓
Display plate candidate / cropped plate / fallback result
```

### Member 3 Test

```text
Load manually cropped plate image from images/test/plate_samples/
↓
Run binarizePlate
↓
Run cleanBinaryImage
↓
Run segmentCharacters
↓
Display binary / cleaned / character candidate results
```

### Member 4 Test

```text
Load manually cropped plate image or use temporary OCR string
↓
Run recognizePlateText
↓
Run cleanRecognizedText
↓
Run identifyState
↓
Record result or display GUI output
```

---

## 16.3 Manual Result Checking

For each image, manually check:

- Was the correct plate region detected?
- Was the cropped plate readable?
- Did OCR return the correct or partially correct text?
- Was the state identified correctly?
- What caused failure if the result was incorrect?
- Was the failure caused by preprocessing, detection, segmentation, OCR, or state identification?

---

## 17. Test Result Recording

Test results should be recorded in:

```text
results_template.csv
```

or a similar CSV file.

Recommended columns:

| Column Name | Description |
|---|---|
| image_name | Test image file name |
| vehicle_type | Car, motorcycle, bus, etc. |
| expected_text | Actual plate text |
| ocr_text | OCR result |
| expected_state | Actual state |
| predicted_state | System output state |
| detection_result | Success, Partial Success, Failure |
| ocr_result | Correct, Partial, Incorrect, UNKNOWN |
| state_result | Correct, Incorrect, UNKNOWN |
| overall_result | Success, Partial Success, Failure |
| notes | Failure reason or observation |

---

## 18. Example Test Result Row

```csv
image_name,vehicle_type,expected_text,ocr_text,expected_state,predicted_state,detection_result,ocr_result,state_result,overall_result,notes
car_selangor_close_01.jpg,car,BMS8147,BMS8147,Selangor,Selangor,Success,Correct,Correct,Success,Plate was clear and front-facing
```

Example for a failure case:

```csv
image_name,vehicle_type,expected_text,ocr_text,expected_state,predicted_state,detection_result,ocr_result,state_result,overall_result,notes
bus_kualalumpur_far_01.jpg,bus,WXY5678,UNKNOWN,Kuala Lumpur,UNKNOWN,Failure,UNKNOWN,UNKNOWN,Failure,Plate was too small and blurry
```

---

## 19. Result Categories

## 19.1 Detection Result

Use one of the following values:

```text
Success
Partial Success
Failure
```

### Success

The correct license plate region is detected and cropped.

### Partial Success

The plate is detected but the crop is incomplete, too large, or includes extra background.

### Failure

The system detects the wrong region or no plate region.

---

## 19.2 OCR Result

Use one of the following values:

```text
Correct
Partial
Incorrect
UNKNOWN
```

### Correct

OCR text matches the expected plate text.

### Partial

OCR text contains some correct characters but is not fully correct.

### Incorrect

OCR text is mostly wrong.

### UNKNOWN

OCR fails or returns no useful result.

---

## 19.3 State Result

Use one of the following values:

```text
Correct
Incorrect
UNKNOWN
```

### Correct

The predicted state matches the expected state.

### Incorrect

The predicted state does not match the expected state.

### UNKNOWN

The system cannot identify the state.

---

## 19.4 Overall Result

Use one of the following values:

```text
Success
Partial Success
Failure
```

### Success

The plate region is detected correctly, OCR is correct or sufficiently accurate, and the state is correctly identified.

### Partial Success

The system produces a partially useful result, but at least one stage is incomplete or inaccurate.

### Failure

The system cannot produce a meaningful result, or the final state identification is incorrect or unknown.

---

## 20. Success Case Criteria

A test case is considered successful if:

1. The plate region is correctly detected.
2. The OCR text is correct or sufficiently close.
3. The state is correctly identified.

A case may still be useful if OCR is partially correct but the state is identified correctly.

---

## 21. Partial Success Criteria

A test case is considered partially successful if:

- The plate is detected but not perfectly cropped.
- OCR reads some characters correctly.
- The state is identified correctly but the full plate text is not perfect.
- The output is usable but still requires improvement.

---

## 22. Failure Case Criteria

A test case is considered failed if:

- No plate region is detected.
- The wrong region is detected.
- The cropped plate is unreadable.
- OCR returns incorrect text.
- The state is incorrectly identified.
- The system returns `UNKNOWN`.

---

## 23. Failure Analysis

Failure cases should not be deleted.

They should be saved and analyzed for the report.

Failure cases should be linked to the likely failed stage:

- Preprocessing failure
- Plate detection failure
- Segmentation or morphology failure
- OCR failure
- State identification failure

---

## 24. Common Failure Reasons

Possible failure reasons include:

- Plate is too small.
- Image is too blurry.
- Vehicle is too far from the camera.
- Plate is angled.
- Plate is partially covered.
- Lighting is too dark.
- Strong reflection appears on the plate.
- Background contains similar rectangular objects.
- Plate text has low contrast.
- Characters are too close together.
- OCR misreads similar characters.
- Morphological processing removes useful text details.
- Function returns fallback output because the module is not fully implemented yet.

---

## 25. OCR-Specific Failure Reasons

OCR may fail due to:

- Low image resolution
- Small character size
- Unclear character boundaries
- Incorrect binarization
- Noise remaining around characters
- Similar-looking characters
- Empty plate image
- Plate crop includes too much background

Common OCR confusion examples:

| Character 1 | Character 2 |
|---|---|
| 0 | O |
| 1 | I |
| 5 | S |
| 8 | B |
| 2 | Z |

---

## 26. Report Use

The dataset and testing results should support the following report sections:

- Experimental Results
- Discussion of Obtained Results
- Critical Comments
- Future Work Direction

Useful report figures include:

- Original image
- Preprocessed image
- Edge detection result
- Binary image
- Cleaned binary image
- Detected plate image
- OCR-ready image
- Character candidate visualization
- GUI final output
- Failure case examples

---

## 27. Output Image Saving

Important output images should be saved in:

```text
output/plate_detection/
output/segmentation/
output/recognition/
output/figures/
```

Examples:

```text
output/plate_detection/car_selangor_close_01_detected.jpg
output/segmentation/car_selangor_close_01_binary.jpg
output/recognition/car_selangor_close_01_ocr_ready.jpg
output/figures/car_selangor_close_01_final_result.jpg
```

For member-level evidence, output images may also be copied into:

```text
report/figures/
```

---

## 28. Dataset Version Control

GitHub will be used mainly for source code and documentation sharing.

Recommended files to include in GitHub:

- MATLAB source code
- Requirement documents
- README
- Metadata CSV
- Results template
- Scratch test scripts
- Small selected test images if needed
- Small manually cropped plate samples if needed

Avoid committing:

- Large raw image datasets
- Too many output images
- Videos
- ZIP files

---

## 29. Recommended `.gitignore` for Dataset

```gitignore
# Large raw datasets
images/raw/

# Output images
output/

# Video recordings
*.mp4
*.mov
*.avi
*.mkv

# Archives
*.zip
*.rar
*.7z
```

If the team wants to share selected test images through GitHub, keep them in:

```text
images/test/
images/test/plate_samples/
images/selected_for_report/
```

and keep the number of files small.

---

## 30. Dataset Quality Checklist

Before testing, confirm that:

- The image contains a visible license plate.
- The vehicle type is recorded.
- The expected state is recorded if known.
- The expected plate text is recorded if known.
- The file name follows the naming convention.
- The image is placed in the correct folder.
- The image source is recorded.
- Difficult images are clearly marked.
- Manually cropped plate samples are placed in `images/test/plate_samples/` if needed.
- Metadata is updated in `dataset_metadata.csv`.

---

## 31. Testing Checklist

For each test image, confirm that:

- The image can be loaded.
- The original image is displayed.
- The plate detection step runs.
- The plate crop is generated or failure is handled.
- OCR runs or returns `UNKNOWN`.
- The state identification runs.
- The result is recorded.
- Output images are saved if needed.
- Failure reason is noted if applicable.

---

## 32. Module-Level Testing Checklist

## 32.1 Member 1 Checklist

```text
[ ] sample_car.jpg exists
[ ] preprocessImage runs
[ ] grayscale image is generated
[ ] enhanced image is generated
[ ] filtered image is generated
[ ] debug outputs are available
```

## 32.2 Member 2 Checklist

```text
[ ] sample_car.jpg exists
[ ] temporary grayscale conversion works if preprocessing is not ready
[ ] detectPlateRegion runs
[ ] plateBBox is returned or safely empty
[ ] plateImg is returned or safely empty
[ ] detection debug outputs are available
```

## 32.3 Member 3 Checklist

```text
[ ] images/test/plate_samples/ exists
[ ] at least one cropped plate sample exists
[ ] binarizePlate runs
[ ] cleanBinaryImage runs
[ ] segmentCharacters runs
[ ] characterImages and characterBBoxes are returned or safely empty
```

## 32.4 Member 4 Checklist

```text
[ ] images/test/plate_samples/ exists or temporary OCR strings are available
[ ] recognizePlateText returns text or UNKNOWN
[ ] cleanRecognizedText runs
[ ] identifyState returns state or UNKNOWN
[ ] launch_gui.m opens
[ ] result row can be recorded if needed
```

---

## 33. Minimum Working Dataset

For the first runnable version, prepare at least:

```text
images/test/sample_car.jpg
```

This file is used by:

```text
main.m
scratch/test_member1_preprocessing.m
scratch/test_member2_plate_detection.m
```

For parallel development, also prepare at least one manually cropped plate image if possible:

```text
images/test/plate_samples/plate_selangor_01.jpg
```

The first version only needs one vehicle image and one cropped plate sample to confirm that the full pipeline and module-level tests can run.

---

## 34. Final Dataset Goal

The final project should include a test set with:

- Multiple vehicle types
- Multiple states or plate prefixes
- Different image conditions
- Success cases
- Difficult cases
- Failure cases
- Manually cropped plate samples for segmentation and OCR explanation if useful
- Sufficient examples for experimental analysis

---

## 35. Notes

- Do not focus only on easy images.
- Keep difficult images for critical analysis.
- Do not delete failed cases.
- Record all testing observations.
- Use the same pipeline for each test image.
- Save important outputs for report screenshots.
- Use `sample_car.jpg` for the first full-pipeline test.
- Use `plate_samples/` for parallel development of segmentation, OCR, and state identification.
- Keep large raw datasets out of GitHub.
- Keep small selected test images in GitHub only if needed by the team.