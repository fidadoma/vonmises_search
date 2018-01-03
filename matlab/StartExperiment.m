function StartExperiment(identifier)
% StartExperiment - Main procedure for administrating experiment.
% In prior to successful testing, all protocols and trajectories have to be
% generated. Needs PsychToolBox-3 to run.
%
% Syntax: StartExperiment()
%
% Example:
%    % we need trajectories and protocols generated in files specified in experiment info
%    % configuration file
%    StartExperiment()
%
% Other m-files required: GetExperimentInfo.m, PixelSize.m, LoadProtocol.m, GetProtocolInfo.m, LoadTrajectories.m, WaitMouse.m
% Subfunctions: cleanup
% MAT-files required: none
%
% See also:  StartExperiment
%
% Author: Filip Dechtìrenko
% MFF UK
% email: filip.dechterenko@gmail.com
% Website: http://ms.mff.cuni.cz/~dechf7am
% Mar 2012; Last revision: 26.06.2012

%------------- BEGIN CODE --------------
    function cleanup
    % simple function for shutting down eyelink and closing window
    if eEyelink, Eyelink('Shutdown'); end
    sca;
    commandwindow;
    end

%% ----------------------------------------------------------
% Set variables about experiment
% -----------------------------------------------------------

confFilePath = './sharedfunctions';
addpath(confFilePath);
expInfo = GetExperimentInfo(confFilePath);

protDir = expInfo.protDir;
if (~exist(protDir,'dir'))
    error('vonMissesMot01:technicalProblems', 'Directory with protocols don''t exist!');
end


trajDir = expInfo.trajDir;
if (~exist(trajDir,'dir'))
    error('vonMissesMot01:technicalProblems', 'Directory with trajectories don''t exist!');
end

resultsDir = expInfo.outDir;
if (~exist(resultsDir,'dir'))
    error('vonMissesMot01:technicalProblems', 'Output directory don''t exist!');
end

%eyeDir = expInfo.eyeDir;
%if (~exist(eyeDir,'dir'))
%    error('vonMissesMot01:technicalProblems','Directory for eye data don''t exist!');
%end


% default values for testing
if (nargin<1), identifier = 0; end

protocolName = sprintf('P%03d', identifier);

clear Screen; % to ensure clean run

% set random generator
RandStream.setGlobalStream(RandStream('mt19937ar', 'seed', 500 + identifier))

dummymode = 0;

% -------------------------------
% important options
% -------------------------------

% enable debug session
eDebug = expInfo.eDebug;

% enable high priority settings
ePriority = 1;

% data will be saved
eSaveData = 1;

% we will use eyelink
eEyelink = 0;

% check, if actual fps differ too much from predefined fps
fpsCheck = 1;

