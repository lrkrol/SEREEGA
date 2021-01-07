% h = plot_source_location_dipplot(sourceIdx, leadfield, varargin)
%
%       Plots the location of the given sources using EEGLAB's dipplot
%       function.
%
%       Note that there must be a reasonable fit with the used lead field's
%       head model and EEGLAB's standard head model for this plot to be
%       meaningful. You can test this by plotting e.g. a larger number of
%       sources and seeing whether or not their boundaries conform to those
%       in the backdrop's MRI image. Alternatively, use
%       plot_source_location.
%
% In:
%       sourceIdx - 1-by-n array containing the index/indices of the 
%                   source(s) in the leadfield to be plotted
%       leadfield - the leadfield from which to plot the sources
%
% Optional (key-value pairs):
%       newfig - (0|1) whether or not to open a new figure window.
%                default: 1
%       color - cell of color specifications, e.g. {'r', [0 1 0]}. source 
%               colors will rotate through the given colors if the number
%               given is less than the number of sources to plot. default
%               is a pinkish color that varies slightly across sources.
%       view - viewpoint specification in terms of azimuth and elevation,
%              as per MATLAB's view(), e.g.
%              [ 0, 90] = axial
%              [90,  0] = sagittal
%              [ 0,  0] = coronal (default: [90, 0]
%       projlines - (0|1) whether or not to plot lines connecting to the 2D
%                   projection. default: 0
%       allviews - (0|1), whether or not to plot all three primary views in
%                  one figure. if true, ignores 'view' and 'newfig'; opens
%                  a new window with coronal, sagittal, and axial views
%                  next to each other. default: 0
%
% Out:  
%       h - handle of the generated figure
%
% Usage example:
%       >> lf = lf_generate_fromnyhead;
%       >> plot_source_location_dipplot(1:25:size(lf.leadfield, 2), lf);
% 
%                    Copyright 2017, 2018 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2018-03-23 lrk
%   - Renamed to plot_source_location_dipplot in favour of new
%     plot_source_location script
% 2018-02-20 lrk
%   - Added allviews argument
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

function h = plot_source_location_dipplot(sourceIdx, leadfield, varargin)

% parsing input
p = inputParser;

addRequired(p, 'sourceIdx', @isnumeric);
addRequired(p, 'leadfield', @isstruct);

addParameter(p, 'newfig', 1, @isnumeric);
addParameter(p, 'color', {}, @iscell);
addParameter(p, 'view', [90, 0], @isnumeric);
addParameter(p, 'projlines', 0, @isnumeric);
addParameter(p, 'allviews', 0, @isnumeric);

parse(p, sourceIdx, leadfield, varargin{:})

lf = p.Results.leadfield;
sourceIdx = p.Results.sourceIdx;
newfig = p.Results.newfig;
color = p.Results.color;
view = p.Results.view;
if p.Results.projlines == 1, projlines = 'on';
else, projlines = 'off'; end
allviews = p.Results.allviews;

if allviews
    % organising figure, calling self three times
    h = figure('name', 'Source location', 'NumberTitle', 'off');

    subplot(1,3,1);
    plot_source_location_dipplot(sourceIdx, lf, 'newfig', 0, 'view', [0 0]);
    pos = get(gca, 'Position');
    set(gca, 'Position', [0, pos(2), 1/3.5, pos(4)]);

    subplot(1,3,3);
    plot_source_location_dipplot(sourceIdx, lf, 'newfig', 0, 'view', [90 90]);
    pos = get(gca, 'Position');
    set(gca, 'Position', [2/3, pos(2), 1/3.5, pos(4)]);

    subplot(1,3,2);
    plot_source_location_dipplot(sourceIdx, lf, 'newfig', 0);
    pos = get(gca, 'Position');
    set(gca, 'Position', [1/3, pos(2), 1/3.5, pos(4)]);

    pos = get(h, 'Position');
    set(h, 'Position', pos .* [1 1 2 1], 'InvertHardcopy', 'off', 'Color', [0 0 0]);
else
    if isempty(color)
        % setting default, somewhat varying "brainy" colours
        for i = .5:.025:.9, color = [color, {[1, i, i]}]; end
        color = color([1, 1+randperm(length(color)-1)]);
    end

    % getting location struct for call to dipplot
    locs = struct();
    for i = sourceIdx
        locs(i).posxyz = lf.pos(i,:);
        locs(i).momxyz = [0 0 0];
        locs(i).rv = 0;
    end

    % calling dipplot
    if newfig, h = figure('name', 'Source location', 'NumberTitle', 'off'); else h = NaN; end
    dipplot(locs, 'coordformat', 'MNI', 'color', color, 'gui', 'off', 'dipolesize', 20, 'view', view, 'projlines', projlines);
end

end