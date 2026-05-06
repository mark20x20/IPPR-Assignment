function cleanedImg = cleanBinaryImage(binaryImg)
%CLEANBINARYIMAGE Remove noise and improve character regions.
%
% This function uses light morphological processing.
% It intentionally avoids aggressive border clearing because some license
% plate characters may touch or sit close to the plate border.

cleanedImg = [];

if isempty(binaryImg)
    return;
end

try
    cleanedImg = logical(binaryImg);

    imgArea = numel(cleanedImg);
    minObjectArea = max(10, round(0.0008 * imgArea));

    % Remove tiny isolated noise.
    cleanedImg = bwareaopen(cleanedImg, minObjectArea);

    % Reconnect slightly broken character strokes.
    cleanedImg = imclose(cleanedImg, strel("rectangle", [2 2]));

    % Remove small noise created after closing.
    cleanedImg = bwareaopen(cleanedImg, minObjectArea);

catch
    cleanedImg = binaryImg;
end

end