% check, if output files exists (this option isn't used, if eSaveData==0)
overwriteCheck = 1;

% -------------------------  --------------------------------
% Prepare eyelink and set variables
% -----------------------------------------------------------
fprintf('======\nvonMissesMot01 Experiment (3/2015)\n======\n');
if eEyelink
    edfFile = [identifier '.edf'];
    % we are connecting to the Eyelink using network
    fprintf('* Connecting to Eyelink...');
    noResponse = unix([ 'ping 100.1.1.1 -c 5 -W 2 >> ' resultsDir 'log.txt']);
    if noResponse
        fprintf('\n  * Could not reach the eye tracker. Check the network setting or cable.\n\nExiting.\n');
        return % better to stop here than later when Window is open
    else
        fprintf('OK\n');
    end
end

% set output file for response and eyetracker
outputFile = sprintf('data-%d.csv',identifier);

% load protocol for participant and parse it
protFile   = fullfile(protDir, [protocolName '.csv']);
if (~exist(protFile,'file'))
    error('vonMissesMot01:technicalProblems','Protocol file %s doesn''t exist!',protFile);
end

fprintf('* Loading protocol file %s\n', protFile);
protocol = LoadProtocol(protFile, expInfo.protStringPattern);
pinfo    = GetProtocolInfo(protocol);

radiusDegrees      = 0.5; % deg
queryRectangleSize = 1.5; % deg
%fieldSizeDegrees = 20;  % deg

%degreesPerSecond = 8; % deg/s
cueTime      = 0.5; % s
feedbackTime = 0.400; % s

viewingDistance = 50;% cm
expectedFps     = expInfo.fps;
generatedFps    = expInfo.generatedFps;
toleranceFps    = 0.05; % = 5%
duration        = expInfo.duration;

defaultFont     = 'Dejavu Sans';

ScreenNumber    = max(Screen('Screens')); % we will use pointer to second screen, if we have more monitors
[monitorXmm, monitorYmm] = Screen('DisplaySize', ScreenNumber);
screenRect = Screen('Rect', ScreenNumber);

% it's better to use smaller window for debugging
if (eDebug)
    screenRect = screenRect/2;
end

% compute degrees per pixel
diagonalCm = sqrt(monitorXmm ^ 2 + monitorYmm ^ 2) / 10;
pixels     = sqrt(sum(screenRect .^ 2));

pixelsPerDegree = PixelSize(1, viewingDistance, pixels, diagonalCm);

if (expInfo.environment == 1)
    %I had to set this value on my computer manually,
    %because my graphic card didn't support automatic detection of radius
    radiusPixels =  5.0;
elseif (expInfo.environment == 2)
    radiusPixels = radiusDegrees * pixelsPerDegree;
else
    error('vonMissesMot01:technicalProblems','Unknown environment');
end


% define response keys
KbName('UnifyKeyNames');
cKey      = KbName('c');
pauseKeys = cKey;
quitKey   = expInfo.quitKey;

% define colors
black = [0 0 0]; white = [255 255 255];
red = [255 0 0]; green = [0 255 0];
yellow = [255 255 0];
midGray = [128 128 128];

% now assign colors
backgroundColor = black;

coreColor       = midGray;
cueColor        = green;
falseAlarmColor = red;
errorColor      = red;
correctColor    = green;
textColor       = white;
queryColor      = yellow;

textSize = 20;

dataFileName     = fullfile(resultsDir,outputFile);
dataFormatString = expInfo.respStringPattern; % we will use this string for output
if eSaveData
    if ~exist(dataFileName, 'file') || ~overwriteCheck
        % add headers
        fileID = fopen(dataFileName, 'a+');
        fprintf(fileID, '# id=%d now=%s\n', identifier, datestr(now));
        fprintf(fileID, '%s\n', ['subject, block, trial, type, trackId, ',...
            'file, responseTime, accuracy']);
        fclose(fileID); % flush
    else
        error('vonMissesMot01:technicalProblems','Result file exists');
    end
end

% instruction text here
 instructionString = [...
     'V tomto experimentu bude vasim najit objekt, ktery meni smer jinak nez ostatni.\n\n' ...
     'Objekty se budou pohybovat po dobu 8s.\n' ...
     'Mysi pote oznacte, ktery objekt menil smer jinak nez ostatni.\n' ...
     'Po 8 s se zastavi a vy budete mit za ukol oznacit sledovane body.\n'...'];
     'Sledovane body oznacite mysi.'];


try
    % open windows and run experiment
    
    % basic setup stuff
    AssertOpenGL;
    InitializeMatlabOpenGL; % allows me to query the maximum dot size
    % This sets a PTB preference to skip some timing tests. A value
    % of 0 runs these tests, and a value of 1 inhibits them. This
    % should be set to 0 for actual experiments, since it can detect
    % timing problems.
    if (eDebug==0)
        Screen('Preference', 'SkipSyncTests', 0);
    end
    % The next line sets a PTB preference to vary the amout of
    % testing that PTB does when it first opens a window. Higher
    % values lead to more testing and debugging, lower values lead
    % to less. 3 seems to be a good level: it reports any major
    % problems but doesn't waste a lot of time.
    Screen('Preference', 'VisualDebugLevel', 3);
    
    % this opens the screen window and places it on the secondary monitor,
    % if there is one
    
    MainWindow = Screen('OpenWindow', ScreenNumber, backgroundColor,screenRect);
    Screen('BlendFunction', MainWindow, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    if (ePriority); Priority(MaxPriority(MainWindow)); end % enable realtime scheduling
    
    % check, if current fps differ too much from preset value
    interFrameInterval = Screen('GetFlipInterval', MainWindow); % get refresh interval
    currentFps = 1/interFrameInterval;
    if fpsCheck && abs(currentFps - expectedFps) > expectedFps * toleranceFps
        msg = sprintf('The current FPS (%2.3f Hz) differs too much from expected FPS (%2.3f Hz)', ...
            (1/interFrameInterval), expectedFps);
        ME = MException('vonMissesMot01:technicalProblem',msg);
        throw(ME);
    end
    maxP = MaxPriority(MainWindow);
    
    if (~eDebug)
        HideCursor;
    end
    Screen('TextSize', MainWindow, textSize);
    Screen('TextFont', MainWindow, defaultFont);
    
    objectRect = [0 0 radiusPixels radiusPixels];
    %objectRect= objectRect*1.05;
    
    % initialize eyelink
    if eEyelink
        el = EyelinkInitDefaults(MainWindow);
        if ~EyelinkInit(dummymode)
            fprintf('* Eyelink Init aborted.\n');
            cleanup; return
        end
        [v vs] = Eyelink('GetTrackerVersion');
        % we are using Eyelink 2
        assert(v==2);
        fprintf('* Running experiment on a ''%s'' tracker.\n', vs);
        %edfFile='demo.edf';
        i = Eyelink('OpenFile', edfFile);
        if i ~= 0
            fprintf('Cannot create EDF file ''%s''\n', edfFile);
            cleanup; return;
        end
        fprintf('Eyelink connected, EDF file ''%s'' created.\n', edfFile);
        Eyelink('command','add_file_preamble_text ''Recorded by vonMissesMot01''');
        
        % setup eyelink library
        el.backgroundcolour = BlackIndex(el.window);
        el.foregroundcolour = GrayIndex(el.window);
        el.msgfontcolour    = GrayIndex(el.window);
        el.imgtitlecolour   = GrayIndex(el.window);
        el.msgfont=defaultFont;
        el.msgfontsize=16;
        el.imgtitlefont=defaultFont;
        el.imgtitlefontsize=16;
        el.calibrationtargetcolour=[255 255 0];
        PsychEyelinkDispatchCallback(el);
        
        
    end
    
    
    if (ePriority); Priority(0); end % disable real-time scheduling
    
    % present instructions
    DrawFormattedText(MainWindow, instructionString, ...
        'center', 'center', textColor, 70);
    %Screen('Flip', MainWindow);
    %if ~PressToContinue([],quitKey);
    %    error('vonMissesMot01:userInterrupt','Escape pressed');
    %end
    
    nTrials = pinfo.ntrials;
    
    % ------------------  BLOCK loop  -----------------------
    allBlocks = pinfo.blocks;
    for block = allBlocks
        isTraining = block == 0;
        blocktrials = find(pinfo.block == block);  % rows for current block
        
        
        %nTrialString = num2str(nTrials);
        if(isTraining),
            message='Nacvik'; 
        else
            message=sprintf('Blok %d',block);
        end
        
        %message = [' Stisknutim klavesy spustite ', nTrialString, ' ',strType ,' ', 'pokusu.'];
        DrawFormattedText(MainWindow, message, 'center', 'center', textColor, 70);
        Screen('Flip', MainWindow);
        
        if ~PressToContinue([],quitKey);
            error('vonMissesMot01:userInterrupt','Escape pressed');
        end
        
        % calibrate eye tracker
        if eEyelink
            EyelinkDoTrackerSetup(el);
        end
        
        % ------------------  TRIAL loop  -----------------------
        for trial = blocktrials
            
            trialFileOnly = char(pinfo.file(trial));
            trialFile     = fullfile(trajDir, trialFileOnly);
            trialType     = pinfo.type(trial);
                        
            trackId   = pinfo.trackid(trial);
            trialCode = sprintf('%d-%d', trackId, trialType);
            nTargets  = 1; 
            
            fprintf('* trial: %d/%d, trialCode: %s\n',trial , nTrials, trialCode);
            
            
            % -------------------------------
            % load trajectory
            % -------------------------------
            
            if(~exist(trialFile,'file'))
                error('vonMissesMot01:technicalProblems','Trajectory file "%s" don''t exist!',trialFile);
            end
            
            % they are in format of ND array: xy*nPoints*nFrames
            traj = LoadTrajectories(trialFile);
			
            % trajectories were generated with default fps, we need them
            % resampled 
            traj = ResampleTrajectory(expInfo,traj,expectedFps);
                        
            % scale the values from deg to pixels
            traj = pixelsPerDegree * traj;
			
            % center on screen
            traj(1,:,:) = traj(1,:,:) + screenRect(3)/2;
            traj(2,:,:) = traj(2,:,:) + screenRect(4)/2;
            
            nFrames = size(traj, 3);
            nPoints = size(traj, 2);
            
            % -------------------------------
            % set colors of points
            % -------------------------------
            
            trackColors = zeros(3, nPoints);
            trackColors(:,:) = repmat(coreColor, nPoints, 1)';
            startColors = trackColors;
                        
            % -------------------------------
            % drift correction
            % -------------------------------
            
            if eEyelink
                Eyelink('Message', 'TRIALID %s', trialCode);
                
                eyelinkMessage=sprintf('TRIALINFO "BL: %d TR: %d/%d (%s) Ans:%d"',block, ...
                    trial, length(blocktrials), trialCode, int32(correct));
                Eyelink('Message', eyelinkMessage);
                
                EyelinkDoDriftCorrection(el);
            end
            
            % enable realtime scheduling, if set
            if (ePriority); Priority(maxP); end
            
            % start recording
            if eEyelink
                Eyelink('StartRecording');
                WaitSecs(0.1);
            end
            
            % -------------------------------
            % loop through frames
            % -------------------------------
            
            % cue phase
            xy = traj(:,:,1);
            Screen('FillRect', MainWindow, backgroundColor);
            if eEyelink; Eyelink('Message', 'CUETIME'); end
            for frame = 1:(cueTime * expectedFps);
                Screen('DrawDots', MainWindow, xy, radiusPixels * 2, ...
                    startColors, [], 2);
                
                Screen('Flip', MainWindow);
                
            end
            
            % move phase
            if eEyelink; Eyelink('Message', 'SYNCTIME'); end
            for frame = 1:nFrames
                xy = traj(:, :, frame);
                Screen('DrawDots', MainWindow, xy, radiusPixels * 2, ...
                    trackColors, [], 2);
                
                Screen('Flip', MainWindow);
            end
            
            % stop recording
            if eEyelink;
                Eyelink('Message', 'SYNCEND');
                WaitSecs(0.1);
                Eyelink('StopRecording');
            end
            if (ePriority); Priority(0); end
            
            % query phase
            %xy = traj(:,:,nFrames);
            %xyq = xy(:,query,:);
            %queryRect = CenterRectOnPoint(queryRect, xyq(1), xyq(2));
            %Screen('DrawDots', MainWindow, xy, radiusPixels*2, ...
            %    trackColors, [], 2);
            %Screen('FrameRect', MainWindow, queryColor, queryRect, 5);
            
            %Screen('Flip', MainWindow);
            
            % -------------------------------
            % collect response
            % -------------------------------
            
            xy = round(xy);
            finalColors = zeros(3, nPoints);
            finalColors(:,:) = repmat(coreColor, nPoints, 1)';
            finalRects = CenterRectOnPoint(repmat(objectRect, nPoints, 1),...
                xy(1, 1:nPoints)', xy(2, 1:nPoints)');
            SetMouse(round(screenRect(RectRight)/2), round(screenRect(RectBottom)/2), MainWindow);
            
            % hide cursor in debug mode
            if (~eDebug)
                ShowCursor('hand');
            end
            nClicks = 0;
            selectedItems = zeros(1, nPoints);
            tstart=tic;
            while nClicks < nTargets
                [mouseX, mouseY] = WaitMouse;
                for j = 1:nPoints
                    if (IsInRect(mouseX, mouseY, finalRects(j, :)) && ~selectedItems(j)) % this item was selected
                        finalColors(:,j) = queryColor;
                        nClicks = nClicks + 1;
                        selectedItems(j) = 1; 
						
                        % change color of selected item
                        Screen('DrawDots', MainWindow, xy, radiusPixels*2, ...
                            finalColors, [], 2);
                        Screen('Flip', MainWindow);
                    end
                end
            end
            reactionTime = toc(tstart);
            if (~eDebug)
                HideCursor;
            end
            
            accuracy = selectedItems(1) == 1; 
			
            isCorrect = accuracy;
            
            if (isCorrect)
                responseColor=correctColor;
                text='Spravne';
            else
                responseColor=errorColor;
                text=['Chybne: ', num2str(nTargets-nCorrect)];                
            end
                        
            DrawFormattedText(MainWindow, text, 'center', 'center', responseColor);
            Screen('Flip', MainWindow);
                        
            if ~PressToContinue;
                error('vonMissesMot01:userInterrupt','Escape pressed');
            end
            
            % -------------------------------
            % save data
            % -------------------------------
            
            %'%d, %d, %d, %d, %d, "%s", %d, %0.2f, %2.3f, %d\n';
            if eSaveData
                fileID = fopen(dataFileName, 'a+'); % reopen
                fprintf(fileID, dataFormatString, ...
                    identifier, block, trial, trialType, trackId, trialFileOnly, ...
                    pinfo.trackfirst(trial), trialStart,reactionTime, accuracy);
                fclose(fileID);
            end
            
            
        end % trial routine
        % is it a last block?? if not:
    end % block routine
    % disconnect from eyelink, download EDF
    
    if eEyelink
        DrawFormattedText(MainWindow, 'Chvili strpeni, ukladam data', 'center', 'center', textColor);
        Screen('Flip', MainWindow);
        Eyelink('Command', 'set_idle_mode');
        WaitSecs(0.5);
        Eyelink('CloseFile');
        try
            fprintf('* Receiving data file ''%s''...\n', edfFile);
            status = Eyelink('ReceiveFile');
            if status > 0
                fprintf('* ReceiveFile status = %d\n', status);
            end
            if exist(edfFile, 'file') == 2
                fprintf('* Data file ''%s'' can be found in ''%s''\n', edfFile, pwd);
            end
        catch ME
            ME.message
            fprintf('* Problem receiving data file ''%s''\n', edfFile);
            cleanup
        end
        
    end
    DrawFormattedText(MainWindow, 'Dekujeme za ucast!', 'center', 'center', textColor);
    Screen('Flip', MainWindow);
    PressToContinue([],quitKey);
    fprintf('* Everything OK.\n');
catch ME
    ME.message
    ple; % print last error
    if eEyelink; cleanup; end
end
if (ePriority); Priority(0); end


cleanup;
ShowCursor;

%------------- END OF CODE --------------
end

function [mouseX mouseY buttons clickTime] = WaitMouse
%WaitMouse  - waits until mouse get pressed
%
% Syntax: [mouseX mouseY buttons clickTime] = WaitMouse()
%
% Output:
%     mouseX  - x coordinate of mouse click
%     mouseY  - y coordinate of mouse click
%     buttons  - buttons that were pressed
%     clickTime  - time of the mouse click
%  Example:
%     [mouseX mouseY ~ clickTime] = WaitMouse();
%     fprintf('You clicked at %s on [%s,%s]',clickTime,mouseX,mouseY);

global MainWindow

buttons = 0;
while ~any(buttons) % wait for press
    [mouseX, mouseY,  buttons] = GetMouse(MainWindow);
    clickTime = GetSecs;
end
while any(buttons) % wait for release
    [mouseX, mouseY,  buttons] = GetMouse(MainWindow);
end
end
