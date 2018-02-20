% class = utl_shift_source(sourceIdx, shift, leadfield)
%
%       Takes source indices and shifts their locations into the given 
%       direction(s), or shifts them to a random location within a given 
%       radius. It returns the indices of the shifted locations, taking the
%       lead field's constraints into account.
%
% In:
%       sourceIdx - 1-by-n array of source indices
%       shift - either a 1-by-3 array of [x y z] shifts, or a single number
%               indicating the radius of the shift
%       leadfield - leadfield structure
%
% Out:  
%       sourceIdx - indices of shifted sources
% 
%                    Copyright 2018 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2018-02-20 First version

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

function sourceIdx = utl_shift_source(sourceIdx, shift, leadfield)

% parsing input
p = inputParser;

addRequired(p, 'sourceIdx', @isnumeric);
addRequired(p, 'shift', @isnumeric);
addRequired(p, 'leadfield', @isstruct);

parse(p, sourceIdx, shift, leadfield);

sourceIdx = p.Results.sourceIdx;
shift = p.Results.shift;
leadfield = p.Results.leadfield;

if numel(shift) == 3
    % returning nearest source to shifted location
    for s = 1:numel(sourceIdx)
        sourceIdx(s) = lf_get_source_nearest(leadfield, leadfield.pos(sourceIdx(s), :) + shift);
    end
elseif numel(shift) == 1
    % returning random source in given radius
    for s = 1:numel(sourceIdx)
        sourceIdx(s) = utl_randsample(lf_get_source_inradius(leadfield, sourceIdx(s), shift), 1);
    end
end

end
