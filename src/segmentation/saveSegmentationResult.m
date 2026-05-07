function exportInfo = saveSegmentationResult(varargin)
% saveSegmentationResult  Save segmentation debug artifacts.
%
% Backward compatibility:
%   saveSegmentationResult(plateImg, charBoxes, outputPath)
%
% New usage:
%   exportInfo = saveSegmentationResult(segmentationDebug)

    exportInfo = struct('outputDir', "", 'savedFiles', strings(0, 1));

    if nargin == 1 && isstruct(varargin{1})
        exportInfo = saveDebugBundle(varargin{1});
        return;
    end

    if nargin < 3
        return;
    end
    plateImg = varargin{1};
    charBoxes = varargin{2};
    outputPath = varargin{3};
    if isempty(outputPath) || isempty(plateImg)
        return;
    end

    [overlay, ~] = localDrawCharOverlayFromBBoxes(plateImg, charBoxes);
    if ~isempty(overlay)
        imwrite(toWritableImage(overlay), outputPath);
    end
end


function exportInfo = saveDebugBundle(debugInfo)
    exportInfo = struct('outputDir', "", 'savedFiles', strings(0, 1));

    paths = getProjectPaths();
    outRoot = paths.segmentationDebugRoot;
    if ~exist(outRoot, 'dir')
        mkdir(outRoot);
    end

    stamp = string(datetime('now', 'Format', 'yyyyMMdd_HHmmss_SSS'));
    outDir = fullfile(outRoot, char("run_" + stamp));
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end

    saved = strings(0, 1);
    warnings = strings(0, 1);
    missingFields = strings(0, 1);
    overlaySaved = false;
    overlayMethod = "";
    overlayOutputPath = fullfile(outDir, '09_character_boxes_overlay.png');
    overlayWarning = "";

    [inputPlate, hasInput] = getFieldAny(debugInfo, {'inputPlate', 'inputPlateImg'});
    [refinedPlate, hasRefined] = getFieldAny(debugInfo, {'refinedPlate', 'refinedPlateImg'});
    [grayImg, hasGray] = getFieldAny(debugInfo, {'grayImg'});
    [enhancedImg, hasEnhanced] = getFieldAny(debugInfo, {'enhancedImg'});
    [binaryBright, hasBinaryBright] = getFieldAny(debugInfo, {'binaryBright'});
    [binaryDark, hasBinaryDark] = getFieldAny(debugInfo, {'binaryDark'});
    [selectedBinary, hasSelectedBinary] = getFieldAny(debugInfo, {'selectedBinary', 'selectedBinaryImg'});
    [cleanedBinary, hasCleanedBinary] = getFieldAny(debugInfo, {'cleanedBinary', 'cleanedBinaryImg'});
    [charBBoxes, hasCharBBoxes] = getFieldAny(debugInfo, {'characterBBoxes'});
    [charImages, hasCharImages] = getFieldAny(debugInfo, {'characterImages'}); %#ok<NASGU>
    [candTable, hasCandTable] = getFieldAny(debugInfo, {'segmentationTable', 'candidateTable'});

    [saved, warnings, missingFields] = safeWriteImage(saved, warnings, missingFields, outDir, '01_input_plate.png', inputPlate, 'inputPlate', hasInput);
    [saved, warnings, missingFields] = safeWriteImage(saved, warnings, missingFields, outDir, '02_refined_plate.png', refinedPlate, 'refinedPlate', hasRefined);
    [saved, warnings, missingFields] = safeWriteImage(saved, warnings, missingFields, outDir, '03_gray.png', grayImg, 'grayImg', hasGray);
    [saved, warnings, missingFields] = safeWriteImage(saved, warnings, missingFields, outDir, '04_enhanced.png', enhancedImg, 'enhancedImg', hasEnhanced);
    [saved, warnings, missingFields] = safeWriteImage(saved, warnings, missingFields, outDir, '05_binary_bright.png', binaryBright, 'binaryBright', hasBinaryBright);
    [saved, warnings, missingFields] = safeWriteImage(saved, warnings, missingFields, outDir, '06_binary_dark.png', binaryDark, 'binaryDark', hasBinaryDark);
    [saved, warnings, missingFields] = safeWriteImage(saved, warnings, missingFields, outDir, '07_selected_binary.png', selectedBinary, 'selectedBinary', hasSelectedBinary);
    [saved, warnings, missingFields] = safeWriteImage(saved, warnings, missingFields, outDir, '08_cleaned_binary.png', cleanedBinary, 'cleanedBinary', hasCleanedBinary);

    if istable(candTable)
        writetable(candTable, fullfile(outDir, 'segmentation_table.csv'));
        saved(end + 1) = "segmentation_table.csv";
    else
        writetable(table(), fullfile(outDir, 'segmentation_table.csv'));
        saved(end + 1) = "segmentation_table.csv";
        if ~hasCandTable
            missingFields(end + 1) = "segmentationTable/candidateTable";
        else
            warnings(end + 1) = "segmentation_table_not_table";
        end
    end

    overlayBase = refinedPlate;
    if isempty(overlayBase)
        overlayBase = inputPlate;
    end
    if ~isempty(overlayBase) && hasCharBBoxes && ~isempty(charBBoxes)
        [overlaySaved, overlayMethod, overlayWarning] = localSaveOverlayFigure(overlayBase, charBBoxes, overlayOutputPath);
        if overlaySaved
            saved(end + 1) = "09_character_boxes_overlay.png";
        end
    else
        overlayWarning = "overlay_skipped: missing base image or characterBBoxes";
        if ~hasCharBBoxes
            missingFields(end + 1) = "characterBBoxes";
        end
    end

    cropBase = refinedPlate;
    if isempty(cropBase)
        cropBase = inputPlate;
    end
    if ~isempty(cropBase)
        bboxList = [];
        if hasCharBBoxes && ~isempty(charBBoxes)
            bboxList = charBBoxes;
        elseif istable(candTable) && ~isempty(candTable) && all(ismember({'IsAccepted', 'X', 'Y', 'Width', 'Height'}, candTable.Properties.VariableNames))
            accepted = candTable(candTable.IsAccepted, :);
            accepted = sortrows(accepted, 'X', 'ascend');
            bboxList = [accepted.X, accepted.Y, accepted.Width, accepted.Height];
        end

        n = min(20, size(bboxList, 1));
        for i = 1:n
            bbox = bboxList(i, :);
            crop = localCrop(cropBase, bbox);
            if ~isempty(crop)
                f = sprintf('character_crop_%02d.png', i);
                try
                    imwrite(toWritableImage(crop), fullfile(outDir, f));
                    saved(end + 1) = string(f);
                catch ME
                    warnings(end + 1) = "character_crop_save_failed(" + string(f) + "): " + string(ME.message);
                end
            end
        end
    end

    summary = buildSummary(debugInfo, outDir, overlaySaved, overlayMethod, overlayOutputPath, overlayWarning, missingFields, warnings, numel(saved));
    writecell(cellstr(summary), fullfile(outDir, 'summary.txt'));
    saved(end + 1) = "summary.txt";

    exportInfo.outputDir = string(outDir);
    exportInfo.savedFiles = saved;
