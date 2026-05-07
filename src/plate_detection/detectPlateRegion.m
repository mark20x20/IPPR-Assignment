function [plateImg, plateBBox, debugInfo] = detectPlateRegion(preprocessedImg, originalImg)
% detectPlateRegion  Multi-candidate orchestrator (Method A + Method B).
% Public signature remains stable.

    plateImg = [];
    plateBBox = [];

    debugInfo = struct( ...
        'grayImg', [], ...
        'enhancedImg', [], ...
        'edgeImg', [], ...
        'closedImg', [], ...
        'filledImg', [], ...
        'cleanedImg', [], ...
        'verticalEdgeResponse', [], ...
        'verticalEdgeBinary', [], ...
        'darkRegionBinary', [], ...
        'regions', [], ...
        'numConnectedComponents', 0, ...
        'numRegionsBeforeFiltering', 0, ...
        'rawCandidateCount', 0, ...
        'methodACandidateCount', 0, ...
        'methodBCandidateCount', 0, ...
        'methodCCandidateCount', 0, ...
        'groupedCandidateCount', 0, ...
        'candidateTable', table(), ...
        'candidateDiagnostics', table(), ...
        'rejectReasonSummary', table(), ...
        'selectedCandidateIdBeforeRefine', NaN, ...
        'selectedBBoxBeforeRefine', [], ...
        'selectedCandidateIdAfterRefine', NaN, ...
        'selectedOriginalBBoxAfterRefine', [], ...
        'selectedRefinedBBoxAfterRefine', [], ...
        'refinementChangedCandidate', false, ...
        'selectedOriginalBBox', [], ...
        'selectedRefinedBBox', [], ...
        'refinementApplied', false, ...
        'refinementQualityScore', 0, ...
        'plateFound', false, ...
        'isFallback', false, ...
        'status', "Not started", ...
        'debugOutputDir', "");

    if nargin < 2 || isempty(preprocessedImg) || isempty(originalImg)
        debugInfo.status = "Input image is empty or missing.";
        return;
    end

    try
        workingGray = localToGrayUint8(preprocessedImg);

        MAX_WORKING_WIDTH = 900;
        [imgH, imgW] = size(workingGray);
        if imgW > MAX_WORKING_WIDTH
            scaleFactor = MAX_WORKING_WIDTH / imgW;
            workingGray = imresize(workingGray, scaleFactor);
            originalImgSmall = imresize(originalImg, scaleFactor);
        else
            scaleFactor = 1.0;
            originalImgSmall = originalImg;
        end

        [rawCandidatesA, methodDebug] = generateEdgeMorphCandidates(workingGray);
        [rawCandidatesB, methodBDebug] = generateVerticalEdgeCandidates(workingGray, methodDebug.edgeImg);
        [rawCandidatesC, methodCDebug] = generateDarkContrastCandidates(workingGray, methodDebug.edgeImg);

        debugInfo.methodACandidateCount = height(rawCandidatesA);
        debugInfo.methodBCandidateCount = height(rawCandidatesB);
        debugInfo.methodCCandidateCount = height(rawCandidatesC);

        if ~isempty(rawCandidatesA)
            if ~ismember('GroupType', rawCandidatesA.Properties.VariableNames)
                rawCandidatesA.GroupType = repmat("single", height(rawCandidatesA), 1);
            end
            if ~ismember('ParentCandidateIds', rawCandidatesA.Properties.VariableNames)
                rawCandidatesA.ParentCandidateIds = strings(height(rawCandidatesA), 1);
            end
            if ~ismember('SourceCount', rawCandidatesA.Properties.VariableNames)
                rawCandidatesA.SourceCount = ones(height(rawCandidatesA), 1);
            end
        end

        [rawCandidatesA, rawCandidatesB, rawCandidatesC] = ...
            alignRawCandidateTables(rawCandidatesA, rawCandidatesB, rawCandidatesC);

        if ~isempty(rawCandidatesB)
            rawCandidatesB.RegionIndex = rawCandidatesB.RegionIndex + height(rawCandidatesA);
        end
        if ~isempty(rawCandidatesC)
            rawCandidatesC.RegionIndex = rawCandidatesC.RegionIndex + height(rawCandidatesA) + height(rawCandidatesB);
        end
        rawCandidates = [rawCandidatesA; rawCandidatesB; rawCandidatesC];
        debugInfo.rawCandidateCount = height(rawCandidates);

        [rawCandidates, groupInfo] = groupHorizontalCandidates(rawCandidates, size(workingGray));
        debugInfo.groupedCandidateCount = groupInfo.groupedCount;

        candidateTable = buildCandidateTable(rawCandidates, size(workingGray), methodDebug.edgeImg, methodDebug.enhancedImg);
        candidateTable = scorePlateCandidates(candidateTable);

        [bestBBoxSmall, bestRow, rankedTable] = selectBestScoredCandidate(candidateTable);

        [bestBBoxSmall, bestRow, rankedTable, refineDecision] = ...
            localRefineAndRerank(originalImgSmall, workingGray, bestBBoxSmall, bestRow, rankedTable);

        debugInfo.grayImg = methodDebug.grayImg;
        debugInfo.enhancedImg = methodDebug.enhancedImg;
        debugInfo.edgeImg = methodDebug.edgeImg;
        debugInfo.closedImg = methodDebug.closedImg;
        debugInfo.filledImg = methodDebug.filledImg;
        debugInfo.cleanedImg = methodDebug.cleanedImg;
        debugInfo.verticalEdgeResponse = methodBDebug.verticalEdgeResponse;
        debugInfo.verticalEdgeBinary = methodBDebug.verticalEdgeBinary;
        debugInfo.darkRegionBinary = methodCDebug.darkRegionBinary;
        debugInfo.regions = methodDebug.regions;
        debugInfo.numConnectedComponents = methodDebug.numConnectedComponents;
        debugInfo.numRegionsBeforeFiltering = methodDebug.numRegionsBeforeFiltering;
        debugInfo.candidateTable = rankedTable;
        debugInfo.candidateDiagnostics = rankedTable;
        debugInfo.selectedCandidateIdBeforeRefine = refineDecision.selectedCandidateIdBeforeRefine;
        debugInfo.selectedBBoxBeforeRefine = refineDecision.selectedBBoxBeforeRefine;
        debugInfo.selectedCandidateIdAfterRefine = refineDecision.selectedCandidateIdAfterRefine;
        debugInfo.selectedOriginalBBoxAfterRefine = refineDecision.selectedOriginalBBoxAfterRefine;
        debugInfo.selectedRefinedBBoxAfterRefine = refineDecision.selectedRefinedBBoxAfterRefine;
        debugInfo.refinementChangedCandidate = refineDecision.changedCandidate;
        debugInfo.selectedOriginalBBox = refineDecision.originalBBox;
        debugInfo.selectedRefinedBBox = refineDecision.refinedBBox;
        debugInfo.refinementApplied = refineDecision.applied;
        debugInfo.refinementQualityScore = refineDecision.qualityScore;

        if ~isempty(rankedTable)
            rejectRows = rankedTable(~rankedTable.IsValid, :);
            if ~isempty(rejectRows)
                [uReasons, ~, idx] = unique(string(rejectRows.RejectReason));
                counts = accumarray(idx, 1);
                debugInfo.rejectReasonSummary = table(uReasons, counts, 'VariableNames', {'Reason', 'Count'});
                debugInfo.rejectReasonSummary = sortrows(debugInfo.rejectReasonSummary, 'Count', 'descend');
            end
        end

        if ~isempty(bestBBoxSmall)
            if scaleFactor < 1.0
                plateBBox = [ ...
                    bestBBoxSmall(1) / scaleFactor, ...
                    bestBBoxSmall(2) / scaleFactor, ...
                    bestBBoxSmall(3) / scaleFactor, ...
                    bestBBoxSmall(4) / scaleFactor];
            else
                plateBBox = bestBBoxSmall;
            end

            plateImg = cropPlateRegion(originalImg, plateBBox);

            if ~isempty(plateImg)
                debugInfo.plateFound = true;
                debugInfo.isFallback = false;
                debugInfo.status = "Plate candidate detected and cropped successfully.";
            else
                plateImg = [];
                plateBBox = [];
                debugInfo.plateFound = false;
                debugInfo.isFallback = false;
                debugInfo.status = "Best candidate exists but crop failed.";
            end
        else
            plateImg = [];
            plateBBox = [];
            debugInfo.plateFound = false;
            debugInfo.isFallback = false;
            debugInfo.status = "No valid plate candidate found.";
        end

        exportInfo = saveDetectionDebugOutputs(originalImgSmall, debugInfo);
        if isstruct(exportInfo) && isfield(exportInfo, 'outputDir')
            debugInfo.debugOutputDir = string(exportInfo.outputDir);
        end

    catch ME
        plateImg = [];
        plateBBox = [];
        debugInfo.plateFound = false;
        debugInfo.isFallback = false;
        debugInfo.status = "Detection failed: " + string(ME.message);
    end
