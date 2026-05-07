function exportInfo = saveDetectionDebugOutputs(originalImg, debugInfo)
% saveDetectionDebugOutputs  Save Phase 1 detection debug artifacts.

    exportInfo = struct('outputDir', "", 'savedFiles', strings(0,1));

    if isempty(originalImg)
        return;
    end

    paths = getProjectPaths();
    outRoot = paths.plateDebugRoot;
    if ~exist(outRoot, 'dir')
        mkdir(outRoot);
    end

    stamp = string(datetime('now', 'Format', 'yyyyMMdd_HHmmss_SSS'));
    outDir = fullfile(outRoot, char("run_" + stamp));
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end

    saved = strings(0, 1);

    saved = saveMaybeImage(saved, outDir, '01_gray.png', getField(debugInfo, 'grayImg'));
    saved = saveMaybeImage(saved, outDir, '02_enhanced.png', getField(debugInfo, 'enhancedImg'));
    saved = saveMaybeImage(saved, outDir, '03_edges.png', getField(debugInfo, 'edgeImg'));
    saved = saveMaybeImage(saved, outDir, '04_closed.png', getField(debugInfo, 'closedImg'));
    saved = saveMaybeImage(saved, outDir, '05_filled.png', getField(debugInfo, 'filledImg'));
    saved = saveMaybeImage(saved, outDir, '06_cleaned.png', getField(debugInfo, 'cleanedImg'));
    saved = saveMaybeImage(saved, outDir, '07_vertical_edge_response.png', getField(debugInfo, 'verticalEdgeResponse'));
    saved = saveMaybeImage(saved, outDir, '08_vertical_edge_binary.png', getField(debugInfo, 'verticalEdgeBinary'));
    saved = saveMaybeImage(saved, outDir, '09_dark_region_binary.png', getField(debugInfo, 'darkRegionBinary'));

    if isfield(debugInfo, 'candidateTable') && istable(debugInfo.candidateTable) && ~isempty(debugInfo.candidateTable)
        writetable(debugInfo.candidateTable, fullfile(outDir, 'candidate_table.csv'));
        saved(end + 1) = "candidate_table.csv";

        rejectMask = ~debugInfo.candidateTable.IsValid;
        rejectTable = debugInfo.candidateTable(rejectMask, :);
        writetable(rejectTable, fullfile(outDir, 'reject_log.csv'));
        saved(end + 1) = "reject_log.csv";
    else
        writetable(table(), fullfile(outDir, 'candidate_table.csv'));
        writetable(table(), fullfile(outDir, 'reject_log.csv'));
        saved(end + 1) = "candidate_table.csv";
        saved(end + 1) = "reject_log.csv";
    end

    overlayAll = drawCandidateOverlay(originalImg, getField(debugInfo, 'candidateTable'), false);
    if ~isempty(overlayAll)
        imwrite(overlayAll, fullfile(outDir, 'all_candidates_overlay.png'));
        saved(end + 1) = "all_candidates_overlay.png";
    end

    overlayTop = drawCandidateOverlay(originalImg, getField(debugInfo, 'candidateTable'), true);
    if ~isempty(overlayTop)
        imwrite(overlayTop, fullfile(outDir, 'top_candidates_overlay.png'));
        saved(end + 1) = "top_candidates_overlay.png";
    end

    overlayGrouped = drawGroupedOverlay(originalImg, getField(debugInfo, 'candidateTable'));
    if ~isempty(overlayGrouped)
        imwrite(overlayGrouped, fullfile(outDir, 'grouped_candidates_overlay.png'));
        saved(end + 1) = "grouped_candidates_overlay.png";
    end

    overlayVertical = drawVerticalEdgeOverlay(originalImg, getField(debugInfo, 'candidateTable'));
    if ~isempty(overlayVertical)
        imwrite(overlayVertical, fullfile(outDir, 'vertical_edge_candidates_overlay.png'));
        saved(end + 1) = "vertical_edge_candidates_overlay.png";
    end

    overlayDark = drawDarkContrastOverlay(originalImg, getField(debugInfo, 'candidateTable'));
    if ~isempty(overlayDark)
        imwrite(overlayDark, fullfile(outDir, '10_dark_contrast_candidates_overlay.png'));
        saved(end + 1) = "10_dark_contrast_candidates_overlay.png";
    end

    overlayRefined = drawRefinedOverlay(originalImg, debugInfo);
    if ~isempty(overlayRefined)
        imwrite(overlayRefined, fullfile(outDir, 'refined_candidate_overlay.png'));
        saved(end + 1) = "refined_candidate_overlay.png";
    end

    if isfield(debugInfo, 'candidateTable') && istable(debugInfo.candidateTable) && ~isempty(debugInfo.candidateTable)
        validRanked = debugInfo.candidateTable(debugInfo.candidateTable.IsValid & isfinite(debugInfo.candidateTable.Score), :);
        validRanked = sortrows(validRanked, 'Score', 'descend');
        nCrops = min(5, height(validRanked));

        for i = 1:nCrops
            bbox = [validRanked.X(i), validRanked.Y(i), validRanked.Width(i), validRanked.Height(i)];
            crop = cropPlateRegion(originalImg, bbox);
            if ~isempty(crop)
                fileName = sprintf('candidate_crop_rank_%02d.png', i);
                imwrite(crop, fullfile(outDir, fileName));
                saved(end + 1) = string(fileName);
            end
        end

        if isfield(debugInfo, 'selectedRefinedBBox') && ~isempty(debugInfo.selectedRefinedBBox)
            rcrop = cropPlateRegion(originalImg, debugInfo.selectedRefinedBBox);
            if ~isempty(rcrop)
                imwrite(rcrop, fullfile(outDir, 'candidate_crop_refined_rank_01.png'));
                saved(end + 1) = "candidate_crop_refined_rank_01.png";
            end
        end
    end

    summaryLines = buildSummary(debugInfo, outDir);
    writecell(cellstr(summaryLines), fullfile(outDir, 'summary.txt'));
    saved(end + 1) = "summary.txt";

    exportInfo.outputDir = string(outDir);
    exportInfo.savedFiles = saved;
