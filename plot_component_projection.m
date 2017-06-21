% h = plot_component_projection(component, leadfield, varargin)
%
%       Plots the signal from a component without any deviations or slopes
%       applied. Due to the random nature of noise, it takes the mean of 10
%       such epochs before the signal is plotted.
%
% In:
%       component - 1x1 struct, the component variable
%       leadfield - the leadfield from which to plot the projection
%
% Optional (key-value pairs):
%       newfig - (0|1) whether or not to open a new figure window.
%                default: 1
%       colormap - the color map to use (default: jet)
%
% Out:  
%       h - handle of the generated figure
%
% Usage example:
%       >> lf = lf_generate_fromnyhead(); 
%       >> erp.peakLatency = 500; erp.peakWidth = 100; erp.amplitude = 1;
%       >> c.source = [1, 30000]; c.signal = {erp};
%       >> c = utl_check_component(c, lf);
%       >> plot_component_projection(c, lf);
% 
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

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

addParamValue(p, 'newfig', 1, @isnumeric);
addParamValue(p, 'colormap', jet(100), @isnumeric);

parse(p, component, leadfield, varargin{:})

leadfield = p.Results.leadfield;
component = p.Results.component;
newfig = p.Results.newfig;
cmap = p.Results.colormap;

% getting mean projection of all sources
meanproj = [];
for s = 1:length(component.source)
    meanproj(:,s) = lf_get_projection(component.source(s), leadfield, 'orientation', component.orientation(s,:));
    
end
meanproj = mean(meanproj,2);

if newfig, h = figure; else h = NaN; end
topoplot(meanproj, leadfield.chanlocs, 'colormap', cmap);

end
