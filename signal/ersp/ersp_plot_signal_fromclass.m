% h = ersp_plot_signal_fromclass(class, epochs, varargin)
%
%       Plots an ERSP class activation signal. In blue, solid line: the 
%       base signal as defined. This function does not apply any deviations
%       or slopes.
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
%                  without any deviations or sloping. default: 1
%
% Out:  
%       h - handle of the generated figure
%
% Usage example:
%       >> epochs = struct('n', 100, 'srate', 1000, 'length', 1000);
%       >> ersp = struct('frequency', 20, 'amplitude', 1, 'phase', 0, ...
%       >>      'modulation', 'ampmod', 'modFrequency', 2, ...
%       >>      'modPhase', -.25, 'type', 'ersp');
%       >> plot_signal_fromclass(ersp, epochs);
% 
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2016-06-20 lrk
%   - Changed variable names for consistency
%   - Added prestimulus attenuation to PAC
% 2017-06-16 First version

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

function h = ersp_plot_signal_fromclass(class, epochs, varargin)

% parsing input
p = inputParser;

addRequired(p, 'class', @isstruct);
addRequired(p, 'epochs', @isstruct);

addParameter(p, 'newfig', 1, @isnumeric);
addParameter(p, 'baseonly', 1, @isnumeric);

parse(p, class, epochs, varargin{:})

class = p.Results.class;
epochs = p.Results.epochs;
newfig = p.Results.newfig;

% getting time stamps
x = 1:epochs.length/1000*epochs.srate;
x = x/epochs.srate;

% correcting time stamps if a prestimulus period is indicated
if isfield(epochs, 'prestim')
    x = x - epochs.prestim/1000; end

if newfig, h = figure('name', 'ERSP signal', 'NumberTitle', 'off', 'ToolBar', 'none'); else h = NaN; end
hold on;

signal = ersp_generate_signal_fromclass(class, epochs, 'baseonly', 1);
plot(x, signal, '-');

end
