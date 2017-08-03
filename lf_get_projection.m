% projection = lf_get_projection(sourceIdx, leadfield, varargin)
%
%       Returns the (mean) projection matrix of (a) given source(s) in the 
%       given leadfield, using the optionally given orientation and 
%       normalisation arguments.
%
% In:
%       sourceIdx - single source index or array of source indices from the 
%                   leadfield. in case of an array, the mean projection of
%                   all sources will be returned.
%       leadfield - the leadfield from which to obtain the projection
%
% Optional (key-value pairs):
%       orientation - [x, y, z] orientation of the source to use
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
%       >> lf = lf_generate_fromnyhead;
%       >> projection = lf_get_projection(1, lf, 'orientation', [1 1 0]);
% 
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

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

function projection = lf_get_projection(sourceIdx, leadfield, varargin)

% parsing input
p = inputParser;

addRequired(p, 'sourceIdx', @isnumeric);
addRequired(p, 'leadfield', @isstruct);

addParamValue(p, 'orientation', [], @isnumeric);
addParamValue(p, 'normaliseLeadfield', 0, @isnumeric);
addParamValue(p, 'normaliseOrientation', 0, @isnumeric);

parse(p, sourceIdx, leadfield, varargin{:})

leadfield = p.Results.leadfield;
sourceIdx = p.Results.sourceIdx;
orientation = p.Results.orientation;
normaliseLeadfield = p.Results.normaliseLeadfield;
normaliseOrientation = p.Results.normaliseOrientation;

if isempty(orientation)
    orientation = leadfield.orientation(sourceIdx,:);
end

if numel(sourceIdx) > 1
    % iteratively calling this script, returning mean projection
    for s = 1:numel(sourceIdx)
        projection(s,:) = lf_get_projection(sourceIdx(s), leadfield);
    end
    projection = mean(projection, 1);
else
    % getting leadfield
    leadfield = squeeze(leadfield.leadfield(:,sourceIdx,:));

    if normaliseLeadfield
        % normalising to have the maximum (or minimum) value be 1 (or -1)
        [~, i] = max(abs(leadfield(:)));
        leadfield = leadfield .* (sign(leadfield(i)) / leadfield(i));
    end

    if normaliseOrientation
        % normalising to have the maximum (or minimum) value be 1 (or -1)
        [~, i] = max(abs(orientation(:)));
        orientation = orientation .* (sign(orientation(i)) / orientation(i));
    end

    % getting oriented projection
    projection = [];
    projection(:,1) = leadfield(:,1) * orientation(1);
    projection(:,2) = leadfield(:,2) * orientation(2);
    projection(:,3) = leadfield(:,3) * orientation(3);
    projection = mean(projection, 2);
end

end