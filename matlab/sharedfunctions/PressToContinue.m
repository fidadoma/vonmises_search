function status = PressToContinue(keyName, quitKey)
%PressToContinue -  Wait for a particular key to be pressed
%If keyName is not provided, any key will do
%
% Syntax:  status = PressToContinue(keyName, quitKey)
%
% Inputs:
%    keyName - key, which should be pressed
%    quitKey - key to quit
%
% Outputs:
%    status - Returns 0 for Escape, 1 otherwise
%
% Example:
%    
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: 
%
% Author: Todd Horowitz
% Modified: Filip Dìchtìrnko
% MFF UK
% email: filip.dechterenko@gmail.com
% Website: http://ms.mff.cuni.cz/~dechf7am
% May 2012; Last revision: 13.05.2012

%------------- BEGIN CODE --------------

if nargin >= 1 && ~isempty(keyName)
    specificKey = KbName(keyName);
    anyFlag = 0;
else
    anyFlag = 1;
end

if nargin == 2
    escapeCode = KbName(quitKey);
else
    escapeCode = KbName('Escape');
end

sitFlag = 1;
while sitFlag
    [keyIsDown, ~, keyCode] = KbCheck;
    if keyIsDown
        response = find(keyCode);
        response = response(1);
        if anyFlag || response == specificKey
            sitFlag = 0;
            status = 1;
        end

        if response == escapeCode
            sitFlag = 0;
            status = 0;
        end
    end
end
% now wait for the key to come up again
while KbCheck; end

%------------- END OF CODE --------------
end