end


function saved = saveMaybeImage(saved, outDir, fileName, img)
    if isempty(img)
        return;
    end

    try
        imwrite(img, fullfile(outDir, fileName));
        saved(end + 1) = string(fileName);
    catch
        % Keep export robust; skip invalid image.
    end
end


function value = getField(s, name)
    value = [];
    if isstruct(s) && isfield(s, name)
        value = s.(name);
    end
end


function overlayImg = drawCandidateOverlay(originalImg, candidateTable, topOnly)
    overlayImg = [];

    if isempty(originalImg) || ~istable(candidateTable) || isempty(candidateTable)
        return;
    end

    rows = candidateTable;
    if topOnly
        rows = rows(rows.IsValid & isfinite(rows.Score), :);
        rows = sortrows(rows, 'Score', 'descend');
        rows = rows(1:min(5, height(rows)), :);
    else
        rows = rows(rows.IsValid, :);
    end

    if isempty(rows)
        return;
    end

    if size(originalImg, 3) == 1
        baseImg = repmat(originalImg, 1, 1, 3);
    else
        baseImg = originalImg;
    end

    try
        overlayImg = baseImg;
        positions = [rows.X, rows.Y, rows.Width, rows.Height];

        if topOnly
            palette = {'red', 'cyan', 'yellow', 'lime', 'magenta'};
            lineWidth = 4;

            for i = 1:size(positions, 1)
                color = palette{mod(i - 1, numel(palette)) + 1};
                overlayImg = insertShape(overlayImg, 'Rectangle', positions(i, :), ...
                    'Color', color, 'LineWidth', lineWidth);

                labelText = sprintf('Rank %d | Score %.3f', i, rows.Score(i));
                labelPos = [max(1, round(rows.X(i))), max(1, round(rows.Y(i) - 18))];
                overlayImg = insertText(overlayImg, labelPos, labelText, ...
                    'FontSize', 18, 'BoxColor', color, 'BoxOpacity', 0.80, ...
                    'TextColor', 'black', 'AnchorPoint', 'LeftBottom');
            end
        else
            lineWidth = 3;
            baseColor = 'yellow';
            overlayImg = insertShape(overlayImg, 'Rectangle', positions, ...
                'Color', baseColor, 'LineWidth', lineWidth);

            maxLabels = min(20, height(rows));
            if ismember('Score', rows.Properties.VariableNames)
                rowsForLabel = sortrows(rows, 'Score', 'descend');
            else
                rowsForLabel = rows;
            end

            rowsForLabel = rowsForLabel(1:maxLabels, :);
            for i = 1:height(rowsForLabel)
                rankText = sprintf('Rank %d', i);
                if ismember('Score', rowsForLabel.Properties.VariableNames) && isfinite(rowsForLabel.Score(i))
                    rankText = sprintf('Rank %d | %.3f', i, rowsForLabel.Score(i));
                end

                labelPos = [max(1, round(rowsForLabel.X(i))), max(1, round(rowsForLabel.Y(i) - 14))];
                overlayImg = insertText(overlayImg, labelPos, rankText, ...
                    'FontSize', 14, 'BoxColor', 'black', 'BoxOpacity', 0.65, ...
                    'TextColor', 'yellow', 'AnchorPoint', 'LeftBottom');
            end
        end
    catch
        overlayImg = baseImg;
    end
