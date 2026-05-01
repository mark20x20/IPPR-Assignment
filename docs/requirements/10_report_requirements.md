# Report Requirements

## 1. Purpose

This document defines the report requirements for the License Plate Recognition (LPR) and State Identification System (SIS) project.

The report should explain the project objective, theoretical background, selected methods, implementation approach, experimental results, critical analysis, and future work.

The report is not only a description of the final system. It should also justify why each image processing method was selected and analyze how well the system performs under different test conditions.

This document also defines how the report should reflect team-based parallel development, member-specific responsibilities, module-level testing, and individual contributions.

---

## 2. Report Objective

The report should demonstrate that the team can:

1. Understand the problem domain.
2. Apply image processing and computer vision techniques.
3. Justify selected algorithms and methods.
4. Implement a working MATLAB-based prototype.
5. Evaluate the system using test images.
6. Critically analyze both successful and failed cases.
7. Explain the contribution of each member.
8. Show evidence of module-level testing.
9. Suggest realistic future improvements.

---

## 3. Required Report Length

The report should be approximately:

```text
2500 to 3000 words
```

This word count should focus on the main report body.

Appendices, code snippets, figures, tables, and references may be treated separately depending on lecturer instructions.

---

## 4. Required Report Sections

The report should include the following sections:

```text
1. Table of Contents
2. Contribution Matrix
3. Acknowledgement
4. Abstract
5. Introduction
6. Description and Justification of Proposed Algorithms / Methods / Techniques
7. Experimental Results
8. Description and Discussion on Obtained Results
9. Critical Comments, Analysis and Future Work Direction
10. Conclusion
11. References
```

The team may also include appendices if useful.

Recommended appendix contents include:

```text
Appendix A: Selected Code Snippets
Appendix B: Additional Test Results
Appendix C: GUI Screenshots
Appendix D: Member-Level Test Evidence
Appendix E: Dataset Metadata
```

---

## 5. Front Cover Requirements

The front cover should include:

- Group member names
- Student ID numbers
- Intake code
- Module code
- Module name
- Assignment title
- Date completed

Recommended title:

```text
License Plate Recognition and State Identification System
```

---

## 6. Table of Contents

The table of contents should list all major sections and subsections with page numbers.

Recommended main structure:

```text
1. Introduction
2. Proposed System and Methodology
3. Implementation
4. Experimental Results
5. Discussion and Critical Analysis
6. Future Work
7. Conclusion
8. References
9. Appendices
```

The exact numbering can be adjusted according to the final report structure.

---

## 7. Contribution Matrix

The contribution matrix should clearly show each group member’s role and contribution.

Recommended table format:

| Member Name | Student ID | Responsibility | Main Deliverables | Contribution Percentage |
|---|---|---|---|---|

Example responsibilities:

- Dataset collection
- Image preprocessing
- Plate detection
- Segmentation
- Morphological processing
- OCR and state identification
- GUI development
- Evaluation
- Report writing
- Presentation preparation

---

## 7.1 Recommended Member Responsibility Structure

The contribution matrix should match the actual implementation structure.

Recommended division:

| Member | Main Responsibility | Assigned Folder or Files |
|---|---|---|
| Member 1 | Dataset and Preprocessing | `src/preprocessing/`, `images/`, `dataset_metadata.csv` |
| Member 2 | License Plate Detection | `src/plate_detection/` |
| Member 3 | Segmentation and Morphology | `src/segmentation/`, `images/test/plate_samples/` |
| Member 4 | Recognition, GUI, and Evaluation | `src/recognition/`, `src/evaluation/`, `src/utils/`, `launch_gui.m` |

Each member should sign off the workload matrix if required.

---

## 7.2 Individual Contribution Evidence

Each member should provide evidence of their technical contribution.

Possible evidence includes:

- Function files written or edited
- Module-level test screenshots
- Intermediate output images
- Failure case analysis
- Explanation of method selection
- Report section contribution
- GUI screenshots
- Evaluation table rows

Recommended member-level evidence:

| Member | Evidence Type |
|---|---|
| Member 1 | Grayscale, enhanced, and filtered preprocessing images |
| Member 2 | Edge detection, candidate region, and cropped plate results |
| Member 3 | Binary plate, cleaned binary image, and character candidate results |
| Member 4 | OCR output, cleaned text, state identification, GUI, and evaluation CSV |

---

## 8. Acknowledgement

The acknowledgement section should briefly thank:

- Lecturer
- Group members
- University or module support
- Dataset providers if applicable

