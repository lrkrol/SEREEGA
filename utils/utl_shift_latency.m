% class = utl_shift_latency(class, shift)
%
%       Takes a valid class struct and shifts all of its latency parameters
%       by the indicated number.
%
%       For example, when called a shift of 200, all latencies will be set
%       to a value 200 higher than their current values.
%
% In:
%       class - 1x1 struct, the class variable
%       shift - number indicating the shift
%
% Out:  
%       class - class struct with updated latency fields
% 
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2017-11-09 First version

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

function class = utl_shift_latency(class, shift)

% parsing input
p = inputParser;

addRequired(p, 'class', @isstruct);
addRequired(p, 'shift', @isnumeric);

parse(p, class, shift);

class = p.Results.class;
shift = p.Results.shift;

% finding all class fields that end with 'Latency'
flds = fields(class);
for f = 1:length(flds)
    field = flds{f};
    if length(field) > 6 && strncmp(field(end-6:end), 'Latency', 7)
        class.(field) = class.(field) + shift;
    end
end

class = utl_check_class(class);

end