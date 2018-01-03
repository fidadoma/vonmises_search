function [resampledTraj] = ResampleTrajectory(expInfo,traj,fps)
%ResampleTrajectory - Resamples trajectories to new fps
%All trajectories are generated for 100 fps. We will use interpolation to
%change speed for specified fps
%
% Syntax:  [resampledTraj] = ResampleTrajectory(traj,fps)
%
% Inputs:
%    traj          - (2,nPoints,nFrames) matrix with trajectory for experiment
%    fps           -  new fps
%
% Outputs:
%    resampledTraj - (2,nPoints,nFrames) matrix with trajectory for experiment
%
% Example:
%    traj=GenerateTrajectoryVonMises()
%    resampledTraj=ResampleTrajectory(traj,60)
%
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: GenerateTrajectory
%
% Author: Filip Dechterenko 
% MFF UK
% email: filip.dechterenko@gmail.com
% Website: http://ms.mff.cuni.cz/~dechf7am
% Feb 2012; Last revision: 07.01.2013

%------------- BEGIN CODE --------------

% Changes speed for generated trajectory 
generatedFps=expInfo.generatedFps;
nLength=numel(1:(generatedFps/fps):size(traj,3));
resampledTraj=zeros(size(traj,1),size(traj,2),nLength);
for jx=1:size(traj,2)        
    for ix=1:2
        a=traj(ix,jx,:); % maybe some simple solution with NDim matrixes
        a=a(:)';
        b=interp1(a,1:(generatedFps/fps):size(traj,3));
        resampledTraj(ix,jx,:) = b;        
    end
end
fprintf('Trajectory resampled to fps %f\n',fps);

%------------- END OF CODE -------------- 

end