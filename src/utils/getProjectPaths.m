function paths = getProjectPaths()
% getProjectPaths returns centralized absolute project paths.

    utilsDir = fileparts(mfilename('fullpath'));
    srcDir = fileparts(utilsDir);
    projectRoot = fileparts(srcDir);

    paths = struct();
    paths.projectRoot = projectRoot;

    paths.outputRoot = fullfile(projectRoot, 'output');
    paths.debugRoot = fullfile(paths.outputRoot, 'debug');
    paths.plateDebugRoot = fullfile(paths.debugRoot, 'plate_detection');
    paths.segmentationDebugRoot = fullfile(paths.debugRoot, 'segmentation');
    paths.recognitionDebugRoot = fullfile(paths.debugRoot, 'recognition');
    paths.guiDebugRoot = fullfile(paths.debugRoot, 'gui_runs');

    paths.outputFiguresRoot = fullfile(paths.outputRoot, 'figures');
    paths.plateFiguresRoot = fullfile(paths.outputFiguresRoot, 'plate_detection');
    paths.segmentationFiguresRoot = fullfile(paths.outputFiguresRoot, 'segmentation');
    paths.recognitionFiguresRoot = fullfile(paths.outputFiguresRoot, 'recognition');

    paths.outputTables = fullfile(paths.outputRoot, 'tables');

    paths.reportFigures = fullfile(projectRoot, 'report', 'figures');
    paths.reportTables = fullfile(projectRoot, 'report', 'tables');

    paths.evaluationCsv = fullfile(paths.reportTables, 'evaluation_results.csv');
    paths.guiResultsCsv = fullfile(paths.reportTables, 'gui_results.csv');
end
