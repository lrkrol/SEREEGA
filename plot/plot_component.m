% h = plot_component(component, epochs, leadfield)
%
%       Plots the mean projection and signal from all given components.
%
% In:
%       component - 1xn struct, the component variables
%       epochs - single epoch configuration struct containing at least
%                sampling rate (srate), epoch length (length), and total
%                number of epochs (n)
%       leadfield - the leadfield from which to plot the projection
%
% Out:  
%       h - handle of the generated figure
%
% Usage example:
%       >> lf = lf_generate_fromnyhead(); 
%       >> epochs.srate = 1000; epochs.length = 1000; epochs.n = 100;
%       >> erp.peakLatency = 500; erp.peakWidth = 100; erp.amplitude = 1;
%       >> noise.color = 'brown'; noise.amplitude = .5;
%       >> c(1).source = 1; c(1).signal = {erp};
%       >> c(2).source = 30000; c(2).signal = {noise};
%       >> c = utl_check_component(c, lf);
%       >> plot_component(c, epochs, lf);
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

h = figure;
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