% h = plot_signal_fromclass(class, epochs, varargin)
%
%       Gateway function to plot class activation patterns. Takes a class
%       variable and calls the corresponding plotting function.
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
%       >> epochs.n = 100; epochs.srate = 500; epochs.length = 1000;
%       >> erp.peakLatency = 200; erp.peakWidth = 100; erp.peakAmplitude = 1;
%       >> erp = utl_check_class(erp, 'type', 'erp');
%       >> plot_signal(erp, epochs);
% 
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2017-06-13 First version

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

function h = plot_signal_fromclass(class, epochs, varargin)

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

class = utl_check_class(class);

% calling type-specific plot function
if ~exist(sprintf('%s_plot_signal_fromclass', class.type), 'file')
    error('SEREEGA:plot_signal_fromclass:error', 'no plotting function found for class type ''%s''', class.type);
else
    class_plot_signal_fromclass = str2func(sprintf('%s_plot_signal_fromclass', class.type));
    h = class_plot_signal_fromclass(class, epochs, 'newfig', newfig, 'baseonly', baseonly);
end

end
