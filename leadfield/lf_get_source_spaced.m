% [sourceIdx] = lf_get_source_spaced(leadfield, number, spacing, varargin)
%
%       Attempts to return a list of random source indices that are all at 
%       least an indicated distance away from each other.
%
%       Note: It may take multiple iterations to find a solution. It may
%       also not be possible at all; in that case, try reducing the spacing
%       or the number of sources.
%
% In:
%       leadfield - the leadfield from which to get the spaced sources
%       number - the number of sources to return
%       spacing - the minimum spacing between sources, in mm
%
% Optional (key-value pairs):
%       sourceIdx - source indices to be included in the final results. 
%                   these must not satisfy the spacing criterion among each
%                   other, but all randomly added sources will be at least
%                   the indicated distance away from these and each other.
%       region - cell containing strings and/or regex patterns representing
%                leadfield.atlas entries. not case sensitive. default: .*
%
% Out:
%       sourceIdx - 1-by-number array containing the source indices of the
%                   spaced sources
%
% Usage example:
%       >> lf = lf_generate_fromnyhead();
%       >> sourceIdx = lf_get_source_spaced(lf, 10, 50);
%       >> plot_source_location(sourceIdx, lf);
% 
%                    Copyright 2017, 2022 Laurens R. Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology
%                    Neuroadaptive Human-Computer Interaction
%                    Brandenburg University of Technology

% 2022-11-17 lrk
%   - Added optional 'region' argument
% 2017-08-01 lrk
%   - Added option to start with given source array
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

function [sourceIdx] = lf_get_source_spaced(leadfield, number, spacing, varargin)

% parsing input
p = inputParser;

addRequired(p, 'leadfield', @isstruct);
addRequired(p, 'number', @(x) isnumeric(x) && ~isempty(x));
addRequired(p, 'spacing', @(x) isnumeric(x) && ~isempty(x));

addParameter(p, 'sourceIdx', [], @isnumeric);
addParameter(p, 'region', {'.*'}, @iscell);

parse(p, leadfield, number, spacing, varargin{:})

leadfield = p.Results.leadfield;
number = p.Results.number;
spacing = p.Results.spacing;
initialSourceIdx = p.Results.sourceIdx;
region = p.Results.region;

if ~all(initialSourceIdx <= size(leadfield.pos, 1))
    warning('not all indicated sources are in the leadfield.');
    initialSourceIdx = initialSourceIdx(initialSourceIdx <= size(leadfield.pos, 1));
end

% getting selected region sources
regionIdx = lf_get_source_all(leadfield, 'region', region);

% starting search for resulting source indices
iteration = 1;
[sources, rndsource] = local_initialise_search(regionIdx, initialSourceIdx);
sourceIdx = initialSourceIdx;
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
        warning('could not find %d sources with %d mm spacing; re-randomising (%d)...', number, spacing, iteration);
        [sources, rndsource] = local_initialise_search(regionIdx, initialSourceIdx);
        iteration = iteration + 1;
    end
end

end


function [sources, rndsource] = local_initialise_search(regionIdx, initialSourceIdx)

% randomising all eligible sources
sources = regionIdx(randperm(numel(regionIdx)));

if isempty(initialSourceIdx)
    % starting with first random source, beginning search at second
    initialSourceIdx = sources(1);
    rndsource = 2;
else
    % moving given sources from source to the beginning of the list, then
    % beginning search at first random source
    idx = ismember(sources, initialSourceIdx);
    sources(idx) = [];
    sources = [initialSourceIdx, sources];
    rndsource = numel(initialSourceIdx) + 1;
end

end