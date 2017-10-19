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
%       The base frequency can be defined by a single frequency in Hz, its
%       amplitude, and optionally, its phase. Alternatively, a frequency
%       band can be indicated. A frequency of [8, 12] for example will
%       result in a base signal with spectral power between 8 and 12 Hz. In
%       case a frequency band is indicated, phase will be ignored.
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
%       Additionally, a prestimulus period can be indicated to attenuate
%       the signal during that time, using an inverse window as above.
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
%         .frequency:            base frequency, or [low, high] in Hz
%         .frequencyDv:          frequency or [low, high] deviation in Hz
%         .frequencySlope:       frequency or [low, high] slope in Hz
%         .phase:                base frequency phase at the start of the
%                                epoch, between 0 and 1, or [] for a random
%                                phase
%         .phaseDv:              base frequency phase deviation
%         .phaseSlope:           base frequency phase slope
%         .amplitude:            amplitude of the base signal, in uV
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
%         .modLatency:            latency in ms of the burst centre
%         .modLatencyDv:          latency deviation
%         .modLatencySlope:       latency slope
%         .modWidth:              width of the width in ms (one-sided)
%         .modWidthDv:            width deviation
%         .modWidthSlope:         width slope
%         .modTaper:              taper of the tukey window between 0 and 1
%         .modTaperDv:            taper deviation
%         .modTaperSlope:         taper slope
%         .modMinAmplitude:       minimum amplitude of the base signal as a
%                                 percentage of the base amplitude
%         .modMinAmplitudeDv:     minimum amplitude deviation
%         .modMinAmplitudeSlope:  minimum amplitude slope
%
%       In case modulation is set to 'pac', the following additional fields 
%       are included:
%
%         .modFrequency:          frequency of the modulating signal, in Hz
%         .modFrequencyDv:        modulating frequency deviation
%         .modFrequencySlope:     modulating frequency slope
%         .modPhase:              phase of the modulation frequency
%         .modPhaseDv:            modulating frequency phase deviation
%         .modPhaseSlope:         modulating frequency phase slope
%         .modMinAmplitude:       minimum amplitude of the base signal as a
%                                 percentage of the base amplitude
%         .modMinAmplitudeDv:     minimum amplitude deviation
%         .modMinAmplitudeSlope:  minimum amplitude slope
%         .modPrestimPeriod:      length in ms of the prestimulus period
%                                 during which to attenuate the signal;
%                                 default 0 disables
%         .modPrestimTaper:       taper of the window to use to apply a
%                                 prestimulus attenuation; 0 >= taper < 1;
%                                 default: 0
%         .modPrestimAmplitude:   amplitude during prestimulus period, as a
%                                 percentage of the base amplitude;
%                                 default: 0
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
%       >> ersp.modulation = 'pac'; ersp.modFrequency = 1;
%       >> ersp.modPhase = -.25; ersp.modMinAmplitude = .1;
%       >> ersp = ersp_check_class(ersp)
% 
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2017-10-19 lrk
%   - Added broadband base activation
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

function class = ersp_check_class(class)

% checking for required variables
if ~isfield(class, 'frequency')
    error('SEREEGA:ersp_check_class:missingField', 'field ''frequency'' is missing from given ERSP class variable');
elseif ~isfield(class, 'amplitude')
    error('SEREEGA:ersp_check_class:missingField', 'field ''amplitude'' is missing from given ERSP class variable');
elseif ~isfield(class, 'amplitude')
    error('SEREEGA:ersp_check_class:missingField', 'field ''modulation'' is missing from given ERSP class variable');
end

if ismember(class.modulation, {'burst', 'invburst'})
    if ~isfield(class, 'modLatency')
        error('SEREEGA:ersp_check_class:missingField', 'field ''modLatency'' is missing from given burst-modulated ERSP class variable');
    elseif ~isfield(class, 'modWidth')
        error('SEREEGA:ersp_check_class:missingField', 'field ''modWidth'' is missing from given burst-modulated ERSP class variable');
    elseif ~isfield(class, 'modTaper')
        error('SEREEGA:ersp_check_class:missingField', 'field ''modTaper'' is missing from given burst-modulated ERSP class variable');
    end
    
    if ~isfield(class, 'modFrequency')
        class.modFrequency = NaN; end
