% signal = erp_generate_signal_fromclass(class, epochs, varargin)
%
%       Takes an ERP activation class, determines single parameters given
%       the deviations/slopes in the class, and returns a signal generated
%       using those parameters.
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
%       >> epochs.n = 100; epochs.srate = 1000; epochs.length = 1000;
%       >> erp = struct('type', 'erp', 'peakLatency', 300, ...
%       >>      'peakWidth', 100, 'peakAmplitude', 1);
%       >> erp = utl_check_class(erp);
%       >> signal = erp_generate_signal_fromclass(erp, epochs);
% 
%                    Copyright 2017, 2018 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2018-06-04 lrk
%   - Added peakLatencyShift
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

function signal = erp_generate_signal_fromclass(class, epochs, varargin)

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

if baseonly
    % generating base signal
    signal = erp_generate_signal(class.peakLatency, class.peakWidth, class.peakAmplitude, epochs.srate, epochs.length);
else
    % checking probability
    if rand() > class.probability + class.probabilitySlope * epochNumber / epochs.n
        % returning flatline
        signal = zeros(1, floor((epochs.length/1000)*epochs.srate));
    else
        % obtaining specific instances of peak latencies, widths, and amps
        peakLatency = utl_apply_dvslopeshift(class.peakLatency, class.peakLatencyDv, class.peakLatencySlope, epochNumber, epochs.n, class.peakLatencyShift);
        peakWidth = abs(utl_apply_dvslopeshift(class.peakWidth, class.peakWidthDv, class.peakWidthSlope, epochNumber, epochs.n));
        peakWidth(peakWidth == 0) = 1;
        peakAmplitude = utl_apply_dvslopeshift(class.peakAmplitude, class.peakAmplitudeDv, class.peakAmplitudeSlope, epochNumber, epochs.n);
        
        % generating signal
        signal = erp_generate_signal(peakLatency, peakWidth, peakAmplitude, epochs.srate, epochs.length);
    end
end

end