end


function [bestBBoxOut, bestRowOut, rankedOut, refineDecision] = localRefineAndRerank(originalImg, grayImg, bestBBoxIn, bestRowIn, rankedIn)
    bestBBoxOut = bestBBoxIn;
    bestRowOut = bestRowIn;
    rankedOut = rankedIn;
    refineDecision = struct( ...
        'selectedCandidateIdBeforeRefine', NaN, ...
        'selectedBBoxBeforeRefine', [], ...
        'selectedCandidateIdAfterRefine', NaN, ...
        'selectedOriginalBBoxAfterRefine', [], ...
        'selectedRefinedBBoxAfterRefine', [], ...
        'changedCandidate', false, ...
        'originalBBox', [], ...
        'refinedBBox', [], ...
        'applied', false, ...
        'qualityScore', 0);

    if isempty(rankedIn) || isempty(bestBBoxIn)
        return;
    end

    if ~ismember('Score', rankedIn.Properties.VariableNames)
        return;
    end

    if ~isempty(bestRowIn) && istable(bestRowIn) && ismember('RegionIndex', bestRowIn.Properties.VariableNames)
        refineDecision.selectedCandidateIdBeforeRefine = bestRowIn.RegionIndex(1);
    end
    refineDecision.selectedBBoxBeforeRefine = bestBBoxIn;

    n = height(rankedIn);
    rankedOut.RefinementQualityScore = nan(n, 1);
    rankedOut.TextCenterednessScore = nan(n, 1);
    rankedOut.RefinementApplied = false(n, 1);
    rankedOut.RefinedX = nan(n, 1);
    rankedOut.RefinedY = nan(n, 1);
    rankedOut.RefinedWidth = nan(n, 1);
    rankedOut.RefinedHeight = nan(n, 1);

    validIdx = find(rankedOut.IsValid & isfinite(rankedOut.Score));
    if isempty(validIdx)
        return;
    end

    topN = min(5, numel(validIdx));
    candIdx = validIdx(1:topN);
    refinedScore = -inf(topN, 1);

    for k = 1:topN
        i = candIdx(k);
        bbox = [rankedOut.X(i), rankedOut.Y(i), rankedOut.Width(i), rankedOut.Height(i)];
        isTinyCandidate = (bbox(3) < 50) || (bbox(4) < 14);

        if isTinyCandidate
            % Safety guard: do not let tiny fragments drive refinement-based rerank switching.
            rankedOut.RefinementQualityScore(i) = 0;
            rankedOut.TextCenterednessScore(i) = 0;
            rankedOut.RefinementApplied(i) = false;
            rankedOut.RefinedX(i) = bbox(1);
            rankedOut.RefinedY(i) = bbox(2);
            rankedOut.RefinedWidth(i) = bbox(3);
            rankedOut.RefinedHeight(i) = bbox(4);
            refinedScore(k) = rankedOut.Score(i);
            continue;
        end

        [rb, info] = refinePlateCandidateBBox(originalImg, grayImg, bbox);

        if info.applied
            % Local consistency guard: reject refinement that drifts too far from original center.
            oCx = bbox(1) + bbox(3) / 2;
            oCy = bbox(2) + bbox(4) / 2;
            rCx = rb(1) + rb(3) / 2;
            rCy = rb(2) + rb(4) / 2;
            centerDist = hypot(rCx - oCx, rCy - oCy);
            distLimit = max(12, 0.65 * hypot(bbox(3), bbox(4)));
            if centerDist > distLimit
                rb = bbox;
                info.applied = false;
                info.qualityScore = 0;
                info.textCenterednessScore = 0;
            end
        end

        rankedOut.RefinementQualityScore(i) = info.qualityScore;
        rankedOut.TextCenterednessScore(i) = info.textCenterednessScore;
        rankedOut.RefinementApplied(i) = info.applied;
        rankedOut.RefinedX(i) = rb(1);
        rankedOut.RefinedY(i) = rb(2);
        rankedOut.RefinedWidth(i) = rb(3);
        rankedOut.RefinedHeight(i) = rb(4);

        rbAspect = rb(3) / max(rb(4), 1);
        aspectFit = max(0, 1 - abs(rbAspect - 4.2) / 4.2);
        sizeGuard = double(rb(3) > 24 && rb(4) > 10);
        refinedScore(k) = rankedOut.Score(i) + 0.10 * info.qualityScore + ...
                         0.05 * info.textCenterednessScore + 0.03 * aspectFit + ...
                         0.02 * sizeGuard;
    end

    [maxRefScore, bestK] = max(refinedScore);
    bestI = candIdx(bestK);
    baseBest = rankedOut.Score(validIdx(1));

    postOriginalBBox = [rankedOut.X(bestI), rankedOut.Y(bestI), rankedOut.Width(bestI), rankedOut.Height(bestI)];
    postRefinedBBox = [rankedOut.RefinedX(bestI), rankedOut.RefinedY(bestI), ...
                       rankedOut.RefinedWidth(bestI), rankedOut.RefinedHeight(bestI)];
    refineDecision.selectedCandidateIdAfterRefine = rankedOut.RegionIndex(bestI);
    refineDecision.selectedOriginalBBoxAfterRefine = postOriginalBBox;
    refineDecision.selectedRefinedBBoxAfterRefine = postRefinedBBox;
    refineDecision.changedCandidate = ~isequaln(refineDecision.selectedCandidateIdAfterRefine, ...
                                                refineDecision.selectedCandidateIdBeforeRefine);
    refineDecision.originalBBox = postOriginalBBox;
    refineDecision.refinedBBox = postRefinedBBox;
    refineDecision.qualityScore = rankedOut.RefinementQualityScore(bestI);

    if isfinite(maxRefScore) && (maxRefScore > (baseBest + 0.02)) && rankedOut.RefinementApplied(bestI)
        bestBBoxOut = refineDecision.refinedBBox;
        bestRowOut = rankedOut(bestI, :);
        refineDecision.applied = true;
    else
        refineDecision.selectedCandidateIdAfterRefine = refineDecision.selectedCandidateIdBeforeRefine;
        refineDecision.selectedOriginalBBoxAfterRefine = bestBBoxIn;
        refineDecision.selectedRefinedBBoxAfterRefine = bestBBoxIn;
        refineDecision.changedCandidate = false;
        refineDecision.originalBBox = bestBBoxIn;
        refineDecision.refinedBBox = bestBBoxIn;
        refineDecision.applied = false;
    end