elseif strcmp(class.modulation, 'pac')
    if ~isfield(class, 'modFrequency')
        error('SEREEGA:ersp_check_class:missingField', 'field ''modFrequency'' is missing from given PAC-modulated ERSP class variable');
    end
    
    if ~isfield(class, 'modLatency')
        class.modLatency = NaN; end
    if ~isfield(class, 'modWidth')
        class.modWidth = NaN; end
    if ~isfield(class, 'modTaper')
        class.modTaper = NaN; end
elseif strcmp(class.modulation, 'none')
    if ~isfield(class, 'modFrequency')
        class.modFrequency = NaN; end
    if ~isfield(class, 'modLatency')
        class.modLatency = NaN; end
    if ~isfield(class, 'modWidth')
        class.modWidth = NaN; end
    if ~isfield(class, 'modTaper')
        class.modTaper = NaN; end
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
    error('SEREEGA:ersp_check_class:unknownFieldValue', 'unknown modulation type ''%s''', class.modulation); end
   
% burst modulation variables
if ~isfield(class, 'modLatencyDv')
    class.modLatencyDv = 0; end
if ~isfield(class, 'modLatencySlope')
    class.modLatencySlope = 0; end

if ~isfield(class, 'modWidthDv')
    class.modWidthDv = 0; end
if ~isfield(class, 'modWidthSlope')
    class.modWidthSlope = 0; end

if ~isfield(class, 'modTaperDv')
    class.modTaperDv = 0; end
if ~isfield(class, 'modTaperSlope')
    class.modTaperSlope = 0; end

if ~isfield(class, 'modMinAmplitude')
    class.modMinAmplitude = 0; end
if ~isfield(class, 'modMinAmplitudeDv')
    class.modMinAmplitudeDv = 0; end
if ~isfield(class, 'modMinAmplitudeSlope')
    class.modMinAmplitudeSlope = 0; end
    
% PAC modulation variables
if ~isfield(class, 'modFrequencyDv')
    class.modFrequencyDv = 0; end
if ~isfield(class, 'modFrequencySlope')
    class.modFrequencySlope = 0; end

if ~isfield(class, 'modPhase')
    class.modPhase = []; end
if ~isfield(class, 'modPhaseDv')
    class.modPhaseDv = 0; end
if ~isfield(class, 'modPhaseSlope')
    class.modPhaseSlope = 0; end

if ~isfield(class, 'modMinAmplitude')
    class.modMinAmplitude = 0; end
if ~isfield(class, 'modMinAmplitudeDv')
    class.modMinAmplitudeDv = 0; end
if ~isfield(class, 'modMinAmplitudeSlope')
    class.modMinAmplitudeSlope = 0; end

if ~isfield(class, 'modPrestimPeriod')
    class.modPrestimPeriod = 0; end
if ~isfield(class, 'modPrestimTaper')
    class.modPrestimTaper = 0; end
if ~isfield(class, 'modPrestimAmplitude')
    class.modPrestimAmplitude = 0; end
    
% checking values
if numel(class.frequency) == 1
    if class.frequency - class.frequencyDv - class.frequencySlope <= 0
        warning('some frequencies may zero or less due to the indicated deviation; this may lead to unexpected results');
    end
elseif numel(class.frequency) == 2
    if ~(numel(class.frequencyDv) == 2 && numel(class.frequencySlope) == 2)
        class.frequencyDv = [class.frequencyDv, class.frequencyDv];
        class.frequencySlope = [class.frequencySlope, class.frequencySlope];
    end
    if class.frequency(1) - class.frequencyDv(1) - class.frequencySlope(1) < 2
        error('SEREEGA:ersp_check_class:incorrectFieldValue', 'lower edge of the frequency band must be at least 2 Hz');
    end
end

if class.modWidth - class.modWidthDv - class.modWidthSlope < 1
    warning('some burst widths may become zero or less due to the indicated deviation; this may lead to unexpected results'); end

if class.modPrestimTaper < 0 || class.modPrestimTaper >= 1
    error('SEREEGA:ersp_check_class:incorrectFieldValue', 'prestimulus taper should be greater than or equal to 0, and less than 1'); end

class = orderfields(class);

end
