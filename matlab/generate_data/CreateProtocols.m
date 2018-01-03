function CreateProtocols(expInfo)
%CreateProtocols - Creates protocols for experiment.
%Creates protocols for experiments. Each protocol contains list of trials which
%will be presented to participant. Must be run after trajectories are
%created
%
% Syntax: CreateProtocols(expInfo)
%         
% Inputs:
%   expInfo          - struct with experiment configuration
%
% Example:
%   expInfo=GetExperimentInfo('../shared functions');
%   
%   CreateProtocols(expInfo)
%
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also:  CreateTrajectories
%
% Author: Filip Dechterenko
% MFF UK
% email: filip.dechterenko@gmail.com
% Website: http://ms.mff.cuni.cz/~dechf7am
% Apr 2011; Last revision: 17.02.2013

%------------- BEGIN CODE --------------

% script for generating protocols from trajectories
% in this experiment, we have only 4+4 configuration
% in each block, we have 5 LR trials and 5 unique, we have 6 blocks, so 90
% trials in total
% 5 trial will be used for training

outDir=fullfile('..',expInfo.protDir);
if (~exist(outDir,'dir'))
    sprintf('Info: outDir %s dont exists, creating',outDir);
    mkdir(outDir);
end

nProtocols=expInfo.protocols;

nTargets=expInfo.targets;
nBlockCount = expInfo.blocks;
nTrialsInBlock = expInfo.trials;
nTrialsTraining=expInfo.nTrialsTraining;

nTrials=nBlockCount*nTrialsInBlock+nTrialsTraining;

nTraj=expInfo.traj;
nRepTraj=expInfo.repInBlock;
nRandom=expInfo.ranInBlock;

% "block","trial","type","trackid","file","trackfirst","trialStart"
for ix=1:nProtocols % for each protocol
    fileName=fullfile(outDir,sprintf('P%03d.csv',ix));
    protFile = fopen(fileName, 'w');
    fprintf(protFile,'block,trial,type,trackid,file,trackfirst,trialStart\n');
    
    % select repeating trials
    trialPermutation=randperm(nTraj);
    selRight=trialPermutation(1:nRepTraj);
    trialsMat=repmat(selRight,nBlockCount,2);
    
    selRandom=trialPermutation(nRepTraj+1:end);
    trialsMat=[trialsMat,reshape(selRandom(1:(nBlockCount*nRandom)),nBlockCount,nRandom)];     %#ok<AGROW>
    typesMat=zeros(nBlockCount,nTrialsInBlock);
    typesMat(:,1:nRepTraj)=1; typesMat(:,nRepTraj+1:2*nRepTraj)=2;
    
    % trial starts 0-2s
    trialStarts=2*rand(nTrials);
    % add training part
    trainingMat=selRandom(nBlockCount*nRandom+1:nBlockCount*nRandom+1+nTrialsTraining);
    
    trType=0;
    tr=1;
    
    for jx=1:nTrialsTraining
        trackId=trainingMat(jx);
        
        fprintf(protFile,'%d,%d,%d,%d,"%s",%d,%.02f\n',0,tr,trType,trackId,sprintf('R%03d.csv',trackId),nTargets,trialStarts(tr));
        tr=tr+1;        
    end
        
    % generate protocols    
    for bl=1:nBlockCount
        
        trialRowPerm=randperm(nTrialsInBlock);
        for jx=trialRowPerm
            trackId=trialsMat(bl,jx);
            trType=typesMat(bl,jx);
            fprintf(protFile,'%d,%d,%d,%d,"%s",%d,%.02f\n',bl,tr,trType,trackId,sprintf('R%03d.csv',trackId),nTargets,trialStarts(tr));
            tr=tr+1;  
        end
    end
    fclose(protFile);
    fprintf('Protocol file "%s" successfully created\n',fileName);
end

%------------- END OF CODE --------------

end



