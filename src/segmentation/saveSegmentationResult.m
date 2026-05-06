function saveSegmentationResult(plateImg, charBoxes, outputPath)
%SAVESEGMENTATIONRESULT Save segmentation visualization with bounding boxes.
%
% Input:
%   plateImg    - cropped plate image
%   charBoxes   - bounding boxes returned by segmentCharacters
%   outputPath  - full path for saved output image

if nargin < 3 || isempty(outputPath)
    return;
end

try
    fig = figure("Visible", "off");
    imshow(plateImg);
    hold on;

    for i = 1:size(charBoxes, 1)
        rectangle("Position", charBoxes(i, :), ...
            "EdgeColor", "g", ...
            "LineWidth", 2);
    end

    hold off;
    title("Segmented Character Candidates");

    exportgraphics(gca, outputPath);
    close(fig);
catch
    try
        close(fig);
    catch
    end
end

end
