% ersp = ersp_get_class_randomnomod(frequencies, amplitudes, varargin)
% 
%       Generates random ERSP classes using the given allowed values.
%       Allowed values are given using an array of values, e.g., with
%       allowed frequencies [10, 20, 30], each individual ERSP class will 
%       have a frequency of 10, 20, or 30 Hz.
%
%       Phases will always be set to random. This function only generates 
%       classes without modulation. See ersp_get_randomclass_burst for
%       random burst-modulated classes, and ersp_get_randomclass_ampmod 
%       for random PAC-modulated classes.
%       
% In:
%       frequencies - row array of possible frequencies
%       amplitudes - row array of possible amplitudes
%
% Optional (key-value pairs):
%       bandWidths - row array of possible frequency band widths. if a non-
%                    zero band with is selected, frequencyRelDvs and
%                    frequencyRelSlopes will be applied to both the lower
%                    and the higher passband frequencies. the edges of the
%                    transition bands will be 25% larger. i.e., a frequency
%                    of 20 with a width of 4 will result in edge bands of
%                    [17 18 22 23]. default: [0]
%       probabilities - row array of possible signal probabilities.
%                       default: 1
%       frequencyRelDvs, frequencyRelSlopes, amplitudeRelDvs, 
%       amplitudeRelSlopes, probabilitySlope
%           - possible relativedeviations and RelSlopes for the frequency 
%             values and amplitudes, and the signal probability. these are 
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
%       >> ersp = ersp_get_class_randomnomod([4:30], [.1:.1:1], ...
%                 'numClasses', 64);
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

function ersp = ersp_get_class_randomnomod(frequencies, amplitudes, varargin)

% parsing input
p = inputParser;

addRequired(p, 'frequencies', @isnumeric);
addRequired(p, 'amplitudes', @isnumeric);

addParameter(p, 'frequencyRelDvs', 0, @isnumeric);
addParameter(p, 'frequencyRelSlopes', 0, @isnumeric);
addParameter(p, 'bandWidths', [0], @isnumeric);
addParameter(p, 'amplitudeRelDvs', 0, @isnumeric);
addParameter(p, 'amplitudeRelSlopes', 0, @isnumeric);
addParameter(p, 'probabilities', 1, @isnumeric);
addParameter(p, 'probabilityRelSlopes', 0, @isnumeric);
addParameter(p, 'numClasses', 1, @isnumeric);

parse(p, frequencies, amplitudes, varargin{:})

frequencies = p.Results.frequencies;
amplitudes = p.Results.amplitudes;
frequencyRelDvs = p.Results.frequencyRelDvs;
frequencyRelSlopes = p.Results.frequencyRelSlopes;
bandWidths = p.Results.bandWidths;
amplitudeRelDvs = p.Results.amplitudeRelDvs;
amplitudeRelSlopes = p.Results.amplitudeRelSlopes;
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
    erspclass.modulation = 'none';
    
    % sampling randomly from given possible values
    erspclass.frequencyDv = utl_randsample(frequencyRelDvs, numel(erspclass.frequency)) .* erspclass.frequency;
    erspclass.frequencySlope = utl_randsample(frequencyRelSlopes, numel(erspclass.frequency)) .* erspclass.frequency;
    erspclass.amplitudeDv = utl_randsample(amplitudeRelDvs, 1) * erspclass.amplitude;
    erspclass.amplitudeSlope = utl_randsample(amplitudeRelSlopes, 1) * erspclass.amplitude;
    erspclass.probability = utl_randsample(probabilities, 1);
    erspclass.probabilitySlope = utl_randsample(probabilityRelSlopes, 1) .* erspclass.probability;
    
    % validating ERSP class
    ersp(c) = utl_check_class(erspclass, 'type', 'ersp');
end

end