# GUI Requirements

## 1. Purpose

This document defines the graphical user interface requirements for the License Plate Recognition (LPR) and State Identification System (SIS).

The GUI should allow users to load a vehicle image, run the license plate recognition pipeline, and view the final results clearly.

The GUI is required because the assignment specifies that the system must show LPR and SIS results through an interface.

This document also defines how the GUI should support parallel development. The GUI should be able to run with placeholder outputs even when some processing modules are not fully completed.

---

## 2. GUI Objective

The GUI should provide a simple and understandable interface for:

1. Loading a vehicle image
2. Displaying the original image
3. Running the recognition process
4. Displaying the detected license plate region
5. Displaying the recognized plate text
6. Displaying the identified registered state
7. Showing processing status and error messages
8. Supporting placeholder outputs during early development
9. Supporting screenshots for the report and presentation

The first version of the GUI does not need to be visually complex.

The main priority is functionality and stability.

---

## 3. GUI Implementation Method

## 3.1 Initial Implementation

The first GUI version should be implemented using MATLAB `.m` files.

Recommended MATLAB components:

```matlab
figure
uicontrol
axes
imshow
set
get
guidata
```

The GUI should be launched from:

```text
launch_gui.m
```

---

## 3.2 App Designer

App Designer `.mlapp` is not required for the first version.

The team may migrate to App Designer later if needed.

For the first version, a script-based GUI is preferred because:

- It is easier to share through GitHub.
- It is easier to review as plain code.
- It is easier to modify using Claude or Codex.
- It avoids `.mlapp` file complexity.
- It is sufficient for assignment demonstration.
- It is easier to connect with the existing `.m` function pipeline.

---

## 3.3 GUI and Parallel Development

The GUI should be designed so that it can run even if some modules are incomplete.

During early development:

- Plate detection may return an empty plate image.
- OCR may return `UNKNOWN`.
- State identification may return `UNKNOWN`.
- Some debug images may not exist yet.

The GUI should handle these cases without crashing.

This allows Member 4 to develop the GUI in parallel while Member 1, Member 2, and Member 3 work on preprocessing, plate detection, and segmentation.

---

## 4. Main GUI File

The GUI entry file should be:

```text
launch_gui.m
```

This file should:

1. Add source folders to MATLAB path.
2. Create the GUI window.
3. Initialize GUI state.
4. Provide image loading functionality.
5. Provide recognition execution functionality.
6. Display final results.
7. Display placeholder outputs when processing fails.
8. Show clear status messages.

Required path setup:

```matlab
addpath(genpath('src'));
```

The GUI should also call:

```matlab
ensureOutputFolders();
```

if output folders are needed.

---

## 5. Required GUI Components

The GUI should include the following components.

---

## 5.1 Load Image Button

### Purpose

Allows the user to select a vehicle image from the local computer.

### Label

```text
Load Image
```

### Expected Behavior

When clicked:

1. Open a file selection dialog.
2. Allow the user to select an image file.
3. Load the selected image.
4. Display the image in the original image display area.
5. Store the image and image path in GUI state.
6. Reset previous recognition results.
7. Update the status message.

### Supported File Types

```text
*.jpg
*.jpeg
*.png
*.bmp
```

### Failure Handling

If no image is selected, the GUI should show:

```text
No image selected.
```

If the selected file is invalid, the GUI should show:

```text
Invalid image file.
```

---

## 5.2 Run Recognition Button

### Purpose

Runs the full LPR and SIS pipeline on the loaded image.

### Label

```text
Run Recognition
```

### Expected Behavior

When clicked:

1. Check whether an image has been loaded.
2. Run preprocessing.
3. Detect the license plate region.
4. Crop the detected plate region.
5. Prepare the plate image for OCR or segmentation.
6. Run OCR.
7. Clean OCR output.
8. Identify the registered state.
9. Display the detected plate.
10. Display recognized text.
11. Display identified state.
12. Update the status message.

If no image is loaded, display a warning message.

Recommended warning:

```text
Please load an image before running recognition.
```

---

## 5.3 Original Image Display Area

### Purpose

Displays the selected vehicle image.

### Recommended Component

```matlab
axes
```

### Display Content

- Original vehicle image
- Optional detected bounding box overlay in later versions

### Initial State

Before image loading, this area may show:

```text
No image loaded
```

or remain empty.

---

## 5.4 Detected Plate Display Area

### Purpose

Displays the detected license plate region.

### Recommended Component

```matlab
axes
```

### Display Content

- Cropped license plate image
- Placeholder image or message if detection fails

### Initial State

Before recognition, this area may show:

```text
No plate detected
```

or remain empty.

### Failure State

If plate detection fails, the GUI should not crash.

It should display a clear status message and set:

