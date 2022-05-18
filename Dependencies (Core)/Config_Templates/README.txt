The configuration files must follow this naming convention:

<CONFIGTYPE><TEXT>_<NUM>.m

where:

<CONFIGTYPE> is the type of configuration file. There are five options:
- audioImportConfig
- receiverImportConfig
- sourceImportConfig
- audioDetectConfig
- audioProcessConfig

<TEXT> is any text that can help identify the file. This can include the template
type (WAV, RAW, Fixed, Towed, etc), relevant configuration characterisitics
(channel, resampling rate) or project identifier (TKOWF).

<NUM> is a number that determines the reading and processing order of the
configuration files.

Example:

audioImportConfig_WAV_ch1_fr1200_01.m
audioImportConfig_WAV_ch2_fr1200_02.m
audioImportConfig_WAV_ch1_fr2400_03.m
audioImportConfig_WAV_ch2_fr2400_04.m

[Guillermo Jiménez Arranz, 07 Jul 2021]

