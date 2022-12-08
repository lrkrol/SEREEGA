% sourceIdx = lf_get_source_random(leadfield[, number])
%
%       Returns (a) random source index/indices, optionally constrained to
%       indicated regions.
%
% In:
%       leadfield - the leadfield from which to get the random source
%
% Optional (key-value pairs):
%       number - number of sources to return. default: 1
%       region - cell containing strings and/or regex patterns representing
%                leadfield.atlas entries. not case sensitive. default: .*
%
% Out:
%       sourceIdx - the random source index/indices
%
% Usage example:
%       >> lf = lf_generate_fromnyhead();
%       >> sourceIdx = lf_get_source_random(lf, 'number', 5);
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

function sourceIdx = lf_get_source_random(leadfield, varargin)

    
if ~isempty(varargin) && isnumeric(varargin{1})
    
    % maintaining backwards compatibility with SEREEGA <= v1.2.2, where
    % 'number' was a simple optional argument and could be called as e.g.
    % lf_get_source_random(leadfield, 5)

    sourceIdx = lf_get_source_random(leadfield, 'number', varargin{:});
    
else

    % parsing input
    p = inputParser;

    addRequired(p, 'leadfield', @isstruct);

    addParameter(p, 'number', 1, @isnumeric);
    addParameter(p, 'region', {'.*'}, @iscell);

    parse(p, leadfield, varargin{:})

    leadfield = p.Results.leadfield;
    number = p.Results.number;
    region = p.Results.region;

    regionIdx = lf_get_source_all(leadfield, 'region', region);

    sourceIdx = regionIdx(randperm(numel(regionIdx)));
    sourceIdx = sourceIdx(1:number);

end
    
end