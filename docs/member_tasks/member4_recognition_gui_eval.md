# Member 4 Task: Recognition, GUI, and Evaluation

## 1. Purpose

This document defines the task details for Member 4.

Member 4 is responsible for OCR-based text recognition, OCR text cleaning, Malaysian state identification, GUI implementation, utility functions, and evaluation result recording for the License Plate Recognition (LPR) and State Identification System (SIS).

The goal of this task is to produce the final user-visible output of the system and support evaluation for the report.

---

## 2. Main Responsibility

Member 4 is responsible for:

- OCR-based license plate text recognition
- OCR fallback handling
- OCR text cleaning
- Malaysian state identification
- GUI implementation
- Final result display
- Output folder creation
- Intermediate and final image saving utilities
- Evaluation result generation
- CSV result saving
- GUI and recognition module testing
- Recognition, GUI, and evaluation-related report content

Member 4’s module depends on earlier modules, but it must also be testable independently using manually cropped plate samples or temporary OCR strings.

---

## 3. Assigned Folders

Member 4 should mainly work in the following folders:

```text
src/recognition/
src/evaluation/
src/utils/
```

Member 4 is also responsible for the root GUI file:

```text
launch_gui.m
```

Member 4 may also update:

```text
scratch/test_member4_recognition_gui.m
results_template.csv
output/recognition/
output/figures/
report/figures/
report/tables/
```

---

## 4. Assigned Files

Member 4 is mainly responsible for the following files:

```text
src/recognition/recognizePlateText.m
src/recognition/cleanRecognizedText.m
src/recognition/identifyState.m

src/evaluation/evaluateSingleImage.m
src/evaluation/saveResultRow.m

src/utils/displayPipelineResults.m
src/utils/saveStepImage.m
src/utils/ensureOutputFolders.m

launch_gui.m
scratch/test_member4_recognition_gui.m
```

---

## 5. Related System Requirements

Member 4 is mainly related to the following system requirements:

```text
FR-08: Recognize Plate Text
FR-09: Clean OCR Output
FR-10: Identify Registered State
FR-11: Display Final Results
FR-12: Save Output Images
FR-13: Record Test Results
FR-14: Provide GUI Operation
FR-15: Support Parallel Development
FR-17: Support Independent Module Testing
```

---

## 6. Related Technical Constraints

Member 4 must follow these constraints:

- Use MATLAB `.m` files.
- Use script-based MATLAB GUI for the first version.
- Use English comments and variable names.
- Do not use TensorFlow.
- Do not use Haar Cascade.
- Do not use YOLO.
- Do not use deep learning object detectors.
- Do not use template matching.
- Do not use pattern matching.
- Do not use character recognition by comparing with fixed template images.
- Use OCR only after plate detection and plate image preparation.
- Do not apply OCR directly to the full original image as the only processing step.
- Use relative paths where possible.
- Keep function names consistent with file names.
- Do not change agreed function signatures without team discussion.
- Return safe fallback outputs if OCR, state identification, GUI display, or evaluation fails.

---

## 7. Input Data

## 7.1 Final Pipeline Input

In the final system, Member 4 mainly receives:

```text
plateImg
rawText
cleanedText
```

The normal final pipeline flow is:

```text
plateImg
↓
recognizePlateText
↓
cleanRecognizedText
↓
identifyState
↓
displayPipelineResults / GUI
↓
evaluateSingleImage / saveResultRow
```

Expected calls:

```matlab
rawText = recognizePlateText(plateImg);

cleanedText = cleanRecognizedText(rawText);

stateName = identifyState(cleanedText);
```

---

## 7.2 Temporary Development Input

If Member 2 or Member 3 modules are not completed, Member 4 may use manually cropped plate images from:

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

---

## 7.3 Temporary OCR Strings

If OCR is not working yet, Member 4 may test text cleaning and state identification using temporary OCR strings.

Examples:

