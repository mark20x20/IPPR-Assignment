# Project Overview

## Project Title

License Plate Recognition and State Identification System

## Module

Image Processing, Computer Vision and Pattern Recognition  
CT036-3-IPPR

## Assignment Type

Group In-Course Assignment

## Project Goal

The goal of this project is to develop a MATLAB-based License Plate Recognition (LPR) and State Identification System (SIS).

The system should detect license plates from vehicle images, extract the text information from the plates, and identify the registered Malaysian state of the vehicle based on the recognized plate text.

## Main Objectives

The system aims to:

- Load vehicle images.
- Detect license plate regions.
- Extract or prepare the plate region for text recognition.
- Recognize text from the license plate.
- Identify the registered state from the plate prefix.
- Display the result using a graphical user interface.

## Expected System Output

For each input image, the system should display:

- Original vehicle image
- Detected license plate region
- Recognized plate text
- Identified state
- Processing status or error message

## Development Environment

The project will be developed using:

- MATLAB R2026a
- Windows environment
- Image Processing Toolbox, if available
- Computer Vision Toolbox, if available

## Implementation Approach

The system will use classical image processing techniques instead of deep learning-based object detection.

The main approach includes:

- Image preprocessing
- Spatial filtering
- Edge detection
- Thresholding
- Morphological image processing
- Connected component analysis
- Region property filtering
- OCR-based text recognition
- Rule-based state identification

## Project Scope

This project focuses on still image-based license plate recognition.

The system is not intended to process real-time video streams in the first version.

## Final Deliverables

The final project should include:

- MATLAB source code
- GUI prototype
- Test images
- Experimental outputs
- Project report
- Individual demonstration recording