Keep this section concise and formal.

---

## 9. Abstract

## 9.1 Length

The abstract should be approximately:

```text
200 to 300 words
```

## 9.2 Content

The abstract should summarize:

- Project background
- Project objective
- Main methods used
- System output
- Key results
- Limitations or future improvement direction

## 9.3 Suggested Abstract Structure

```text
Sentence 1-2: Background and problem
Sentence 3-4: Project objective
Sentence 5-7: Methods used
Sentence 8-9: Results and system output
Sentence 10: Limitation or future work
```

## 9.4 Example Points to Include

- License plate recognition is useful for vehicle identification and traffic-related applications.
- The project develops a MATLAB-based LPR and SIS system.
- The system uses classical image processing methods.
- The system applies preprocessing, segmentation, morphological processing, OCR, and rule-based state identification.
- The GUI displays the original image, detected plate, recognized text, and identified state.
- The system is evaluated using both successful and difficult test cases.

---

## 10. Introduction

## 10.1 Purpose

The introduction should explain the background, problem, and motivation of the project.

## 10.2 Recommended Content

Include:

- Background of image processing and computer vision
- Importance of license plate recognition
- Problem statement
- Assignment objective
- Scope of the project
- Challenges in license plate detection
- Overview of the LPR and SIS system

## 10.3 Problem Context

The report should explain that license plate recognition can be difficult because of:

- Different vehicle types
- Different plate designs
- Different image distances
- Lighting changes
- Shadows and reflections
- Complex backgrounds
- Different viewing angles
- Low image resolution
- OCR errors caused by unclear characters

## 10.4 Project Scope

The project scope should state that the system focuses on:

- Still image input
- MATLAB-based implementation
- Classical image processing techniques
- License plate detection
- Plate cropping
- Plate image cleanup
- OCR-based text recognition
- Malaysian state identification based on plate prefix
- GUI-based result display
- Evaluation using selected test images

## 10.5 Out of Scope

The following are outside the first version scope:

- Real-time video processing
- Deep learning-based detection
- YOLO-based detection
- TensorFlow-based models
- Haar Cascade detection
- Template matching
- Pattern matching methods
- Character recognition by comparing with fixed template images

---

## 11. Proposed System and Methodology

## 11.1 Purpose

This section should describe the overall system workflow and justify the chosen approach.

## 11.2 Recommended Workflow Diagram

Include a system workflow diagram such as:

```text
Input Vehicle Image
↓
Preprocessing
↓
Plate Region Detection
↓
Plate Cropping
↓
Plate Image Cleanup
↓
Character Segmentation for Visualization
↓
OCR
↓
Text Cleaning
↓
State Identification
↓
GUI Output
↓
Evaluation Recording
```

## 11.3 Parallel Development Workflow

The report may briefly explain that the system was developed using independent modules.

Recommended development workflow diagram:

```text
Shared MATLAB Skeleton
↓
Member 1: Preprocessing
↓
Member 2: Plate Detection
↓
Member 3: Segmentation and Morphology
↓
Member 4: OCR, GUI, and Evaluation
↓
Integration and Testing
```

Although the final system is sequential, the implementation can be developed in parallel using:

- Fixed function signatures
- Placeholder outputs
- Scratch test scripts
- `images/test/sample_car.jpg`
- `images/test/plate_samples/`

---

## 11.4 Methods to Explain

This section should explain and justify the following methods where used:

- Image acquisition
- Grayscale conversion
- Contrast enhancement
- Noise reduction
- Spatial filtering
- Edge detection
- Thresholding
- Morphological operations
- Connected component analysis
- Region property analysis
- Character segmentation for visualization
- OCR
- Text cleaning
- State identification
- GUI display
- Evaluation recording

---

## 12. Description and Justification of Proposed Algorithms / Methods / Techniques

This is one of the most important sections of the report.

It should not only describe what was used, but also explain why each method was selected.

---

## 12.1 Image Acquisition

### Description

The system loads vehicle images using MATLAB image reading functions.

### Possible MATLAB Function

```matlab
imread
```

### Justification

Image acquisition is the first step because the system requires an input vehicle image before any processing can be performed.

---

## 12.2 Grayscale Conversion

### Description

RGB images are converted to grayscale to simplify processing.

### Possible MATLAB Function

```matlab
rgb2gray
```

### Justification

Grayscale conversion reduces image complexity by converting three color channels into one intensity channel. This makes edge detection, thresholding, and morphological processing easier.

