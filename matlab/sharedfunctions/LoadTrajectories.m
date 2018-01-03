function [data,comment] = LoadTrajectories(dataFileName)
%LoadTrajectories - Loads trajectories from specified data file
%Loads trajectories from file
%
% Syntax:  [data,comment] = LoadTrajectories(dataFileName)
%
% Inputs:
%    dataFileName - path to file containing trajectory
%
% Outputs:
%    data         - (2,nPoints,nFrames) matrix with trajectory for experiment
%    comment      - comment from header line of file
%
% Example:
%    dataFile='../data/tracks/R001.csv';
%    [data,comment]=LoadTrajectories(dataFile)
%    fprintf('Trajectory from file %s loaded\nComment: %s\n',dataFile,comment);
%
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: ExperimentDemo, StartExperiment
%
% Author: Filip Dechterenko 
% MFF UK
% email: filip.dechterenko@gmail.com
% Website: http://ms.mff.cuni.cz/~dechf7am
% Feb 2012; Last revision: 01.07.2012

%------------- BEGIN CODE --------------

dataFile = fopen(dataFileName, 'r');

comment = fgetl(dataFile) ;
line1 = fgetl(dataFile);
d1 = sscanf(line1,'%f');
howmany1 = size(d1,1);
frewind(dataFile);
fgetl(dataFile);
dataraw = fscanf(dataFile, '%f');
dataraw = reshape(dataraw, howmany1, []);
dataraw = dataraw';
fclose(dataFile);

% reshape trajectories
xindex = 1:2:howmany1;  % odd numbers
yindex = 2:2:howmany1;  % even
nPoints = howmany1 / 2;
nFrames = size(dataraw, 1);
data = zeros(2, nPoints, nFrames);
data(1,:,:) = dataraw(:,xindex)';
data(2,:,:) = dataraw(:,yindex)';
   
%------------- END OF CODE -------------- 

end