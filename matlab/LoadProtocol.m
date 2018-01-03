function protocol = LoadProtocol(dataFileName, protStringPattern, headerLines)
%LoadProtocol - Loads protocol from specified data file
%Loads protocol for experiment from file.
%
% Syntax:  protocol = LoadProtocol(dataFileName)
%
% Inputs:
%    dataFileName - path to the protocol file (usualy stored as .csv)
%
% Outputs:
%    protocol - cell array with protocol
%
% Example:
%    protocol = LoadProtocol('../data/protocols/P001.csv')
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: GenerateProtocols

% Author: Filip Dechterenko 
% MFF UK
% email: filip.dechterenko@gmail.com
% Website: http://ms.mff.cuni.cz/~dechf7am
% Apr 2011; Last revision: 26.06.2012

%------------- BEGIN CODE --------------

if (~exist(dataFileName,'file'))
    error('crowdMOT:technicalProblems','File with protocol "%s" doesn''t exist\n',dataFileName);
end

if(nargin < 2), 
    conf = getExperimentInfo();
    protStringPattern = conf.protStringPattern;
end

if(nargin < 3), headerLines = 1; end

dataFile = fopen(dataFileName, 'r');
protocol = textscan(dataFile, protStringPattern, 'Delimiter', ',',...
    'Headerlines',headerLines);

fclose(dataFile);
if (numel(protocol{end})==0)
    warning('crowdMOT:technicalProblems','protocol file "%s" doesn''t contain any data (probably is badly formated). Data should be delimited by comma.\n',dataFileName);
end
fprintf('Protocol file "%s" successfully loaded\n',dataFileName);

%------------- END OF CODE --------------
end