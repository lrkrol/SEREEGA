% value = utl_apply_dvslope(mean, deviation, slope, epochNumber, maxEpoch)
%
%       Applies the indicated slope and random deviation to a given value.
%
% In:
%       mean - 1-by-n array of the value(s) to be adjusted
%       deviation - 1-by-n array of the maximum (six sigma) deviation(s)
%       slope - 1-by-n array of the slope(s)
%       epochNumber - the current epoch number
%       maxEpoch - the maximum number of epochs
%
% Out:  
%       value - 1-by-n array of the adjusted value(s)
% 
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2017-07-06 lrk
%   - Fixed issue where slope already influenced the very first epoch
% 2017-06-14 First version

% This file is part of Simulating Event-Related EEG Activity (SEREEGA).

% SEREEGA is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.

% SEREEGA is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.

% You should have received a copy of the GNU General Public License
% along with SEREEGA.  If not, see <http://www.gnu.org/licenses/>.

function value = utl_apply_dvslope(mean, deviation, slope, epochNumber, maxEpoch)

if numel(mean) > 1
    % recursively calling self in case more than one value is given
    for i = 1:numel(mean)
        value(i) = utl_apply_dvslope(mean(i), deviation(i), slope(i), epochNumber, maxEpoch);
    end
else
    % slope can be NaN when maxEpoch = 1
    value = nansum([mean + deviation / 3 * randn(), slope * (epochNumber-1) / (maxEpoch-1)]);
end

end
