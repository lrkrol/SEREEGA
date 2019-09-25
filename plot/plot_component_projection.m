% h = plot_component_projection(component, leadfield, varargin)
%
%       Plots (a) component projection(s) onto the scalp.
%
% In:
%       component - struct containing the component variable(s).
%       leadfield - the leadfield from which to plot the projection
%
% Optional (key-value pairs):
%       newfig - (0|1) whether or not to open a new figure window.
%                default: 1
%       colormap - the color map to use (default: blue-red)
%
% Out:  
%       h - handle of the generated figure
%
% Usage example:
%       >> lf = lf_generate_fromnyhead(); 
%       >> sig = struct('type', 'noise', 'color', 'white', 'amplitude', 1);
%       >> src = lf_get_source_random(lf, 4);
%       >> comps = utl_create_component(src, sig, lf);
%       >> plot_component_projection(comps, lf);
%
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2019-09-25 lrk
%   - Fixed the function call to utl_multigradient
% 2019-04-30 lrk
%   - Changed default colormap
% 2017-08-10 lrk
%   - Added ability to plot multiple component projections in one figure
% 2017-06-19 First version

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

function h = plot_component_projection(component, leadfield, varargin)

% parsing input
p = inputParser;

addRequired(p, 'component', @isstruct);
addRequired(p, 'leadfield', @isstruct);

addParameter(p, 'newfig', 1, @isnumeric);
addParameter(p, 'colormap', utl_multigradient('preset', 'div.km.BuRd', 'length', 100), @isnumeric);

parse(p, component, leadfield, varargin{:})

leadfield = p.Results.leadfield;
component = p.Results.component;
newfig = p.Results.newfig;
cmap = p.Results.colormap;

if newfig, h = figure('name', 'Component projection', 'NumberTitle', 'off', 'ToolBar', 'none'); else h = NaN; end

if length(component) > 1
    % creating subplots
    ncols = ceil(sqrt(length(component)));
    nrows = ceil(length(component)/ncols);
    for c = 1:length(component)
        subplot(nrows, ncols, c);
        title(c);
        plot_component_projection(component(c), leadfield, 'colormap', cmap, 'newfig', 0);
    end
else
    % getting mean projection of all sources
    meanproj = [];
    for s = 1:length(component.source)
        meanproj(:,s) = lf_get_projection(leadfield, component.source(s), 'orientation', component.orientation(s,:));
    end
    meanproj = mean(meanproj,2);

    topoplot(meanproj, leadfield.chanlocs, 'colormap', cmap);
    camzoom(1.15);
end

end
