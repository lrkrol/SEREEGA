% [sourceIdx, dist] = lf_get_source_nearest(leadfield, pos)
%
%       Returns the source in the leadfield nearest to the given position,
%       and its distance from that position.
%
% In:
%       leadfield - the leadfield from which to get the random source
%       pos - 1-by-3 matrix of x, y, z coordinates
%
% Out:
%       sourceIdx - the nearest source index
%       dist - the distance of the found source to the indicated position
%
% Usage example:
%       >> lf = lf_generate_fromnyhead;
%       >> sourceIdx = lf_get_source_nearest(lf, [0 0 0]);
% 
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

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

function [sourceIdx, dist] = lf_get_source_nearest(leadfield, pos)

distances = sqrt( ...
        (leadfield.pos(:,1) - pos(1)).^2 + ...
        (leadfield.pos(:,2) - pos(2)).^2 + ...
        (leadfield.pos(:,3) - pos(3)).^2);

[dist, sourceIdx] = min(distances);

end