```text
BMS8147
PAB1234
MAB5678
WXY5678
JAB1234
AAB4321
```

These temporary strings are only for development and testing.

They should not replace the final OCR-based pipeline.

---

## 8. Expected Outputs

Member 4 should produce:

```text
rawText
cleanedText
stateName
resultRow
GUI display
saved output images
evaluation CSV
```

Where:

- `rawText` is the OCR output.
- `cleanedText` is the cleaned OCR text.
- `stateName` is the identified Malaysian state.
- `resultRow` is a structured evaluation result.
- GUI display shows original image, detected plate, recognized text, identified state, and status.
- Evaluation CSV records experimental results.

---

## 9. Required Function Signatures

Member 4 should use the following function signatures.

```matlab
function rawText = recognizePlateText(plateImg)
```

```matlab
function cleanedText = cleanRecognizedText(rawText)
```

```matlab
function stateName = identifyState(cleanedText)
```

```matlab
function resultRow = evaluateSingleImage(imagePath, expectedText, expectedState, vehicleType)
```

```matlab
function saveResultRow(resultRow, csvPath)
```

```matlab
function displayPipelineResults(originalImg, plateImg, recognizedText, stateName)
```

```matlab
function saveStepImage(img, outputFolder, fileName)
```

```matlab
function ensureOutputFolders()
```

These signatures should not be changed without team discussion.

---

## 10. Function Responsibilities

## 10.1 recognizePlateText.m

### Purpose

Recognizes license plate text using OCR.

### Input

```text
plateImg
```

### Output

```text
rawText
```

### Responsibilities

- Validate the plate image.
- Prepare the plate image for OCR if needed.
- Run OCR using MATLAB OCR functionality if available.
- Extract raw text from OCR output.
- Return `UNKNOWN` if OCR fails or returns empty text.

### Allowed MATLAB Function

```matlab
ocr
```

### Important Rule

OCR should be applied to the detected or cropped plate image.

OCR should not be applied directly to the full original vehicle image as the only processing step.

### Failure Handling

If `plateImg` is empty, return:

```matlab
rawText = "UNKNOWN";
```

If OCR is unavailable or fails, return:

```matlab
rawText = "UNKNOWN";
```

---

## 10.2 cleanRecognizedText.m

### Purpose

Cleans raw OCR output before state identification.

### Input

```text
rawText
```

### Output

```text
cleanedText
```

### Responsibilities

- Convert OCR output to string.
- Convert text to uppercase.
- Remove spaces.
- Remove line breaks.
- Remove punctuation.
- Remove non-alphanumeric characters.
- Return `UNKNOWN` if the cleaned result is empty.

### Allowed MATLAB Functions

```matlab
string
upper
regexprep
strtrim
```

### Example

```text
Raw OCR output:
B M S 8147

Cleaned output:
BMS8147
```

### Failure Handling

If input is empty or invalid, return:

```matlab
cleanedText = "UNKNOWN";
```

---

## 10.3 identifyState.m

### Purpose

Identifies the registered Malaysian state based on the first character or prefix of the cleaned plate text.

### Input

```text
cleanedText
```

### Output

```text
stateName
```

### Responsibilities

- Validate cleaned text.
- Extract the first character or prefix.
- Match the prefix with a Malaysian state mapping.
- Return the identified state name.
- Return `UNKNOWN` if the prefix is not recognized.

### Required Minimum Mapping

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

### Example

```text
Input:
BMS8147

Prefix:
B

Output:
Selangor
```

### Failure Handling

If input is empty, `UNKNOWN`, or the prefix is not recognized, return:

```matlab
stateName = "UNKNOWN";
```

---

## 10.4 evaluateSingleImage.m

### Purpose

Runs the full pipeline on one test image and returns a structured evaluation result.

### Input

```text
imagePath
expectedText
expectedState
vehicleType
```

### Output

```text
resultRow
```

### Responsibilities

