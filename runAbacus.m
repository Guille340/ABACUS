% Add Libraries
addpath(genpath(fullfile(pwd,'Dependencies (Core)')))
addpath(genpath(fullfile(pwd,'Dependencies (External)')))

% Storage Directory
root = jsondecode(fileread(fullfile(pwd,'root.json')));

% Import Audio
AudImpConfig = readAudioImportConfig(root);
audioImportFun(root,AudImpConfig)

% Detect Audio
updateAcousticDatabases(root)
AudDetConfig = readAudioDetectConfig(root);
preProcessNeymanPearson(root,AudDetConfig);
audioDetectFun(root,AudDetConfig)

% Process Audio
updateAcousticDatabases(root)
AudProConfig = readAudioProcessConfig(root);
audioProcessFun(root,AudProConfig)

% Import Receivers
RecImpConfig = readReceiverImportConfig(root);
receiverImportFun(root,RecImpConfig)

% Import Sources
SouImpConfig = readSourceImportConfig(root);
sourceImportFun(root,SouImpConfig)

% Process Navigation
updateAcousticDatabases(root)
NavProConfig = readNavigationProcessConfig(root);
navigationProcessFun(root,NavProConfig)