```text
Recognized Text: UNKNOWN
Identified State: UNKNOWN
```

---

## 5.5 Recognized Text Field

### Purpose

Displays the OCR result.

### Recommended Component

```matlab
uicontrol
```

Possible style:

```matlab
'Style', 'text'
```

or:

```matlab
'Style', 'edit'
```

### Label

```text
Recognized Text:
```

### Default Value

```text
UNKNOWN
```

### Expected Values

Examples:

```text
BMS8147
PAB1234
UNKNOWN
```

---

## 5.6 Identified State Field

### Purpose

Displays the registered Malaysian state identified from the plate prefix.

### Recommended Component

```matlab
uicontrol
```

Possible style:

```matlab
'Style', 'text'
```

or:

```matlab
'Style', 'edit'
```

### Label

```text
Identified State:
```

### Default Value

```text
UNKNOWN
```

### Expected Values

Examples:

```text
Selangor
Penang
Malacca
Kuala Lumpur
UNKNOWN
```

---

## 5.7 Status Message Field

### Purpose

Displays system status, warnings, and errors.

### Recommended Component

```matlab
uicontrol
```

### Label Examples

```text
Status: Ready
Status: Image loaded successfully
Status: Running recognition...
Status: Recognition completed
Status: Plate detection failed
Status: OCR unavailable
Status: State could not be identified
```

The status message should help users understand what happened during processing.

---

## 6. Recommended GUI Layout

## 6.1 Basic Layout

The GUI should use a simple layout.

Recommended structure:

```text
------------------------------------------------------------
| Load Image | Run Recognition | Status: Ready              |
------------------------------------------------------------
| Original Image Area        | Detected Plate Area          |
|                            |                              |
|                            |                              |
------------------------------------------------------------
| Recognized Text: [ BMS8147                     ]          |
| Identified State: [ Selangor                   ]          |
------------------------------------------------------------
```

---

## 6.2 Window Title

Recommended GUI title:

```text
License Plate Recognition and State Identification System
```

---

## 6.3 Window Size

The GUI should be large enough to display images clearly.

Recommended approximate size:

```text
1000 x 650 pixels
```

or larger if needed.

---

## 6.4 Layout Priority

The GUI layout should prioritize:

1. Original image visibility
2. Detected plate visibility
3. Clear text result display
4. Clear state result display
5. Clear status message

Advanced visual design is not required for the first version.

---

## 7. GUI Workflow

## 7.1 Normal Workflow

```text
Launch GUI
↓
Click Load Image
↓
Select vehicle image
↓
Display original image
↓
Click Run Recognition
↓
Run full processing pipeline
↓
Display detected plate image
↓
Display recognized text
↓
Display identified state
↓
Show completion status
```

---

## 7.2 No Image Loaded Workflow

If the user clicks `Run Recognition` before loading an image:

```text
Run Recognition clicked
↓
Check image state
↓
No image found
↓
Show warning message
↓
Stop processing
```

Recommended message:

```text
Please load an image before running recognition.
```

---

## 7.3 Plate Detection Failure Workflow

If plate detection fails:

```text
Run pipeline
↓
No valid plate region found
↓
Detected plate area remains empty or shows placeholder
↓
Recognized Text = UNKNOWN
↓
Identified State = UNKNOWN
↓
Status message explains the failure
```

Recommended message:

```text
Plate detection failed. Please try another image.
```

The GUI should still remain open and usable.

---

## 7.4 OCR Failure Workflow

If OCR fails or is unavailable:

```text
Plate region detected
↓
OCR fails
↓
Recognized Text = UNKNOWN
↓
Identified State = UNKNOWN
↓
Status message explains OCR issue
```

Recommended message:

```text
OCR failed or is unavailable.
```

---

## 7.5 State Identification Failure Workflow

If OCR returns text but the prefix cannot be matched:

```text
OCR returns text
↓
Text cleaning runs
↓
Prefix is not found in mapping
↓
Identified State = UNKNOWN
↓
Status message explains state identification issue
```

Recommended message:

```text
State could not be identified.
```

---

## 8. GUI Placeholder Development Workflow

## 8.1 Purpose

The GUI should support development even when the full image processing pipeline is incomplete.

This allows Member 4 to develop the GUI while other members continue working on preprocessing, plate detection, and segmentation.

---

## 8.2 Placeholder Outputs

If a module is incomplete, the GUI should support the following placeholder values:

```matlab
plateImg = [];
plateBBox = [];
rawText = "UNKNOWN";
cleanedText = "UNKNOWN";
stateName = "UNKNOWN";
```

---

## 8.3 Placeholder Display

If `plateImg` is empty:

```text
Detected Plate: No plate detected
Recognized Text: UNKNOWN
Identified State: UNKNOWN
```

