function [candidateTableOut, groupInfo] = groupHorizontalCandidates(candidateTableIn, imageSize)
% groupHorizontalCandidates  Add grouped candidates for horizontally split text parts.

    candidateTableOut = candidateTableIn;
    groupInfo = struct('rawCount', 0, 'groupedCount', 0, 'newCandidateCount', 0);

    if ~istable(candidateTableIn) || isempty(candidateTableIn) || numel(imageSize) < 2
        return;
    end

    t = candidateTableIn;
    n = height(t);
    groupInfo.rawCount = n;

    if ~ismember('GroupType', t.Properties.VariableNames)
        t.GroupType = repmat("single", n, 1);
    end
    if ~ismember('ParentCandidateIds', t.Properties.VariableNames)
        t.ParentCandidateIds = strings(n, 1);
    end
    if ~ismember('GroupGeometryPenalty', t.Properties.VariableNames)
        t.GroupGeometryPenalty = zeros(n, 1);
    end

    imgH = imageSize(1);
    imgW = imageSize(2);
    minGroupHeight = max(10, round(imgH * 0.012));
    maxGroupSpanRatio = 0.70;
    minGroupAspect = 1.6;
    maxGroupAspect = 8.5;

    centerX = t.X + t.Width / 2;
    centerY = t.Y + t.Height / 2;

    groupMap = containers.Map('KeyType', 'char', 'ValueType', 'logical');
    newRows = table();

    for i = 1:n
        if t.Height(i) < minGroupHeight || t.Width(i) < 6
            continue;
        end

        members = i;

        for j = 1:n
            if i == j
                continue;
            end

            if t.Height(j) < minGroupHeight || t.Width(j) < 6
                continue;
            end

            avgH = max(1, (t.Height(i) + t.Height(j)) / 2);
            centerYDiff = abs(centerY(i) - centerY(j));
            if centerYDiff >= 0.5 * avgH
                continue;
            end

            hRatio = t.Height(i) / max(t.Height(j), 1);
            if hRatio < 0.5 || hRatio > 2.0
                continue;
            end

            leftIdx = i;
            rightIdx = j;
            if centerX(j) < centerX(i)
                leftIdx = j;
                rightIdx = i;
            end

            leftRight = t.X(leftIdx) + t.Width(leftIdx);
            gap = t.X(rightIdx) - leftRight;
            if gap < 0 || gap >= 3.0 * avgH
                continue;
            end

            members(end + 1) = j; %#ok<AGROW>
        end

        members = unique(members);
        if numel(members) < 2
            continue;
        end

        x1 = min(t.X(members));
        y1 = min(t.Y(members));
        x2 = max(t.X(members) + t.Width(members));
        y2 = max(t.Y(members) + t.Height(members));

        w = x2 - x1;
        h = y2 - y1;
        if w <= 1 || h <= 1
            continue;
        end
        if w > (maxGroupSpanRatio * imgW)
            continue;
        end

        groupAspect = w / max(h, 1);
        if groupAspect < minGroupAspect || groupAspect > maxGroupAspect
            continue;
        end

        parentAvgH = mean(t.Height(members));
        if h > (1.45 * parentAvgH)
            continue;
        end

        ySpread = std(centerY(members)) / max(parentAvgH, 1);
        if ySpread > 0.24
            continue;
        end

        parentCentersX = centerX(members);
        weights = t.Width(members) .* t.Height(members);
        weightedCx = sum(parentCentersX .* weights) / max(sum(weights), 1);
        groupCx = x1 + w / 2;
        centerOffsetRatio = abs(groupCx - weightedCx) / max(w, 1);
        if centerOffsetRatio > 0.22
            continue;
        end

        leftMass = sum(weights(parentCentersX < groupCx));
        rightMass = sum(weights(parentCentersX >= groupCx));
        balanceRatio = abs(leftMass - rightMass) / max(leftMass + rightMass, 1);
        if balanceRatio > 0.82
            continue;
        end

        groupGeometryPenalty = 0;
        if balanceRatio > 0.65
            groupGeometryPenalty = groupGeometryPenalty + 0.06;
        end
        if centerOffsetRatio > 0.16
            groupGeometryPenalty = groupGeometryPenalty + 0.05;
        end
        if ySpread > 0.18
            groupGeometryPenalty = groupGeometryPenalty + 0.04;
        end

        memberKey = sprintf('%d_', sort(members));
        if isKey(groupMap, memberKey)
            continue;
        end
        groupMap(memberKey) = true;

        sourceMethods = unique(string(t.SourceMethod(members)));
        sourceMethod = "horizontal_group";
        if ~isempty(sourceMethods)
            sourceMethod = sourceMethod + "|" + strjoin(sourceMethods, "|");
        end

        parentIds = string(t.RegionIndex(members))';
        parentIds = sort(parentIds);
        parentIdsStr = strjoin(parentIds, ";");

        extentVal = safeMean(t, 'Extent', members);
        solidityVal = safeMean(t, 'Solidity', members);
        meanIntensityVal = safeMean(t, 'MeanIntensity', members);

        newRow = table( ...
            max(t.RegionIndex) + height(newRows) + 1, ...
            string(sourceMethod), ...
            x1, y1, w, h, ...
            w * h, ...
            extentVal, solidityVal, meanIntensityVal, ...
            "horizontal_group", ...
            parentIdsStr, ...
            numel(members), ...
            groupGeometryPenalty, ...
            'VariableNames', {'RegionIndex', 'SourceMethod', 'X', 'Y', 'Width', 'Height', ...
            'RegionArea', 'Extent', 'Solidity', 'MeanIntensity', 'GroupType', ...
            'ParentCandidateIds', 'SourceCount', 'GroupGeometryPenalty'});

        newRows = [newRows; newRow]; %#ok<AGROW>
    end

    if isempty(newRows)
        candidateTableOut = t;
        return;
    end

    missingCols = setdiff(t.Properties.VariableNames, newRows.Properties.VariableNames);
    for k = 1:numel(missingCols)
        colName = missingCols{k};
        baseCol = t.(colName);
        if isnumeric(baseCol)
            newRows.(colName) = nan(height(newRows), 1);
        elseif islogical(baseCol)
            newRows.(colName) = false(height(newRows), 1);
        elseif isstring(baseCol)
            newRows.(colName) = strings(height(newRows), 1);
        else
            newRows.(colName) = repmat(missingValueLike(baseCol), height(newRows), 1);
        end
    end

    extraCols = setdiff(newRows.Properties.VariableNames, t.Properties.VariableNames);
    for k = 1:numel(extraCols)
        colName = extraCols{k};
        baseCol = newRows.(colName);
        if isnumeric(baseCol)
            t.(colName) = nan(height(t), 1);
        elseif islogical(baseCol)
            t.(colName) = false(height(t), 1);
        elseif isstring(baseCol)
            t.(colName) = strings(height(t), 1);
        else
            t.(colName) = repmat(missingValueLike(baseCol), height(t), 1);
        end
    end

    newRows = newRows(:, t.Properties.VariableNames);
    candidateTableOut = [t; newRows];

    groupInfo.groupedCount = height(newRows);
    groupInfo.newCandidateCount = height(newRows);
end


function v = safeMean(t, colName, idx)
    v = NaN;
    if ~ismember(colName, t.Properties.VariableNames)
        return;
    end
    x = t.(colName);
    if isempty(x)
        return;
    end
    xv = x(idx);
    xv = xv(isfinite(xv));
    if ~isempty(xv)
        v = mean(xv);
    end
end


function mv = missingValueLike(x)
    if iscell(x)
        mv = {[]};
    else
        mv = [];
    end
end
