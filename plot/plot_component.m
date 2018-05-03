% h = plot_component(component, epochs, leadfield)
%
%       Plots the mean projection and signal from all given components.
%
% In:
%       component - 1xn struct, the component variables
%       epochs - single epoch configuration struct containing at least
%                sampling rate in Hz (field name 'srate'), epoch length in ms
%                 ('length'), and the total number of epochs ('n')
%       leadfield - the leadfield from which to plot the projection
%
% Out:  
%       h - handle of the generated figure
%
% Usage example:
%       >> lf = lf_generate_fromnyhead(); 
%       >> epochs = struct('n', 100, 'srate', 1000, 'length', 1000);
%       >> sig = struct('type', 'noise', 'color', 'white', 'amplitude', 1);
%       >> src = lf_get_source_random(lf, 4);
%       >> comps = utl_create_component(src, sig, lf);
%       >> plot_component(comps, epochs, lf);
% 
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

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

function h = plot_component(component, epochs, leadfield)

ncomponents = numel(component);

if ncomponents > 10, nrows = 10; else, nrows = ncomponents; end

h = figure('name', 'Components', 'NumberTitle', 'off', 'ToolBar', 'none');
j = 0;
for i = 1:ncomponents
    % component projection, 1 column
    subplot(nrows,3,(i-j-1)*3+1);
    plot_component_projection(component(i), leadfield, 'newfig', 0);

    % component signal, 2 columns
    subplot(nrows,3,(i-j-1)*3+[2 3]);
    plot_component_signal(component(i), epochs, 'newfig', 0);
    
    if mod(i, 10) == 0 && i ~= ncomponents
        % opening new figure
        h(end+1) = figure;
        j = j + 10;
    end
end

end