If OCR is not ready:

```text
Recognized Text: UNKNOWN
Identified State: UNKNOWN
```

If state identification is not ready:

```text
Identified State: UNKNOWN
```

---

## 8.4 Temporary OCR Strings for GUI Testing

During GUI development, temporary OCR strings may be used to test display behavior.

Examples:

```text
BMS8147
PAB1234
MAB5678
WXY5678
```

These should only be used for early GUI testing and should not replace the final OCR pipeline.

---

## 9. GUI Data Flow

The GUI should store the following data internally.

```text
imagePath
originalImg
preprocessedImg
plateImg
plateBBox
recognizedText
cleanedText
stateName
statusMessage
```

Recommended MATLAB storage method:

```matlab
handles.imagePath = imagePath;
handles.originalImg = originalImg;
guidata(fig, handles);
```

Additional optional fields:

```text
preprocessDebug
detectionDebug
characterImages
characterBBoxes
```

These optional fields may be used later for showing processing steps.

---

## 10. Pipeline Function Calls from GUI

The GUI should call the same functions used by `main.m`.

Recommended call flow:

```matlab
[preprocessedImg, preprocessDebug] = preprocessImage(originalImg);

[plateImg, plateBBox, detectionDebug] = detectPlateRegion(preprocessedImg, originalImg);

[characterImages, characterBBoxes] = segmentCharacters(plateImg);

rawText = recognizePlateText(plateImg);

cleanedText = cleanRecognizedText(rawText);

stateName = identifyState(cleanedText);
```

The GUI should not duplicate processing logic.

The GUI should only control:

- User input
- Function calls
- Display output
- Status messages
- Error handling

---

## 11. GUI Error Handling

The GUI should handle common errors gracefully.

## 11.1 Missing Image

If no image is selected:

```text
No image selected.
```

---

## 11.2 Invalid Image

If the selected file cannot be loaded as an image:

```text
Invalid image file.
```

---

## 11.3 Plate Detection Failure

If no valid plate is detected:

```text
Plate detection failed.
```

Fallback display:

```text
Recognized Text: UNKNOWN
Identified State: UNKNOWN
```

---

## 11.4 Empty Plate Image

If `plateImg` is empty:

```text
No plate image available.
```

The GUI should not attempt to display an invalid image.

---

## 11.5 OCR Failure

If OCR fails:

```text
OCR failed. Result set to UNKNOWN.
```

---

## 11.6 Unknown State

If the state prefix is not recognized:

```text
State could not be identified.
```

---

## 11.7 Missing Output Folder

If output folders do not exist, the GUI or utility function should create them automatically.

Recommended utility function:

```matlab
ensureOutputFolders();
```

---

## 11.8 Unexpected Runtime Error

If an unexpected error occurs, the GUI should show a clear status message instead of closing unexpectedly.

Possible message:

```text
Unexpected error occurred during recognition.
```

Use `try-catch` where appropriate.

---

## 12. GUI Output Requirements

After processing, the GUI should display:

| Output Item | Required |
|---|---|
| Original image | Yes |
| Detected plate image | Yes |
| Recognized text | Yes |
| Identified state | Yes |
| Status message | Yes |
| Intermediate images | Optional |
| Bounding box overlay | Optional |
| Save result button | Optional |
| Show processing steps button | Optional |

---

## 13. Optional GUI Features

The following features are optional and may be added after the basic GUI works.

---

## 13.1 Save Result Button

Allows the user to save the final result screenshot or output images.

Possible label:

```text
Save Result
```

Possible outputs:

- Final GUI screenshot
- Detected plate image
- OCR-ready image
- Result summary

---

## 13.2 Show Processing Steps Button

Displays intermediate images such as:

- Grayscale image
- Enhanced image
- Filtered image
- Edge image
- Binary image
- Cleaned image

Possible label:

```text
Show Steps
```

This can support report screenshots and presentation explanation.

---

## 13.3 Batch Test Button

Allows the user to process multiple images.

This is optional and not required for the first version.

Possible label:

```text
Batch Test
```

---

## 13.4 Bounding Box Overlay

The GUI may display the detected bounding box on the original image.

This can help explain the plate detection result.

---

## 13.5 Load Plate Sample Button

Optional for development only.

This button may allow Member 4 to load a manually cropped plate image from:

```text
images/test/plate_samples/
```

This is useful for OCR and state identification testing before automatic plate detection is fully complete.

This feature is optional and does not need to appear in the final submitted GUI.

---

## 14. GUI Design Principles

The GUI should be:

- Simple
- Clear
- Easy to demonstrate
- Stable
- Easy to explain in the presentation
- Not visually overloaded
- Robust against missing or failed outputs

