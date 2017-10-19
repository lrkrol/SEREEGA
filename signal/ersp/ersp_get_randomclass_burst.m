% ersp = ersp_get_randomclass_burst(frequencies, amplitudes, varargin)
% 
%       Generates random ERSP classes using the given allowed values.
%       Allowed values are given using an array of values, e.g., with
%       allowed frequencies [10, 20, 30], each individual ERSP class will 
%       have a frequency of 10, 20, or 30 Hz.
%
%       Phases will always be set to random. This function only generates 
%       classes with burst or invburst modulation. See 
%       ersp_get_randomclass_nomod for non-modulated random ERSP classes,
%       and ersp_get_randomclass_pac for random PAC-modulated classes.
%       
% In:
%       frequencies - row array of possible base frequencies
%       amplitudes - row array of possible amplitudes
%       modLatencies - row array of possible burst centre latencies
%       modWidths - row array of possible burst widths
%       modTapers - row array of possible burst tapers
%       modMinAmplitudes - row array of possible minum amplitudes as a
%                          percentage of the base amplitude
%
% Optional (key-value pairs):
%       bandWidths - row array of possible frequency band widths. default:
%                    [0]
%       bursts - row array of possible burst modulation types, where 1 is
%                burst and -1 is invburst; options are thus [1], [-1], or
%                [-1, 1]. default: [1]
%       probabilities - row array of possible signal probabilities.
%                       default: 1
%       frequencyRelDvs, frequencyRelSlopes, bandWidthRelDvs,
%       bandWidthRelSlopes, amplitudeRelDvs, amplitudeRelSlopes,
%       modLatencyRelDvs, modLatencyRelSlopes, modWidthRelDvs,
%       modWidthRelSlopes, modTaperRelDvs, modTaperRelSlopes,
%       modMinAmplitudeRelDvs, modMinAmplitudeRelSlopes,
%       probabilityRelSlopes,
%           - possible relative deviations and relative slopes for the base
%             and modulation values, and the signal probability. these are 
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
%       >> epochs.srate = 1000; epochs.length = 1000; epochs.n = 1;
%       >> ersp = ersp_get_randomclass_burst([4:30], [.1:.1:1], ...
%                 [300:1000], [50:300], [.5:.1:1], [0:.1:.5], ...
%                 'bursts', [-1, 1], 'numClasses', 64);
%       >> plot_signal_fromclass(ersp(1), epochs);
% 
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

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

function ersp = ersp_get_randomclass_burst(frequencies, amplitudes, modLatencies, modWidths, modTapers, modMinAmplitudes, varargin)

% parsing input
p = inputParser;

addRequired(p, 'frequencies', @isnumeric);
addRequired(p, 'amplitudes', @isnumeric);
addRequired(p, 'modLatencies', @isnumeric);
addRequired(p, 'modWidths', @isnumeric);
addRequired(p, 'modTapers', @isnumeric);
addRequired(p, 'modMinAmplitudes', @isnumeric);

addParameter(p, 'bursts', [1], @isnumeric);
addParameter(p, 'frequencyRelDvs', 0, @isnumeric);
addParameter(p, 'frequencyRelSlopes', 0, @isnumeric);
addParameter(p, 'bandWidths', [0], @isnumeric);
addParameter(p, 'bandWidthRelDvs', 0, @isnumeric);
addParameter(p, 'bandWidthRelSlopes', 0, @isnumeric);
addParameter(p, 'amplitudeRelDvs', 0, @isnumeric);
addParameter(p, 'amplitudeRelSlopes', 0, @isnumeric);
addParameter(p, 'modLatencyRelDvs', 0, @isnumeric);
addParameter(p, 'modLatencyRelSlopes', 0, @isnumeric);
addParameter(p, 'modWidthRelDvs', 0, @isnumeric);
addParameter(p, 'modWidthRelSlopes', 0, @isnumeric);
addParameter(p, 'modTaperRelDvs', 0, @isnumeric);
addParameter(p, 'modTaperRelSlopes', 0, @isnumeric);
addParameter(p, 'modMinAmplitudeRelDvs', 0, @isnumeric);
addParameter(p, 'modMinAmplitudeRelSlopes', 0, @isnumeric);
addParameter(p, 'probabilities', 1, @isnumeric);
addParameter(p, 'probabilityRelSlopes', 0, @isnumeric);
addParameter(p, 'numClasses', 1, @isnumeric);

parse(p, frequencies, amplitudes, modLatencies, modWidths, modTapers, modMinAmplitudes, varargin{:})

