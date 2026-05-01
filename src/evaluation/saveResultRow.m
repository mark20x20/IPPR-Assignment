function saveResultRow(resultRow, csvPath)
if nargin < 2 || isempty(csvPath)
    csvPath = "results_template.csv";
end

if istable(resultRow)
    rowTable = resultRow;
else
    rowTable = struct2table(resultRow);
end

if ~isfile(csvPath)
    writetable(rowTable, csvPath);
    return;
end

existing = readtable(csvPath, "TextType", "string");
for i = 1:numel(existing.Properties.VariableNames)
    vName = existing.Properties.VariableNames{i};
    if ~ismember(vName, rowTable.Properties.VariableNames)
        rowTable.(vName) = "";
    end
end
rowTable = rowTable(:, existing.Properties.VariableNames);
merged = [existing; rowTable];
writetable(merged, csvPath);
end
