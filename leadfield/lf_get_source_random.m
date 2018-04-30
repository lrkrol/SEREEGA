% sourceIdx = lf_get_source_random(leadfield[, number])
%
%       Returns (a) random source index/indices.
%
% In:
%       leadfield - the leadfield from which to get the random source
%
% Optional:
%       number - number of sources to return. default: 1
%
% Out:
%       sourceIdx - the random source index/indices
%
% Usage example:
%       >> lf = lf_generate_fromnyhead();
%       >> sourceIdx = lf_get_source_random(lf, 5);
%       >> plot_source_location(sourceIdx, lf);
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

function sourceIdx = lf_get_source_random(leadfield, num)

if ~exist('num', 'var'), num = 1; end

sourceIdx = randperm(size(leadfield.leadfield, 2));
sourceIdx = sourceIdx(1:num);

end