% [allregions, numall, generic, numgeneric] = lf_get_regions(leadfield)
%
%       Returns a cell of generic region categories present in the given
%       leadfield's atlas, as well as a list of all unique regions. 
%
% In:
%       leadfield - the leadfield from which to get the regions
%
% Out:
%       allregions - cell of strings listing all unique regions present in
%                    the atlas
%       numall - numeric list indicating how many sources are present in
%                each of the regions in the allregions list
%       generic - cell of strings indicating generic region categories that
%                 are present in the atlas. currently recognised are:
%                 - brain
%                 - muscle
%                 - eye
%       numgeneric - numeric list indicating how many sources are present
%                    in each of the generic region categories
%
% Usage example:
%       >> lf = lf_generate_fromnyhead();
%       >> generic = lf_get_regions_fromatlas(lf);
% 
%                    Copyright 2021 Laurens R. Krol
%                    Neuroadaptive Human-Computer Interaction
%                    Brandenburg University of Technology

% 2022-11-25 lrk
%   - Renamed from utl_get_regions_fromatlas to lf_get_regions
% 2022-11-18 lrk
%   - Changed output order
% 2021-09-07 lrk
%   - Improved efficiency for large cell arrays
% 2021-01-07 First version

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

function [allregions, numall, generic, numgeneric] = lf_get_regions(leadfield)

% getting all unique regions
[allregions, ~, ic] = unique(leadfield.atlas);
allregions = allregions';
numall = histcounts(ic, numel(allregions));

% looking for recognised region categories
cats = {'brain', 'eye', 'muscle'};

generic = {};
numgeneric = [];
for c = cats
    % finding any generic regions in list of unique regions    
    idx = cellfun(@(x) ~isempty(x), regexpi(allregions, ['^' c{1} '.*'], 'once'));
    if any(idx)
        % counting all sources in generic regions
        generic = [generic, c];
        numgeneric = [numgeneric, sum(~cellfun(@isempty, regexpi(leadfield.atlas, ['^' c{1} '.*'], 'once')))];
    end
end

end