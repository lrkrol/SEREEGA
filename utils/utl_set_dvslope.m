% class = utl_set_dvslope(class, varargin)
%
%       Takes a valid class struct and sets all of its deviation and/or 
%       slope fields to a value relative to the respective base values.
%
%       For example, when called with 'dv' .2, all deviations will be set
%       to .2 of their base values. An ERP class with a peakLatency of 200
%       will thus be given a peakLatencyDv of 40, etc.
%
% In:
%       class - 1x1 struct, the class variable
%
% Optional (key-value pairs):
%       dv - the deviation value, relative to its base value. default []
%            does not change deviation values.
%       slope - the slope value, relative to its base value. default []
%               does not change slope values.
%       overwrite - (1|0) whether or not to overwrite nonzero dv/slope
%                   values. default: 1
%
% Out:  
%       class - class struct with updated dv/slope fields
% 
%                    Copyright 2017, 2018 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2018-02-13 lrk
%   - Added overwrite argument
% 2017-11-03 First version

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

function class = utl_set_dvslope(class, varargin)

% parsing input
p = inputParser;

addRequired(p, 'class', @isstruct);

addParameter(p, 'dv', [], @isnumeric);
addParameter(p, 'slope', [], @isnumeric);
addParameter(p, 'overwrite', 1, @isnumeric);

parse(p, class, varargin{:})

class = p.Results.class;
dv = p.Results.dv;
slope = p.Results.slope;
overwrite = p.Results.overwrite;

% finding all class fields that end with 'Dv' or 'Slope'
flds = fields(class);
for f = 1:length(flds)
    field = flds{f};
    if length(field) > 2 && strncmp(field(end-1:end), 'Dv', 2)
        if ~isempty(dv)
            if ~(~overwrite & class.(field)) %#ok<AND2>
                % setting Dv field to new value relative to base value
                baseField = field(1:end-2);
                baseValue = class.(baseField);
                class.(field) = baseValue .* dv;
            end
        end
    elseif length(field) > 5 && strncmp(field(end-4:end), 'Slope', 5)
        if ~isempty(slope)
            if ~(~overwrite & class.(field)) %#ok<AND2>
                % setting Slope field to new value relative to base value
                baseField = field(1:end-5);
                baseValue = class.(baseField);
                class.(field) = baseValue .* slope;
            end
        end
    end
end

class = utl_check_class(class);

end