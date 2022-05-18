%  AcousticDatabase = INITIALISEACOUSTICDATABASE()
%
%  DESCRIPTION
%  Initialises the ACOUSTICDATABASE structure. The initialised structure
%  contains all the fields and subfields down to the lowest level. All 
%  fields that are not structures are set as empty ([]).
%
%  ACOUSTICDATABASE contains two structures: ACOCONFIG and ACODATA. 
%  Both are multi-element structures, where each element corresponds to
%  a unique RECEIVERNAME/SOURCENAME combination. Note that ACOCONFIG and
%  ACODATA contain only one element and no information, other than the
%  structure fields.
%
%  The fields in each of these structures are described below.
%
%  ACOCONFIG
%  =========
%  - audiodbName: name of the Audio Database on which ACOUSTICDATABASE is based.
%  - channel: channel of the Audio Database on which ACOUSTICDATABASE is based.
%  - resampleRate: sampling rate (after resampling) of the Audio Database on 
%    which ACOUSTICDATABASE is based [Hz]
%  - receiverName: name of the receiver for the current element of ACOCONFIG.
%  - sourceName: name of the source for the current element of ACOCONFIG.
%  - AudImpConfig: see INITIALISEAUDIOIMPORTCONFIG
%  - RecImpConfig: see INITIALISERECEIVERIMPORTCONFIG
%  - SouImpConfig: see INITIALISESOURCEIMPORTCONFIG
%  - VesImpConfig: see INITIALISEVESSELIMPORTCONFIG
%  - AudDetConfig: see INITIALISEAUDIODETECTCONFIG
%  - AudProConfig: see INITIALISEAUDIOPROCESSCONFIG
%  - NavProConfig: see INITIALISENAVIGATIONPROCESSCONFIG
%
%  ACODATA
%  =========
%  - audiodbName: name of the Audio Database on which ACOUSTICDATABASE is based.
%  - channel: channel of the Audio Database on which ACOUSTICDATABASE is based.
%  - resampleRate: sampling rate (after resampling) of the Audio Database on 
%    which ACOUSTICDATABASE is based [Hz]
%  - receiverName: name of the receiver for the current element of ACODATA.
%  - sourceName: name of the source for the current element of ACODATA.
%  - AudDetData: see INITIALISEAUDIODETECTDATA
%  - AudProData: see INITIALISEAUDIOPROCESSDATA
%  - RecProData: see INITIALISERECEIVERPROCESSCONFIG
%  - SouProData: see INITIALISESOURCEPROCESSCONFIG
%  - VesProData: see INITIALISEVESSELPROCESSCONFIG
%  - RevData: see INITIALISEREVISEDATA
%
%  INPUT ARGUMENTS
%  - None
%
%  OUTPUT ARGUMENTS
%  - AcousticDatabase: initialised Acoustic Database structure.
%
%  FUNCTION CALL
%  AcousticDatabase = initialiseAcousticDatabase()
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  18 Jun 2021

function AcousticDatabase = initialiseAcousticDatabase()

% Initialise Acoustic Database (configuration)
AudImpConfig = initialiseAudioImportConfig();
RecImpConfig = initialiseReceiverImportConfig();
SouImpConfig = initialiseSourceImportConfig();
VesImpConfig = initialiseVesselImportConfig();
AudDetConfig = initialiseAudioDetectConfig();
AudProConfig = initialiseAudioProcessConfig();
NavProConfig = initialiseNavigationProcessConfig();
AcoConfig = struct('audiodbName',[],'channel',[],'resampleRate',[],...
    'receiverName',[],'sourceName',[],'AudImpConfig',AudImpConfig,...
    'RecImpConfig',RecImpConfig,'SouImpConfig',SouImpConfig,...
    'VesImpConfig',VesImpConfig,'AudDetConfig',AudDetConfig',...
    'AudProConfig',AudProConfig,'NavProConfig',NavProConfig);

% Initialise Acoustic Database (data)
RecProData = initialiseReceiverProcessData();
SouProData = initialiseSourceProcessData();
VesProData = initialiseVesselProcessData();
AudDetData = initialiseAudioDetectData();
AudProData = initialiseAudioProcessData();
RevData = initialiseReviseData();
AcoData = struct('audiodbName',[],'channel',[],'resampleRate',[],...
    'receiverName',[],'sourceName',[],'AudDetData',AudDetData,...
    'AudProData',AudProData,'RecProData',RecProData,...
    'SouProData',SouProData,'VesProData',VesProData,'RevData',RevData);

% Acoustic Database Structure
AcousticDatabase.AcoConfig = AcoConfig;
AcousticDatabase.AcoData = AcoData;