end


function summaryLines = buildSummary(debugInfo, outDir)
    summaryLines = [ ...
        "Phase 1 Detection Summary"; ...
        "output_dir=" + string(outDir); ...
        "status=" + string(getField(debugInfo, 'status')); ...
        "plate_found=" + string(getField(debugInfo, 'plateFound')); ...
        "is_fallback=" + string(getField(debugInfo, 'isFallback'))
    ];

    if isfield(debugInfo, 'candidateTable') && istable(debugInfo.candidateTable)
        t = debugInfo.candidateTable;
        total = height(t);
        validCount = sum(t.IsValid);
        rejectedCount = sum(~t.IsValid);
        rawCount = getField(debugInfo, 'rawCandidateCount');
        groupedCount = getField(debugInfo, 'groupedCandidateCount');
        if isempty(rawCount)
            rawCount = total;
        end
        if isempty(groupedCount)
            groupedCount = 0;
        end
        summaryLines(end + 1) = "raw_candidate_count=" + string(rawCount);
        summaryLines(end + 1) = "method_a_candidate_count=" + string(getField(debugInfo, 'methodACandidateCount'));
        summaryLines(end + 1) = "method_b_candidate_count=" + string(getField(debugInfo, 'methodBCandidateCount'));
        summaryLines(end + 1) = "method_c_candidate_count=" + string(getField(debugInfo, 'methodCCandidateCount'));
        summaryLines(end + 1) = "grouped_candidate_count=" + string(groupedCount);
        summaryLines(end + 1) = "final_candidate_count=" + string(total);
        summaryLines(end + 1) = "candidate_count=" + string(total);
        summaryLines(end + 1) = "valid_candidate_count=" + string(validCount);
        summaryLines(end + 1) = "rejected_candidate_count=" + string(rejectedCount);

        if any(t.IsValid & isfinite(t.Score))
            best = t(t.IsValid & isfinite(t.Score), :);
            best = sortrows(best, 'Score', 'descend');
            summaryLines(end + 1) = "selected_candidate_id=" + string(best.RegionIndex(1));
            summaryLines(end + 1) = "best_score=" + string(best.Score(1));
            summaryLines(end + 1) = "selected_score=" + string(best.Score(1));
            summaryLines(end + 1) = "best_bbox=[" + string(best.X(1)) + "," + string(best.Y(1)) + "," + ...
                string(best.Width(1)) + "," + string(best.Height(1)) + "]";
            summaryLines(end + 1) = "selected_bbox=[" + string(best.X(1)) + "," + string(best.Y(1)) + "," + ...
                string(best.Width(1)) + "," + string(best.Height(1)) + "]";
            if ismember('GroupType', best.Properties.VariableNames)
                summaryLines(end + 1) = "selected_group_type=" + string(best.GroupType(1));
            end
            summaryLines(end + 1) = "selected_source_method=" + string(best.SourceMethod(1));
            summaryLines(end + 1) = "selected_candidate_id_before_refine=" + string(getField(debugInfo, 'selectedCandidateIdBeforeRefine'));
            summaryLines(end + 1) = "selected_bbox_before_refine=[" + ...
                string(getVec(debugInfo, 'selectedBBoxBeforeRefine', 1)) + "," + ...
                string(getVec(debugInfo, 'selectedBBoxBeforeRefine', 2)) + "," + ...
                string(getVec(debugInfo, 'selectedBBoxBeforeRefine', 3)) + "," + ...
                string(getVec(debugInfo, 'selectedBBoxBeforeRefine', 4)) + "]";
            summaryLines(end + 1) = "selected_candidate_id_after_refine=" + string(getField(debugInfo, 'selectedCandidateIdAfterRefine'));
            summaryLines(end + 1) = "selected_original_bbox_after_refine=[" + ...
                string(getVec(debugInfo, 'selectedOriginalBBoxAfterRefine', 1)) + "," + ...
                string(getVec(debugInfo, 'selectedOriginalBBoxAfterRefine', 2)) + "," + ...
                string(getVec(debugInfo, 'selectedOriginalBBoxAfterRefine', 3)) + "," + ...
                string(getVec(debugInfo, 'selectedOriginalBBoxAfterRefine', 4)) + "]";
            summaryLines(end + 1) = "selected_refined_bbox_after_refine=[" + ...
                string(getVec(debugInfo, 'selectedRefinedBBoxAfterRefine', 1)) + "," + ...
                string(getVec(debugInfo, 'selectedRefinedBBoxAfterRefine', 2)) + "," + ...
                string(getVec(debugInfo, 'selectedRefinedBBoxAfterRefine', 3)) + "," + ...
                string(getVec(debugInfo, 'selectedRefinedBBoxAfterRefine', 4)) + "]";
            summaryLines(end + 1) = "selected_original_bbox=[" + ...
                string(getVec(debugInfo, 'selectedOriginalBBox', 1)) + "," + ...
                string(getVec(debugInfo, 'selectedOriginalBBox', 2)) + "," + ...
                string(getVec(debugInfo, 'selectedOriginalBBox', 3)) + "," + ...
                string(getVec(debugInfo, 'selectedOriginalBBox', 4)) + "]";
            summaryLines(end + 1) = "selected_refined_bbox=[" + ...
                string(getVec(debugInfo, 'selectedRefinedBBox', 1)) + "," + ...
                string(getVec(debugInfo, 'selectedRefinedBBox', 2)) + "," + ...
                string(getVec(debugInfo, 'selectedRefinedBBox', 3)) + "," + ...
                string(getVec(debugInfo, 'selectedRefinedBBox', 4)) + "]";
            summaryLines(end + 1) = "refinement_applied=" + string(getField(debugInfo, 'refinementApplied'));
            summaryLines(end + 1) = "refinement_changed_candidate=" + string(getField(debugInfo, 'refinementChangedCandidate'));
            summaryLines(end + 1) = "refinement_quality_score=" + string(getField(debugInfo, 'refinementQualityScore'));
            if ismember('CharacterScore', best.Properties.VariableNames)
                summaryLines(end + 1) = "selected_character_score=" + string(best.CharacterScore(1));
            end
            if ismember('MultiSourceBonus', best.Properties.VariableNames)
                summaryLines(end + 1) = "selected_multisource_bonus=" + string(best.MultiSourceBonus(1));
            end
            if ismember('VerticalSinglePenalty', best.Properties.VariableNames)
                summaryLines(end + 1) = "selected_vertical_single_penalty=" + string(best.VerticalSinglePenalty(1));
            end
            if ismember('CharacterEvidencePenalty', best.Properties.VariableNames)
                summaryLines(end + 1) = "selected_character_evidence_penalty=" + string(best.CharacterEvidencePenalty(1));
            end
            if ismember('PositionSoftPenalty', best.Properties.VariableNames)
                summaryLines(end + 1) = "selected_position_soft_penalty=" + string(best.PositionSoftPenalty(1));
            end
            if ismember('TextOnlyPenalty', best.Properties.VariableNames)
                summaryLines(end + 1) = "selected_text_only_penalty=" + string(best.TextOnlyPenalty(1));
            end
        end
    end
