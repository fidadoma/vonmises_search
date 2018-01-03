function trajectory = GenerateTrajectoryVonMises(trackInfo, startPositions)
% GenerateTrajectoryVonMises - generates trajectory sampling from von mises distribution

if (nargin<1)
    nDots   = 8;
    k       = repmat(16, nDots,1); % ballistic-like-distractors
    degSize = repmat(0.02, nDots,1);
    nFrames = 600;
    a       = 15;
    speedVarCoef    = repmat(0.01, nDots, 1); %0.1;
    changeVarCoef   = 0.1;
    meanChangeFrame = 8;    
else
    nDots   = trackInfo.nDots;
    k       = trackInfo.k;
    degSize = trackInfo.degSize;
    nFrames = trackInfo.nFrames;
    a       = trackInfo.arenaEdge/2;
    speedVarCoef    = repmat(trackInfo.speedVarCoef, nDots, 1);
    changeVarCoef   = trackInfo.changeVarCoef;
    meanChangeFrame = trackInfo.meanChangeFrame;
end

    
fieldRect           = [-a, -a, a, a]; % rectangle, where will dot move

objectPixels        = 1;
interItemBufferZone = objectPixels * 1.10;

% define borders
leftEdge   = fieldRect(RectLeft) + objectPixels;
rightEdge  = fieldRect(RectRight) - objectPixels;
topEdge    = fieldRect(RectTop) + objectPixels;
bottomEdge = fieldRect(RectBottom) - objectPixels;

% initialize directions
oldCoordinates  = startPositions; %-(a - 1) + (2 * (a - 1)) .* rand(2, nDots);
theta           = rand(1, nDots) * 2 * pi;

trajectory      = zeros(2, nDots, nFrames);
newCoordinates  = oldCoordinates;
thetaDeltas    = zeros(nFrames, nDots);

% pre-generate all trajectory changes
for i=1:nDots
    thetaDeltas(:,i) = randraw('vonmises', [0, k(i)], nFrames, 1);
end

% pre-generate all speed changes
speeds          = repmat(degSize, 1, nFrames + 1)' + (repmat(speedVarCoef', nFrames + 1,1) .* repmat(degSize, 1, nFrames + 1)') .* randn(nFrames + 1, nDots);

% set the frames, where will the speed and angle change
changeFrame     = meanChangeFrame + (changeVarCoef * meanChangeFrame) .* randn(nFrames + 1, nDots);
changeFrame     = cumsum(changeFrame);
indexes         = ones(1,nDots);
currspeed       = speeds(end,:);

for f = 1:nFrames
    changeMov = f > changeFrame(indexes);
    thetaDelta = zeros(1,nDots);
    if (any(changeMov))
        thetaDelta(changeMov) = thetaDeltas(f,changeMov);
        currspeed(changeMov)  = speeds(f,changeMov);
        indexes(changeMov) = indexes(changeMov) + 1;
    end
        
    % don't change direction when two dots occlude
    [X, Y] = meshgrid(newCoordinates(1, :), newCoordinates(2, :));
    distances = triu(sqrt((X - X') .^ 2 + (Y - Y') .^ 2));
    
	% find pairs of items that are too close
    [i, j] = find(distances < interItemBufferZone & distances);
       
    % if objects are close to each other, don't change direction rapidly
    if (~isempty(i))
        thetaDelta(abs(thetaDelta(i)) > pi / 2)=0;
    end
    if (~isempty(j))
        thetaDelta(abs(thetaDelta(j)) > pi / 2)=0;
    end
    theta = theta + thetaDelta;
    
    % recompute coordinates
    newCoordinates = computeCoordinates(oldCoordinates, theta, currspeed);
    
    % now prevent distractors from going out of bounds
    xViolation = newCoordinates(1, :) < leftEdge | newCoordinates(1, :) > rightEdge;
    yViolation = newCoordinates(2, :) < topEdge | newCoordinates(2, :) > bottomEdge;
    
    theta(xViolation) = 2*pi - theta(xViolation);
    theta(yViolation) = pi - theta(yViolation);
    
    newCoordinates = computeCoordinates(oldCoordinates, theta, currspeed); % recompute coordinates
    
    trajectory(:, :, f) = newCoordinates;
	
    % set the old coordinates (for the next frame) equal to the coordinates used for the current frame
    oldCoordinates = newCoordinates;
    
end

end

