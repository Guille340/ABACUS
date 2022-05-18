%  AudImpConfigOne = UPDATEAUDIOIMPORTCONFIG(root,AudImpConfigFile)
%
%  DESCRIPTION
%  Returns a full one-element audio configuration structure AUDIMPCONFIGONE
%  populated with the information given in the audio import configuration 
%  structure AUDIMPCONFIGFILE. The function also checks for any non-valid 
%  input values.
%  
%  AUDIMPCONFIGFILE is extracted directly from an audio import configuration 
%  file 'audioImportConfig*.json' stored in '<ROOT.BLOCK>\configdb'. Function 
%  READAUDIOIMPORTCONFIG generates the structure AUDIMPCONFIGFILE and calls 
%  UPDATEAUDIOIMPORTCONFIG immediately after.
%    
%  INPUT ARGUMENTS
%  - root: structure containing the root directories where the audio data
%    (ROOT.AUDIO), position data (ROOT.POSITION) and block data (ROOT.BLOCK)
%    are stored. ROOT.BLOCK contains the directories where the Configuration 
%    Files ('configdb'), Resampled Audio ('audiodb'), Detection Database
%    ('detectiondb), Navigation Database ('navigationdb'), and Acoustic 
%    Databases ('acousticdb') are stored.
%  - AudImpConfigFile: partial audio import configuration structure, as
%    retrieved from the configuration file in '<ROOT.BLOCK>\configdb'. It 
%    contains only a fraction of the fields of AUDIMPCONFIGONE.
%
%  OUTPUT ARGUMENTS
%  - AudImpConfigOne: populated audio import configuration structure.
%    For details about its fields see INITIALISEAUDIODETECTCONFIG.
%
%  FUNCTION CALL
%  AudImpConfigOne = UPDATEAUDIOIMPORTCONFIG(root,AudImpConfigFile)
%
%  FUNCTION DEPENDENCIES
%  - initialiseAudioImportConfig
%  - readwavHeader
%  - readChannelToReceiver
%  - readResampleRateToSource
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%  - Resampling
%  - Read Audio Files
%
%  See also READAUDIOIMPORTCONFIG, AUDIOIMPORTFUN

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  06 Jul 2021

function AudImpConfigOne = updateAudioImportConfig(root,AudImpConfigFile)

narginchk(1,2) % check number of input arguments

% Obtain Audio Absolute Paths from 'audioPaths.json'
filePath = fullfile(root.block,'configdb','audioPaths.json');
audioPaths = getFilePaths(readAudioPaths(root,filePath),...
    {'.wav','.raw2int16','.raw','.pcm'}); % absolute audio paths
[~,~,audioExtensions] = cellfun(@(x) fileparts(x),audioPaths,'Uniform',false);

% Retrieve Field Names
fieldNames = fieldnames(AudImpConfigFile); % field names of temporal structure

% Sort Properties by Priority Order
fieldNames_valid = {'audioFormat','sampleRate','bitDepth','numChannels',...
    'endianness','channel','resampleRate'}';
[iMember,iOrder] = ismember(fieldNames,fieldNames_valid);
fieldNames = fieldNames_valid(unique(iOrder(iMember)));

% Initialise Full Audio Import Configuration Structure
AudImpConfigOne = initialiseAudioImportConfig();

% Error Control(Structure Fields)
nFields = numel(fieldNames); % number of fields in temporal structure
for m = 1:nFields
    fieldName = fieldNames{m}; % current field name
    fieldValue = [AudImpConfigFile.(fieldName)]; % current field value

    switch fieldName
        case 'audioFormat'
            if ischar(fieldValue)
                fieldValue = lower(fieldValue);
                switch fieldValue
                    case 'wav'
                        % if RAW config template
                        if all(ismember({'sampleRate','bitDepth',...
                                'numChannels','endianness'},fieldNames)) 
                            % if RAW files
                            if all(ismember(audioExtensions,...
                                {'.raw2int16','.raw','.pcm'})) 
                            fieldValue = 'raw';
                            warning(['All audio files have RAW audio '...
                                'extensions (*.raw2int16,*.raw,*.pcm). '...
                                'RAW format will be assumed'])
                            % WAV & RAW files
                            elseif ~all(ismember(audioExtensions,{'.wav'}))
                                warning(['One or more audio files have a '...
                                    'format different than WAV. Those '...
                                    'files will be ignored'])
                            % WAV files
                            else
                                warning(['SAMPLERATE, BITDEPTH, NUMCHANNELS '...
                                    'and ENDIANNESS properties are ignored '...
                                    'for WAV audio files'])
                            end                         
                        end
                    case 'raw'
                        % if WAV config template
                        if ~all(ismember({'sampleRate','bitDepth',...
                                'numChannels','endianness'},fieldNames)) 
                            % if WAV files
                            if all(ismember(audioExtensions,{'.wav'})) 
                            fieldValue = 'wav';
                            warning(['All audio files have a WAV audio '...
                                'extension (*.wav). WAV format will be '...
                                'assumed'])
                            % if WAV & RAW, or RAW files
                            else 
                                warning(['SAMPLERATE, BITDEPTH, NUMCHANNELS '...
                                    'and ENDIANNESS properties are needed '...
                                    'for AUDIOFORMAT = ''RAW'''])
                            end
                        end
                end
                
                % Determine SAMPLERATE and NUMCHANNELS
                switch fieldValue
                    case 'wav'
                        isWav = ismember(audioExtensions,'.wav');
                        audioPaths = audioPaths(isWav); % remove non-WAV
                        nFiles = numel(audioPaths);
                        sampleRate_wav = nan(nFiles,1);
                        numChannels_wav = nan(nFiles,1);
                        for n = 1:nFiles
                            header = readwavHeader(audioPaths{n});
                            sampleRate_wav(n) = header.sampleRate;
                            numChannels_wav(n) = header.numChannels;
                        end
                        sampleRate_wav = unique(sampleRate_wav);
                        numChannels_wav = unique(numChannels_wav);
                end     
            end
        case 'sampleRate'
            if ~isempty(fieldValue)
                if isnumeric(fieldValue) && fieldValue > 0 %#ok<*BDSCI>
                    fieldValue = floor(fieldValue);
                else
                    fieldValue = [];
                    warning('SAMPLERATE field must contain a positive number')
                end
            end
        case 'bitDepth'
            if ~isempty(fieldValue) 
                if ~isnumeric(fieldValue) || fieldValue <= 0 ...
                        || rem(fieldValue,2)
                    fieldValue = [];
                    warning('BITDEPTH field must be an even positive number');
                end
            end
        case 'numChannels'
            if ~isempty(fieldValue)
                if ~isnumeric(fieldValue) || fieldValue < 1 ...
                        || rem(fieldValue,1)
                    fieldValue = [];
                    warning(['NUMCHANNELS field must be a positive integer '...
                        'equal to or higher than 1']);
                end
            end
        case 'endianness'
            if ~any(fieldValue == ['l' 'b'])
                fieldValue = 'l';
                warning(['ENDIANNESS field must be ''l'' or ''b''. '
                'Little endian (''l'') will be assumed']); 
            end
        case 'channel'
            if ~isempty(fieldValue)
                if isnumeric(fieldValue) && fieldValue > 0 && ~rem(fieldValue,1)
                    % Read 'channelToReceiver.json'
                    ch2recPath = fullfile(root.block,'configdb',...
                        'channelToReceiver.json');
                    ch2rec = readChannelToReceiver(ch2recPath);
                    if isempty(ch2rec) || (~isempty(ch2rec)...
                            && ~any(fieldValue == [ch2rec.channel]))
                        fieldValue = [];
                        warning(['CHANNEL must be listed in file '...
                            '''<ROOT.BLOCK>\\configdb\\'...
                            'channelToReceiver.json. Ensure that '...
                            '''channelToReceiver.json'' and '...
                            '''resampleRateToSource.json'' have been '...
                            'created before proceeding further'])
                    end  
                else
                    fieldValue = [];
                    warning(['CHANNEL must be a non-decimal number higher '...
                        'than 1'])
                end
                switch AudImpConfigOne.audioFormat
                    case 'wav'
                        if ~isempty(numChannels_wav) ...
                                && any(fieldValue > numChannels_wav)
                            warning(['CHANNEL exceeds the number of '...
                                'channels in one or more audio files. '...
                                'Those files will be ignored'])
                        end
                    case 'raw'
                        if ~isempty(AudImpConfigOne.numChannels) ...
                                && fieldValue > AudImpConfigOne.numChannels
                            fieldValue = [];
                            warning('CHANNEL must be lower than NUMCHANNELS')
                        end
                end
            end
        case 'resampleRate'
            if ~isempty(fieldValue)
                if ~isnumeric(fieldValue) || fieldValue < 0
                    fieldValue = AudImpConfigOne.sampleRate;
                    warning(['RESAMPLERATE must be a strictly positive '...
                        'numeric value. The audio files will be imported '...
                        'but not resampled (RESAMPLERATE = SAMPLERATE)']);
                else
                    fieldValue = round(fieldValue);
                    
                    % AUDIOFORMAT = 'wav'
                    if strcmp(AudImpConfigOne.audioFormat,'wav')
                        if any(fieldValue > sampleRate_wav)
                            warning(['RESAMPLERATE exceeds the sampling '...
                                'rate of one or more audio files. Those '...
                                'files will be imported but not resampled'...
                                '(RESAMPLERATE = SAMPLERATE)'])
                        end
                    % AUDIOFORMAT = 'raw'
                    else 
                        if fieldValue > AudImpConfigOne.sampleRate
                            fieldValue = AudImpConfigOne.sampleRate;
                            warning(['RESAMPLERATE must be lower than '...
                                'SAMPLERATE. The audio files will be '...
                                'imported but not resampled '...
                                '(RESAMPLERATE = SAMPLERATE)'])
                        end
                    end
                    
                    % Read 'resampleRateToSource.json'
                    fr2souPath = fullfile(root.block,'configdb',...
                        'resampleRateToSource.json');
                    fr2sou = readResampleRateToSource(fr2souPath);
                    if isempty(fr2sou) || (~isempty(fr2sou)...
                            && ~any(fieldValue == [fr2sou.resampleRate]))
                        fieldValue = [];
                        warning(['RESAMPLERATE must be listed in file '...
                            '''<ROOT.BLOCK>\\configdb\\'...
                            'resampleRateToSource.json. Ensure that '...
                            '''channelToReceiver.json'' and '...
                            '''resampleRateToSource.json'' have been '...
                            'created before proceeding further'])
                    end 
                end
            end
    end

    % Update Current Field ('fieldName') with Current Value ('fieldValue')
    AudImpConfigOne(1).(fieldName) = fieldValue;
end
