function [refinedPlateImg, refineDebug] = refinePlateForSegmentation(plateImg)
% refinePlateForSegmentation  Lightly refine a cropped plate image for segmentation.

    refinedPlateImg = plateImg;
    refineDebug = struct( ...
        'grayImg', [], ...
        'enhancedImg', [], ...
        'selectedBinaryMask', [], ...
        'rowProjection', [], ...
        'colProjection', [], ...
        'originalSize', [], ...
        'refinedBBox', [], ...
        'refinementApplied', false, ...
        'status', "not_started");

    if isempty(plateImg)
        refineDebug.status = "empty_input";
        return;
    end

    try
        if size(plateImg, 3) == 3
            grayImg = rgb2gray(plateImg);
        else
            grayImg = plateImg;
        end
        grayImg = im2uint8(grayImg);
        enhancedImg = adapthisteq(grayImg, 'ClipLimit', 0.02, 'Distribution', 'rayleigh');
        enhancedImg = imadjust(enhancedImg);

        refineDebug.grayImg = grayImg;
        refineDebug.enhancedImg = enhancedImg;
        refineDebug.originalSize = size(plateImg);

        imgH = size(grayImg, 1);
        imgW = size(grayImg, 2);
        if imgH < 16 || imgW < 30
            refineDebug.status = "image_too_small";
            return;
        end

        tBright = adaptthresh(enhancedImg, 0.48, 'ForegroundPolarity', 'bright');
        tDark = adaptthresh(enhancedImg, 0.48, 'ForegroundPolarity', 'dark');
        bwBright = imbinarize(enhancedImg, tBright);
        bwDark = imbinarize(enhancedImg, tDark);

        bwBright = bwareaopen(bwBright, max(4, round(numel(bwBright) * 0.001)));
        bwDark = bwareaopen(bwDark, max(4, round(numel(bwDark) * 0.001)));

        ratioB = nnz(bwBright) / numel(bwBright);
        ratioD = nnz(bwDark) / numel(bwDark);
        targetRatio = 0.22;
        if abs(ratioB - targetRatio) <= abs(ratioD - targetRatio)
            selectedMask = bwBright;
        else
            selectedMask = bwDark;
        end

        fgRatio = nnz(selectedMask) / numel(selectedMask);
        if fgRatio < 0.02 || fgRatio > 0.80
            refineDebug.selectedBinaryMask = selectedMask;
            refineDebug.status = "foreground_ratio_unreliable";
            return;
        end

        rowProj = sum(selectedMask, 2);
        colProj = sum(selectedMask, 1);
        rowThr = max(2, 0.18 * max(rowProj));
        colThr = max(2, 0.18 * max(colProj));

        rowIdx = find(rowProj >= rowThr);
        colIdx = find(colProj >= colThr);
        if isempty(rowIdx) || isempty(colIdx)
            refineDebug.selectedBinaryMask = selectedMask;
            refineDebug.rowProjection = rowProj;
            refineDebug.colProjection = colProj;
            refineDebug.status = "projection_empty";
            return;
        end

        y1 = min(rowIdx);
        y2 = max(rowIdx);
        x1 = min(colIdx);
        x2 = max(colIdx);

        padX = max(4, round(0.06 * imgW));
        padY = max(3, round(0.10 * imgH));
        x1 = max(1, x1 - padX);
        y1 = max(1, y1 - padY);
        x2 = min(imgW, x2 + padX);
        y2 = min(imgH, y2 + padY);

        rw = x2 - x1 + 1;
        rh = y2 - y1 + 1;
        if rw < 0.45 * imgW || rh < 0.35 * imgH
            refineDebug.selectedBinaryMask = selectedMask;
            refineDebug.rowProjection = rowProj;
            refineDebug.colProjection = colProj;
            refineDebug.status = "refined_box_too_small";
            return;
        end

        refinedPlateImg = plateImg(y1:y2, x1:x2, :);
        refineDebug.selectedBinaryMask = selectedMask;
        refineDebug.rowProjection = rowProj;
        refineDebug.colProjection = colProj;
        refineDebug.refinedBBox = [x1, y1, rw, rh];
        sameAsInput = (x1 == 1) && (y1 == 1) && (rw == imgW) && (rh == imgH);
        refineDebug.refinementApplied = ~sameAsInput;
        refineDebug.status = "ok";
    catch ME
        refinedPlateImg = plateImg;
        refineDebug.status = "refine_failed: " + string(ME.message);
    end
end
