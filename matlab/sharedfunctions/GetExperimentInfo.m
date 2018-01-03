function expinfo = GetExperimentInfo(path)
% GetExperimentInfo - Loads experiment info file. If this file is missing,
% creates default one.
% Shared configuration is stored in expInfo file, configuration is loaded
% dynamicaly, so it's easy to add new option.
%
% Syntax: GetExperimentInfo(path)
%         GetExperimentInfo()
% Inputs:
%    path - path to experiment info file or dir, where is experiment info
%    file located
%         
% Example:
%    path='./sharedfunctions';
%    expInfo=GetExperimentInfo(path);
%
% Other m-files required: none
% Subfunctions: CreateExperimentInfo
% MAT-files required: none
%
% See also:  StartExperiment
%
% Author: Filip Dechterenko
% MFF UK
% email: filip.dechterenko@gmail.com
% Website: http://ms.mff.cuni.cz/~dechf7am
% May 2011; Last revision: 26.06.2012

%------------- BEGIN CODE --------------

if (nargin<1)
    % use default file
    path='expinfo.txt';
end
% if we are calling this function with directory as path, we add
% expinfo.txt to the end
if (isempty(regexp(path,'.*expinfo.txt$', 'once')))
    path=fullfile(path,'expinfo.txt');
end
if (~exist(path,'file'))
    fprintf(sprintf('Expinfo file "%s" doesn''t exists, creating new one with default parameters',path));
    CreateExperimentInfo(path);
end

f = fopen(path,'r');
expinfodata = textscan(f,'%s%s','Delimiter','=',...
    'CommentStyle','#');
fclose(f);

% we load data dynamicaly, new options can be added easily in format
% option=value
expinfo=struct();
for ikey=1:size(expinfodata{1},1)
    val=expinfodata{2}{ikey};
    [vali,status]=str2num(val); %#ok<ST2NM>
    if (status==1)
        val=vali;
    end
    expinfo.(expinfodata{1}{ikey})=val;
end

fprintf('expInfo file successfully loaded.\n')

%------------- END OF CODE --------------
end

function CreateExperimentInfo(file)
% creates default experiment info file.
fileptr = fopen(file,'w');
fprintf(fileptr,'## ID of the experiment\n');
fprintf(fileptr,'id=CrowdMOT03\n');
fprintf(fileptr,'## Summary of the experiment\n');
fprintf(fileptr,'expSummary=How multiple distractors affects eye movements during multiple object tracking\n');
fprintf(fileptr,'## Author of the experiment\n');
fprintf(fileptr,'author=FD\n');
fprintf(fileptr,'## Configuration file created\n');
fprintf(fileptr,['Date=' date '\n']);
fprintf(fileptr,'## Directory where trajectories are stored\n');
fprintf(fileptr,'trajDir=../data/tracks\n');
fprintf(fileptr,'## Directory where protocols are stored\n');
fprintf(fileptr,'protDir=../data/protocols\n');
fprintf(fileptr,'## Output directory for data\n');
fprintf(fileptr,'outDir=../data/responses\n');
fprintf(fileptr,'## Directory for eye data\n');
fprintf(fileptr,'eyeDir=../data/eyetracks\n');
fprintf(fileptr,'## Directory for processed eye data\n');
fprintf(fileptr,'eyeProcessedDir=../data/eyetracks_processed\n');
fprintf(fileptr,'## Directory for parsed eye data\n');
fprintf(fileptr,'parsedDir=../data/parsedEye\n');
fprintf(fileptr,'## Directory for experiment results\n');
fprintf(fileptr,'resultsDir=../results\n');
fprintf(fileptr,'## Directory for .mat files\n');
fprintf(fileptr,'datamatDir=../data/datamat\n');
fprintf(fileptr,'## Name of file with clean eye data\n');
fprintf(fileptr,'eyematFile=eyeData.mat\n');
fprintf(fileptr,'## Name of file with clean eye data\n');
fprintf(fileptr,'trackmatFile=trackData.mat\n');
fprintf(fileptr,'## Name of file with clean responses\n');
fprintf(fileptr,'responsematFile=response.mat\n');
fprintf(fileptr,'## Debug session\n');
fprintf(fileptr,'eDebug=1\n');
fprintf(fileptr,'## Are we working on experimental computer?\n');
fprintf(fileptr,'## 1 - my computer, 2 - experimental computer\n');
fprintf(fileptr,'enviroment=1\n');
fprintf(fileptr,'## Key for exit experiment\n');
fprintf(fileptr,'quitKey=q\n');
fprintf(fileptr,'##############################\n');
fprintf(fileptr,'## Experiment configuration ##\n');
fprintf(fileptr,'##############################\n');
fprintf(fileptr,'## Number of targets that will be tracked\n');
fprintf(fileptr,'targets=4\n');
fprintf(fileptr,'## Distractor levels in experiment\n');
fprintf(fileptr,'distLevels=[4 8 12 16]\n');
fprintf(fileptr,'## Framerate for the experiment\n');
fprintf(fileptr,'fps=85\n');
fprintf(fileptr,'## Duration of one trial (in seconds)\n');
fprintf(fileptr,'duration=10\n');
fprintf(fileptr,'## Movement speed of dots in experiment\n');
fprintf(fileptr,'speed=4\n');
fprintf(fileptr,'## Width of arena where dots can move (in degrees)\n');
fprintf(fileptr,'arenaWidth=30\n');
fprintf(fileptr,'## Heigth of arena where dots can move (in degrees)\n');
fprintf(fileptr,'arenaHeigth=30\n');
fprintf(fileptr,'## Width of grid for initial positions of dots (in degrees)\n');
fprintf(fileptr,'startWidth=20\n');
fprintf(fileptr,'## Width of grid for initial positions of dots (in degrees)\n');
fprintf(fileptr,'startHeigth=20\n');
fprintf(fileptr,'## Size of the starting grid (nxn)\n');
fprintf(fileptr,'gridSize=7\n');
fprintf(fileptr,'#########################################\n');
fprintf(fileptr,'## Trajectory generation configuration ##\n');
fprintf(fileptr,'#########################################\n');
fprintf(fileptr,'## Probablity of direction change per frame\n');
fprintf(fileptr,'changeDirectionProb=0.03\n');
fprintf(fileptr,'## How much will direction change\n');
fprintf(fileptr,'directionChange=2\n');
fprintf(fileptr,'## Number of random trajectories that will be generated\n');
fprintf(fileptr,'traj=500\n');
fprintf(fileptr,'#######################################\n');
fprintf(fileptr,'## Protocol generation configuration ##\n');
fprintf(fileptr,'#######################################\n');
fprintf(fileptr,'## Number of protocols\n');
fprintf(fileptr,'protocols=30\n');
fprintf(fileptr,'## Number of blocks\n');
fprintf(fileptr,'blocks=4\n');
fprintf(fileptr,'## Number of trials in block\n');
fprintf(fileptr,'trials=24\n');
fprintf(fileptr,'## Number of repeating trials in block\n');
fprintf(fileptr,'repInBlock=4\n');
fprintf(fileptr,'## Number of difficulty categories\n');
fprintf(fileptr,'repLevelConf=4\n');
fprintf(fileptr,'## Random tasks in block \n');
fprintf(fileptr,'ranInBlock=8\n');
fclose(fileptr);
end