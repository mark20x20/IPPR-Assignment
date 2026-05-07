function [bestBBox, bestRow, rankedTable] = selectBestScoredCandidate(scoredTable)
% selectBestScoredCandidate  Return the top valid scored candidate.

    bestBBox = [];
    bestRow = table();
    rankedTable = scoredTable;

    if isempty(scoredTable)
        return;
    end

    validMask = scoredTable.IsValid & isfinite(scoredTable.Score);
    if ~any(validMask)
        return;
    end

    validRows = scoredTable(validMask, :);
    validRows = sortrows(validRows, 'Score', 'descend');
    bestRow = validRows(1, :);

    bestBBox = [bestRow.X(1), bestRow.Y(1), bestRow.Width(1), bestRow.Height(1)];
end