---

## 12.3 Contrast Enhancement

### Description

Contrast enhancement improves the visibility of the plate region and text.

### Possible MATLAB Functions

```matlab
imadjust
histeq
adapthisteq
```

### Justification

License plate images may suffer from poor lighting, shadows, or low contrast. Enhancing contrast can make text and plate borders more visible.

---

## 12.4 Noise Reduction

### Description

Noise reduction removes small unwanted variations from the image.

### Possible MATLAB Functions

```matlab
medfilt2
imfilter
fspecial
```

### Justification

Noise can produce false edges or false connected components. Reducing noise before segmentation improves the stability of plate detection.

---

## 12.5 Spatial Filtering

### Description

Spatial filtering modifies pixel values based on neighboring pixels.

### Possible Uses

- Smoothing
- Sharpening
- Noise reduction
- Edge enhancement

### Justification

Spatial filtering supports preprocessing by reducing noise and improving important image structures before detection.

---

## 12.6 Edge Detection

### Description

Edge detection identifies sharp intensity changes in the image.

### Possible MATLAB Function

```matlab
edge
```

Possible methods:

- Sobel
- Canny
- Prewitt
- Roberts

### Justification

License plates usually contain strong rectangular borders and character edges. Edge detection helps locate candidate plate regions.

---

## 12.7 Thresholding and Binarization

### Description

Thresholding separates foreground objects from the background based on pixel intensity.

### Possible MATLAB Functions

```matlab
graythresh
imbinarize
adaptthresh
```

### Justification

Binarization is useful for separating plate text and plate regions from the background. It is also useful before morphological processing and character segmentation.

---

## 12.8 Morphological Image Processing

### Description

Morphological processing modifies image regions based on shape.

### Possible MATLAB Functions

```matlab
strel
imdilate
imerode
imopen
imclose
imfill
bwareaopen
```

### Justification

Morphological operations can remove small noise, connect broken edges, fill holes, and clean binary images. This is especially useful after segmentation and before plate candidate selection or OCR.

---

## 12.9 Connected Component Analysis

### Description

Connected component analysis identifies connected regions in a binary image.

### Possible MATLAB Functions

```matlab
bwconncomp
bwlabel
regionprops
```

### Justification

After segmentation, connected component analysis helps identify candidate regions that may represent the license plate or characters.

---

## 12.10 Region Property Filtering

### Description

Region properties are used to select the most likely plate region.

### Possible Properties

- Bounding box
- Area
- Width
- Height
- Aspect ratio
- Extent
- Solidity

### Justification

License plates typically have rectangular shapes and specific width-to-height ratios. Region property filtering helps remove false candidates.

---

## 12.11 Character Segmentation

### Description

Character segmentation identifies possible character regions from the cropped plate image.

### Possible MATLAB Functions

```matlab
bwconncomp
regionprops
imcrop
sortrows
```

### Justification

Character segmentation helps visualize how plate characters are separated after binarization and morphological processing. It is useful for explanation, OCR preparation, and failure analysis.

### Important Note

Character segmentation should not be used for template-based character recognition.

Final text recognition should use OCR, not template matching or pattern matching.

---

## 12.12 OCR

### Description

OCR is used to extract text from the detected license plate image.

### Possible MATLAB Function

```matlab
ocr
```

### Justification

OCR allows the system to recognize characters from the cropped and processed plate image. This supports the LPR requirement.

### Important Note

OCR should be applied after plate detection and plate image preprocessing, not directly to the full original image as the only processing step.

---

## 12.13 Text Cleaning

### Description

OCR output is cleaned before state identification.

### Possible Operations

- Convert to uppercase
- Remove spaces
- Remove punctuation
- Remove non-alphanumeric characters
- Remove line breaks

### Justification

OCR output may contain unnecessary spaces or symbols. Cleaning makes the result more suitable for state identification.

---

## 12.14 State Identification

### Description

The system identifies the registered state based on the first character or prefix of the recognized plate text.

### Example Mapping

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

### Justification

Malaysian license plates commonly use prefixes related to registration regions. A rule-based mapping is simple, explainable, and suitable for this project scope.

---

## 13. Implementation

## 13.1 Purpose

This section should explain how the system was implemented in MATLAB.

## 13.2 Development Environment

Mention:

- MATLAB R2026a
- Windows
- Relevant MATLAB toolboxes
- GitHub for code sharing if used
- Script-based MATLAB GUI
- MATLAB `.m` files

---

