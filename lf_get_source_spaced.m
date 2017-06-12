% [sourceIdx] = lf_get_source_spaced(leadfield, number, spacing)
%
%       Attempts to returns a list of source indices that are all at least
%       an indicated distance away from each other.
%
%       Note: It may take multiple iterations to find a solution. It may
%       also not be possible at all; in that case, try reducing the spacing
%       or the number of sources.
%
% In:
%       leadfield - the leadfield from which to get the spaced sources
%       num - the number of sources to return
%       spacing - the minimum spacing in mm between sources
%
% Out:
%       sourceIdx - the source indices of the spaced sources
%
% Usage example:
%       >> lf = lf_generate_fromnyhead;
%       >> sourceIdx = lf_get_source_spaced(lf, 10, 50);
% 
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2017-06-12 First version

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

function [sourceIdx] = lf_get_source_spaced(leadfield, number, spacing)

% randomising sources
sources = randperm(size(leadfield.pos, 1));

% starting with one random source
sourceIdx = sources(1);

% running through remaining sources
rndsource = 2;
while numel(sourceIdx) < number
    % calculating distance of next source to previously selected sources
    distances = zeros(numel(sourceIdx), 1);
    for s = 1:numel(sourceIdx)
        distances(s) = sqrt( ...
                (leadfield.pos(sources(rndsource),1) - leadfield.pos(sourceIdx(s),1)).^2 + ...
                (leadfield.pos(sources(rndsource),2) - leadfield.pos(sourceIdx(s),2)).^2 + ...
                (leadfield.pos(sources(rndsource),3) - leadfield.pos(sourceIdx(s),3)).^2);
    end
    
    % adding source to list if it satisfies spacing requirement
    if ~(any(distances < spacing))
        sourceIdx = [sourceIdx, sources(rndsource)];
    end
    
    % examining next source
    rndsource = rndsource + 1;
    
    % starting again if all sources have been examined without having found
    % the required number of spaced sources
    if rndsource > numel(sources)
        warning('could not find %d sources with %d mm spacing; re-randomising...', number, spacing);
        sources = randperm(size(leadfield.pos, 1));
        sourceIdx = sources(1);
        rndsource = 2;
    end
end

end