- Validate image path.
- Load image.
- Run the full pipeline.
- Compare OCR output with expected text.
- Compare predicted state with expected state.
- Record detection result.
- Record OCR result.
- Record state result.
- Record overall result.
- Record notes or failure reason.

### Required Output Fields

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

### Failure Handling

If the image cannot be loaded, return a result row with:

```text
detection_result = Failure
ocr_result = UNKNOWN
state_result = UNKNOWN
overall_result = Failure
```

---

## 10.5 saveResultRow.m

### Purpose

Saves or appends one evaluation result row to a CSV file.

### Input

```text
resultRow
csvPath
```

### Output

```text
No direct output
```

### Responsibilities

- Check if the CSV file exists.
- Create the CSV file if it does not exist.
- Append the result row if the CSV file already exists.
- Preserve the expected column structure.
- Handle file writing errors safely.

### Expected CSV Header

```csv
image_name,vehicle_type,expected_text,ocr_text,expected_state,predicted_state,detection_result,ocr_result,state_result,overall_result,notes
```

### Allowed MATLAB Functions

```matlab
writetable
readtable
```

---

## 10.6 displayPipelineResults.m

### Purpose

Displays the final pipeline results in a MATLAB figure.

### Input

```text
originalImg
plateImg
recognizedText
stateName
```

### Output

```text
Figure display
```

### Responsibilities

- Display the original vehicle image.
- Display the detected or cropped plate image.
- Display recognized plate text.
- Display identified state.
- Handle empty plate image safely.

### Failure Handling

If `plateImg` is empty, display:

```text
No plate detected
```

or skip the plate image area safely.

---

## 10.7 saveStepImage.m

### Purpose

Saves intermediate or final images to the output folders.

### Input

```text
img
outputFolder
fileName
```

### Output

```text
No direct output
```

### Responsibilities

- Check whether `img` is valid.
- Create output folder if it does not exist.
- Save image using `imwrite`.
- Skip saving safely if the image is empty.

### Allowed MATLAB Function

```matlab
imwrite
```

---

## 10.8 ensureOutputFolders.m

### Purpose

Creates required output and report folders if they do not exist.

### Input

```text
No input
```

### Output

```text
No direct output
```

### Responsibilities

Create the following folders if they do not exist:

```text
output/plate_detection/
output/segmentation/
output/recognition/
output/figures/
report/figures/
report/tables/
```

### Allowed MATLAB Functions

```matlab
exist
mkdir
```

---

## 10.9 launch_gui.m

### Purpose

Provides the graphical user interface for the LPR and SIS system.

### Type

```text
MATLAB script-based GUI
```

### Responsibilities

- Add `src` folders to MATLAB path.
- Create the GUI window.
- Provide a Load Image button.
- Provide a Run Recognition button.
- Display the original image.
- Display the detected plate image or fallback message.
- Display recognized text.
- Display identified state.
- Display status messages.
- Handle missing image, empty plate image, OCR failure, and unknown state safely.
- Call existing pipeline functions instead of duplicating processing logic.

### Recommended GUI Components

```matlab
figure
uicontrol
axes
imshow
guidata
```

### Important Rule

The GUI should call the same functions used by `main.m`.

Do not duplicate image processing logic inside GUI callbacks.

---

## 11. Independent Test Script

Member 4 should use:

```text
scratch/test_member4_recognition_gui.m
```

This script should test:

- `recognizePlateText.m`
- `cleanRecognizedText.m`
- `identifyState.m`
- `displayPipelineResults.m`
- `evaluateSingleImage.m`
- `saveResultRow.m`
- `ensureOutputFolders.m`
- `launch_gui.m`

---

## 12. Suggested Test Script Flow

```text
Clear workspace
↓
Add src folder to MATLAB path
↓
Ensure output folders exist
↓
Test text cleaning with temporary OCR strings
↓
Test state identification with temporary OCR strings
↓
Load manually cropped plate image if available
↓
Run OCR on plate sample
↓
Clean OCR output
↓
Identify state
↓
Display result
↓
Test evaluation row generation if needed
↓
Open or test launch_gui.m
```

