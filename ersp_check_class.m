% class = ersp_check_class(class)
%
%       Validates and completes an ERSP class structure.
%
%       ERSPs (event-related spectral perturbation) here refer to signal
%       activations that constitute one base frequency, and optionally
%       modulate this frequency, either by applying an (inverse) tukey
%       window, or by coupling the signal's amplitude to the phase of
%       another frequency.
%
%       The base frequency is defined by its frequency in Hz, its
%       amplitude, and optionally, its phase. 
%
%       A burst can additionally be indicated using its latency (the burst
%       window's centre) in ms, its width in ms, and its taper, where a
%       taper of 0 indicates a rectangular window, and a taper of 1
%       indicates a Hann window.
%
%       For phase-amplitude coupling, a second frequency and phase can be
%       indicated. The base frequency will have its maximum amplitude at
%       90-degree phase (.25) of this second frequency. The base
%       frequency's minimal amplitude (at .75 of the second frequency) can 
%       be indicated separately as well.
%
%       Deviations and slopes can be indicated for all variables.
%       A deviation of x indicates that 99.7% (six sigma) of the final 
%       simulated values will be between +/- x of the indicated base value,
%       following a normal distribution. 
%       A slope indicates a systematic change from the first epoch to the
%       last. A slope of -100 indicates that on the last epoch, the
%       simulated value will be (on average, if any deviations are also
%       indicated) 100 less than in the first epoch.
%
%       The probability can range from 0 (this ERSP signal will never be
%       generated) to 1 (this signal will be generated for every single
%       epoch). 
%
%       A complete ERSP class definition includes the following fields:
%
%         .type:                 class type (must be 'ersp')
%         .frequency:            base frequency in Hz
%         .frequencyDv:          base frequency deviation in Hz
%         .frequencySlope:       base frequency slope in Hz
%         .phase:                base frequency phase at the start of the
%                                epoch, between 0 and 1, or [] for a random
%                                phase
%         .phaseDv:              base frequency phase deviation
%         .phaseSlope:           base frequency phase slope
%         .amplitude:            amplitude of the base frequency, in uV
%         .amplitudeDv:          amplitude deviation
%         .amplitudeSlope:       amplitude slope
%         .probability:          probability of appearance, between 0 and 1
%         .probabilitySlope:     probability slope
%         .modulation:           type of modulation to apply to the base
%                                frequency, 'none', 'burst', 'invburst', or
%                                'pac'
%
%       In case modulation is set to 'burst' or 'invburst', the following
%       additional fields are included:
%
%         .burstLatency:        latency in ms of the burst centre
%         .burstLatencyDv:      latency deviation
%         .burstLatencySlope:   latency slope
%         .burstWidth:          width of the width in ms (one-sided)
%         .burstWidthDv:        width deviation
%         .burstWidthSlope:     width slope
%         .burstTaper:          taper of the tukey window, between 0 and 1
%         .burstTaperDv:        taper deviation
%         .burstTaperSlope:     taper slope
%
%       In case modulation is set to 'pac', the following additional fields 
%       are included:
%
%         .pacFrequency:          frequency of the modulating signal, in Hz
%         .pacFrequencyDv:        modulating frequency deviation
%         .pacFrequencySlope:     modulating frequency slope
%         .pacPhase:              phase of the modulation frequency
%         .pacPhaseDv:            modulating frequency phase deviation
%         .pacPhaseSlope:         modulating frequency phase slope
%         .pacMinAmplitude:       minimum amplitude of the base signal as a
%                                 percentage of the base amplitude
%         .pacMinAmplitudeDv:     minimum amplitude deviation
%         .pacMinAmplitudeSlope:  minimum amplitude slope
%
% In:
%       class - the class variable as a struct with at least the required
%               fields: frequency, phase, amplitude, and modulation
%
% Out:  
%       class - the class variable struct with all fields completed
%
% Usage example:
%       >> ersp.frequency = 20; ersp.amplitude = 1;
%       >> ersp.modulation = 'pac'; ersp.pacFrequency = 1;
%       >> ersp.pacPhase = -.25; ersp.pacMinAmplitude = .1;
%       >> ersp = ersp_check_class(ersp)
% 
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

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

function class = ersp_check_class(class)

% checking for required variables
if ~isfield(class, 'frequency')
    error('field frequency is missing from given ERSP class variable');
elseif ~isfield(class, 'amplitude')
    error('field amplitude is missing from given ERSP class variable');
end

% adding fields / filling in defaults
if ~isfield(class, 'type') || isempty(class.type)
    class.type = 'ersp'; end

if ~isfield(class, 'frequencyDv')
    class.frequencyDv = 0; end
if ~isfield(class, 'frequencySlope')
    class.frequencySlope = 0; end

if ~isfield(class, 'phase')
    class.phase = []; end
if ~isfield(class, 'phaseDv')
    class.phaseDv = 0; end
if ~isfield(class, 'phaseSlope')
    class.phaseSlope = 0; end

if ~isfield(class, 'amplitudeDv')
    class.amplitudeDv = 0; end
if ~isfield(class, 'amplitudeSlope')
    class.amplitudeSlope = 0; end

if ~isfield(class, 'probability')
    class.probability = 1; end
if ~isfield(class, 'probabilitySlope')
    class.probabilitySlope = 0; end

if ~isfield(class, 'modulation')
    class.modulation = 'none'; end

if ~ismember(class.modulation, {'none', 'burst', 'invburst', 'pac'})
    error('unknown modulation type'); end

if ismember(class.modulation, {'burst', 'invburst'})
    if ~isfield(class, 'burstLatency')
        error('field burstLatency is missing from given burst-modulated ERSP class variable');
    elseif ~isfield(class, 'burstWidth')
        error('field burstWidth is missing from given burst-modulated ERSP class variable');
    elseif ~isfield(class, 'burstTaper')
        error('field burstTaper is missing from given burst-modulated ERSP class variable');
    end
    
    if ~isfield(class, 'burstLatencyDv')
        class.burstLatencyDv = 0; end
    if ~isfield(class, 'burstLatencySlope')
        class.burstLatencySlope = 0; end
    
    if ~isfield(class, 'burstWidthDv')
        class.burstWidthDv = 0; end
    if ~isfield(class, 'burstWidthSlope')
        class.burstWidthSlope = 0; end
    
    if ~isfield(class, 'burstTaperDv')
        class.burstTaperDv = 0; end
    if ~isfield(class, 'burstTaperSlope')
        class.burstTaperSlope = 0; end
elseif strcmp(class.modulation, 'pac')
    if ~isfield(class, 'pacFrequency')
        error('field pacFrequency is missing from given PAC-modulated ERSP class variable');
    end
    
    if ~isfield(class, 'pacFrequencyDv')
        class.pacFrequencyDv = 0; end
    if ~isfield(class, 'pacFrequencySlope')
        class.pacFrequencySlope = 0; end
    
    if ~isfield(class, 'pacPhase')
        class.pacPhase = []; end
    if ~isfield(class, 'pacPhaseDv')
        class.pacPhaseDv = 0; end
    if ~isfield(class, 'pacPhaseSlope')
        class.pacPhaseSlope = 0; end
    
    if ~isfield(class, 'pacMinAmplitude')
        class.pacMinAmplitude = 0; end
    if ~isfield(class, 'pacMinAmplitudeDv')
        class.pacMinAmplitudeDv = 0; end
    if ~isfield(class, 'pacMinAmplitudeSlope')
        class.pacMinAmplitudeSlope = 0; end
end

class = orderfields(class);

% checking values
if isfield(class, 'burstWidth') && (class.burstWidth - class.burstWidthDv - class.burstWidthSlope < 1)
    warning('some burst widths may become zero or less due to the indicated deviation; this may lead to unexpected results'); end

end
