% class = utl_shift_latency(classorcomp, shift)
%
%       Takes a class or component struct and shifts all of its 
%       latency parameters by the indicated number.
%
%       For example, when called with a shift of 200, all latencies will be
%       set to a value 200 higher than their current values.
%
% In:
%       classorcomp - 1-by-n struct, the class or component variable
%       shift - number indicating the shift
%
% Out:  
%       class - class struct with updated latency fields
% 
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2019-03-25 lrk
%   - Fixed bug in first argument name
% 2017-12-01 lrk
%   - Function now also accepts components
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

function classorcomp = utl_shift_latency(classorcomp, shift)

% parsing input
p = inputParser;

addRequired(p, 'classorcomp', @isstruct);
addRequired(p, 'shift', @isnumeric);

parse(p, classorcomp, shift);

classorcomp = p.Results.classorcomp;
shift = p.Results.shift;

if utl_iscomponent(classorcomp)
    if numel(classorcomp) > 1
        % recursively calling self
        for c = 1:numel(classorcomp)
            classorcomp(c) = utl_shift_latency(classorcomp(c), shift);
        end
    else
        % calling self on all signal activation classes
        for s = 1:numel(classorcomp.signal)
            classorcomp.signal{s} = utl_shift_latency(classorcomp.signal{s}, shift);
        end
    end
else
    % finding all class fields that end with 'Latency'
    flds = fields(classorcomp);
    for f = 1:length(flds)
        field = flds{f};
        if length(field) > 6 && strncmp(field(end-6:end), 'Latency', 7)
            classorcomp.(field) = classorcomp.(field) + shift;
        end
    end
    
    classorcomp = utl_check_class(classorcomp);
end


end