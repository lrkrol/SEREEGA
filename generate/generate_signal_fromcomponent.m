% componentsignal = generate_signal_fromcomponent(component, epochs, varargin)
%
%       Generates a mean base signal from all signals in a given component.
%
% In:
%       component - 1x1 struct, the component variable
%       epochs - single epoch configuration struct containing at least
%                sampling rate in Hz (field name 'srate'), epoch length in ms
%                 ('length'), and the total number of epochs ('n')
%
% Optional (key-value pairs):
%       epochNumber - current epoch number. this is required for slope
%                     calculation, but defaults to 1 if not indicated
%       baseonly - whether or not to only plot the base signal, without any
%                  deviations or slopes (1|0, default 0)
%
% Out:  
%       componentsignal - row array containing the simulated mean signal
%
% Usage example:
%       >> epochs = struct('n', 100, 'srate', 1000, 'length', 1000);
%       >> erp = struct('type', 'erp', 'peakLatency', 200, ...
%       >>      'peakWidth', 100, 'peakAmplitude', 1);
%       >> noise = struct('type','noise', 'color','brown', 'amplitude',.5);
%       >> comp = utl_create_component(1, {erp, noise}, lf);
%       >> csignal = generate_signal_fromcomponent(comp, epochs);
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

function componentsignal = generate_signal_fromcomponent(component, epochs, varargin)

% parsing input
p = inputParser;

addRequired(p, 'component', @isstruct);
addRequired(p, 'epochs', @isstruct);

addParameter(p, 'epochNumber', 1, @isnumeric);
addParameter(p, 'baseonly', 0, @isnumeric);

parse(p, component, epochs, varargin{:})

component = p.Results.component;
epochs = p.Results.epochs;
epochNumber = p.Results.epochNumber;
baseonly = p.Results.baseonly;

signaldata = zeros(numel(component.signal), floor((epochs.length/1000)*epochs.srate));

% for each signal...
for s = 1:numel(component.signal)
    % obtaining signal
    signal = generate_signal_fromclass(component.signal{s}, epochs, 'epochNumber', epochNumber, 'baseonly', baseonly);
    signaldata(s,:) = signal;
end

% combining signals into single component activation
componentsignal = sum(signaldata, 1);
        
end