% [h, hsxz, hsyz, hsxy] = plot_source_location(sourceIdx, leadfield, varargin)
%
%       Plots the location of the given source(s) using an estimate of the
%       lead field's brain's boundaries. 
%
%       The accuracy of this estimate depends primarily on the resolution
%       of the lead field, i.e., the number of sources present in it. Use
%       the 'shrink' argument to vary the estimate's edge sensitivity.
%
% In:
%       sourceIdx - 1-by-n array containing the index/indices of the 
%                   source(s) in the leadfield to be plotted
%       leadfield - the leadfield from which to plot the sources
%
% Optional (key-value pairs):
%       newfig - (0|1) whether or not to open a newfigure window.
%                default: 1
%       shrink - shrink factor for the boundary calculation, ranging from 0
%                (convex hull) to 1 (tightest boundaries). default: .5
%       mode - '2d' plots coronal, sagittal, and axial views of the brain;
%              '3d' plots a 3D view (default: '2d')
%       view - viewpoint specification in terms of azimuth and elevation,
%              as per MATLAB's view(), for te 3d mode. e.g.
%              [ 0, 90] = axial
%              [90,  0] = sagittal
%              [ 0,  0] = coronal (default: [120, 20]
%       region - cell of strings representing leadfield.atlas entries
%                indicating which regions should be plotted to provide
%                context. default {} plots all sources.
%
% Out:  
%       h - handle of the generated figure
%       hsxz - handle of the source locations plot in the x/z plane
%       hsyz - handle of the source locations plot in the y/z plane
%       hsxy - handle of the source locations plot in the x/y plane
%
% Usage example:
%       >> lf = lf_generate_fromnyhead;
%       >> plot_source_location(1000, lf, 'mode', '3d');
% 
%                    Copyright 2018 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2021-01-07 lrk
%   - Added region argument
% 2018-10-04 lrk
%   - Put the toolbar back in 3d mode
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

function [h, hsxz, hsyz, hsxy] = plot_source_location(sourceIdx, leadfield, varargin)

% parsing input
p = inputParser;

addRequired(p, 'sourceIdx', @isnumeric);
addRequired(p, 'leadfield', @isstruct);

addParameter(p, 'newfig', 1, @isnumeric);
addParameter(p, 'shrink', .5, @isnumeric);
addParameter(p, 'mode', '2d', @ischar);
addParameter(p, 'view', [120, 20], @isnumeric);
addParameter(p, 'region', {}, @iscell);

parse(p, sourceIdx, leadfield, varargin{:})

leadfield = p.Results.leadfield;
sourceIdx = p.Results.sourceIdx;
newfig = p.Results.newfig;
shrink = p.Results.shrink;
mode = p.Results.mode;
viewpoint = p.Results.view;
region = p.Results.region;

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

braincolour = [.85 .85 .85];
sourcecolour = [ones(numel(sourceIdx),1), linspace(.6, .3, numel(sourceIdx))', linspace(.6, .3, numel(sourceIdx))'];
sourcecolour = sourcecolour(randperm(numel(sourceIdx)), :);
markersize = 35;

if strcmp(mode, '3d')
    if newfig, h = figure('name', 'Source location', 'NumberTitle', 'off'); end
    hold on;
    k = boundary(leadfield.pos(regionIdx,1), leadfield.pos(regionIdx,2), leadfield.pos(regionIdx,3), shrink);
    s = trisurf(k, leadfield.pos(regionIdx,1), leadfield.pos(regionIdx,2), leadfield.pos(regionIdx,3), 'FaceColor', [1 .75, .75], 'EdgeColor', 'none');
    light('Position',[1 1 1],'Style','infinite', 'Color', braincolour);
    light('Position',[-1 -1 -1],'Style','infinite', 'Color', [.5 .25 .25]);
    scatter3(leadfield.pos(sourceIdx,1), leadfield.pos(sourceIdx,2), leadfield.pos(sourceIdx,3), markersize, sourcecolour, 'fill');
    material dull;
    xlabel('X'); ylabel('Y'); zlabel('Z');
    axis equal;
    alpha(s, .25);
    view(viewpoint);
elseif strcmp(mode, '2d')
    if newfig, h = figure('name', 'Source location', 'NumberTitle', 'off', 'ToolBar', 'none'); end
    
    xmin = min(leadfield.pos([regionIdx, sourceIdx],1));
    xmax = max(leadfield.pos([regionIdx, sourceIdx],1));
    ymin = min(leadfield.pos([regionIdx, sourceIdx],2));
    ymax = max(leadfield.pos([regionIdx, sourceIdx],2));
    zmin = min(leadfield.pos([regionIdx, sourceIdx],3));
    zmax = max(leadfield.pos([regionIdx, sourceIdx],3));

    % coronal view
    subplot(1,3,1);
    pos = get(gca, 'Position');
    set(gca, 'Position', [0, pos(2), 1/3, pos(4)]);
    hold on;
    xz = [leadfield.pos(regionIdx,1), leadfield.pos(regionIdx,3)];
    k = boundary(xz, shrink);
    fill(xz(k,1), xz(k,2), braincolour, 'EdgeColor', 'none');    
    hsxz = scatter(leadfield.pos(sourceIdx, 1), leadfield.pos(sourceIdx, 3), markersize, sourcecolour, 'fill');
    xlabel('X'); ylabel('Z');
    xlim([xmin xmax]);
    ylim([zmin zmax]);
    daspect([1 1 1]);

    % sagittal view
    subplot(1,3,2);
    pos = get(gca, 'Position');
    set(gca, 'Position', [1/2.9, pos(2), 1/3, pos(4)]);
    hold on;
    yz = [leadfield.pos(regionIdx,2), leadfield.pos(regionIdx,3)];
    k = boundary(yz, shrink);
    fill(yz(k,1), yz(k,2), braincolour, 'EdgeColor', 'none');
    hsyz = scatter(leadfield.pos(sourceIdx, 2), leadfield.pos(sourceIdx, 3), markersize, sourcecolour, 'fill');
    xlabel('Y'); ylabel('Z');
    xlim([ymin ymax]);
    ylim([zmin zmax]);
    daspect([1 1 1]);

    % axial view
    subplot(1,3,3);
    pos = get(gca, 'Position');
    set(gca, 'Position', [2/3, pos(2), 1/3, pos(4)]);
    hold on;
    xy = [leadfield.pos(regionIdx,1), leadfield.pos(regionIdx,2)];
    k = boundary(xy, shrink);
    fill(xy(k,1), xy(k,2), braincolour, 'EdgeColor', 'none');
    hsxy = scatter(leadfield.pos(sourceIdx, 1), leadfield.pos(sourceIdx, 2), markersize, sourcecolour, 'fill');
    xlabel('X'); ylabel('Y');
    xlim([xmin xmax]);
    ylim([ymin ymax]);
    daspect([1 1 1]);

    % resizing figure to make the three views fit properly
    pos = get(h, 'Position');
    set(h, 'Position', pos .* [1/2 1 2.5 1]);
end

end