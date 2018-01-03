function newCoordinates = computeCoordinates(oldCoordinates, theta, magnitude)
%computeCoordinates - computes new coordinates using polar system.
%
% Syntax:
%   newCoordinates - computeCoordinates(oldCoordinates, theta, magnitude)
%         
% Inputs:
%   oldCoordinates - (2,nPoints) array with current coordinates for dots
%   theta          -  direction change
%   magnitude      - magnitude of coordinate change
%
% Outputs:
%   newCoordinates - (2,nPoints) array with new coordinates for dots

newCoordinates(1, :) = magnitude .* sin(theta) + oldCoordinates(1, :); %x coordinate of the next point
newCoordinates(2, :) = magnitude .* cos(theta) + oldCoordinates(2, :); %y coordinate of the next point

end
