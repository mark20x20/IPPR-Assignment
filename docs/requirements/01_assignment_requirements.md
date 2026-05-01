# Assignment Requirements

## Assignment Objective

The assignment requires the development of a License Plate Recognition (LPR) and State Identification System (SIS).

The system must be able to:

- Detect license plates in vehicle images.
- Segment or prepare the text area on the license plate.
- Recognize the text on the license plate.
- Identify the registered state of the vehicle.

## Required System Capabilities

The system should be capable of processing images of different vehicle types, including:

- Cars
- Buses
- Motorcycles

## Required Plate Variations

The system should support at least 3 to 4 unique combinations or representations depending on the group size.

Possible plate variations include:

- State plates
- Military plates
- Special status plates
- Two-row number plates
- Special series plates
- Diplomatic series plates

## Robustness Requirement

The system should be robust enough to handle variations in:

- Vehicle type
- Plate design
- Image distance
- Lighting condition
- Background condition
- Viewing angle

## GUI Requirement

A graphical user interface must be developed.

The GUI must show:

- LPR result
- SIS result

## Prohibited Methods

The following methods must not be used:

- Haar Cascade
- TensorFlow
- Pattern matching methods

## Allowed General Direction

The project should mainly use classical image processing and computer vision techniques.

Recommended techniques include:

- Grayscale conversion
- Contrast enhancement
- Noise reduction
- Edge detection
- Thresholding
- Morphological operations
- Connected component analysis
- Region property analysis
- OCR

## Prototype Application Requirements

The prototype application should include:

- Source code
- Test image files
- Working system demonstration
- GUI for displaying results

## Documentation Requirements

The project report should describe and justify:

- The image processing methods used
- The computer vision algorithms used
- The implementation approach
- Experimental results
- Critical analysis of successful and failed cases
- Future work

## Individual Assessment

Although this is a group assignment, each student will also be assessed individually based on their contribution.

Each group member should be able to explain:

- Their own contribution
- The methods used
- The system workflow
- The results obtained
- The limitations and possible improvements