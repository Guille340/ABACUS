%  strNameNew = RENAMEEXISTINGSTRING(strName,strNames,strAppend)
%
%  DESCRIPTION
%  Returns a renamed version of the input string STRNAME if STRNAME is equal to 
%  any of the character vectors in the input cell STRNAMES.
%
%  If STRNAME is found in STRNAMES, the renamed output STRNAME will be 
%  '<STRNAME><STRAPPEND><NUM>', where SRTAPPEND is an appending string and 
%  <NUM> is a 2-digit number indicating the duplicate version. <NUM> will only
%  be different from 01 when STRNAMES contains a character vector already 
%  generated with this function.
%
%  RENAMEEXISTINGSTRING is particularly useful when trying to save a file with 
%  name STRNAME onto a folder with a file with an identical name. To avoid 
%  overwritting, you can use the output of this function to save the file with 
%  a different name that does not exist in the folder already.
%
%  For example, for STRNAME = 'Airgun', STRAPPEND = '_COPY', and STRNAMES = 
%  {'Airgun','Pile','Airgun_COPY01','Airgun_COPY02'}. The output will be
%  STRNAMENEW = 'Airgun_COPY03'.
%
%  INPUT ARGUMENTS
%  - strName: character vector to be renamed (if applicable)
%  - strNames: cell of character vectors against which to compare STRNAME.
%    If STRNAME is a member of STRNAMES, STRNAME will be renamed.
%  - strAppend: suffix character vector appended to STRNAME when the latter
%    exists in STRNAMES and needs to be renamed (e.g. '_COPY').
%
%  OUTPUT ARGUMENTS
%  - strNameNew: renamed version (if applicable) of input character vector 
%    STRNAME. If STRNAME is not a member of STRNAMES, character vectors 
%    STRNAMENEW and STRNAME are identical.
%
%  FUNCTION CALL
%  strNameNew = RENAMEEXISTINGSTRING(strName,strNames,strAppend)
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  16 Jul 2021

function strName = renameExistingString(strName,strNames,strAppend)

nChar = length(strAppend); % number of characters in append string
cnt = 1; % initialise counter
if ismember(strName,strNames)
    % Find New Name for First Iteration
    if ~contains(strName,strAppend) 
        % New Name (append '<STRAPPEND><NUM>')
        strAppendFullNew = sprintf('%s%0.2d',strAppend,cnt); % <STRAPPEND><NUM>
        strNameNew = sprintf('%s%s',strName,strAppendFullNew);
        strAppendFull = strAppendFullNew;
        cnt = cnt + 1;
    else 
        % Extract Duplicate Number <NUM>
        iStrAppend = strfind(strName,strAppend); % start index of append string
        strAppendFull = strName(iStrAppend:iStrAppend + nChar + 1); % <STRAPPEND><NUM>
        iNumString = iStrAppend + nChar;
        numString = strName(iNumString:iNumString + 1); % number string (2 digits)
        
        % New Name (replace '<NUM>')
        cnt = str2double(numString) + 1; % update counter to next number
        strAppendFullNew = sprintf('%s%0.2d',strAppend,cnt); % <STRAPPEND><NUM+1>
        strNameNew = strrep(strName,strAppendFull,strAppendFullNew);
        strAppendFull = strAppendFullNew;
        cnt = cnt + 1;
    end
    
    % Update Name if Still Exists in in STRNAMES
    while ismember(strNameNew,strNames)
        strAppendFullNew = sprintf('%s%0.2d',strAppend,cnt);
        strNameNew = strrep(strNameNew,strAppendFull,strAppendFullNew);
        strAppendFull = strAppendFullNew;
        cnt = cnt + 1;
    end
end
