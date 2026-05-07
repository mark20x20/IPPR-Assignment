function saveResultRow(resultRow, csvPath)
% saveResultRow saves one evaluation row to CSV with fixed header order.

    if nargin < 2 || strlength(string(csvPath)) == 0
        paths = getProjectPaths();
        csvPath = paths.evaluationCsv;
    end

    requiredCols = ["image_name","vehicle_type","expected_text","ocr_text","expected_state", ...
        "predicted_state","detection_result","ocr_result","state_result","overall_result","notes"];

    try
        [csvDir, ~, ~] = fileparts(csvPath);
        if strlength(string(csvDir)) > 0 && ~exist(csvDir, 'dir')
            mkdir(csvDir);
        end

        if istable(resultRow)
            rowTable = resultRow;
        else
            rowTable = struct2table(resultRow);
        end

        for i = 1:numel(requiredCols)
            c = requiredCols(i);
            if ~ismember(c, string(rowTable.Properties.VariableNames))
                rowTable.(c) = "";
            end
        end

        rowTable = rowTable(:, cellstr(requiredCols));

        if ~isfile(csvPath)
            writetable(rowTable, csvPath);
            return;
        end

        existing = readtable(csvPath, 'TextType', 'string');
        for i = 1:numel(requiredCols)
            c = requiredCols(i);
            if ~ismember(c, string(existing.Properties.VariableNames))
                existing.(c) = "";
            end
        end

        existing = existing(:, cellstr(requiredCols));
        merged = [existing; rowTable];
        writetable(merged, csvPath);

    catch saveErr
        fprintf(2, '[EVAL] Failed to save result row to %s: %s\n', string(csvPath), saveErr.message);
    end
end
