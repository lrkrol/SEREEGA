% signal = arm_generate_signal_fromclass(class, epochs, varargin)
%
%       Takes an ARM activation class, determines single parameters given
%       the deviations/slopes in the class, and returns a signal generated
%       using those parameters.
%
%       An ARM class structure can only be used to generate one single,
%       independent time series using an autoregressive model. To simulate
%       interactions between different time series, use
%       arm_get_class_interacting.
%
% In:
%       class - 1x1 struct, the class variable
%       epochs - single epoch configuration struct containing at least
%                sampling rate in Hz (field name 'srate'), epoch length in ms
%                 ('length'), and the total number of epochs ('n')
%
% Optional (key-value pairs):
%       epochNumber - current epoch number. this is required for slope
%                     calculation, but defaults to 1 if not indicated
%       baseonly - whether or not to only generate the base signal, without
%                  any deviations or slopes (1|0, default 0)
%
% Out:  
%       signal - row array containing the simulated noise activation signal
%
% Usage example:
%       >> epochs = struct('n', 100, 'srate', 1000, 'length', 1000);
%       >> arm = struct('order', 10, 'amplitude', 1);
%       >> arm = utl_check_class(arm, 'type', 'arm');
%       >> signal = arm_generate_signal_fromclass(arm, epochs);
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

function signal = arm_generate_signal_fromclass(class, epochs, varargin)

% parsing input
p = inputParser;

addRequired(p, 'class', @isstruct);
addRequired(p, 'epochs', @isstruct);

addParameter(p, 'epochNumber', 1, @isnumeric);
addParameter(p, 'baseonly', 0, @isnumeric);

parse(p, class, epochs, varargin{:})

class = p.Results.class;
epochs = p.Results.epochs;
epochNumber = p.Results.epochNumber;
baseonly = p.Results.baseonly;

samples = floor(epochs.srate * epochs.length/1000);

% checking probability
if ~baseonly && rand() > class.probability + class.probabilitySlope * epochNumber / epochs.n
    % returning flatline
    signal = zeros(1, samples);
else
    % generating signal
    signal = arm_generate_signal(1, samples, class.order, 0, 0, class.arm);

    % normalising to given amplitude
    amplitude = utl_apply_dvslopeshift(class.amplitude, class.amplitudeDv, class.amplitudeSlope, epochNumber, epochs.n);
    signal = utl_normalise(signal, amplitude);
end

end