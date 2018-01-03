function newPositions = JitterPositions(positions, jitterRadiusPixels)
% function newPositions = JitterPositions(positions, jitterRadiusPixels)
%
% Jitters point positions using uniform random jitter with a specified
% radius 
%
%   positions          = (2, nPoints) original positions
%   jitterRadiusPixels = (jx, jy) radius in pixels, maximum jitter size
%
% Returns (2, nPoints) vector with new positions

    %nPoints = size(positions, 2)
    randomJitter = rand(size(positions)) - .5;
    noise = diag(jitterRadiusPixels) * randomJitter;
    newPositions = noise + positions;
end