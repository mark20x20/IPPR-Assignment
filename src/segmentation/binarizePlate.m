function [binaryPlateImg, binarizeDebug] = binarizePlate(plateImg)
% binarizePlate  Convert a plate image to binary (character foreground = white).

    binaryPlateImg = [];
    binarizeDebug = struct( ...
        'grayImg', [], ...
        'enhancedImg', [], ...
        'binaryBright', [], ...
        'binaryDark', [], ...
        'selectedBinary', [], ...
        'selectedPolarity', "", ...
        'brightPolarityScore', NaN, ...
        'darkPolarityScore', NaN, ...
        'foregroundRatio', NaN, ...
        'componentCount', 0, ...
        'status', "not_started");

    if isempty(plateImg)
        binarizeDebug.status = "empty_input";
        return;
    end

    try
        if ndims(plateImg) == 3
            grayImg = rgb2gray(plateImg);
        else
            grayImg = plateImg;
        end
        grayImg = im2uint8(grayImg);
        enhancedImg = adapthisteq(grayImg, 'ClipLimit', 0.02, 'Distribution', 'rayleigh');
        enhancedImg = imadjust(enhancedImg);
        enhancedImg = medfilt2(enhancedImg, [3 3]);

        tBright = adaptthresh(enhancedImg, 0.47, 'ForegroundPolarity', 'bright');
        tDark = adaptthresh(enhancedImg, 0.47, 'ForegroundPolarity', 'dark');
        binaryBright = imbinarize(enhancedImg, tBright);
        binaryDark = imbinarize(enhancedImg, tDark);

        scoreBright = localScoreMask(binaryBright);
        scoreDark = localScoreMask(binaryDark);

        % Mild preference shift to dark polarity when bright looks background-dominated.
        brightAdjusted = scoreBright.total - 0.08 * scoreBright.borderBandPenalty - ...
                         0.06 * scoreBright.largeBlobPenalty - 0.06 * scoreBright.borderPenalty;
        darkAdjusted = scoreDark.total + 0.05 * scoreDark.textBandScore + ...
                       0.04 * scoreDark.heightConsistency + 0.04 * scoreDark.charLikeScore;

        if brightAdjusted >= darkAdjusted
            selectedMask = binaryBright;
            selectedPolarity = "bright_foreground";
            selectedScore = brightAdjusted;
        else
            selectedMask = binaryDark;
            selectedPolarity = "dark_foreground";
            selectedScore = darkAdjusted;
        end

        binaryPlateImg = logical(selectedMask);
        fgRatio = nnz(binaryPlateImg) / max(1, numel(binaryPlateImg));
        cc = bwconncomp(binaryPlateImg);

        binarizeDebug.grayImg = grayImg;
        binarizeDebug.enhancedImg = enhancedImg;
        binarizeDebug.binaryBright = binaryBright;
        binarizeDebug.binaryDark = binaryDark;
        binarizeDebug.selectedBinary = binaryPlateImg;
        binarizeDebug.selectedPolarity = selectedPolarity;
        binarizeDebug.brightPolarityScore = scoreBright.total;
        binarizeDebug.darkPolarityScore = scoreDark.total;
        binarizeDebug.foregroundRatio = fgRatio;
        binarizeDebug.componentCount = cc.NumObjects;
        binarizeDebug.status = "ok(score=" + string(selectedScore) + ")";
    catch ME
        binaryPlateImg = [];
        binarizeDebug.status = "binarize_failed: " + string(ME.message);
    end
end


