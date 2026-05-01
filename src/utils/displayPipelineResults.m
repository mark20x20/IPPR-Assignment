function displayPipelineResults(originalImg, plateImg, recognizedText, stateName)
figure("Name", "Pipeline Results", "NumberTitle", "off");

subplot(1, 2, 1);
if ~isempty(originalImg)
    imshow(originalImg);
    title("Original Image");
else
    axis off;
    title("Original Image (Unavailable)");
end

subplot(1, 2, 2);
if ~isempty(plateImg)
    imshow(plateImg);
    title("Detected Plate");
else
    axis off;
    title("Detected Plate (Not Found)");
end

annotation("textbox", [0.1 0.01 0.8 0.08], ...
    "String", "Recognized Text: " + string(recognizedText) + " | Identified State: " + string(stateName), ...
    "EdgeColor", "none", "HorizontalAlignment", "center");
end