## 13.3 File Structure

Briefly explain the project structure:

```text
main.m
launch_gui.m
scratch/
docs/
src/preprocessing/
src/plate_detection/
src/segmentation/
src/recognition/
src/evaluation/
src/utils/
images/
output/
report/
```

---

## 13.4 Main Functions

Briefly describe important functions:

| Function | Purpose |
|---|---|
| `preprocessImage.m` | Runs preprocessing |
| `detectPlateRegion.m` | Detects plate candidate |
| `segmentCharacters.m` | Segments possible characters |
| `recognizePlateText.m` | Runs OCR |
| `cleanRecognizedText.m` | Cleans OCR result |
| `identifyState.m` | Identifies state |
| `evaluateSingleImage.m` | Runs one-image evaluation |
| `saveResultRow.m` | Saves evaluation result |
| `displayPipelineResults.m` | Displays pipeline output |
| `launch_gui.m` | Runs GUI |

---

## 13.5 Member-Based Implementation Structure

The report should briefly explain how implementation was divided.

| Member | Implementation Area | Main Files |
|---|---|---|
| Member 1 | Dataset and Preprocessing | `preprocessImage.m`, `convertToGray.m`, `enhanceContrast.m`, `removeNoise.m` |
| Member 2 | Plate Detection | `detectPlateRegion.m`, `selectPlateCandidate.m`, `cropPlateRegion.m` |
| Member 3 | Segmentation and Morphology | `binarizePlate.m`, `cleanBinaryImage.m`, `segmentCharacters.m` |
| Member 4 | OCR, State Identification, GUI, Evaluation | `recognizePlateText.m`, `cleanRecognizedText.m`, `identifyState.m`, `launch_gui.m`, `evaluateSingleImage.m`, `saveResultRow.m` |

---

## 13.6 Parallel Development Support

The report may mention that early development used:

```text
scratch/test_member1_preprocessing.m
scratch/test_member2_plate_detection.m
scratch/test_member3_segmentation.m
scratch/test_member4_recognition_gui.m
images/test/sample_car.jpg
images/test/plate_samples/
```

This allowed each member to test their module independently.

This is especially useful because the final system has a sequential dependency:

```text
Preprocessing
↓
Plate Detection
↓
Segmentation
↓
OCR / State Identification / GUI
```

---

## 13.7 GUI Implementation

Explain that the GUI allows the user to:

- Load an image
- Run recognition
- View original image
- View detected plate
- View OCR text
- View identified state
- View status messages

The GUI should also handle failure cases by showing:

```text
Recognized Text: UNKNOWN
Identified State: UNKNOWN
```

---

## 14. Experimental Results

## 14.1 Purpose

This section presents the test results obtained from different images.

## 14.2 Recommended Content

Include:

- Test image table
- Output screenshots
- Detection results
- OCR results
- State identification results
- Segmentation or morphology examples
- GUI output screenshots
- Success cases
- Failure cases

---

## 14.3 Recommended Result Table

| Image Name | Vehicle Type | Expected Text | OCR Text | Expected State | Predicted State | Detection Result | OCR Result | State Result | Overall Result | Notes |
|---|---|---|---|---|---|---|---|---|---|

The `overall_result` column should be included for consistency with the evaluation plan.

---

## 14.4 Suggested Figures

Include figures such as:

- Original vehicle image
- Grayscale image
- Preprocessed image
- Edge detection result
- Binary image
- Cleaned binary image
- Detected plate image
- OCR-ready image
- Character candidate visualization
- GUI final result screenshot
- Failure case output

---

## 14.5 Module-Level Results

The report may include a short table showing module-level results for each member.

Recommended table:

| Member | Module | Test Input | Output Evidence | Result |
|---|---|---|---|---|
| Member 1 | Preprocessing | `sample_car.jpg` | Enhanced image | Success |
| Member 2 | Plate Detection | `sample_car.jpg` | Cropped plate image | Partial Success |
| Member 3 | Segmentation | `plate_selangor_01.jpg` | Binary / cleaned image | Success |
| Member 4 | OCR and State Identification | `plate_selangor_01.jpg` | OCR text and state | Success |

This table is useful for showing individual contribution and module-level testing.

---

## 15. Description and Discussion on Obtained Results

## 15.1 Purpose

This section explains what the results mean.

## 15.2 Discussion Points

Discuss:

