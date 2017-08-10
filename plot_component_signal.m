% h = plot_component_signal(class, epochs, varargin)
%
%       Plots the signal from a component without any deviations or slopes
%       applied. Due to the random nature of noise, it takes the mean of 10
%       such epochs before the signal is plotted.
%
% In:
%       class - 1x1 struct, the class variable
%       epochs - single epoch configuration struct containing at least
%                sampling rate (srate), epoch length (length), and total
%                number of epochs (n)
%
% Optional (key-value pairs):
%       newfig - (0|1) whether or not to open a new figure window.
%                default: 1
%
% Out:  
%       h - handle of the generated figure
%
% Usage example:
%       >> epochs.srate = 1000; epochs.length = 1000;
%       >> erp.peakLatency = 500; erp.peakWidth = 100; erp.amplitude = 1;
%       >> c.source = 1; c.signal = {erp, noise};
%       >> plot_signal_fromcomponent(c, epochs);
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

function h = plot_component_signal(component, epochs, varargin)

% parsing input
p = inputParser;

addRequired(p, 'component', @isstruct);
addRequired(p, 'epochs', @isstruct);

addParameter(p, 'newfig', 1, @isnumeric);

parse(p, component, epochs, varargin{:})

component = p.Results.component;
epochs = p.Results.epochs;
newfig = p.Results.newfig;

% getting time stamps
x = 1:epochs.length/1000*epochs.srate;
x = x/epochs.srate;

% correcting time stamps if a prestimulus period is indicated
if isfield(epochs, 'prestim')
    x = x - epochs.prestim/1000; end

if newfig, h = figure; else, h = NaN; end

% getting mean signal of ten epochs 
componentsignal = [];
for i = 1:10
    componentsignal(i,:) = generate_signal_fromcomponent(component, epochs, 'baseonly', 1);
end

componentsignal = mean(componentsignal, 1);
plot(x, componentsignal, '-');
