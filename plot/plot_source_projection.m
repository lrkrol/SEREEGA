% h = plot_source_projection(sourceIdx, leadfield, varargin)
%
%       Plots the projection of the given source using EEGLAB's topoplot
%       for x, y, and z separately, plus using a given (or default)
%       orientation. Can also plot only the oriented projection.
%
% In:
%       sourceIdx - the index of the source in the leadfield to be plotted
%       leadfield - the leadfield from which to plot the source
%
% Optional (key-value pairs):
%       newfig - (0|1) whether or not to open a new figure window.
%                default: 1
%       orientation - 1-by-3 array of xyz source orientation. default uses
%                     the source's default orientation from the lead field.
%       orientedonly - (0|1) if true, only returns one plot of the given
%                      (or default) orientation, otherwise, plots four: one
%                      in each direction, plus the given (or default)
%                      orientation. default: 0
%       colormap - the color map to use (default: jet)
%
% Out:  
%       h - handle of the generated figure
%
% Usage example:
%       >> lf = lf_generate_fromnyhead;
%       >> plot_source_projection(lf, 1, 'colormap', bone(100))
% 
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2017-04-24 First version

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

function h = plot_source_projection(sourceIdx, leadfield, varargin)

% parsing input
p = inputParser;

addRequired(p, 'sourceIdx', @isnumeric);
addRequired(p, 'leadfield', @isstruct);

addParameter(p, 'newfig', 1, @isnumeric);
addParameter(p, 'orientation', [], @isnumeric);
addParameter(p, 'orientedonly', 0, @isnumeric);
addParameter(p, 'colormap', jet(100), @isnumeric);

parse(p, sourceIdx, leadfield, varargin{:})

sourceIdx = p.Results.sourceIdx;
lf = p.Results.leadfield;
newfig = p.Results.newfig;
orientation = p.Results.orientation;
orientedonly = p.Results.orientedonly;
cmap = p.Results.colormap;

if isempty(orientation)
    % getting default orientation
    orientation = lf.orientation(sourceIdx,:);
end

if newfig, h = figure; else h = NaN; end

if ~orientedonly
    % plotting three projections
    subplot(2,2,1); title('projection x'); 
    pos = get(gca, 'Position');
    set(gca, 'Position', [0, pos(2)-.05, .5, pos(4)+.05]);
    projection = lf_get_projection(sourceIdx, leadfield, 'orientation', repmat([1 0 0], numel(sourceIdx), 1));
    topoplot(projection, lf.chanlocs, 'colormap', cmap);
    
    subplot(2,2,2); title('projection y');
    pos = get(gca, 'Position');
    set(gca, 'Position', [.5, pos(2)-.05, .5, pos(4)+.05]);
    projection = lf_get_projection(sourceIdx, leadfield, 'orientation', repmat([0 1 0], numel(sourceIdx), 1));
    topoplot(projection, lf.chanlocs, 'colormap', cmap);
    
    subplot(2,2,3); title('projection z');
    pos = get(gca, 'Position');
    set(gca, 'Position', [0, pos(2)-.05, .5, pos(4)+.05]);
    projection = lf_get_projection(sourceIdx, leadfield, 'orientation', repmat([0 0 1], numel(sourceIdx), 1));
    topoplot(projection, lf.chanlocs, 'colormap', cmap);
    
    subplot(2,2,4);
    pos = get(gca, 'Position');
    set(gca, 'Position', [.5, pos(2)-.05, .5, pos(4)+.05]);
end

% getting oriented projection
projection = lf_get_projection(sourceIdx, leadfield, 'orientation', orientation);

meanorientation = mean(orientation, 1);
title(sprintf('orientation [%.2f, %.2f, %.2f] (n=%d)', meanorientation (1), meanorientation (2), meanorientation (3), numel(sourceIdx))); topoplot(projection, lf.chanlocs, 'colormap', cmap);

end