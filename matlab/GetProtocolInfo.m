function info = GetProtocolInfo(protocol)
%GetProtocolInfo - Gets information from protocol
% Gets information from cell array and stores them in struct. This is an
% utility function for better readibility of code (cell arrays aren't self
% explaining.
%   
% Syntax:  GetProtocolInfo(protocol)
%
% Inputs:
%    protocol - cell array with raw protocol data
%
% Outputs:
%    info - struct with informations about protocol
%
% Example:
%    protocolPath='protocols/P001.csv';    
%    protocol=LoadProtocol(protocolPath);
%    pinfo=GetProtocolInfo(protocol);
%    fprintf('Protocol loaded, there are %d trials in this experiment,pinfo.ntrials);
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: LoadProtocol,GetProtocolInfo

% Author: Filip Dechterenko
% MFF UK
% email: filip.dechterenko@gmail.com
% Website: http://ms.mff.cuni.cz/~dechf7am
% Apr 2011; Last revision: 26.06.2012

%------------- BEGIN CODE --------------
    info = {};
    info.pid     = protocol{1}'; % integers
    info.block   = protocol{2}'; % integers
    info.trial   = protocol{3}';  % integers
    info.file    = protocol{4}';  % integers
    info.trackid = protocol{5}';  % cell
    info.type    = protocol{6}'; % integers
    info.ntrials = length(info.trial); % single int
    info.blocks = unique(info.block);  % vector of unique integers
    info.nblocks = length(info.blocks); % single int
%------------- END OF CODE --------------
end
