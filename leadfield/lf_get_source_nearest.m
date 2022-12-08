% [sourceIdx, dist] = lf_get_source_nearest(leadfield, pos, varargin)
%
%       Returns the source in the leadfield nearest to the given position,
%       and its distance from that position. The returned source can
%       optionally be constrained to indicated region(s), using
%       non-case-sensitive regular expressions.
%
% In:
%       leadfield - the leadfield from which to get the source
%       pos - 1-by-3 matrix of x, y, z coordinates
%
% Optional (key-value pairs):
%       region - cell containing strings and/or regex patterns representing
%                leadfield.atlas entries. not case sensitive. default: .*
%
% Out:
%       sourceIdx - the nearest source index
%       dist - the distance of the found source to the indicated position
%
% Usage example:
%       >> lf = lf_generate_fromnyhead();
%       >> sourceIdx = lf_get_source_nearest(lf, [0 0 0]);
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

function [sourceIdx, dist] = lf_get_source_nearest(leadfield, pos, varargin)

% parsing input
p = inputParser;

addRequired(p, 'leadfield', @isstruct);
addRequired(p, 'pos', @isnumeric);

addParameter(p, 'region', {'.*'}, @iscell);

parse(p, leadfield, pos, varargin{:})

leadfield = p.Results.leadfield;
pos = p.Results.pos;
region = p.Results.region;

regionIdx = lf_get_source_all(leadfield, 'region', region);

distances = sqrt( ...
        (leadfield.pos(regionIdx,1) - pos(1)).^2 + ...
        (leadfield.pos(regionIdx,2) - pos(2)).^2 + ...
        (leadfield.pos(regionIdx,3) - pos(3)).^2);

[dist, i] = min(distances);
sourceIdx = regionIdx(i);

end