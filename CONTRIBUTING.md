# Contributing Guide

## Branch Strategy
- `main`: stable release
- `dev`: integration branch
- `feature/preprocessing`
- `feature/plate-detection`
- `feature/segmentation-morphology`
- `feature/recognition-gui-evaluation`

## Folder Responsibility
Use feature-based folders under `src/`. Do not create member-based source folders.

## Workflow
1. Create a feature branch from `dev`.
2. Make changes only in assigned functional areas.
3. Run related scratch tests and ensure fallback behavior works.
4. Commit and push.
5. Open PR to `dev`.
6. Merge `dev` to `main` when stable.

## Important Rules
- Branch names are not folder names.
- Source folders are divided by system function, not member name.
- Do not change agreed function signatures without discussion.

## Do Not Commit
- `output/`
- `report/figures/`
- `images/raw/`
- large videos, archives, or temporary files