Suggested MATLAB flow:

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

## 13. Testing Checklist

Before merging Member 4’s work, confirm:

```text
[ ] images/test/plate_samples/ exists or temporary OCR strings are used
[ ] test_member4_recognition_gui.m runs
[ ] recognizePlateText.m returns text or UNKNOWN
[ ] cleanRecognizedText.m runs
[ ] identifyState.m returns a state or UNKNOWN
[ ] displayPipelineResults.m handles empty plateImg safely
[ ] ensureOutputFolders.m creates output folders
[ ] saveStepImage.m skips empty images safely
[ ] evaluateSingleImage.m returns required result fields
[ ] saveResultRow.m saves or appends CSV rows
[ ] launch_gui.m opens
[ ] GUI loads an image
[ ] GUI displays UNKNOWN safely when recognition fails
[ ] no prohibited methods are used
[ ] no template matching or pattern matching is used
[ ] function signatures are unchanged
[ ] comments and variable names are in English
```

---

## 14. Output Saving

Member 4 may save useful outputs into:

```text
output/recognition/
output/figures/
report/figures/
report/tables/
```

Useful output examples:

```text
output/recognition/plate_selangor_01_ocr_ready.jpg
output/figures/car_selangor_close_01_final_result.jpg
report/figures/gui_success_case.jpg
report/tables/evaluation_results.csv
```

Avoid committing large output folders to GitHub unless the team agrees.

---

## 15. Evaluation Result Responsibility

Member 4 should maintain or support:

```text
results_template.csv
report/tables/evaluation_results.csv
```

The required CSV header is:

```csv
image_name,vehicle_type,expected_text,ocr_text,expected_state,predicted_state,detection_result,ocr_result,state_result,overall_result,notes
```

Member 4 should ensure that `overall_result` is included.

---

## 16. Report Contribution

Member 4 should contribute to the following report sections:

- OCR
- OCR text cleaning
- State identification
- GUI implementation
- Result display
- Evaluation procedure
- Experimental results
- Evaluation table
- OCR failure analysis
- State identification failure analysis
- GUI screenshots and explanation

---

## 17. Recommended Report Figures and Tables

Member 4 should prepare figures and tables such as:

- OCR-ready plate image
- OCR output example
- Text cleaning example
- State identification example
- GUI success case screenshot
- GUI failure case screenshot
- Evaluation result table
- Failure analysis table

Example figure caption:

```text
Figure X. GUI output showing the original image, detected plate region, recognized text, and identified registered state.
```

Example table title:

```text
Table X. Experimental Results of License Plate Recognition and State Identification.
```

---

## 18. Success Criteria

Member 4’s task is considered successful when:

```text
[ ] recognizePlateText.m runs without syntax errors
[ ] OCR returns text or UNKNOWN safely
[ ] cleanRecognizedText.m cleans OCR output correctly
[ ] identifyState.m maps known prefixes correctly
[ ] unknown prefixes return UNKNOWN
[ ] displayPipelineResults.m displays output safely
[ ] ensureOutputFolders.m creates folders
[ ] saveResultRow.m can save result rows
[ ] launch_gui.m opens and runs basic workflow
[ ] GUI does not crash when detection or OCR fails
[ ] Evaluation result includes overall_result
```

---

## 19. Failure Case Analysis

Member 4 should keep and analyze difficult or failed recognition cases.

Common failure causes:

- Plate image is empty.
- Plate crop is too blurry.
- Plate crop has low resolution.
- OCR toolbox is unavailable.
- OCR returns empty text.
- OCR misreads similar characters.
- OCR misreads the first character.
- Text cleaning removes useful characters.
- State prefix is unknown.
- GUI does not display fallback output clearly.
- Evaluation CSV does not match required column structure.

