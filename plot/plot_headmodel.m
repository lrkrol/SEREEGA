% h = plot_headmodel(leadfield, varargin)
%
%       Plots both the sources and the electrodes from the given lead
%       field, illustrating the head model as a whole.
%
% In:
%       leadfield - the lead field to visualise
%
% Optional inputs (key-value pairs):
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
%
% Out:  
%       h - the handle of the generated figure
%
% Usage example:
%       >> lf = lf_generate_frompha('8to18', '2562');
%       >> plot_headmodel(lf, 'labels', 0, 'style', 'chull');
% 
%                    Copyright 2018 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

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

addParameter(p, 'labels', 1, @isnumeric);
addParameter(p, 'style', 'scatter', @ischar);
addParameter(p, 'shrink', 1, @isnumeric);
addParameter(p, 'view', [120 20], @isnumeric);

parse(p, leadfield, varargin{:})

leadfield = p.Results.leadfield;
labels = p.Results.labels;
style = p.Results.style;
shrink = p.Results.shrink;
viewpoint = p.Results.view;

% drawing figure
h = figure();
axis equal;
xlabel('X');
ylabel('Y');
zlabel('Z');
view(viewpoint);
hold;

% plotting brain
if strcmp(style, 'scatter')
    color = [ones(1, size(leadfield.pos, 1)); linspace(.3, .7, size(leadfield.pos,1)); linspace(.3, .7, size(leadfield.pos,1))]';
    color = color(randperm(length(color)),:);
    scatter3(leadfield.pos(:,1), leadfield.pos(:,2), leadfield.pos(:,3), 10, color, 'filled');
elseif strcmp(style, 'boundary')
    k = boundary(leadfield.pos(:,1), leadfield.pos(:,2), leadfield.pos(:,3), shrink);
    trisurf(k, leadfield.pos(:,1), leadfield.pos(:,2), leadfield.pos(:,3), 'FaceColor', [1 .75, .75], 'EdgeColor', 'none')
    light('Position',[1 1 1],'Style','infinite', 'Color', [1 .75 .75]);
    light('Position',[-1 -1 -1],'Style','infinite', 'Color', [.5 .25 .25]);
    material dull ;
end

% plotting electrodes
scatter3(-[leadfield.chanlocs.Y]', [leadfield.chanlocs.X]', [leadfield.chanlocs.Z]', 10, [.2 .2 .2], 'filled');
if labels, text(-[leadfield.chanlocs.Y]'+ 2.5, [leadfield.chanlocs.X]', [leadfield.chanlocs.Z]', {leadfield.chanlocs.labels}, 'Color', [.2 .2 .2], 'FontSize', 8); end

end