end


function grayImg = localToGrayUint8(inputImg)
    if size(inputImg, 3) == 3
        grayImg = rgb2gray(inputImg);
    else
        grayImg = inputImg;
    end

    if isa(grayImg, 'uint8')
        return;
    end

    if isfloat(grayImg)
        grayImg = im2uint8(mat2gray(grayImg));
    else
        grayImg = im2uint8(mat2gray(double(grayImg)));
    end
end


function [a, b, c] = alignRawCandidateTables(a, b, c)
    names = {};
    if istable(a), names = [names, a.Properties.VariableNames]; end
    if istable(b), names = [names, b.Properties.VariableNames]; end
    if istable(c), names = [names, c.Properties.VariableNames]; end
    names = unique(names, 'stable');

    a = addMissingColumns(a, names);
    b = addMissingColumns(b, names);
    c = addMissingColumns(c, names);

    if istable(a), a = a(:, names); end
    if istable(b), b = b(:, names); end
    if istable(c), c = c(:, names); end
end


function t = addMissingColumns(t, allNames)
    if ~istable(t)
        t = table();
        for i = 1:numel(allNames)
            t.(allNames{i}) = [];
        end
        return;
    end

    n = height(t);
    for i = 1:numel(allNames)
        col = allNames{i};
        if ismember(col, t.Properties.VariableNames)
            continue;
        end

        if ismember(col, {'SourceMethod', 'GroupType', 'ParentCandidateIds'})
            t.(col) = strings(n, 1);
        elseif ismember(col, {'RegionIndex', 'SourceCount', 'BrightComponentCount'})
            t.(col) = nan(n, 1);
        else
            t.(col) = nan(n, 1);
        end
    end
end
