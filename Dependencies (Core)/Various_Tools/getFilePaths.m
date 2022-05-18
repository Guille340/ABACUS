%  filePaths = GETFILEPATHS(fileDirectories,fileExtensions)
%
%  DESCRIPTION
%  Returns the absolute paths of the files with extensions FILEEXTENSIONS
%  contained in the directories FILEDIRECTORIES. FILEDIRECTORIES and 
%  FILEEXTENSIONS can be a character vector or a cell array of character 
%  vectors. All extensions in FILEEXTENSIONS should include the leading '.' 
%  (added otherwise). 
%
%  To return all the files in FILEDIRECTORIES, regardless of their extension,
%  use FILEEXTENSIONS = ''.
%
%  FILEDIRECTORIES may also include absolute paths along with directories. 
%  Only input paths with extensions included in FILEEXTENSIONS will be 
%  returned.
%
%  INPUT ARGUMENTS
%  - fileDirectories: character vector or cell array of character vectors
%    specifying the directory or directories where the files are stored.
%    It may also include absolute file paths.
%  - fileExtensions: character vector or cell array of character vectors
%    specifying the extension or extensions of the files to be listed.
%
%  OUTPUT ARGUMENTS
%  - filePaths: absolute paths of the files in directory(ies) FILEDIRECTORIES
%    with extension(s) FILEEXTENSIONS. It will also include any absolute input
%    file paths with extension(s) FILEEXTENSIONS.
%
%  FUNCTION CALL
%  filePaths = GETFILEPATHS(fileDirectories,fileExtensions)
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  12 Jul 2021

function filePaths = getFilePaths(fileDirectories,fileExtensions)

% Error Control
errorFlag = false;
if ~ischar(fileDirectories) && ~all(cell2mat(cellfun(@(x) ischar(x),...
        fileDirectories,'UniformOutput',false)))
    errorFlag = true;
end
if ~ischar(fileExtensions) && ~all(cell2mat(cellfun(@(x) ischar(x),...
        fileExtensions,'UniformOutput',false)))
    errorFlag = true;
end

% Find File Paths
if ~errorFlag
    % Convert Char Directory to Cell
    if ischar(fileDirectories)
        fileDirectories = {fileDirectories};
    end
    % Convert Char Extension to Cell
    if ischar(fileExtensions)
        fileExtensions = {fileExtensions};
    end
    
    % Set FILEEXTENSIONS = {''} if Any Extension is ''
    if any(cell2mat(cellfun(@(x) isempty(x),fileExtensions,...
            'UniformOutput',false)))
        fileExtensions = {''};
    end
    
    % Add Dot to File Extensions (if missing)
    nExtensions = numel(fileExtensions);
    for k = 1:nExtensions
        if ~isempty(fileExtensions{k}) && ~strcmp(fileExtensions{k}(1),'.')
            fileExtensions{k} = strcat('.',fileExtensions{k});
        end
    end
    
    % Separate Input Paths from Input Directories
    nFolders = numel(fileDirectories);
    isInputFile = false(nFolders,1);
    isInputFolder = false(nFolders,1);
    for m = 1:nFolders
        isInputFile(m) = exist(fileDirectories{m},'file') == 2;
        isInputFolder(m) = exist(fileDirectories{m},'dir') == 7;
    end
    filePaths_input = fileDirectories(isInputFile);
    fileDirectories = fileDirectories(isInputFolder);
    
    % Keep Input Paths with Valid Extensions
    nFiles_input = numel(filePaths_input);
    if ~isempty(fileExtensions{1})
        isValidInputFile = false(nFiles_input,1);
        for m = 1:nFiles_input
            [~,~,fileExtension] = fileparts(filePaths_input{m});
            isValidInputFile(m) = ismember(fileExtension,fileExtensions);
        end
        filePaths_input = filePaths_input(isValidInputFile);
        nFiles_input = numel(filePaths_input);
    end

    % Find Paths
    filePaths = filePaths_input; % set file paths cell to input ones
    nFiles = nFiles_input; % set initial number of files to that of input paths
    nFolders = numel(fileDirectories);
    for m = 1:nFolders
        % File Names from Current Folder
        Directory = [];
        for k = 1:nExtensions
            Directory_temp = dir(strcat(fileDirectories{m},'\*',...
                fileExtensions{k}));
            Directory = [Directory; Directory_temp]; %#ok<AGROW>
        end
        fileNames = {Directory.name};
        
        % Remove '.' and '..' from FILENAMES (only for FILEEXTENSIONS = {''})
        if isempty(fileExtensions{1})
            [~,iDot1] = ismember('.',fileNames);
            [~,iDot2] = ismember('..',fileNames);
            fileNames([iDot1 iDot2]) = [];
        end
       
        % File Paths in Current Folder
        nFilesInFolder = numel(fileNames);
        filePaths(nFiles+1:nFiles+nFilesInFolder) = ...
            fullfile(fileDirectories{m},fileNames);
        nFiles = nFiles + nFilesInFolder;
    end 
    
    % Remove Folders (keep file paths only)
    isFile = false(nFiles,1);
    for m = 1:nFiles
        isFile(m) = exist(filePaths{m},'file') == 2;
    end
    filePaths = filePaths(isFile);
    
    % Remove Duplicated File Paths
    filePaths = unique(filePaths,'stable');
else
    filePaths = '';
end
