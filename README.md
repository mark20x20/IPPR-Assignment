# License Plate Recognition and State Identification System

## Overview
This MATLAB project provides a modular skeleton for License Plate Recognition (LPR) and Malaysian state identification.

## Environment
- MATLAB R2026a (or compatible)
- Windows

## Folder Structure
- `main.m`, `launch_gui.m`
- `src/preprocessing`, `src/plate_detection`, `src/segmentation`, `src/recognition`, `src/evaluation`, `src/utils`
- `scratch/` for member test scripts
- `images/test/sample_car.jpg` for full pipeline test
- `images/test/plate_samples/` for segmentation and OCR module tests

## Run main.m
1. Open MATLAB at project root.
2. Run `main`.

## Run launch_gui.m
1. Open MATLAB at project root.
2. Run `launch_gui`.

## Run Scratch Tests
- `scratch/test_member1_preprocessing.m`
- `scratch/test_member2_plate_detection.m`
- `scratch/test_member3_segmentation.m`
- `scratch/test_member4_recognition_gui.m`

## Prohibited Methods
Do not use TensorFlow, Haar Cascade, YOLO, deep learning object detectors, template matching, or pattern matching.

## Troubleshooting
- If `images/test/sample_car.jpg` is missing, `main.m` exits with a clear message.
- If plate sample images are missing, scratch scripts skip safely with a clear message.
- OCR failures fall back to `UNKNOWN`.
