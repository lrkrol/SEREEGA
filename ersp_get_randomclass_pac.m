% ersp = ersp_get_randomclass_burst(frequencies, amplitudes, varargin)
% 
%       Generates random ERSP classes using the given allowed values.
%       Allowed values are given using an array of values, e.g., with
%       allowed frequencies [10, 20, 30], each individual ERSP class will 
%       have a frequency of 10, 20, or 30 Hz.
%
%       Phases will always be set to random. This function only generates 
%       classes with phase-amplitude coupling. See 
%       ersp_get_randomclass_nomod for non-modulated random ERSP classes,
%       and ersp_get_randomclass_burst for burst-modulated classes.
%       
% In:
%       frequencies - row array of possible frequencies
%       amplitudes - row array of possible amplitudes
%       modFrequencies - row array of possible modulating frequencies
%       modMinAmplitudes - row array of possible minum amplitudes as a
%                          percentage of the base amplitude
%
% Optional (key-value pairs):
%       modPrestimPeriod - length in ms of the prestimulus period;
%                          default: 0
%       modPrestimTaper - taper for the prestimPeriod window; default: 0
%       modPrestimAmplitude - prestimPeriod amplitude; default: 0
%       probabilities - row array of possible signal probabilities.
%                       default: 1
%       frequencyDvs, frequencySlopes, amplitudeDvs, amplitudeSlopes,
%       modFrequencyDvs, modFrequencySlopes, modMinAmplitudeDvs,
%       modMinAmplitudeSlopes, probabilitySlopes,
%           - possible deviations and slopes for the base and modulation 
%             values, and the signal probability. these are given as ratio
%             of the actual value, e.g. a probability of .5 with a
%             probabilitySlope of .5, will have a probability at the final 
%             epoch of .25, and a frequency of 20 with a Dv of .1 will have
%             an effective deviation of 2 Hz.
%       numClasses - the number of random classes to return. default: 1
%
% Out:
%       ersp - 1-by-numClasses struct of ERSP classes
%
% Usage example:
%       >> epochs.srate = 1000; epochs.length = 1000; epochs.n = 1;
%       >> ersp = ersp_get_randomclass_pac([10:30], [.1:.1:1], ...
%                 [.1:.5:3], [0:.1:.5]);
%       >> plot_signal_fromclass(ersp(1), epochs);
% 
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2017-07-13 First version

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

function ersp = ersp_get_randomclass_pac(frequencies, amplitudes, modFrequencies, modMinAmplitudes, varargin)

% parsing input
p = inputParser;

addRequired(p, 'frequencies', @isnumeric);
addRequired(p, 'amplitudes', @isnumeric);
addRequired(p, 'modFrequencies', @isnumeric);
addRequired(p, 'modMinAmplitudes', @isnumeric);

addParameter(p, 'bursts', [1], @isnumeric);
addParameter(p, 'frequencyDvs', 0, @isnumeric);
addParameter(p, 'frequencySlopes', 0, @isnumeric);
addParameter(p, 'amplitudeDvs', 0, @isnumeric);
addParameter(p, 'amplitudeSlopes', 0, @isnumeric);
addParameter(p, 'modFrequencyDvs', 0, @isnumeric);
addParameter(p, 'modFrequencySlopes', 0, @isnumeric);
addParameter(p, 'modMinAmplitudeDvs', 0, @isnumeric);
addParameter(p, 'modMinAmplitudeSlopes', 0, @isnumeric);
addParameter(p, 'modPrestimPeriod', 0, @isnumeric);
addParameter(p, 'modPrestimTaper', 0, @isnumeric);
addParameter(p, 'modPrestimAmplitude', 0, @isnumeric);
addParameter(p, 'probabilities', 1, @isnumeric);
addParameter(p, 'probabilitySlopes', 0, @isnumeric);
addParameter(p, 'numClasses', 1, @isnumeric);

parse(p, frequencies, amplitudes, modFrequencies, modMinAmplitudes, varargin{:})

frequencies = p.Results.frequencies;
amplitudes = p.Results.amplitudes;
modFrequencies = p.Results.modFrequencies;
modMinAmplitudes = p.Results.modMinAmplitudes;
frequencyDvs = p.Results.frequencyDvs;
frequencySlopes = p.Results.frequencySlopes;
amplitudeDvs = p.Results.amplitudeDvs;
amplitudeSlopes = p.Results.amplitudeSlopes;
modFrequencyDvs = p.Results.modFrequencyDvs;
modFrequencySlopes = p.Results.modFrequencySlopes;
modMinAmplitudeDvs = p.Results.modMinAmplitudeDvs;
modMinAmplitudeSlopes = p.Results.modMinAmplitudeSlopes;
modPrestimPeriod = p.Results.modPrestimPeriod;
modPrestimTaper = p.Results.modPrestimTaper;
modPrestimAmplitude = p.Results.modPrestimAmplitude;
probabilities = p.Results.probabilities;
probabilitySlopes = p.Results.probabilitySlopes;
numClasses = p.Results.numClasses;

for c = 1:numClasses
    % generating random ERSP class
    erspclass = struct();
    
    % setting base parameters
    erspclass.frequency = utl_randsample(frequencies, 1);
    erspclass.phase = [];
    erspclass.amplitude = utl_randsample(amplitudes, 1);
    
    % setting modulation parameter
    erspclass.modulation = 'pac';
    
    % sampling randomly from given possible values
    erspclass.frequencyDv = utl_randsample(frequencyDvs, 1) * erspclass.frequency;
    erspclass.frequencySlope = utl_randsample(frequencySlopes, 1) * erspclass.frequency;
    erspclass.amplitudeDv = utl_randsample(amplitudeDvs, 1) * erspclass.amplitude;
    erspclass.amplitudeSlope = utl_randsample(amplitudeSlopes, 1) * erspclass.amplitude;
    erspclass.probability = utl_randsample(probabilities, 1);
    erspclass.probabilitySlope = utl_randsample(probabilitySlopes, 1) .* erspclass.probability;    
    erspclass.modFrequency = utl_randsample(modFrequencies, 1);
    erspclass.modFrequencyDv = utl_randsample(modFrequencyDvs, 1) * erspclass.modFrequency;
    erspclass.modFrequencySlope = utl_randsample(modFrequencySlopes, 1) * erspclass.modFrequency;
    erspclass.modMinAmplitude = utl_randsample(modMinAmplitudes, 1);
    erspclass.modMinAmplitudeDv = utl_randsample(modMinAmplitudeDvs, 1) * erspclass.modMinAmplitude;
    erspclass.modMinAmplitudeSlope = utl_randsample(modMinAmplitudeSlopes, 1) * erspclass.modMinAmplitude;
    erspclass.modPrestimPeriod = modPrestimPeriod;
    erspclass.modPrestimTaper = modPrestimTaper;
    erspclass.modPrestimAmplitude = modPrestimAmplitude;
    
    % validating ERSP class
    ersp(c) = utl_check_class(erspclass, 'type', 'ersp');
end

end