end


function overlayImg = drawRefinedOverlay(originalImg, debugInfo)
    overlayImg = [];
    if isempty(originalImg)
        return;
    end
    ob = getField(debugInfo, 'selectedOriginalBBox');
    rb = getField(debugInfo, 'selectedRefinedBBox');
    if isempty(ob) && isempty(rb)
        return;
    end
    if size(originalImg, 3) == 1
        overlayImg = repmat(originalImg, 1, 1, 3);
    else
        overlayImg = originalImg;
    end
    try
        if ~isempty(ob) && numel(ob) == 4
            overlayImg = insertShape(overlayImg, 'Rectangle', ob, 'Color', 'yellow', 'LineWidth', 3);
            overlayImg = insertText(overlayImg, [max(1, round(ob(1))), max(1, round(ob(2)-14))], ...
                'Original', 'FontSize', 14, 'BoxColor', 'yellow', 'TextColor', 'black');
        end
        if ~isempty(rb) && numel(rb) == 4
            overlayImg = insertShape(overlayImg, 'Rectangle', rb, 'Color', 'red', 'LineWidth', 4);
            overlayImg = insertText(overlayImg, [max(1, round(rb(1))), max(1, round(rb(2)-14))], ...
                'Refined', 'FontSize', 14, 'BoxColor', 'red', 'TextColor', 'white');
        end
    catch
    end
end


function v = getVec(s, fieldName, idx)
    v = "";
    if ~isstruct(s) || ~isfield(s, fieldName)
        return;
    end
    a = s.(fieldName);
    if isempty(a) || numel(a) < idx
        return;
    end
    v = string(a(idx));
end


