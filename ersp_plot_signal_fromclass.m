% h = ersp_plot_signal_fromclass(class, epochs, varargin)
%
%       Plots an ERSP class activation signal. In blue, solid line: the 
%       base signal as defined. This function does not apply any deviations
%       or slopes.
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
%       baseonly - (0|1) whether or not to plot only the base signal,
%                  without any deviations or sloping. default: 1
%
% Out:  
%       h - handle of the generated figure
%
% Usage example:
%       >> epochs.n = 100; epochs.srate = 500; epochs.length = 1000;
%       >> ersp.frequency = 20; ersp.amplitude = 1; ersp.phase = 0;
%       >> ersp.modulation='mod'; ersp.modFrequency=2; ersp.modPhase= -.25;
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

addParamValue(p, 'newfig', 1, @isnumeric);
addParamValue(p, 'baseonly', 1, @isnumeric);

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

if newfig, h = figure; else h = NaN; end
hold on;

% plotting the base signal, no deviations applied
if strcmp(class.modulation, 'none')
    signal = ersp_generate_signal(class.frequency, class.amplitude, class.phase, epochs.srate, epochs.length);
elseif ismember(class.modulation, {'burst', 'invburst'})
    signal = ersp_generate_signal(class.frequency, class.amplitude, class.phase, epochs.srate, epochs.length, ...
            'modulation', class.modulation, 'modLatency', class.modLatency, 'modWidth', class.modWidth, 'modTaper', class.modTaper, 'modMinAmplitude', class.modMinAmplitude);
elseif strcmp(class.modulation, 'pac')
    signal = ersp_generate_signal(class.frequency, class.amplitude, class.phase, epochs.srate, epochs.length, ...
            'modulation', class.modulation, 'modFrequency', class.modFrequency, 'modPhase', class.modPhase, 'modMinAmplitude', class.modMinAmplitude, ...
                'modPrestimPeriod', class.modPrestimPeriod, 'modPrestimTaper', class.modPrestimTaper, 'modPrestimAmplitude', class.modPrestimAmplitude);
end
plot(x, signal, 'b-', 'LineWidth', 2);

end
