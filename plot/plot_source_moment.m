% plot_source_moment(sourceIdx, leadfield, varargin)
%
%       Plots source orientations as arrows (dipolar moments), generally in
%       an existing plot, e.g. to be used after plot_headmodel.
%
% In:
%       sourceIdx - the index of the source in the leadfield to be plotted
%       leadfield - the leadfield from which to plot the source
%
% Optional (key-value pairs):
%       scale - numeric scaling value to scale the length of the arrow
%       orientation - n-by-3 array of xyz source orientation, n being the
%                     number of sources indicated at sourceIdx. default
%                     uses the source's default orientation from the lead
%                     field.
%       properties - quiver properties to adjust the drawing style.
%
% Usage example:
%       >> lf = lf_generate_fromnyhead;
%       >> rgn = {'Brain_Right_Temporal_Pole'};
%       >> plot_headmodel(lf, 'region', rgn, 'electrodes', 0);
%       >> plot_source_moment(lf_get_source_middle(lf, 'region', rgn), lf);
% 
%                    Copyright 2022 Laurens R. Krol
%                    Neuroadaptive Human-Computer Interaction
%                    Brandenburg University of Technology

% 2022-12-02 First version

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

function plot_source_moment(sourceIdx, leadfield, varargin)

% parsing input
p = inputParser;

addRequired(p, 'sourceIdx', @isnumeric);
addRequired(p, 'leadfield', @isstruct);

addParameter(p, 'scale', 50, @isnumeric);
addParameter(p, 'orientation', [], @isnumeric);
addParameter(p, 'properties', {'MaxHeadSize', 0.5, 'Color', 'k', 'LineWidth', 3, 'AutoScale', 'off'}, @iscell);

parse(p, sourceIdx, leadfield, varargin{:})

sourceIdx = p.Results.sourceIdx;
lf = p.Results.leadfield;
scale = p.Results.scale;
orientation = p.Results.orientation;
props = p.Results.properties;

if isempty(orientation)
    orientation = lf.orientation(sourceIdx,:);
end

% drawing quiver arrow(s)
quiver3( ...
        lf.pos(sourceIdx,1), ...
        lf.pos(sourceIdx,2), ...
        lf.pos(sourceIdx,3), ...
        orientation(:,1) * scale, ...
        orientation(:,2) * scale, ...
        orientation(:,3) * scale, ...
        props{:} ...
    );

end