function overlayImg = drawDarkContrastOverlay(originalImg, candidateTable)
    overlayImg = [];
    if isempty(originalImg) || ~istable(candidateTable) || isempty(candidateTable)
        return;
    end
    if ~ismember('SourceMethod', candidateTable.Properties.VariableNames)
        return;
    end

    src = string(candidateTable.SourceMethod);
    rows = candidateTable(contains(src, "dark_contrast"), :);
    rows = rows(rows.IsValid & isfinite(rows.Score), :);
    rows = sortrows(rows, 'Score', 'descend');
    if isempty(rows)
        return;
    end

    if size(originalImg, 3) == 1
        baseImg = repmat(originalImg, 1, 1, 3);
    else
        baseImg = originalImg;
    end

    try
        overlayImg = baseImg;
        positions = [rows.X, rows.Y, rows.Width, rows.Height];
        overlayImg = insertShape(overlayImg, 'Rectangle', positions, 'Color', 'magenta', 'LineWidth', 3);
        nLabels = min(15, height(rows));
        for i = 1:nLabels
            labelText = sprintf('D%d | %.3f', i, rows.Score(i));
            labelPos = [max(1, round(rows.X(i))), max(1, round(rows.Y(i) - 14))];
            overlayImg = insertText(overlayImg, labelPos, labelText, ...
                'FontSize', 14, 'BoxColor', 'magenta', 'BoxOpacity', 0.75, ...
                'TextColor', 'black', 'AnchorPoint', 'LeftBottom');
        end
    catch
        overlayImg = baseImg;
    end
end


function overlayImg = drawGroupedOverlay(originalImg, candidateTable)
    overlayImg = [];

    if isempty(originalImg) || ~istable(candidateTable) || isempty(candidateTable)
        return;
    end

    if ~ismember('GroupType', candidateTable.Properties.VariableNames)
        return;
    end

    rows = candidateTable(string(candidateTable.GroupType) == "horizontal_group", :);
    rows = rows(rows.IsValid & isfinite(rows.Score), :);
    rows = sortrows(rows, 'Score', 'descend');
    if isempty(rows)
        return;
    end

    if size(originalImg, 3) == 1
        baseImg = repmat(originalImg, 1, 1, 3);
    else
        baseImg = originalImg;
    end

    try
        overlayImg = baseImg;
        positions = [rows.X, rows.Y, rows.Width, rows.Height];
        overlayImg = insertShape(overlayImg, 'Rectangle', positions, ...
            'Color', 'green', 'LineWidth', 4);

        nLabels = min(8, height(rows));
        for i = 1:nLabels
            labelText = sprintf('Grouped %d | %.3f', i, rows.Score(i));
            labelPos = [max(1, round(rows.X(i))), max(1, round(rows.Y(i) - 18))];
            overlayImg = insertText(overlayImg, labelPos, labelText, ...
                'FontSize', 16, 'BoxColor', 'green', 'BoxOpacity', 0.75, ...
                'TextColor', 'black', 'AnchorPoint', 'LeftBottom');
        end
    catch
        overlayImg = baseImg;
    end
end


function overlayImg = drawVerticalEdgeOverlay(originalImg, candidateTable)
    overlayImg = [];
    if isempty(originalImg) || ~istable(candidateTable) || isempty(candidateTable)
        return;
    end
    if ~ismember('SourceMethod', candidateTable.Properties.VariableNames)
        return;
    end

    sourceStr = string(candidateTable.SourceMethod);
    rows = candidateTable(contains(sourceStr, "vertical_edge"), :);
    rows = rows(rows.IsValid & isfinite(rows.Score), :);
    rows = sortrows(rows, 'Score', 'descend');
    if isempty(rows)
        return;
    end

    if size(originalImg, 3) == 1
        baseImg = repmat(originalImg, 1, 1, 3);
    else
        baseImg = originalImg;
    end

    try
        overlayImg = baseImg;
        positions = [rows.X, rows.Y, rows.Width, rows.Height];
        overlayImg = insertShape(overlayImg, 'Rectangle', positions, ...
            'Color', 'cyan', 'LineWidth', 3);

        nLabels = min(15, height(rows));
        for i = 1:nLabels
            labelText = sprintf('V%d | %.3f', i, rows.Score(i));
            labelPos = [max(1, round(rows.X(i))), max(1, round(rows.Y(i) - 14))];
            overlayImg = insertText(overlayImg, labelPos, labelText, ...
                'FontSize', 14, 'BoxColor', 'cyan', 'BoxOpacity', 0.75, ...
                'TextColor', 'black', 'AnchorPoint', 'LeftBottom');
        end
    catch
        overlayImg = baseImg;
    end
end
