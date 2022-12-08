% h = plot_headmodel(leadfield, varargin)
%
%       Plots both the sources and the electrodes from the given lead
%       field, illustrating the model as a whole or selected regions. The
%       sources can be plotted either all individually as points in a
%       scatter plot, or as a 3D boundary estimated from these points.
%
% In:
%       leadfield - the lead field to visualise
%
% Optional inputs (key-value pairs):
%       newfig - (0|1) whether or not to open a new figure window.
%                default: 1
%       electrodes - whether or not to plot electrodes (0|1, default: 1)
%       labels - whether or not to plot electrode labels (0|1, default: 1)
%       style - 'scatter' plots all brain sources individually;
%               'boundary' plots the boundary surface of these sources
%               (default: 'scatter')
%       shrink - shrink factor for the boundary calculation, ranging from 0
%                (convex hull) to 1 (tighest boundaries). default: 1
%       view - viewpoint specification in terms of azimuth and elevation,
%              as per MATLAB's view(), e.g.
%              [ 0, 90] = axial
%              [90,  0] = sagittal
%              [ 0,  0] = coronal (default: [120, 20]
%       region - cell of strings representing leadfield.atlas entries
%                indicating which regions should be plotted. default {}
%                plots all sources.
%
% Out:  
%       h - the handle of the generated figure
%
% Usage example:
%       >> lf = lf_generate_fromnyhead();
%       >> plot_headmodel(lf, 'labels', 0, 'style', 'boundary');
% 
%                    Copyright 2018 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2022-12-06 lrk
%   - Changed length(color) to size(color,1) for when there's only 1 source
% 2022-12-02 lrk
%   - Added electrodes argument
% 2021-01-06 lrk
%   - Added newfig argument
%   - Added region argument
% 2018-03-23 First version

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

function h = plot_headmodel(leadfield, varargin)

% parsing input
p = inputParser;

addRequired(p, 'leadfield', @isstruct);

addParameter(p, 'newfig', 1, @isnumeric);
addParameter(p, 'electrodes', 1, @isnumeric);
addParameter(p, 'labels', 1, @isnumeric);
addParameter(p, 'style', 'scatter', @ischar);
addParameter(p, 'shrink', 1, @isnumeric);
addParameter(p, 'view', [120 20], @isnumeric);
addParameter(p, 'region', {}, @iscell);

parse(p, leadfield, varargin{:})

leadfield = p.Results.leadfield;
newfig = p.Results.newfig;
electrodes = p.Results.electrodes;
labels = p.Results.labels;
style = p.Results.style;
shrink = p.Results.shrink;
viewpoint = p.Results.view;
region = p.Results.region;

% drawing figure
if newfig
    h = figure('name', 'Head model', 'NumberTitle', 'off');
else
    h = NaN;
end
axis equal;
xlabel('X');
ylabel('Y');
zlabel('Z');
view(viewpoint);
hold;

% selecting sources based on atlas
regionIdx = 1:size(leadfield.pos, 1);
if ~isempty(region)
    if isfield(leadfield, 'atlas') && ~isempty(leadfield.atlas)
        idx = lf_get_source_all(leadfield, 'region', region);
        if any(idx)
            regionIdx = idx;
        else
            warning('indicated region(s) not found in the lead field''s atlas; plotting all sources');
        end
    else
        warning('no atlas information present in the lead field; plotting all sources');
    end
end

% plotting regions
if strcmp(style, 'scatter')
    color = [ones(1, numel(regionIdx)); linspace(.3, .7, numel(regionIdx)); linspace(.3, .7, numel(regionIdx))]';
    color = color(randperm(size(color, 1)),:);
    scatter3(leadfield.pos(regionIdx,1), leadfield.pos(regionIdx,2), leadfield.pos(regionIdx,3), 10, color, 'filled');
elseif strcmp(style, 'boundary')
    k = boundary(leadfield.pos(regionIdx,1), leadfield.pos(regionIdx,2), leadfield.pos(regionIdx,3), shrink);
    trisurf(k, leadfield.pos(regionIdx,1), leadfield.pos(regionIdx,2), leadfield.pos(regionIdx,3), 'FaceColor', [1 .75, .75], 'EdgeColor', 'none');
    light('Position',[1 1 1],'Style','infinite', 'Color', [1 .75 .75]);
    light('Position',[-1 -1 -1],'Style','infinite', 'Color', [.5 .25 .25]);
    material dull;
end

% plotting electrodes
if electrodes
    scatter3(-[leadfield.chanlocs.Y]', [leadfield.chanlocs.X]', [leadfield.chanlocs.Z]', 10, [.2 .2 .2], 'filled');
    if labels
        text(-[leadfield.chanlocs.Y]'+ 2.5, [leadfield.chanlocs.X]', [leadfield.chanlocs.Z]', {leadfield.chanlocs.labels}, 'Color', [.2 .2 .2], 'FontSize', 8);
    end
end

end
