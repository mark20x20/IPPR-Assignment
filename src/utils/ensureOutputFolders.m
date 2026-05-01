function ensureOutputFolders()
requiredFolders = {
    fullfile("output", "plate_detection")
    fullfile("output", "segmentation")
    fullfile("output", "recognition")
    fullfile("output", "figures")
    fullfile("report", "figures")
    fullfile("report", "tables")
};

for i = 1:numel(requiredFolders)
    folderPath = requiredFolders{i};
    if ~exist(folderPath, "dir")
        mkdir(folderPath);
    end
end
end