end


function [overlaySaved, overlayMethod, overlayWarning] = localSaveOverlayFigure(baseImg, boxes, outputPath)
    overlaySaved = false;
    overlayMethod = "";
    overlayWarning = "";
    fig = [];
    ax = [];
    try
        if isempty(boxes)
            overlayWarning = "no character boxes";
            return;
        end
        fig = figure('Visible', 'off');
        ax = axes('Parent', fig); %#ok<LAXES>
        imshow(baseImg, 'Parent', ax);
        hold(ax, 'on');
        for i = 1:size(boxes, 1)
            rectangle(ax, 'Position', boxes(i, :), 'EdgeColor', 'g', 'LineWidth', 2);
            text(ax, max(1, boxes(i, 1)), max(1, boxes(i, 2) - 2), sprintf('C%d', i), ...
                'Color', 'y', 'FontSize', 10, 'FontWeight', 'bold', 'Interpreter', 'none');
        end
        hold(ax, 'off');
        drawnow;

        try
            exportgraphics(ax, outputPath);
            overlayMethod = "exportgraphics";
        catch ME1
            try
                saveas(fig, outputPath);
                overlayMethod = "saveas";
            catch ME2
                overlayWarning = "overlay_export_failed: " + string(ME1.message) + " | fallback_failed: " + string(ME2.message);
                return;
            end
        end

        overlaySaved = (exist(outputPath, 'file') == 2);
        if ~overlaySaved && strlength(overlayWarning) == 0
            overlayWarning = "overlay_export_failed: output file not found after export";
        end
    catch ME
        overlayWarning = "overlay_draw_failed: " + string(ME.message);
    end

    try
        if ~isempty(ax) && isvalid(ax)
            hold(ax, 'off');
        end
        if ~isempty(fig) && isvalid(fig)
            close(fig);
        end
    catch
    end
end


function crop = localCrop(img, bbox)
    crop = [];
    try
        x1 = max(1, floor(bbox(1)));
        y1 = max(1, floor(bbox(2)));
        x2 = min(size(img, 2), ceil(bbox(1) + bbox(3)));
        y2 = min(size(img, 1), ceil(bbox(2) + bbox(4)));
        if x2 < x1 || y2 < y1
            return;
        end
        crop = img(y1:y2, x1:x2, :);
    catch
        crop = [];
    end
end


