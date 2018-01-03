function [speed,response] = LoadResponse(fileName)
%LoadResponse - Loads participant response from file
%Loads participant response from file.
%
% Syntax: [speedPerSec,response] = LoadResponse(fileName)
%
% Inputs:
%    rawdata    - raw eye data from parseasc utility
%    response   - struct with subject responses
%
% Outputs:
%    speed      - speed with which dots moved
%    response   - cell array with response information
%
% Example:
%    responseFile='../../data/responses/data-04.csv';
%    [speedPerSec,response]=LoadResponse(responseFile);
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: ParseData
%
% Author: Filip Dechterenko 
% MFF UK
% email: filip.dechterenko@gmail.com
% Website: http://ms.mff.cuni.cz/~dechf7am
% Mar 2012; Last revision: 30.06.2012

%------------- BEGIN CODE --------------

% gets speed and response from file
dataFile = fopen(fileName, 'r');
response=textscan(dataFile,'%d%d%d%q%q%d%d%f%d','Delimiter',',',...
    'Headerlines',3);

% response loaded, now get speed
frewind(dataFile);
fgetl(dataFile);fgetl(dataFile);
speedStr=fgetl(dataFile);
ix=strfind(speedStr,':');
speedStr(1:ix)=[];
speed=str2double(speedStr);
fclose(dataFile);

%------------- END OF CODE -------------- 

end