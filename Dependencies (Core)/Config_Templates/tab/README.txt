### timeOffset.csv ###

Example of a Time Offset table. 

This file contains the PC time offset 'TimeOffset_s' relative to UTC at a 
particular PC timestamp 'Timestamp_yyyymmddTHHMMSS'. The time offset' value, in 
seconds, is subtracted from the PC timestamp to obtain the UTC timestamp that 
will be used for syncing audio and navigation data.

- TimeOffset_s: time offset, in seconds, referred to UTC for a given local 
  time 'Timestamp_yyyymmddTHHMMSS'.
- 'Timestamp_yyyymmddTHHMMSS': local timestamp with associated time offset.
  It must be expressed with format yyyymmddTHHMMSS, where 'y','m','d','H',
  'M','S' represent digits of the year, month, day, hour, minute and second,
  and 'T' is a delimiter indicating the start of the time string.

### vesseldb.csv ###

Example of Vessel Database table. 

This file contains the specifications of a number of vessels detected by the
AIS unit. The data in this file is used to populate with these specs the matching
vessels of 'fleet' category found in the Navigation Database. The table must
include a first line with the following field names, followed by as many lines as
vessels are to be populated:

- mmsi: MMSI number of the vessel
- vesselName: name of the vessel
- vesselLength: length of the vessel [m]
- vesselBeam: width of the vessel [m]
- vesselDraft: draft of the vessel [m]
- vesselGrossTonnage: vessel gross tonnage [tonnes]

### pulseTable.csv ###

Example of Pulse table.

This file contains the information necessary for the 'ConstantRate' detector to
find the location of the detections. The table must include a first line with the
following field names, followed by as many lines as audio files are to be processed:

- FirstPulse_s: time of the first pulse, in seconds, relative to the start of the
  audio file
- PulseInterval_ms: time interval between consecutive pulses, in seconds
- AudioName: name of the audio file containing the pulses, including extension


