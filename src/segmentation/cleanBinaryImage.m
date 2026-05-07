function [cleanedImg, cleanDebug] = cleanBinaryImage(binaryImg)
% cleanBinaryImage  Mild cleanup for binary plate image.

    cleanedImg = [];
    cleanDebug = struct( ...
        'beforeClean', [], ...
        'afterSmallRemoval', [], ...
        'afterMorphology', [], ...
        'cleanedImg', [], ...
        'removedNoiseCount', 0, ...
        'status', "not_started");

    if isempty(binaryImg)
        cleanDebug.status = "empty_input";
        return;
    end

    try
        bw = logical(binaryImg);
        cleanDebug.beforeClean = bw;

        imgArea = numel(bw);
        minObjectArea = max(4, round(0.0008 * imgArea));

        beforeCount = nnz(bw);
        bw1 = bwareaopen(bw, minObjectArea);
        cleanDebug.afterSmallRemoval = bw1;

        seOpen = strel('rectangle', [2 2]);
        seClose = strel('rectangle', [2 2]);
        bw2 = imopen(bw1, seOpen);
        bw2 = imclose(bw2, seClose);

        % Final light denoise pass.
        bw2 = bwareaopen(bw2, minObjectArea);

        cleanedImg = bw2;
        cleanDebug.afterMorphology = bw2;
        cleanDebug.cleanedImg = bw2;
        cleanDebug.removedNoiseCount = max(0, beforeCount - nnz(bw2));
        cleanDebug.status = "ok";
    catch ME
        cleanedImg = logical(binaryImg);
        cleanDebug.beforeClean = logical(binaryImg);
        cleanDebug.afterSmallRemoval = cleanedImg;
        cleanDebug.afterMorphology = cleanedImg;
        cleanDebug.cleanedImg = cleanedImg;
        cleanDebug.status = "clean_failed: " + string(ME.message);
    end
end
