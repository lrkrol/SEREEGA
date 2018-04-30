% erp = erp_get_class_random(numpeaks, latencies, widths, amplitudes, varargin)
% 
%       Generates random ERP classes using the given allowed values.
%       Allowed values are given using an array of values, e.g., with an
%       allowed number of peaks of [1 2 3], each returned ERP class will
%       have either 1, 2, or 3 individual peaks.
%
% In:
%       numpeaks - row array of possible numbers of peaks
%       latencies - row array of possible peak latencies
%       widths - row array of possible peak widths
%       amplitudes - row array of possible peak amplitudes
%
% Optional (key-value pairs):
%       probabilities - row array of possible signal probabilities.
%                       default: 1
%       latencyRelDvs, latencyRelSlopes, widthRelDvs, widthRelSlopes, 
%       amplitudeRelDvs, amplitudeRelSlopes, probabilityRelSlopes
%           - possible relative deviations and RelSlopes for the peak latency, 
%             width, and amplitudes, and the signal probability. these are 
%             given as ratio of the actual value, e.g. a probability of .5 
%             with a probabilitySlope of .5, will have a probability at the 
%             final epoch of .25, and an amplitude of 2 with a Dv of .1 will 
%             have an effective deviation of .2.
%       numClasses - the number of random classes to return. default: 1
%       
% Out:
%       erp - 1-by-numClasses struct of ERP classes
%
% Usage example:
%       >> epochs = struct('n', 100, 'srate', 1000, 'length', 1000);
%       >> erp = erp_get_class_random([1:3], [200:1000], [25:200], ...
%               [-1:.1:-.5, .5:.1:1], 'numClasses', 64);
%       >> plot_signal_fromclass(erp(1), epochs);
% 
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2017-12-05 lrk
%   - Renamed file to be in line with SEREEGA recommended practices
% 2017-08-10 lrk
%   - Changed *Dvs/*Slopes argument names to *RelDvs/*RelSlopes for clarity
% 2017-07-01 First version

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

function erp = erp_get_class_random(numpeaks, latencies, widths, amplitudes, varargin)

% parsing input
p = inputParser;

addRequired(p, 'numpeaks', @isnumeric);
addRequired(p, 'latencies', @isnumeric);
addRequired(p, 'widths', @isnumeric);
addRequired(p, 'amplitudes', @isnumeric);

addParameter(p, 'latencyRelDvs', 0, @isnumeric);
addParameter(p, 'latencyRelSlopes', 0, @isnumeric);
addParameter(p, 'widthRelDvs', 0, @isnumeric);
addParameter(p, 'widthRelSlopes', 0, @isnumeric);
addParameter(p, 'amplitudeRelDvs', 0, @isnumeric);
addParameter(p, 'amplitudeRelSlopes', 0, @isnumeric);
addParameter(p, 'probabilities', 1, @isnumeric);
addParameter(p, 'probabilityRelSlopes', 0, @isnumeric);
addParameter(p, 'numClasses', 1, @isnumeric);

parse(p, numpeaks, latencies, widths, amplitudes, varargin{:})

numpeaks = p.Results.numpeaks;
latencies = p.Results.latencies;
widths = p.Results.widths;
amplitudes = p.Results.amplitudes;
latencyRelDvs = p.Results.latencyRelDvs;
latencyRelSlopes = p.Results.latencyRelSlopes;
widthRelDvs = p.Results.widthRelDvs;
widthRelSlopes = p.Results.widthRelSlopes;
amplitudeRelDvs = p.Results.amplitudeRelDvs;
amplitudeRelSlopes = p.Results.amplitudeRelSlopes;
probabilities = p.Results.probabilities;
probabilityRelSlopes = p.Results.probabilityRelSlopes;
numClasses = p.Results.numClasses;

for c = 1:numClasses
    % generating random ERP class
    erpclass = struct();
    
    % selecting number of peaks
    n = utl_randsample(numpeaks, 1);
    
    % sampling randomly from given possible values
    erpclass.peakLatency = utl_randsample(latencies, n);
    erpclass.peakLatencyDv = utl_randsample(latencyRelDvs, n, 1) .* erpclass.peakLatency;
    erpclass.peakLatencySlope = utl_randsample(latencyRelSlopes, n, 1) .* erpclass.peakLatency;
    erpclass.peakWidth = utl_randsample(widths, n, 1);
    erpclass.peakWidthDv = utl_randsample(widthRelDvs, n, 1) .* erpclass.peakWidth;
    erpclass.peakWidthSlope = utl_randsample(widthRelSlopes, n, 1) .* erpclass.peakWidth;
    erpclass.peakAmplitude = utl_randsample(amplitudes, n, 1);
    erpclass.peakAmplitudeDv = utl_randsample(amplitudeRelDvs, n, 1) .* erpclass.peakAmplitude;
    erpclass.peakAmplitudeSlope = utl_randsample(amplitudeRelSlopes, n, 1) .* erpclass.peakAmplitude;
    erpclass.probability = utl_randsample(probabilities, 1);
    erpclass.probabilitySlope = utl_randsample(probabilityRelSlopes, 1) .* erpclass.probability;
    
    % validating ERP class
    erp(c) = utl_check_class(erpclass, 'type', 'erp');
end

end