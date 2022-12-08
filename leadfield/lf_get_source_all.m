% sourceIdx = lf_get_source_all(leadfield, varargin)
%
%       Returns all source indices in the lead field, optionally
%       corresponding to the regions indicated using non-case-sensitive
%       regular expressions.
%
% In:
%       leadfield - the leadfield from which to get the random source
%
% Optional (key-value pairs):
%       region - cell containing strings and/or regex patterns representing
%                leadfield.atlas entries. not case sensitive. default: '.*'
%
% Out:
%       sourceIdx - the selected source index/indices
%
% Usage example:
%       >> lf = lf_generate_fromnyhead();
%       >> sourceIdx = lf_get_source_all(lf, 'region', {'Brain.*'});
%       >> plot_source_location(sourceIdx, lf);
% 
%                    Copyright 2021 Laurens R. Krol
%                    Neuroadaptive Human-Computer Interaction
%                    Brandenburg University of Technology

% 2022-11-30 lrk
%   - Escaped special characters when exact match found
%   - Improved efficiency for large atlases
% 2022-11-17 lrk
%   - Shortened name to lf_get_source_all
%   - Switched to inputParser with 'region' as optional parameter
% 2021-01-06 First version

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

function sourceIdx = lf_get_source_all(leadfield, varargin)

% parsing input
p = inputParser;

addRequired(p, 'leadfield', @isstruct);

addParameter(p, 'region', {'.*'}, @iscell);

parse(p, leadfield,varargin{:})

leadfield = p.Results.leadfield;
region = p.Results.region;

[allregions, ~, ~, ~] = lf_get_regions(leadfield);

idx = [];
for r = region
    if any(strcmp(r{1}, allregions))
        % since regions are assessed using regular expressions,
        % 'EyeRetina_Choroid_Sclera_left', for example, also matches
        % 'EyeRetina_Choroid_Sclera_leftright'; therefore, when an exact
        % match is detected, this is enforced. it can be circumvented by
        % using regex wildcards
        r{1} = regexprep(r{1}, '([\\\(\)\[\]\{\}\,\.\+\?\^\<\>\!\=])', '\\$1');
        r{1} = ['^' r{1} '$'];
        fprintf('Assuming exact match: %s\n', r{1});
    end
    
    idx = [idx, ~cellfun(@isempty, regexpi(leadfield.atlas, r{1}))];
end
sourceIdx = find(sum(idx, 2) > 0)';

end