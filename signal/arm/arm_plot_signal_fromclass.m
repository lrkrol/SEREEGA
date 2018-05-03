% h = arm_plot_signal_fromclass(class, epochs, varargin)
%
%       Plots a sample ARM class activation signal.
%
% In:
%       class - 1x1 struct, the class variable
%       epochs - single epoch configuration struct containing at least
%                sampling rate in Hz (field name 'srate'), epoch length in ms
%                 ('length'), and the total number of epochs ('n')
%
% Optional (key-value pairs):
%       newfig - (0|1) whether or not to open a new figure window.
%                default: 1
%       baseonly - (0|1) whether or not to plot only the base signal,
%                  without any deviations or sloping. default: 0
%
% Out:  
%       h - handle of the generated figure
%
% Usage example:
%       >> arm = struct('order', 10, 'amplitude', 1, 'amplitudeDv', .5);
%       >> arm = utl_check_class(arm, 'type', 'arm');
%       >> arm_plot_signal_fromclass(arm, epochs);
% 
%                    Copyright 2018 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2018-01-15 First version

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

function h = arm_plot_signal_fromclass(class, epochs, varargin)

% parsing input
p = inputParser;

addRequired(p, 'class', @isstruct);
addRequired(p, 'epochs', @isstruct);

addParameter(p, 'newfig', 1, @isnumeric);
addParameter(p, 'baseonly', 0, @isnumeric);

parse(p, class, epochs, varargin{:})

class = p.Results.class;
epochs = p.Results.epochs;
newfig = p.Results.newfig;
baseonly = p.Results.baseonly;

% getting time stamps
x = 1:epochs.length/1000*epochs.srate;
x = x/epochs.srate;

% correcting time stamps if a prestimulus period is indicated
if isfield(epochs, 'prestim')
    x = x - epochs.prestim/1000; end

if newfig, h = figure('name', 'ARM signal', 'NumberTitle', 'off', 'ToolBar', 'none'); else, h = NaN; end
hold on;

% plotting the base signal, no deviations applied
signal = arm_generate_signal_fromclass(class, epochs);
plot(x, signal, '-');

if ~baseonly
    % signal with maximum possible deviation (negative)
    ax = gca;
    ax.ColorOrderIndex = 1;
    plot(x, signal - class.amplitudeDv, ':');

    % signal with maximum possible deviation (positive)
    ax.ColorOrderIndex = 1;
    plot(x, signal + class.amplitudeDv, ':');
end

end