frequencies = p.Results.frequencies;
amplitudes = p.Results.amplitudes;
modLatencies = p.Results.modLatencies;
modWidths = p.Results.modWidths;
modTapers = p.Results.modTapers;
modMinAmplitudes = p.Results.modMinAmplitudes;
bursts = p.Results.bursts;
frequencyRelDvs = p.Results.frequencyRelDvs;
frequencyRelSlopes = p.Results.frequencyRelSlopes;
bandWidths = p.Results.bandWidths;
bandWidthRelDvs = p.Results.bandWidthRelDvs;
bandWidthRelSlopes = p.Results.bandWidthRelSlopes;
amplitudeRelDvs = p.Results.amplitudeRelDvs;
amplitudeRelSlopes = p.Results.amplitudeRelSlopes;
modLatencyRelDvs = p.Results.modLatencyRelDvs;
modLatencyRelSlopes = p.Results.modLatencyRelSlopes;
modWidthRelDvs = p.Results.modWidthRelDvs;
modWidthRelSlopes = p.Results.modWidthRelSlopes;
modTaperRelDvs = p.Results.modTaperRelDvs;
modTaperRelSlopes = p.Results.modTaperRelSlopes;
modMinAmplitudeRelDvs = p.Results.modMinAmplitudeRelDvs;
modMinAmplitudeRelSlopes = p.Results.modMinAmplitudeRelSlopes;
probabilities = p.Results.probabilities;
probabilityRelSlopes = p.Results.probabilityRelSlopes;
numClasses = p.Results.numClasses;

for c = 1:numClasses
    % generating random ERSP class
    erspclass = struct();
    
    % setting base parameters
    erspclass.frequency = utl_randsample(frequencies, 1);
    erspclass.bandWidth = utl_randsample(bandWidths, 1);
    erspclass.phase = [];
    erspclass.amplitude = utl_randsample(amplitudes, 1);
    
    % setting modulation parameters
    if utl_randsample(bursts, 1) == 1
        erspclass.modulation = 'burst';
    else
        erspclass.modulation = 'invburst';
    end
    
    % sampling randomly from given possible values
    erspclass.frequencyDv = utl_randsample(frequencyRelDvs, 1) * erspclass.frequency;
    erspclass.frequencySlope = utl_randsample(frequencyRelSlopes, 1) * erspclass.frequency;
    erspclass.bandWidthDv = utl_randsample(bandWidthRelDvs, 1) * erspclass.bandWidth;
    erspclass.bandWidthSlope = utl_randsample(bandWidthRelSlopes, 1) * erspclass.bandWidth;
    erspclass.amplitudeDv = utl_randsample(amplitudeRelDvs, 1) * erspclass.amplitude;
    erspclass.amplitudeSlope = utl_randsample(amplitudeRelSlopes, 1) * erspclass.amplitude;
    erspclass.probability = utl_randsample(probabilities, 1);
    erspclass.probabilitySlope = utl_randsample(probabilityRelSlopes, 1) .* erspclass.probability;    
    erspclass.modLatency = utl_randsample(modLatencies, 1);
    erspclass.modLatencyDv = utl_randsample(modLatencyRelDvs, 1) * erspclass.modLatency;
    erspclass.modLatencySlope = utl_randsample(modLatencyRelSlopes, 1) * erspclass.modLatency;
    erspclass.modWidth = utl_randsample(modWidths, 1);
    erspclass.modWidthDv = utl_randsample(modWidthRelDvs, 1) * erspclass.modWidth;
    erspclass.modWidthSlope = utl_randsample(modWidthRelSlopes, 1) * erspclass.modWidth;
    erspclass.modTaper = utl_randsample(modTapers, 1);
    erspclass.modTaperDv = utl_randsample(modTaperRelDvs, 1) * erspclass.modTaper;
    erspclass.modTaperSlope = utl_randsample(modTaperRelSlopes, 1) * erspclass.modTaper;
    erspclass.modMinAmplitude = utl_randsample(modMinAmplitudes, 1);
    erspclass.modMinAmplitudeDv = utl_randsample(modMinAmplitudeRelDvs, 1) * erspclass.modMinAmplitude;
    erspclass.modMinAmplitudeSlope = utl_randsample(modMinAmplitudeRelSlopes, 1) * erspclass.modMinAmplitude;
    
    % validating ERSP class
    ersp(c) = utl_check_class(erspclass, 'type', 'ersp');
end

end