Avoid unnecessary complex design.

The assignment focuses on image processing methods and results, not advanced UI design.

---

## 15. GUI Demonstration Requirements

The GUI should support individual demonstration recording.

During the demonstration, the presenter should be able to show:

1. Opening the GUI
2. Loading a vehicle image
3. Running recognition
4. Showing the detected plate
5. Showing OCR text
6. Showing identified state
7. Explaining success or failure
8. Explaining placeholder or `UNKNOWN` outputs if a case fails

---

## 16. GUI Screenshots for Report

The GUI should produce clear screenshots for the report.

Useful screenshots include:

- GUI before loading image
- GUI after loading original image
- GUI after recognition
- Successful result
- Failed or difficult result
- Plate detection failure case
- OCR failure case

Screenshots should be saved or copied into:

```text
report/figures/
```

if needed.

---

## 17. GUI and Member Responsibility

## 17.1 Main GUI Owner

Member 4 is the main owner of:

```text
launch_gui.m
```

and related display/evaluation utilities.

Assigned folders and files:

```text
src/recognition/
src/evaluation/
src/utils/
launch_gui.m
scratch/test_member4_recognition_gui.m
```

---

## 17.2 Other Members' Responsibilities for GUI Integration

Other members should ensure that their functions return stable outputs so the GUI can call them safely.

### Member 1

Should provide:

```matlab
[preprocessedImg, preprocessDebug] = preprocessImage(originalImg);
```

### Member 2

Should provide:

```matlab
[plateImg, plateBBox, detectionDebug] = detectPlateRegion(preprocessedImg, originalImg);
```

### Member 3

Should provide:

```matlab
[characterImages, characterBBoxes] = segmentCharacters(plateImg);
```

### Member 4

Should provide:

```matlab
rawText = recognizePlateText(plateImg);
cleanedText = cleanRecognizedText(rawText);
stateName = identifyState(cleanedText);
```

If any function fails, it should return safe fallback values.

---

## 18. GUI Scratch Test

## 18.1 Purpose

The GUI scratch test allows Member 4 to test recognition and GUI behavior independently.

Scratch test script:

```text
scratch/test_member4_recognition_gui.m
```

---

## 18.2 Test Inputs

The scratch test may use:

```text
images/test/plate_samples/
```

or temporary OCR strings such as:

```text
BMS8147
PAB1234
MAB5678
WXY5678
```

---

## 18.3 Expected Scratch Test Outputs

The scratch test should confirm that:

- OCR returns text or `UNKNOWN`.
- OCR text cleaning works.
- State identification works.
- `displayPipelineResults` can show outputs.
- `launch_gui.m` opens.
- The GUI does not crash when plate detection or OCR fails.

---

## 19. Minimum GUI Version

The minimum working GUI should include:

1. Load Image button
2. Run Recognition button
3. Original image display area
4. Detected plate display area
5. Recognized text display
6. Identified state display
7. Status message

The minimum version should not crash even if recognition fails.

The minimum version should support:

```text
Recognized Text: UNKNOWN
Identified State: UNKNOWN
```

when plate detection or OCR fails.

---

## 20. First Runnable GUI Goal

The first runnable GUI version should:

1. Open from `launch_gui.m`.
2. Allow the user to load an image.
3. Display the original image.
4. Run the pipeline functions.
5. Display a detected plate image or fallback message.
6. Display recognized text or `UNKNOWN`.
7. Display identified state or `UNKNOWN`.
8. Show status messages.
9. Avoid crashing when any module is incomplete.

Perfect recognition accuracy is not required for the first GUI version.

---

## 21. Final GUI Goal

The final GUI should allow users to:

1. Load different vehicle images.
2. Run the full pipeline.
3. View original and detected plate images.
4. View recognized plate text.
5. View identified registered state.
6. Understand whether processing succeeded or failed.
7. Capture screenshots for the report and presentation.
8. Demonstrate both successful and failed cases.
9. Support individual presentation explanation.

---

## 22. Notes for Claude or Codex

When generating GUI code:

- Use `launch_gui.m` as the entry file.
- Use script-based MATLAB GUI components.
- Do not use App Designer `.mlapp` for the first version.
- Do not duplicate the processing logic inside GUI callbacks.
- Call existing pipeline functions from `src`.
- Use `guidata` or nested functions to manage GUI state.
- Handle errors using `try-catch`.
- Return `UNKNOWN` when OCR or state identification fails.
- Handle empty `plateImg` safely.
- Keep comments and variable names in English.
- Allow GUI development with placeholder outputs.
- Do not require all image processing modules to be fully completed before the GUI can open.
- Do not use TensorFlow, Haar Cascade, YOLO, template matching, or pattern matching.