function scoredTable = scorePlateCandidates(candidateTable)
% scorePlateCandidates  Compute weighted candidate scores.

    scoredTable = candidateTable;

    if isempty(candidateTable)
        return;
    end

    n = height(candidateTable);

    aspectTarget = 3.8;
    aspectScore = max(0, 1 - abs(scoredTable.AspectRatio - aspectTarget) / 4.4);
    plateAspectScore = max(0, 1 - abs(scoredTable.AspectRatio - 4.0) / 2.4);

    areaTarget = 0.018;
    areaScore = max(0, 1 - abs(scoredTable.AreaRatio - areaTarget) / 0.05);

    edgeCenter = 0.16;
    edgeScore = max(0, 1 - abs(scoredTable.EdgeDensity - edgeCenter) / 0.24);

    interiorScore = min(max(scoredTable.InteriorEdgeRatio, 0), 1);

    if all(isnan(scoredTable.ContrastStd))
        contrastScore = zeros(n, 1);
    else
        contrastScore = normalize01(scoredTable.ContrastStd);
    end

    if ismember('SourceCount', scoredTable.Properties.VariableNames)
        sourceCountScore = min(max((scoredTable.SourceCount - 1) / 3, 0), 1);
    else
        sourceCountScore = zeros(n, 1);
    end

    widthSpanTarget = 0.17;
    if ismember('AreaPixels', scoredTable.Properties.VariableNames)
        imgAreaApprox = scoredTable.AreaPixels ./ max(scoredTable.AreaRatio, eps);
        imgWApprox = sqrt(max(imgAreaApprox, 1));
        widthRatio = scoredTable.Width ./ max(imgWApprox, 1);
    else
        widthRatio = min(scoredTable.Width ./ max(scoredTable.Width, 1), 1);
    end
    widthSpanScore = min(max((widthRatio - 0.05) / max(widthSpanTarget - 0.05, eps), 0), 1);

    textOnlyMask = (scoredTable.AspectRatio < 2.0) & (widthRatio < 0.13) & ...
                   ((scoredTable.EdgeDensity > 0.12) | (scoredTable.InteriorEdgeRatio > 0.45));
    textOnlyPenalty = zeros(n, 1);
    textOnlyPenalty(textOnlyMask) = 0.18;

    groupedCandidateBonus = zeros(n, 1);
    if ismember('GroupType', scoredTable.Properties.VariableNames)
        groupedMask = string(scoredTable.GroupType) == "horizontal_group";
        groupedCandidateBonus(groupedMask) = 0.12;
    end

    multiSourceBonus = zeros(n, 1);
    verticalSinglePenalty = zeros(n, 1);
    verticalGroupPenalty = zeros(n, 1);
    supportMask = false(n, 1);
    if ismember('SourceMethod', scoredTable.Properties.VariableNames)
        src = string(scoredTable.SourceMethod);
        supportMask = contains(src, "edge_morph") & contains(src, "vertical_edge");

        verticalOnlyMask = contains(src, "vertical_edge") & ~contains(src, "edge_morph");
        singleMask = false(n, 1);
        groupMask = false(n, 1);
        if ismember('GroupType', scoredTable.Properties.VariableNames)
            singleMask = string(scoredTable.GroupType) == "single";
            groupMask = string(scoredTable.GroupType) == "horizontal_group";
        end
        verticalSinglePenalty(verticalOnlyMask & singleMask) = 0.16;
        verticalGroupPenalty(verticalOnlyMask & groupMask) = 0.05;
    end

    characterStructureScore = zeros(n, 1);
    characterCountScore = zeros(n, 1);
    characterCoverageScore = zeros(n, 1);
    charCompCount = zeros(n, 1);
    if ismember('CharacterStructureScore', scoredTable.Properties.VariableNames)
        characterStructureScore = min(max(zeroNaN(scoredTable.CharacterStructureScore), 0), 1);
    end
    if ismember('CharacterComponentCount', scoredTable.Properties.VariableNames)
        charCompCount = zeroNaN(scoredTable.CharacterComponentCount);
        characterCountScore = max(0, 1 - abs(charCompCount - 6) / 6);
    end
    if ismember('CharacterWidthCoverage', scoredTable.Properties.VariableNames)
        cov = zeroNaN(scoredTable.CharacterWidthCoverage);
        characterCoverageScore = min(max((cov - 0.20) / 0.55, 0), 1);
    end
    characterScore = 0.55 * characterStructureScore + 0.25 * characterCountScore + 0.20 * characterCoverageScore;
    textContinuityReward = min(max((zeroNaN(scoredTable.CharacterWidthCoverage) - 0.45) / 0.45, 0), 1) * 0.05;

    if ismember('DarkContrastScore', scoredTable.Properties.VariableNames)
        darkContrastScore = min(max(zeroNaN(scoredTable.DarkContrastScore), 0), 1);
    else
        darkContrastScore = zeros(n, 1);
    end
    darkCentroidPenalty = zeros(n, 1);
    if ismember('BrightCentroidOffset', scoredTable.Properties.VariableNames)
        darkCentroidPenalty = min(max((zeroNaN(scoredTable.BrightCentroidOffset) - 0.20) / 0.60, 0), 1) * 0.08;
    end

    if any(supportMask)
        hasCharEvidence = (characterScore >= 0.25) | (charCompCount >= 2);
        multiSourceBonus(supportMask & hasCharEvidence) = 0.10;
        multiSourceBonus(supportMask & ~hasCharEvidence) = 0.02;
    end

    noCharEvidenceMask = (characterScore <= 0.01) & (charCompCount <= 0.1);
    characterEvidencePenalty = zeros(n, 1);
    characterEvidencePenalty(noCharEvidenceMask) = 0.26;

    positionSoftPenalty = zeros(n, 1);
    y = scoredTable.CenterYRatio;
    x = scoredTable.CenterXRatio;
    topPenalty = min(max((0.16 - y) / 0.16, 0), 1);
    bottomPenalty = min(max((y - 0.90) / 0.10, 0), 1);
    sidePenalty = min(max((abs(x - 0.5) - 0.43) / 0.07, 0), 1);
    positionSoftPenalty = 0.08 * topPenalty + 0.10 * bottomPenalty + 0.06 * sidePenalty;
    groupGeometryPenalty = zeros(n, 1);
    if ismember('GroupGeometryPenalty', scoredTable.Properties.VariableNames)
        groupGeometryPenalty = min(max(zeroNaN(scoredTable.GroupGeometryPenalty), 0), 0.25);
    end
    lowCoverageGroupPenalty = zeros(n, 1);
    if ismember('GroupType', scoredTable.Properties.VariableNames)
        groupedMask = string(scoredTable.GroupType) == "horizontal_group";
        lowCoverageGroupPenalty(groupedMask) = min(max((0.22 - zeroNaN(scoredTable.CharacterWidthCoverage(groupedMask))) / 0.22, 0), 1) * 0.08;
    end

    w = struct();
    w.aspect = 0.12;
    w.plateAspect = 0.18;
    w.area = 0.10;
    w.edge = 0.14;
    w.interior = 0.10;
    w.contrast = 0.10;
    w.widthSpan = 0.17;
    w.sourceCount = 0.04;
    w.character = 0.13;
    w.darkContrast = 0.05;

    finalScore = w.aspect * aspectScore + ...
                 w.plateAspect * plateAspectScore + ...
                 w.area * areaScore + ...
                 w.edge * edgeScore + ...
                 w.interior * interiorScore + ...
                 w.contrast * contrastScore + ...
                 w.widthSpan * widthSpanScore + ...
                 w.sourceCount * sourceCountScore + ...
                 w.character * characterScore + ...
                 w.darkContrast * darkContrastScore + ...
                 textContinuityReward + ...
                 multiSourceBonus + ...
                 groupedCandidateBonus - ...
                 textOnlyPenalty - ...
                 verticalSinglePenalty - ...
                 verticalGroupPenalty - ...
                 positionSoftPenalty - ...
                 darkCentroidPenalty - ...
                 groupGeometryPenalty - ...
                 lowCoverageGroupPenalty - ...
                 characterEvidencePenalty;

    finalScoreBeforeCap = finalScore;
    scoreCapApplied = false(n, 1);
    noCapMask = (darkContrastScore >= 0.70) | (characterScore >= 0.45);
    capMask = noCharEvidenceMask & ~noCapMask;
    scoreCap = 0.65;
    finalScore(capMask) = min(finalScore(capMask), scoreCap);
    scoreCapApplied(capMask) = true;

    finalScore = min(max(finalScore, 0), 1);

    finalScore(~scoredTable.IsValid) = NaN;

    scoredTable.AspectScore = aspectScore;
    scoredTable.PlateAspectScore = plateAspectScore;
    scoredTable.AreaScore = areaScore;
    scoredTable.EdgeDensityScore = edgeScore;
    scoredTable.InteriorScore = interiorScore;
    scoredTable.ContrastScore = contrastScore;
    scoredTable.WidthSpanScore = widthSpanScore;
    scoredTable.SourceCountScore = sourceCountScore;
    scoredTable.TextOnlyPenalty = textOnlyPenalty;
    scoredTable.VerticalSinglePenalty = verticalSinglePenalty;
    scoredTable.PositionSoftPenalty = positionSoftPenalty;
    scoredTable.CharacterEvidencePenalty = characterEvidencePenalty;
    scoredTable.GroupedCandidateBonus = groupedCandidateBonus;
    scoredTable.MultiSourceBonus = multiSourceBonus;
    scoredTable.CharacterScore = characterScore;
    scoredTable.FinalScoreBeforeCap = finalScoreBeforeCap;
    scoredTable.ScoreCapApplied = scoreCapApplied;
    scoredTable.Score = finalScore;

    scoredTable = sortrows(scoredTable, 'Score', 'descend', 'MissingPlacement', 'last');
end


function y = zeroNaN(x)
    y = x;
    y(~isfinite(y)) = 0;
end


function y = normalize01(x)
    y = zeros(size(x));
    valid = isfinite(x);

    if ~any(valid)
        return;
    end

    xv = x(valid);
    minV = min(xv);
    maxV = max(xv);

    if maxV <= minV
        y(valid) = 0.5;
        return;
    end

    y(valid) = (xv - minV) / (maxV - minV);
end
