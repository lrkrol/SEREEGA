% orientation = utl_get_orientation_pseudoperpendicular(sourceIdx, leadfield)
%
%       Returns a source orientation pointing outwards, i.e. away from the
%       origin at [0, 0, 0], toward the scalp.
%
%       Note that pointing away from the origin is usually not the same as 
%       being perpendicular to the scalp surface, but it is a quick and
%       dirty approximation.
%
% In:
%       sourceIdx - 1-by-n vector of source indices from the lead field
%       leadfield - the lead field from which the source comes
%
% Out:  
%       orientation - n-by-3 array of doubles each between -1 and 1
%
% Usage example:
%       >> lf = lf_generate_fromnyhead();
%       >> plot_source_projection(41000, lf, 'orientation', ...
%               utl_get_orientation_pseudoperpendicular(41000, lf));
%
%                    Copyright 2018 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2018-04-25 First version

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

function orientation = utl_get_orientation_pseudoperpendicular(sourceIdx, leadfield)

orientation = leadfield.pos(sourceIdx,:);

for i = 1:size(orientation, 1)
    orientation(i,:) = utl_normalise(orientation(i,:));
end

end
