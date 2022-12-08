% sourceIdx = lf_get_source_inradius(leadfield, centre, radius, varargin)
%
%       Returns the source(s) in the leadfield within a certain radius of
%       an indicated source or coordinate.
%
% In:
%       leadfield - the leadfield from which to get the sources
%       centre - 1-by-3 matrix of x, y, z coordinates or single source
%                index
%       radius - the radius in which to search, in mm
%
% Out:
%       sourceIdx - the source index/indices within the indicated area
%
% Usage example:
%       >> lf = lf_generate_fromnyhead();
%       >> sourceIdx = lf_get_source_inradius(lf, [0 0 0], 10);
%       >> plot_source_location(sourceIdx, lf);
% 
%                    Copyright 2017, 2022 Laurens R. Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology
%                    Neuroadaptive Human-Computer Interaction
%                    Brandenburg University of Technology

% 2022-11-17 lrk
%   - Switched to inpurParser to handle arguments
%   - Added optional 'region' argument
% 2017-04-27 First version

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

function sourceIdx = lf_get_source_inradius(leadfield, centre, radius, varargin)

% parsing input
p = inputParser;

addRequired(p, 'leadfield', @isstruct);
addRequired(p, 'centre', @isnumeric);
addRequired(p, 'radius', @isnumeric);

addParameter(p, 'region', {'.*'}, @iscell);

parse(p, leadfield, centre, radius, varargin{:})

leadfield = p.Results.leadfield;
centre = p.Results.centre;
radius = p.Results.radius;
region = p.Results.region;


regionIdx = lf_get_source_all(leadfield, 'region', region);

if numel(centre) == 1, centre = leadfield.pos(centre,:); end

sourceIdx = [];
for p = regionIdx
    if sqrt( ...
            (leadfield.pos(p,1) - centre(1))^2 + ...
            (leadfield.pos(p,2) - centre(2))^2 + ...
            (leadfield.pos(p,3) - centre(3))^2) <= radius
        sourceIdx = [sourceIdx, p];
    end
end

end