function score = localScoreMask(maskIn)
    mask = logical(maskIn);
    fgRatio = nnz(mask) / max(1, numel(mask));

    % Prefer moderate foreground amount for text.
    ratioScore = max(0, 1 - abs(fgRatio - 0.24) / 0.22);
    if fgRatio > 0.48 || fgRatio < 0.03
        ratioScore = ratioScore * 0.25;
    end

    cc = bwconncomp(mask);
    stats = regionprops(cc, 'BoundingBox', 'Area');
    nComp = cc.NumObjects;

    if nComp == 0
        score = struct('total', 0, 'borderBandPenalty', 1, 'largeBlobPenalty', 1, ...
            'borderPenalty', 1, 'textBandScore', 0, 'heightConsistency', 0, 'charLikeScore', 0);
        return;
    end

    imgH = size(mask, 1);
    imgW = size(mask, 2);
    charLike = 0;
    xMin = inf;
    xMax = -inf;
    cyList = [];
    hList = [];
    borderHeavyCount = 0;
    wideOrLargeCount = 0;
    for i = 1:nComp
        bb = stats(i).BoundingBox;
        w = bb(3);
        h = bb(4);
        area = stats(i).Area;
        ar = w / max(h, 1);
        x = bb(1);
        y = bb(2);
        touchRatio = borderTouchRatio(x, y, w, h, imgW, imgH);
        if touchRatio > 0.40
            borderHeavyCount = borderHeavyCount + 1;
        end
        if (w > 0.42 * imgW) || (area > 0.18 * imgH * imgW)
            wideOrLargeCount = wideOrLargeCount + 1;
        end
        if h < 0.20 * imgH || h > 0.95 * imgH
            continue;
        end
        if w < 0.01 * imgW || w > 0.35 * imgW
            continue;
        end
        if area < max(5, round(0.001 * imgH * imgW))
            continue;
        end
        if ar > 1.8
            continue;
        end
        charLike = charLike + 1;
        xMin = min(xMin, bb(1));
        xMax = max(xMax, bb(1) + bb(3));
        cyList(end + 1, 1) = bb(2) + bb(4) / 2; %#ok<AGROW>
        hList(end + 1, 1) = h; %#ok<AGROW>
    end

    charCountScore = max(0, 1 - abs(charLike - 6) / 5.5);
    if charLike <= 1
        charCountScore = charCountScore * 0.2;
    end

    widthCoverage = 0;
    if isfinite(xMin) && isfinite(xMax)
        widthCoverage = (xMax - xMin) / max(imgW, 1);
    end
    spreadScore = min(max((widthCoverage - 0.22) / 0.56, 0), 1);

    if numel(cyList) >= 2
        baselineSpread = std(cyList) / max(imgH, 1);
        textBandScore = max(0, 1 - baselineSpread / 0.16);
    elseif numel(cyList) == 1
        textBandScore = 0.5;
    else
        textBandScore = 0;
    end

    if numel(hList) >= 2
        heightVar = std(hList) / max(mean(hList), 1);
        heightConsistency = max(0, 1 - heightVar / 0.9);
    else
        heightConsistency = 0.5;
    end

    borderPenalty = min(1, borderHeavyCount / max(nComp, 1));
    largeBlobPenalty = min(1, wideOrLargeCount / max(nComp, 1));

    % Border-band occupancy penalty for background/frame dominated masks.
    topBand = max(1, round(0.10 * imgH));
    bottomBand = max(1, round(0.10 * imgH));
    leftBand = max(1, round(0.08 * imgW));
    rightBand = max(1, round(0.08 * imgW));
    borderMask = false(imgH, imgW);
    borderMask(1:topBand, :) = true;
    borderMask((imgH-bottomBand+1):imgH, :) = true;
    borderMask(:, 1:leftBand) = true;
    borderMask(:, (imgW-rightBand+1):imgW) = true;
    borderFgRatio = nnz(mask & borderMask) / max(1, nnz(mask));
    borderBandPenalty = min(max((borderFgRatio - 0.45) / 0.45, 0), 1);

    total = 0.28 * ratioScore + 0.25 * charCountScore + 0.16 * spreadScore + ...
            0.16 * textBandScore + 0.15 * heightConsistency - ...
            0.16 * borderPenalty - 0.12 * largeBlobPenalty - 0.10 * borderBandPenalty;
    total = min(max(total, 0), 1);

    score = struct('total', total, ...
        'borderBandPenalty', borderBandPenalty, ...
        'largeBlobPenalty', largeBlobPenalty, ...
        'borderPenalty', borderPenalty, ...
        'textBandScore', textBandScore, ...
        'heightConsistency', heightConsistency, ...
        'charLikeScore', charCountScore);
end


function r = borderTouchRatio(x, y, w, h, imgW, imgH)
    hit = double(x <= 1.5) + double(y <= 1.5) + ...
          double((x + w) >= (imgW - 0.5)) + double((y + h) >= (imgH - 0.5));
    r = hit / 4.0;
end
