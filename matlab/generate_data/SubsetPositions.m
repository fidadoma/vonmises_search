function newPositions = SubsetPositions(nSelect, positions, random)
%SubsetPositions - select several points from position grid
%Select several positions from grid. Data can be selected randmly or we
%could take first several points
%
% Syntax: newpositions = SubsetPositions(nSelect, positions, random)
%         
% Inputs:
%   nSelect        - either number of points to select, or vector of indexes
%   positions      - (2, nPoints) array with positions
%   random         - 1 if points should be selected randomly, 0 if we just
%   take first nPoints positions
%
% Outputs:
%   newPositions - (2 x nSelect) array with positions
%
% Example:
%   % we will generate starting grid somehow (e.g. with StartingPositionsGrid
%   positions = SubsetPositions(nPoints, positionGrid, 1);   
%
% Remarks:
%    Works also for trajectories: accepts (2, nP, nFr) as positions and
%    returns (2, nSelect, nFr) matrix.
% 
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also:  StartingPositionsGrid
%
% Author: Filip Dechterenko
% MFF UK
% email: filip.dechterenko@gmail.com
% Website: http://ms.mff.cuni.cz/~dechf7am
% Apr 2011; Last revision: 26.06.2012

%------------- BEGIN CODE --------------

nPoints = size(positions, 2);
if size(nSelect, 2) == 1
    index = 1:nSelect;  % if (int) n is provided, we take first n
else
    index = nSelect;
end

if random == 1
    positions = positions(:,randperm(nPoints),:);
end

newPositions = positions(:,index,:);

%------------- END OF CODE --------------
end