function [saved, warnings, missingFields] = safeWriteImage(saved, warnings, missingFields, outDir, fileName, img, fieldName, fieldFound)
    if ~fieldFound
        missingFields(end + 1) = string(fieldName);
        return;
    end
    if isempty(img)
        warnings(end + 1) = "empty_field(" + string(fieldName) + ")";
        return;
    end
    try
        imwrite(toWritableImage(img), fullfile(outDir, fileName));
        saved(end + 1) = string(fileName);
    catch ME
        warnings(end + 1) = "save_failed(" + string(fileName) + "): " + string(ME.message);
    end
end


function outImg = toWritableImage(img)
    if islogical(img)
        outImg = uint8(img) * 255;
        return;
    end
    if isa(img, 'uint8') || isa(img, 'uint16')
        outImg = img;
        return;
    end
    outImg = im2uint8(mat2gray(double(img)));
end


function [value, ok] = getFieldAny(s, names)
    value = [];
    ok = false;
    for i = 1:numel(names)
        n = names{i};
        if isstruct(s) && isfield(s, n)
            value = s.(n);
            ok = true;
            return;
        end
    end
end


function value = getField(s, name)
    value = [];
    if isstruct(s) && isfield(s, name)
        value = s.(name);
    end
end


function lines = buildSummary(debugInfo, outDir, overlaySaved, overlayMethod, overlayOutputPath, overlayWarning, missingFields, internalWarnings, savedFileCount)
    lines = [ ...
        "Segmentation Debug Summary"; ...
        "output_dir=" + string(outDir); ...
        "status=" + string(getField(debugInfo, 'status')) ...
    ];

    [inImg, ~] = getFieldAny(debugInfo, {'inputPlate', 'inputPlateImg'});
    [rfImg, ~] = getFieldAny(debugInfo, {'refinedPlate', 'refinedPlateImg'});
    if ~isempty(inImg)
        lines(end + 1) = "input_size=[" + string(size(inImg, 2)) + "x" + string(size(inImg, 1)) + "]";
    end
    if ~isempty(rfImg)
        lines(end + 1) = "refined_size=[" + string(size(rfImg, 2)) + "x" + string(size(rfImg, 1)) + "]";
    end

    lines(end + 1) = "refinement_applied=" + string(getField(debugInfo, 'refinementApplied'));
    lines(end + 1) = "selected_polarity=" + string(getField(debugInfo, 'selectedPolarity'));
    lines(end + 1) = "bright_polarity_score=" + string(getField(debugInfo, 'brightPolarityScore'));
    lines(end + 1) = "dark_polarity_score=" + string(getField(debugInfo, 'darkPolarityScore'));
    lines(end + 1) = "foreground_ratio=" + string(getField(debugInfo, 'foregroundRatio'));
    lines(end + 1) = "raw_component_count=" + string(getField(debugInfo, 'rawComponentCount'));
    lines(end + 1) = "accepted_character_count=" + string(getField(debugInfo, 'acceptedCharacterCount'));

    [candTable, hasCandTable] = getFieldAny(debugInfo, {'segmentationTable', 'candidateTable'});
    if hasCandTable && istable(candTable) && ~isempty(candTable) && ismember('IsAccepted', candTable.Properties.VariableNames)
        lines(end + 1) = "rejected_component_count=" + string(sum(~candTable.IsAccepted));
    else
        lines(end + 1) = "rejected_component_count=0";
    end

    tBand = getField(debugInfo, 'textBandYRange');
    if ~isempty(tBand) && numel(tBand) >= 2
        lines(end + 1) = "text_band_y_range=[" + string(tBand(1)) + "," + string(tBand(2)) + "]";
    else
        lines(end + 1) = "text_band_y_range=[]";
    end

    lines(end + 1) = "overlay_saved=" + string(overlaySaved);
    lines(end + 1) = "overlay_method=" + string(overlayMethod);
    lines(end + 1) = "overlay_output_path=" + string(overlayOutputPath);
    if strlength(string(overlayWarning)) > 0
        lines(end + 1) = "overlay_warning=" + string(overlayWarning);
    end
    lines(end + 1) = "saved_file_count=" + string(savedFileCount);

    if ~isempty(missingFields)
        lines(end + 1) = "missing_debug_fields=" + strjoin(unique(string(missingFields), 'stable'), ";");
    else
        lines(end + 1) = "missing_debug_fields=";
    end

    userWarnings = getField(debugInfo, 'warnings');
    idx = 1;
    if ~isempty(userWarnings)
        for i = 1:numel(userWarnings)
            lines(end + 1) = "warning_" + string(idx) + "=" + string(userWarnings(i));
            idx = idx + 1;
        end
    end
    if ~isempty(internalWarnings)
        for i = 1:numel(internalWarnings)
            lines(end + 1) = "warning_" + string(idx) + "=" + string(internalWarnings(i));
            idx = idx + 1;
        end
    end
end
