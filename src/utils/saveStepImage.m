function saveStepImage(img, outputFolder, fileName)
if isempty(img) || isempty(outputFolder) || isempty(fileName)
    return;
end

if ~exist(outputFolder, "dir")
    mkdir(outputFolder);
end

outPath = fullfile(outputFolder, fileName);
try
    imwrite(img, outPath);
catch saveErr
    warning("Failed to save image (%s): %s", outPath, saveErr.message);
end
end
