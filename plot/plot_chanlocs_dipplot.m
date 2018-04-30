% h = plot_chanlocs_dipplot(leadfield, varargin)
%
%       Plots the location of the given sources using EEGLAB's dipplot
%       function. 
%
%       Note that there must be a reasonable fit with the used lead field's
%       head model and EEGLAB's standard head model for this plot to be
%       meaningful. Alternatively, use plot_headmodel to inspect the
%       electrode's positions.
%
% In:
%       leadfield - the leadfield from which to plot the sources
%
% Optional (key-value pairs):
%       newfig - (0|1) whether or not to open a new figure window.
%                default: 1. note: 'plain' mode always opens a new figure
%                window.
%       color - cell of color specifications, e.g. {'r', [0 1 0]}. source 
%               colors will rotate through the given colors if the number
%               given is less than the number of sources to plot. default
%               is white.
%       view - viewpoint specification in terms of azimuth and elevation,
%              as per MATLAB's view(), e.g.
%              [ 0, 90] = axial
%              [90,  0] = sagittal
%              [ 0,  0] = coronal (default: [90, 0]
%
% Out:  
%       h - handle of the generated figure
%
% Usage example:
%       >> lf = lf_generate_fromnyhead;
%       >> plot_chanlocs_dipplot(lf);
% 
%                    Copyright 2017, 2018 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2018-03-23 lrk
%   - Removed 'style' argument and renamed to plot_chanlocs_diplot;
%     plot_headmodel now covers this script's previous functionality
% 2018-02-06 lrk
%   - Added 'style' argument and plotchans3d call
% 2017-04-27 First version

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

function h = plot_chanlocs_dipplot(leadfield, varargin)

% parsing input
p = inputParser;

addRequired(p, 'leadfield', @isstruct);

addParameter(p, 'newfig', 1, @isnumeric);
addParameter(p, 'color', {}, @iscell);
addParameter(p, 'view', [90, 0], @isnumeric);

parse(p, leadfield, varargin{:})

lf = p.Results.leadfield;
newfig = p.Results.newfig;
color = p.Results.color;
viewpoint = p.Results.view;
    
if isempty(color)
    color = {[1 1 1]};
end

% getting location struct for call to dipplot
locs = struct();
for i = 1:length(lf.chanlocs)
    locs(i).posxyz = [-lf.chanlocs(i).Y, lf.chanlocs(i).X, lf.chanlocs(i).Z];
    locs(i).momxyz = [0 0 0];
    locs(i).rv = 0;
end

% calling dipplot
if newfig, h = figure('name', 'Channel locations', 'NumberTitle', 'off'); else h = NaN; end
dipplot(locs, 'coordformat', 'MNI', 'color', color, 'gui', 'off', 'dipolesize', 20, 'view', viewpoint);

end