- Which images were processed successfully
- Which images failed
- How lighting affected detection
- How distance affected OCR
- How background affected false detection
- How plate angle affected cropping
- How segmentation affected OCR readability
- How OCR errors affected state identification
- How GUI displayed successful and failed results

---

## 15.3 Success Case Discussion

For success cases, explain:

- Plate was clear
- Plate had high contrast
- Plate was close to the camera
- Background was simple
- Bounding box was selected correctly
- OCR received a clean plate crop
- State prefix was recognized correctly
- GUI displayed the result clearly

---

## 15.4 Failure Case Discussion

For failed cases, explain:

- Plate was too small
- Plate was blurry
- Plate was angled
- Image was too dark
- Reflection affected characters
- Background contained similar rectangular objects
- OCR misread similar characters
- State prefix was not recognized
- Morphological processing removed useful character details
- Plate detection selected the wrong candidate region

---

## 15.5 Module-Based Failure Discussion

When a result fails, identify the module where the failure most likely occurred.

Recommended table:

| Failed Stage | Possible Cause | Example Discussion |
|---|---|---|
| Preprocessing | Low contrast remained after enhancement | The plate region was still unclear after preprocessing. |
| Plate Detection | Wrong rectangular object selected | The background contained a similar rectangular shape. |
| Plate Cropping | Bounding box was too large or too small | The cropped region included too much background. |
| Segmentation | Characters merged or disappeared | Morphological cleaning removed thin character strokes. |
| OCR | Characters were misread | OCR confused `B` and `8`. |
| State Identification | First character was wrong | OCR changed `B` to `P`, causing the wrong state. |
| GUI | Empty output not displayed correctly | The GUI needed better fallback handling. |

---

## 16. Critical Comments, Analysis and Future Work Direction

## 16.1 Purpose

This section critically evaluates the limitations of the system and proposes improvements.

---

## 16.2 Critical Comments

Possible critical comments:

- The system depends heavily on image quality.
- OCR performance depends on plate crop quality.
- Plate detection may fail in complex backgrounds.
- Fixed thresholds may not work for all lighting conditions.
- Angled plates are difficult to process.
- Low-resolution plates reduce OCR accuracy.
- State identification fails if the first character is misread.
- Morphological operations may remove useful character details if parameters are not tuned carefully.
- Manually cropped plate samples are useful for module testing but do not replace full-pipeline evaluation.
- Placeholder outputs are useful during development but should be clearly separated from final results.

---

## 16.3 Future Work

Possible future improvements:

- Improve adaptive thresholding
- Improve plate candidate scoring
- Add more robust angle correction
- Improve OCR preprocessing
- Add batch testing
- Expand state mapping
- Add more plate types
- Improve GUI usability
- Test with a larger dataset
- Add better failure messages
- Improve evaluation result visualization
- Improve parameter tuning for different image conditions
- Add more comprehensive module-level tests

---

## 17. Conclusion

## 17.1 Purpose

The conclusion summarizes the project.

## 17.2 Recommended Content

Include:

- What system was developed
- What methods were used
- What the system can do
- Main result summary
- Main limitations
- Future improvement direction
- How team-based modular implementation supported the project

## 17.3 Suggested Conclusion Structure

```text
Paragraph 1: Restate the project objective.
Paragraph 2: Summarize the implementation approach.
Paragraph 3: Summarize results and limitations.
Paragraph 4: Mention future work.
```

---

## 18. References

## 18.1 Reference Requirement

References should be scholarly and reliable.

Avoid:

- Wikipedia
- Personal blogs
- Forums
- Unverified websites

## 18.2 Citation Format

Use APA format for:

- In-text citations
- Reference list

## 18.3 Possible Reference Topics

References may cover:

- Image processing
- Computer vision
- License plate recognition
- Morphological image processing
- OCR
- Thresholding
- Edge detection
- MATLAB image processing functions
- Connected component analysis
- Region property analysis

---

## 19. Appendices

Appendices may include supporting materials that are too detailed for the main body.

Possible appendix contents:

- Selected code snippets
- Additional screenshots
- Extra test result tables
- Workload matrix
- Dataset metadata
- GUI screenshots
- Additional failure cases
- Member-level test screenshots
- Scratch test outputs
- Additional module-level result tables

---

## 20. Code in Report

Full source code does not need to be included in the main body of the report.

Recommended approach:

- Explain important algorithms in the main report.
- Include selected code snippets only if necessary.
- Put longer code snippets in the appendix.
- Submit full source code separately in the project ZIP.

---

## 20.1 Recommended Code Snippets to Include

