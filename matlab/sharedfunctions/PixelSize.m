function pixSize = PixelSize(degSize,viewDistance,screenResolution,monitorSize)
%PixelSize - Loads participant response from file
%Loads participant response from file.
%
% Syntax: pixSize = PixelSize(degSize,viewDistance,screenResolution,monitorSize)
%
% Inputs:
%   degSize          - size in degrees (1 or 2 dim)
%   viewDistance     - viewing distance in cm
%   screenResolution - resolution in pixels (1 or 2 dim)
%   monitorSize      - screen size in cm (or same units as viewDistance)
%
% Outputs:
%    pixSize         - size of degSize degrees in pixels
%
% Example:
%    degSize=1;
%    viewingDistance=50;
%    screenResolution=1280;
%    monitorSize=45.14;
%    pixSize = PixelSize(degSize,viewingDistance,screenResolution,monitorSize);
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: ParseData
%
% Author: Filip Dechterenko 
% MFF UK
% email: filip.dechterenko@gmail.com
% Website: http://ms.mff.cuni.cz/~dechf7am
% Mar 2012; Last revision: 30.06.2012

%------------- BEGIN CODE --------------
    radSize = degSize ./ 180 .* pi;
    cmSize  = 2 .* viewDistance .* tan(radSize ./ 2);
    pixSize = cmSize ./ monitorSize .* screenResolution;
    
%------------- END OF CODE -------------- 
 
end
