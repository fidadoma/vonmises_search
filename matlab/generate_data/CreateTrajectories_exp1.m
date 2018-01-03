am function CreateTrajectories_exp1(expInfo)
%CreateTrajectories - generate files with trajectories
%
% Syntax: GenerateRandomTrajectories(count,nPoints,nFrames,positionGrid,pixelsPerFrame,objectPixels,fieldRect)
%
% Inputs:
%   expInfo            - struct with experiment parameters
%
% Example:
%   confFilePath='./sharedfunctions';
%   expInfo=GetExperimentInfo(confFilePath);
%   CreateTrajectories(expInfo)
%
% Other m-files required: SubsetPositions.m, GenerateTrajectories.m
% Subfunctions: none
% MAT-files required: none
%
% See also:  CreateTrajectories,GenerateTrajectories
%
% Author: Filip Dechterenko
% MFF UK
% email: filip.dechterenko@gmail.com
% Website: http://ms.mff.cuni.cz/~dechf7am
% Apr 2011; Last revision: 09.10.2012

%------------- BEGIN CODE --------------

if(nargin<1)
    confFilePath='../sharedfunctions';
    addpath(confFilePath);
    expInfo = GetExperimentInfo(confFilePath);
end

outputdir = fullfile('..',expInfo.trajDir); % output directory for trajectories
if (~exist(outputdir, 'dir'))
    fprintf('Info: outputdir %s dont exists, creating',outputdir);
    mkdir(outputdir);
end

RandStream.setGlobalStream(RandStream('mt19937ar', 'seed', 12345))

nTargets     = expInfo.targets;
nDistractors = expInfo.distractors;


startingGrid = [expInfo.gridSize, expInfo.gridSize];
if (expInfo.gridSize^2 < nDistractors+nTargets)
    error('Incorrectly set parameters: max capacity of the grid is lower then max number of points');
end


% create starting grid
positionsGrid = StartingPositionsGrid(startingGrid, [0,0], ...
    [expInfo.startWidth, expInfo.startHeigth] ./ (startingGrid - [1,1]));


nDots = nTargets + nDistractors;
trackInfo = struct(...
    'nDots', nDots, ...
    'k', repmat(16, nDots,1), ...
    'degSize', repmat(0.02, nDots,1), ...
    'nFrames', 800, ... % 8 seconds of movement
    'arenaEdge', 30, ...
    'speedVarCoef', 0.1, ...
    'changeVarCoef', 0.1, ...
    'meanChangeFrame', 8);
    
nTraj = 200;    
ks = [1,2,4,8,16,32,64,128];
for k = ks
    trackInfo.k(1) = k;
    for jx = 1:nTraj
        fileName  = sprintf('%03d_%d_rest%d', jx, k,16);
        positions = SubsetPositions(nDots, positionsGrid, 1);
        positions = JitterPositions(positions,[1 1]);
        rTraj     = GenerateTrajectoryVonMises(trackInfo,positions);
        SaveTrajectories(rTraj, sprintf('%s/T%s.csv', outputdir, fileName),...
            sprintf('Trajectories for vonMissesSearch01, conf:%d+%d, fps:100, length:%f, no bouncing, rectangular arena:%d', ...
            nTargets, nDistractors, expInfo.duration, expInfo.fieldEdgeLength));
    end
end

trackInfo.k(2:7) = 4;
for k = ks
    trackInfo.k(1) = k;
    for jx = 1:nTraj
        fileName  = sprintf('%03d_%d_rest%d', jx, k, 4);
        positions = SubsetPositions(nDots, positionsGrid, 1);
        positions = JitterPositions(positions,[1 1]);
        rTraj     = GenerateTrajectoryVonMises(trackInfo,positions);
        SaveTrajectories(rTraj, sprintf('%s/T%s.csv', outputdir, fileName),...
            sprintf('Trajectories for vonMissesSearch01, conf:%d+%d, fps:100, length:%f, no bouncing, rectangular arena:%d', ...
            nTargets, nDistractors, expInfo.duration, expInfo.fieldEdgeLength));
    end
end

fprintf('Trajectories successfuly generated. Total: %d\n',nTraj);

%------------- END OF CODE --------------

end