If code snippets are needed, include short and meaningful examples such as:

- Preprocessing flow
- Plate candidate filtering
- Character segmentation logic
- OCR text cleaning
- State prefix mapping
- Evaluation row generation

Avoid pasting all source code into the main report.

---

## 21. Figures and Tables

## 21.1 Required or Recommended Figures

Recommended figures:

- System workflow diagram
- Parallel development or module structure diagram
- GUI screenshot
- Original image example
- Preprocessed image
- Plate detection result
- Cropped plate image
- Binary or cleaned plate image
- OCR-ready image
- Failure case example

## 21.2 Recommended Tables

Recommended tables:

- Contribution matrix
- Member responsibility table
- Test image summary
- Experimental result table
- Module-level test result table
- Failure analysis table
- State prefix mapping table

---

## 22. Formatting Guidelines

Recommended formatting:

- Font: Times New Roman
- Font size: 12
- Line spacing: 1.5
- Alignment: Justified
- Consistent heading levels
- Captions for figures and tables
- APA references

Confirm final formatting with the lecturer or group requirements if needed.

---

## 23. Report Writing Style

The report should be:

- Formal
- Clear
- Objective
- Evidence-based
- Technically specific
- Not overly casual

Avoid writing only general explanations.

For each method, explain:

```text
What method was used
Why it was used
How it was implemented
What result it produced
What limitation it had
```

---

## 24. Experimental Analysis Style

When writing experimental analysis, avoid only saying:

```text
The system worked well.
```

Instead, write more specifically:

```text
The system successfully detected the plate region because the plate had a clear rectangular shape, high contrast, and a simple background. The OCR result was accurate because the cropped plate image had clear characters with limited noise.
```

For failed cases, avoid only saying:

```text
The system failed.
```

Instead, write:

```text
The system failed to detect the correct plate region because the image contained multiple rectangular objects in the background. These objects produced similar edge responses, causing the candidate selection step to choose the wrong region.
```

---

## 24.1 Module-Based Analysis Style

For module-based analysis, write clearly which stage caused the issue.

Example:

```text
In this case, preprocessing improved the image contrast, but plate detection still failed because the background contained several rectangular objects. The region property filtering step selected a false candidate instead of the actual license plate.
```

Another example:

```text
The plate region was detected correctly, but OCR misread the first character. As a result, the state identification module returned the wrong state. This shows that state identification depends strongly on OCR accuracy.
```

---

## 25. Academic Integrity

The report must be written in the team’s own words.

Any external information, figures, datasets, or code references must be cited properly.

Do not copy from:

- Websites
- Reports
- GitHub repositories
- AI-generated text without review
- Other students' work

All AI-assisted content should be reviewed, edited, and understood by the team before submission.

---

## 26. Submission Notes

The final submission should include:

- Project report
- MATLAB source code
- GUI file
- Test images
- Dataset or selected images
- Result outputs if required
- Workload matrix
- Individual presentation or screencam if required

GitHub may be used for sharing and collaboration, but the official submission should be prepared according to the assignment instructions.

---

## 27. Checklist Before Submission

Before submission, check:

```text
[ ] Report has all required sections
[ ] Abstract is 200 to 300 words
[ ] Report is approximately 2500 to 3000 words
[ ] Contribution matrix is included
[ ] Member responsibilities are clear
[ ] Methods are described and justified
[ ] Prohibited methods are not used
[ ] Experimental results are included
[ ] Results table includes overall_result
[ ] Failure cases are analyzed
[ ] Module-level failure analysis is included if useful
[ ] Future work is included
[ ] Conclusion is included
[ ] References use APA format
[ ] Figures and tables have captions
[ ] GUI screenshots are included
[ ] Source code is included in ZIP
[ ] Test images are included
[ ] Workload matrix is included if required
[ ] Individual presentation/demo is prepared
```

---

## 28. Notes for Claude or Codex

When helping with report writing or report-related code:

- Follow the required report sections.
- Do not claim perfect accuracy unless supported by test results.
- Include both success and failure analysis.
- Use formal academic writing.
- Explain methods clearly.
- Justify why each method is used.
- Avoid prohibited methods in explanations.
- Keep MATLAB implementation consistent with the technical constraints.
- Include member-based contribution if requested.
- Include `overall_result` in result tables.
- Explain character segmentation as visualization, explanation, and OCR preparation, not template-based recognition.
- Do not describe TensorFlow, Haar Cascade, YOLO, template matching, or pattern matching as implemented methods.
