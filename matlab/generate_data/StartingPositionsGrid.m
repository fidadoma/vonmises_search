function positions = StartingPositionsGrid(nPoints, centerPixels, distancePixels)
%StartingPositionsGrid - Generates grid with positions.
%Generates starting grid with positions where can be objects located in
%beginning of the trial. Those positions are centered around central point
%and have fixed distance between them
%
% Syntax: positions = StartingPositionsGrid(nPoints, centerPixels, distancePixels)
%         
% Inputs:
%   nPoints        - vector in format [nx,ny], where nx/ny is number of points in row/column
%   centerPixels   - vector in format [x,y], where x,y are coordinates of the center
%   distancePixels - vector in format [sx, sy], where sx/sy is distance between objects in row/column
%
% Outputs:
%   positions - (2 x n) array with positions, where n=nx*ny
%
% Example:
%   expInfo=GetExperimentInfo('../sharedfunctions');
%   startingGrid = [expInfo.gridSize, expInfo.gridSize];
%   positionsGrid = StartingPositionsGrid(startingGrid, [0,0], ...
%        [expInfo.startWidth, expInfo.startHeigth] ./ (startingGrid - [1,1]));
%
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also:  SubsetPositions
%
% Author: Filip Dechterenko
% MFF UK
% email: filip.dechterenko@gmail.com
% Website: http://ms.mff.cuni.cz/~dechf7am
% Apr 2011; Last revision: 26.06.2012

%------------- BEGIN CODE --------------

% if we called grid generation with only one number for nPoints, we'll
% consider it as square
if size(nPoints, 2) == 1
    nPoints = [nPoints nPoints];
end

% same with distance
if size(distancePixels, 2) == 1
    distancePixels = [distancePixels distancePixels];
end
nPositions = nPoints(1) * nPoints(2);
positions = zeros(2, nPositions);
[xpos, ypos] = meshgrid(1:nPoints(1),1:nPoints(2));
xpos = xpos(:) - (nPoints(1) - 1) / 2 - 1;  % center them first
ypos = ypos(:) - (nPoints(1) - 1) / 2 - 1;  % -1 because they start with 1 not 0
% scale them
positions(1, :) = centerPixels(1) + xpos * distancePixels(1);
positions(2, :) = centerPixels(2) + ypos * distancePixels(2);

%------------- END OF CODE --------------
end
