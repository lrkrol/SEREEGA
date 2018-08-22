% projection = lf_get_projection(leadfield, sourceIdx, varargin)
%
%       Returns the (oriented) projection matrix of (a) given source(s) in
%       the given leadfield, using the optionally given orientation and 
%       normalisation arguments.
%
% In:
%       leadfield - the leadfield from which to obtain the projection
%       sourceIdx - single source index or array of source indices from the 
%                   leadfield. in case of an array, the mean projection of
%                   all sources will be returned.
%
% Optional (key-value pairs):
%       orientation - numel(sourceIdx)-by-3 matrix of [x, y, z] 
%                     orientations of the source(s) to use; when multiple
%                     sources are indicated by only one orientation, this
%                     orientation will be applied to all sources
%       normaliseLeadfield - 1|0, whether or not to normalise the
%                            leadfields before  projecting the signal to
%                            have the most extreme value be either 1 or -1,
%                            depending on its sign. default: 0
%       normaliseOrientation - 1|0, as above, except for orientation
%
% Out:
%       projection - channels x 1 array representing the projection
%
% Usage example:
%       >> lf = lf_generate_fromnyhead();
%       >> projection = lf_get_projection(lf, 1, 'orientation', [1 1 0])
% 
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2018-08-22 cp/lrk
%   - Single orientation can now be indicated to apply to multiple sources
%     (GitHub issue #3)
% 2018-03-23 lrk
%   - Changed argument order for consistency
% 2017-10-26 lrk
%   - Fixed issue where the wrong orientation was passed in recursive mode
% 2017-10-19 lrk
%   - Fixed issue where only the oriented projection was returned when
%     multiple sources were given
% 2017-08-03 lrk
%   - Switched normalisation defaults to 0
%   - Added possibility to pass multiple source indices
% 2017-06-20 First version

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

function projection = lf_get_projection(leadfield, sourceIdx, varargin)

% parsing input
p = inputParser;

addRequired(p, 'leadfield', @isstruct);
addRequired(p, 'sourceIdx', @isnumeric);

addParameter(p, 'orientation', [], @isnumeric);
addParameter(p, 'normaliseLeadfield', 0, @isnumeric);
addParameter(p, 'normaliseOrientation', 0, @isnumeric);

parse(p, leadfield, sourceIdx, varargin{:})

leadfield = p.Results.leadfield;
sourceIdx = p.Results.sourceIdx;
orientation = p.Results.orientation;
normaliseLeadfield = p.Results.normaliseLeadfield;
normaliseOrientation = p.Results.normaliseOrientation;

if isempty(orientation)
    orientation = leadfield.orientation(sourceIdx,:);
end

if numel(sourceIdx) > 1
    % if only one orientation indicated, applying this to all sources
    if size(orientation, 1) == 1
        warning('Only one orientation indicated for %d sources; applying that same orientation to all sources', numel(sourceIdx));
        orientation = repmat(orientation, [numel(sourceIdx), 1]);
    end
    
    % iteratively calling this script, returning mean projection
    for s = 1:numel(sourceIdx)
        projection(s,:) = lf_get_projection(leadfield, sourceIdx(s), 'orientation', orientation(s,:), 'normaliseLeadfield', normaliseLeadfield, 'normaliseOrientation', normaliseOrientation);
    end
    projection = mean(projection, 1);
else
    % getting leadfield
    leadfield = squeeze(leadfield.leadfield(:,sourceIdx,:));

    if normaliseLeadfield
        % normalising to have the maximum (or minimum) value be 1 (or -1)
        leadfield = utl_normalise(leadfield);
    end

    if normaliseOrientation
        % normalising to have the maximum (or minimum) value be 1 (or -1)
        orientation = utl_normalise(orientation);
    end

    % getting oriented projection
    projection = [];
    projection(:,1) = leadfield(:,1) * orientation(1);
    projection(:,2) = leadfield(:,2) * orientation(2);
    projection(:,3) = leadfield(:,3) * orientation(3);
    projection = sum(projection, 2);
end

end