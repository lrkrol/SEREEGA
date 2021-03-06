% ersp = ersp_get_class_randomampmod(frequencies, amplitudes, varargin)
% 
%       Generates random ERSP classes using the given allowed values.
%       Allowed values are given using an array of values, e.g., with
%       allowed frequencies [10, 20, 30], each individual ERSP class will 
%       have a frequency of 10, 20, or 30 Hz.
%
%       Phases will always be set to random. This function only generates 
%       classes with amplitude modulation. See 
%       ersp_get_randomclass_nomod for non-modulated random ERSP classes,
%       and ersp_get_randomclass_burst for burst-modulated classes.
%       
% In:
%       frequencies - row array of possible frequencies
%       amplitudes - row array of possible amplitudes
%       modFrequencies - row array of possible modulating frequencies
%       modMinRelAmplitudes - row array of possible minum amplitudes as a
%                             percentage of the base amplitude
%
% Optional (key-value pairs):
%       bandWidths - row array of possible frequency band widths. if a non-
%                    zero band with is selected, frequencyRelDvs and
%                    frequencyRelSlopes will be applied to both the lower
%                    and the higher passband frequencies. the edges of the
%                    transition bands will be 25% larger. i.e., a frequency
%                    of 20 with a width of 4 will result in edge bands of
%                    [17 18 22 23]. default: [0]
%       modPrestimPeriod - length in ms of the prestimulus period;
%                          default: 0
%       modPrestimTaper - taper for the prestimPeriod window; default: 0
%       modPrestimRelAmplitude - prestimPeriod amplitude; default: 0
%       probabilities - row array of possible signal probabilities.
%                       default: 1
%       frequencyRelDvs, frequencyRelSlopes, amplitudeRelDvs, 
%       amplitudeRelSlopes, modFrequencyRelDvs, modFrequencyRelSlopes, 
%       modMinRelAmplitudeRelDvs, modMinRelAmplitudeRelSlopes, 
%       probabilityRelSlopes
%           - possible relative deviations and RelSlopes for the base and 
%             modulation values, and the signal probability. these are 
%             given as ratio of the actual value, e.g. a probability of .5 
%             with a probabilitySlope of .5, will have a probability at the 
%             final epoch of .25, and a frequency of 20 with a Dv of .1 
%             will have an effective deviation of 2 Hz.
%       numClasses - the number of random classes to return. default: 1
%
% Out:
%       ersp - 1-by-numClasses struct of ERSP classes
%
% Usage example:
%       >> epochs = struct('n', 100, 'srate', 1000, 'length', 1000);
%       >> ersp = ersp_get_class_randomampmod([10:30], [.1:.1:1], ...
%                 [.1:.5:3], [0:.1:.5]);
%       >> plot_signal_fromclass(ersp(1), epochs);
% 
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2018-01-02 lrk
%   - Adapted to new bandpass filter method (see ersp_generate_signal 
%     2017-12-30)
% 2017-12-05 lrk
%   - Renamed file to be in line with SEREEGA recommended practices
% 2017-11-24 lrk
%   - Renamed 'pac' to 'ampmod' and replaced references accordingly
% 2017-11-22 lrk
%   - Renamed parameters modMinAmplitude and modPrestimAmplitude to 
%     modMinRelAmplitude and modPrestimRelAmplitude for clarity
% 2017-10-19 lrk
%   - Added broadband base activation
% 2017-08-10 lrk
%   - Changed *Dvs/*Slopes argument names to *RelDvs/*RelSlopes for clarity
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

function ersp = ersp_get_class_randomampmod(frequencies, amplitudes, modFrequencies, modMinRelAmplitudes, varargin)

% parsing input
p = inputParser;

addRequired(p, 'frequencies', @isnumeric);
addRequired(p, 'amplitudes', @isnumeric);
addRequired(p, 'modFrequencies', @isnumeric);
addRequired(p, 'modMinRelAmplitudes', @isnumeric);

addParameter(p, 'bursts', [1], @isnumeric);
addParameter(p, 'frequencyRelDvs', 0, @isnumeric);
addParameter(p, 'frequencyRelSlopes', 0, @isnumeric);
addParameter(p, 'bandWidths', [0], @isnumeric);
addParameter(p, 'amplitudeRelDvs', 0, @isnumeric);
addParameter(p, 'amplitudeRelSlopes', 0, @isnumeric);
addParameter(p, 'modFrequencyRelDvs', 0, @isnumeric);
addParameter(p, 'modFrequencyRelSlopes', 0, @isnumeric);
addParameter(p, 'modMinRelAmplitudeRelDvs', 0, @isnumeric);
addParameter(p, 'modMinRelAmplitudeRelSlopes', 0, @isnumeric);
addParameter(p, 'modPrestimPeriod', 0, @isnumeric);
addParameter(p, 'modPrestimTaper', 0, @isnumeric);
addParameter(p, 'modPrestimRelAmplitude', 0, @isnumeric);
addParameter(p, 'probabilities', 1, @isnumeric);
addParameter(p, 'probabilityRelSlopes', 0, @isnumeric);
addParameter(p, 'numClasses', 1, @isnumeric);

parse(p, frequencies, amplitudes, modFrequencies, modMinRelAmplitudes, varargin{:})

frequencies = p.Results.frequencies;
amplitudes = p.Results.amplitudes;
modFrequencies = p.Results.modFrequencies;
modMinRelAmplitudes = p.Results.modMinRelAmplitudes;
frequencyRelDvs = p.Results.frequencyRelDvs;
frequencyRelSlopes = p.Results.frequencyRelSlopes;
bandWidths = p.Results.bandWidths;
amplitudeRelDvs = p.Results.amplitudeRelDvs;
amplitudeRelSlopes = p.Results.amplitudeRelSlopes;
modFrequencyRelDvs = p.Results.modFrequencyRelDvs;
modFrequencyRelSlopes = p.Results.modFrequencyRelSlopes;
modMinRelAmplitudeRelDvs = p.Results.modMinRelAmplitudeRelDvs;
modMinRelAmplitudeRelSlopes = p.Results.modMinRelAmplitudeRelSlopes;
modPrestimPeriod = p.Results.modPrestimPeriod;
modPrestimTaper = p.Results.modPrestimTaper;
modPrestimRelAmplitude = p.Results.modPrestimRelAmplitude;
probabilities = p.Results.probabilities;
probabilityRelSlopes = p.Results.probabilityRelSlopes;
numClasses = p.Results.numClasses;

for c = 1:numClasses
    % generating random ERSP class
    erspclass = struct();
    
    % setting base parameters
    bandWidth = utl_randsample(bandWidths, 1);
    frequency = utl_randsample(frequencies, 1);
    if bandWidth == 0
        erspclass.frequency = frequency;
    else
        erspclass.frequency = [frequency - 3*bandWidth/4, frequency - bandWidth/2, frequency + bandWidth/2, frequency + 3*bandWidth/4];
    end
    erspclass.phase = [];
    erspclass.amplitude = utl_randsample(amplitudes, 1);
    
    % setting modulation parameter
    erspclass.modulation = 'ampmod';
    
    % sampling randomly from given possible values
    erspclass.frequencyDv = utl_randsample(frequencyRelDvs, numel(erspclass.frequency)) .* erspclass.frequency;
    erspclass.frequencySlope = utl_randsample(frequencyRelSlopes, numel(erspclass.frequency)) .* erspclass.frequency;
    erspclass.amplitudeDv = utl_randsample(amplitudeRelDvs, 1) * erspclass.amplitude;
    erspclass.amplitudeSlope = utl_randsample(amplitudeRelSlopes, 1) * erspclass.amplitude;
    erspclass.probability = utl_randsample(probabilities, 1);
    erspclass.probabilitySlope = utl_randsample(probabilityRelSlopes, 1) .* erspclass.probability;    
    erspclass.modFrequency = utl_randsample(modFrequencies, 1);
    erspclass.modFrequencyDv = utl_randsample(modFrequencyRelDvs, 1) * erspclass.modFrequency;
    erspclass.modFrequencySlope = utl_randsample(modFrequencyRelSlopes, 1) * erspclass.modFrequency;
    erspclass.modMinRelAmplitude = utl_randsample(modMinRelAmplitudes, 1);
    erspclass.modMinRelAmplitudeDv = utl_randsample(modMinRelAmplitudeRelDvs, 1) * erspclass.modMinRelAmplitude;
    erspclass.modMinRelAmplitudeSlope = utl_randsample(modMinRelAmplitudeRelSlopes, 1) * erspclass.modMinRelAmplitude;
    erspclass.modPrestimPeriod = modPrestimPeriod;
    erspclass.modPrestimTaper = modPrestimTaper;
    erspclass.modPrestimRelAmplitude = modPrestimRelAmplitude;
    
    % validating ERSP class
    ersp(c) = utl_check_class(erspclass, 'type', 'ersp');
end

end