function paths = ensureOutputFolders()
% ensureOutputFolders creates official output/report folders if missing.

    paths = getProjectPaths();
    requiredFolders = {
        paths.outputRoot
        paths.debugRoot
        paths.plateDebugRoot
        paths.segmentationDebugRoot
        paths.recognitionDebugRoot
        paths.guiDebugRoot
        paths.outputFiguresRoot
        paths.plateFiguresRoot
        paths.segmentationFiguresRoot
        paths.recognitionFiguresRoot
        paths.outputTables
        paths.reportFigures
        paths.reportTables
    };

    for i = 1:numel(requiredFolders)
        folderPath = requiredFolders{i};
        if ~exist(folderPath, 'dir')
            mkdir(folderPath);
        end
    end
end
