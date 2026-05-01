function launch_gui()
addpath(genpath("src"));
ensureOutputFolders();

state.originalImg = [];
state.plateImg = [];
state.cleanedText = "UNKNOWN";
state.stateName = "UNKNOWN";
state.imagePath = "";

fig = figure("Name", "LPR and SIS", "NumberTitle", "off", "Position", [100, 100, 1000, 600]);

axOriginal = axes("Parent", fig, "Units", "normalized", "Position", [0.06, 0.28, 0.4, 0.64]);
title(axOriginal, "Original Image");
axis(axOriginal, "off");

axPlate = axes("Parent", fig, "Units", "normalized", "Position", [0.54, 0.28, 0.4, 0.64]);
title(axPlate, "Detected Plate");
axis(axPlate, "off");

txtRecognized = uicontrol("Style", "text", "Units", "normalized", ...
    "Position", [0.06, 0.18, 0.88, 0.05], "HorizontalAlignment", "left", ...
    "String", "Recognized Text: UNKNOWN");
txtState = uicontrol("Style", "text", "Units", "normalized", ...
    "Position", [0.06, 0.12, 0.88, 0.05], "HorizontalAlignment", "left", ...
    "String", "Identified State: UNKNOWN");
txtStatus = uicontrol("Style", "text", "Units", "normalized", ...
    "Position", [0.06, 0.05, 0.88, 0.05], "HorizontalAlignment", "left", ...
    "String", "Status: Ready");

uicontrol("Style", "pushbutton", "String", "Load Image", "Units", "normalized", ...
    "Position", [0.06, 0.92, 0.18, 0.06], "Callback", @onLoadImage);
uicontrol("Style", "pushbutton", "String", "Run Recognition", "Units", "normalized", ...
    "Position", [0.26, 0.92, 0.18, 0.06], "Callback", @onRunRecognition);

ui.axOriginal = axOriginal;
ui.axPlate = axPlate;
ui.txtRecognized = txtRecognized;
ui.txtState = txtState;
ui.txtStatus = txtStatus;
ui.data = state;
guidata(fig, ui);

    function onLoadImage(~, ~)
        uiLocal = guidata(fig);
        [fileName, pathName] = uigetfile({"*.jpg;*.jpeg;*.png;*.bmp", "Image Files"});
        if isequal(fileName, 0)
            set(uiLocal.txtStatus, "String", "Status: Image selection canceled.");
            return;
        end
        selectedPath = fullfile(pathName, fileName);
        try
            img = imread(selectedPath);
            uiLocal.data.originalImg = img;
            uiLocal.data.imagePath = string(selectedPath);
            axes(uiLocal.axOriginal); %#ok<LAXES>
            imshow(img);
            title(uiLocal.axOriginal, "Original Image");
            cla(uiLocal.axPlate);
            title(uiLocal.axPlate, "Detected Plate");
            set(uiLocal.txtRecognized, "String", "Recognized Text: UNKNOWN");
            set(uiLocal.txtState, "String", "Identified State: UNKNOWN");
            set(uiLocal.txtStatus, "String", "Status: Image loaded. Click Run Recognition.");
        catch loadErr
            set(uiLocal.txtStatus, "String", "Status: Failed to load image.");
            warning("Failed to load selected image: %s", loadErr.message);
        end
        guidata(fig, uiLocal);
    end

    function onRunRecognition(~, ~)
        uiLocal = guidata(fig);
        if isempty(uiLocal.data.originalImg)
            set(uiLocal.txtStatus, "String", "Status: Load an image first.");
            return;
        end
        try
            [preprocessedImg, ~] = preprocessImage(uiLocal.data.originalImg);
            [plateImg, ~, ~] = detectPlateRegion(preprocessedImg, uiLocal.data.originalImg);
            [~, ~] = segmentCharacters(plateImg);
            rawText = recognizePlateText(plateImg);
            cleanedText = cleanRecognizedText(rawText);
            stateNameLocal = identifyState(cleanedText);

            uiLocal.data.plateImg = plateImg;
            uiLocal.data.cleanedText = cleanedText;
            uiLocal.data.stateName = stateNameLocal;

            if ~isempty(plateImg)
                axes(uiLocal.axPlate); %#ok<LAXES>
                imshow(plateImg);
                title(uiLocal.axPlate, "Detected Plate");
            else
                cla(uiLocal.axPlate);
                title(uiLocal.axPlate, "Detected Plate (Not Found)");
            end

            set(uiLocal.txtRecognized, "String", "Recognized Text: " + string(cleanedText));
            set(uiLocal.txtState, "String", "Identified State: " + string(stateNameLocal));
            set(uiLocal.txtStatus, "String", "Status: Recognition completed.");
        catch runErr
            set(uiLocal.txtStatus, "String", "Status: Recognition failed safely.");
            warning("Recognition callback error: %s", runErr.message);
        end
        guidata(fig, uiLocal);
    end
end
