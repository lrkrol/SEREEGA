% orientation = utl_get_orientation_pseudotangential(sourceIdx, leadfield)
%
%       Returns a source orientation perpendicular to the vector pointing
%       away from the origin at [0, 0, 0]. That is, it returns a random
%       vector from the plane that is perpendicular to the vector pointing
%       outward toward the scalp.
%
%       Note that this is usually not the same as a vector parallel or 
%       tangential to the scalp surface, as the vector pointing away from
%       the origin is usually not perpendicular to the scalp surface, but
%       it is a quick and dirty approximation.
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
%       >> plot_source_projection(100, lf, 'orientation', ...
%               utl_get_orientation_pseudotangential(100, lf));
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

function orientation = utl_get_orientation_pseudotangential(sourceIdx, leadfield)

outward = utl_get_orientation_pseudoperpendicular(sourceIdx, leadfield);

orientation = nan(size(outward));
for i = 1:size(outward, 1)
    basis = null(outward(i,:));
    orientation(i,:) = utl_normalise(basis * randn(1,2)');
end

end
