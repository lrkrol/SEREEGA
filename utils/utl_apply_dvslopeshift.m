% value = utl_apply_dvslopeshift(mean, deviation, slope, epochNumber, maxEpoch, shift)
%
%       Applies the indicated slope, random deviation, and optional random
%       shift to a given (array of) value(s). Deviations are sampled
%       following a normal distribution with the indicated deviation being
%       the six-sigma range, capped to never exceed the indicated maximum.
%
% In:
%       mean - 1-by-n array of the value(s) to be adjusted
%       deviation - 1-by-n array of the maximum deviation(s)
%       slope - 1-by-n array of the slope(s)
%       epochNumber - the current epoch number
%       maxEpoch - the maximum number of epochs
%
% Optional:
%       shift - maximum value by which to shift all values
%
% Out:  
%       value - 1-by-n array of the adjusted value(s)
% 
%                    Copyright 2017, 2019 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2021-09-27 lrk
%   - updated documentation
% 2019-04-26 lrk
%   - Added shift parameter, now as utl_apply_dvslopeshift
% 2018-06-04 lrk
%   - Fixed actual deviation value to never exceed abs(deviation)
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

function value = utl_apply_dvslopeshift(mean, deviation, slope, epochNumber, maxEpoch, shift)

if nargin == 5, shift = 0; end

if numel(mean) > 1
    % in case more than one value is given, first recursively calling self
    % without shift
    for i = 1:numel(mean)
        value(i) = utl_apply_dvslopeshift(mean(i), deviation(i), slope(i), epochNumber, maxEpoch, 0);
    end
else
    % fixing applied deviation value between -/+ deviation
    dv = deviation / 3 * randn();
    if abs(dv) > deviation, dv = deviation * sign(dv); end
    
    % getting slope
    slope = slope * (epochNumber-1) / (maxEpoch-1);
    
    % applying; using nansum because slope can be NaN when maxEpoch = 1
    value = nansum([mean, dv, slope]);
end

if shift ~= 0
    % adding shift
    shiftvalue = shift / 3 * randn();
    if abs(shiftvalue) > shift, shiftvalue = shift * sign(shiftvalue); end
    value = value + shiftvalue;
end

end