Example analysis sentence:

```text
In this case, the plate region was detected, but OCR misread the first character from B to P. As a result, the state identification module predicted Penang instead of Selangor.
```

Another example:

```text
The OCR module returned UNKNOWN because the cropped plate image was too blurry and the character boundaries were unclear. The GUI handled this failure by displaying UNKNOWN for both recognized text and identified state.
```

---

## 20. Common Problems and Fixes

| Problem | Possible Cause | Suggested Fix |
|---|---|---|
| OCR returns empty text | Plate image is unclear or OCR fails | Return `UNKNOWN` safely |
| OCR toolbox error | OCR function unavailable | Use `try-catch` and return `UNKNOWN` |
| State result is wrong | OCR first character is wrong | Explain as OCR-dependent failure |
| Text cleaning removes too much | Regex too strict | Keep only useful alphanumeric characters |
| GUI cannot find functions | MATLAB path not set | Use `addpath(genpath('src'))` |
| GUI crashes on empty plate | Empty image not checked | Add fallback display |
| CSV save error | Result row columns mismatch | Match required CSV header |
| Output folder missing | Folder not created | Run `ensureOutputFolders()` |

---

## 21. Collaboration Notes

Member 4 should coordinate with all other members because GUI and evaluation depend on the full pipeline.

Member 4 expects:

```matlab
[preprocessedImg, preprocessDebug] = preprocessImage(originalImg);
```

```matlab
[plateImg, plateBBox, detectionDebug] = detectPlateRegion(preprocessedImg, originalImg);
```

```matlab
[characterImages, characterBBoxes] = segmentCharacters(plateImg);
```

Member 4 should then run:

```matlab
rawText = recognizePlateText(plateImg);
cleanedText = cleanRecognizedText(rawText);
stateName = identifyState(cleanedText);
```

If earlier modules are incomplete, Member 4 can use:

```text
images/test/plate_samples/
```

or temporary OCR strings.

---

## 22. Git Notes

Recommended branch for Member 4:

```text
feature/recognition-gui-evaluation
```

Recommended main assigned folders:

```text
src/recognition/
src/evaluation/
src/utils/
```

Recommended root file:

```text
launch_gui.m
```

Branch names are not folder names.

Correct:

```text
Git branch: feature/recognition-gui-evaluation
Assigned folders: src/recognition/, src/evaluation/, src/utils/
```

Incorrect:

```text
Assignment/feature/recognition-gui-evaluation/
```

---

## 23. Before Pull Request Checklist

Before creating a Pull Request to `dev`, Member 4 should check:

```text
[ ] I am on feature/recognition-gui-evaluation
[ ] I mainly edited src/recognition/, src/evaluation/, src/utils/, launch_gui.m, and related test files
[ ] I did not change core function signatures
[ ] I ran scratch/test_member4_recognition_gui.m
[ ] I tested launch_gui.m
[ ] I did not commit large output files
[ ] I did not commit unnecessary generated images
[ ] I used English comments and variable names
[ ] I did not use template matching or pattern matching
[ ] I added useful notes, screenshots, or tables for the report if needed
```

---

## 24. Notes for Claude or Codex

When generating or editing Member 4 files:

- Use MATLAB `.m` files.
- Use script-based GUI for the first version.
- Keep function names matched with file names.
- Use English comments and variable names.
- Keep the required function signatures.
- Add safe fallback handling for empty plate images, OCR failure, unknown prefix, and CSV errors.
- Use OCR only after plate detection and plate image preparation.
- Do not apply OCR directly to the full original image as the only processing step.
- Use classical image processing only.
- Do not use prohibited methods.
- Do not use template matching or pattern matching.
- Generate or update `scratch/test_member4_recognition_gui.m`.
- Support `images/test/plate_samples/`.
- Include `overall_result` in evaluation outputs.
- Make sure `launch_gui.m` can open even if some modules are incomplete.
