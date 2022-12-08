% sourceIdx = lf_get_source_middle(leadfield, region)
%
%       Returns the source nearest to either the average coordinates of all
%       sources in the the indicated region(s), or to the average of their
%       boundaries.       
%
%       Note that regardless of method, this may or may not be an actual
%       'middle'.
%
% In:
%       leadfield - the leadfield from which to get the source
%
% Optional (key-value pairs):
%       region - cell containing strings and/or regex patterns representing
%                leadfield.atlas entries. not case sensitive.
%       method - ('mean'|'minmax') indicating the method how to
%                calculate the 'middle'. 'average' takes the mean of all
%                coordinate. 'minmax' takes the mean of the minimum and
%                maximum values along each axis. default: average
%
% Out:
%       sourceIdx - the nearest-to-average source index
%
% Usage example:
%       >> lf = lf_generate_fromnyhead();
%       >> sourceIdx = lf_get_source_middle(lf, 'region', {'Brain.*'});
%       >> plot_source_location(sourceIdx, lf);
% 
%                    Copyright 2021 Laurens R. Krol
%                    Neuroadaptive Human-Computer Interaction
%                    Brandenburg University of Technology

% 2022-11-17 First version

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

function sourceIdx = lf_get_source_middle(leadfield, varargin)

% parsing input
p = inputParser;

addRequired(p, 'leadfield', @isstruct);

addParameter(p, 'region', {'.*'}, @iscell);
addParameter(p, 'method', 'average', @ischar);

parse(p, leadfield, varargin{:})

leadfield = p.Results.leadfield;
region = p.Results.region;
method = p.Results.method;

sourceIdx = lf_get_source_all(leadfield, 'region', region);

if numel(sourceIdx) < 3
    error('SEREEGA:lf_get_source_middle:error', 'no ''middle'' can be determined from < 3 sources');
end

if strcmp(method, 'average')
    sourceIdx = lf_get_source_nearest(leadfield, mean(leadfield.pos(sourceIdx, :)), 'region', region);
elseif strcmp(method, 'minmax')
    sourceIdx = lf_get_source_nearest(leadfield, mean([max(leadfield.pos(sourceIdx, :)); min(leadfield.pos(sourceIdx, :))]), 'region', region);
else
    error('SEREEGA:lf_get_source_middle:invalidFunctionArguments', 'unknown method ''%s''', method);
end

end
