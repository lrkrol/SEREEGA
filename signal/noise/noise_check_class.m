% class = noise_check_class(class)
%
%       Validates (and/or completes) a given noise class structure.
%
%       Noise is defined by its colour and its amplitude.
%       Additionally, the epoch-to-epoch variability of the amplitude is
%       indicated using a possible deviation (Dv), and the change over time
%       is indicated using a slope. Finally, a probability can be set for
%       the appearance of the noise signal as a whole.
%
%       The amplitude represents the maximum absolute amplitude of any
%       point in the noise signal.
%
%       The deviation represents the epoch-to-epoch (trial-to-trial) 
%       variability. A deviation of .05 for an amplitude of .1 means that
%       the amplitude varies according to a normal distribution, with 99.7% 
%       of maximum amplitudes being between .05 and .15. A deviation of 0
%       means all signals will be exactly the same (barring any sloping).
%
%       The slope represents the change over time, from the first to the
%       last epoch. An amplitude of .1 with a slope of -.1 will have a
%       maximum amplitude of .1 in the first epoch, and .2 in the last.
%
%       The probability can range from 0 (this signal will never be 
%       generated) to 1 (this signal will be generated for every single
%       epoch). 
%
%       Note: Noise is generated using the ColoredNoise function of the DSP
%       System Toolbox, which was introduced in version R2014a. For older
%       versions of MATLAB, the script reverts to noise generated using
%       the randn() function.
%
%       A complete noise class definition includes the following fields:
%
%         .type:                 class type (must be 'noise')
%         .color:                noise color, 'white', 'pink', 'brown', 
%                                'blue' or 'purple' for gaussian noise. add
%                                '-unif' (e.g. 'brown-unif' for uniform
%                                noise.
%         .peakAmplitude:        1-by-n matrix of peak amplitudes
%         .peakAmplitudeDv:      1-by-n matrix of peak amplitude deviations
%         .peakAmplitudeSlope:   1-by-n matrix of peak amplitude slopes
%         .probability:          0-1 scalar indicating probability of
%                                appearance
%         .probabilitySlope:     scalar, slope of the probability
%
% In:
%       class - the class variable as a struct with at least the required
%               fields: peakLatency, peakWidth, and peakAmplitude
%
% Out:  
%       class - the class variable struct with all fields completed
%
% Usage example:
%       >> noise = struct('color', 'brown', 'amplitude', .1);
%       >> noise = noise_check_class(noise)
% 
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2017-07-06 lrk
%   - Added uniform white noise
% 2017-06-15 First version

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

function class = noise_check_class(class)

% checking for required variables
if ~isfield(class, 'color')
    error('SEREEGA:noise_check_class:missingField', 'field ''color'' is missing from given noise class variable');
elseif ~isfield(class, 'amplitude')
    error('SEREEGA:noise_check_class:missingField', 'field ''amplitude'' is missing from given noise class variable');
elseif isfield(class, 'type') && ~isempty(class.type) && ~strcmp(class.type, 'noise')
    error('SEREEGA:noise_check_class:missingField', 'indicated type (''%s'') not set to ''noise''', class.type);
end

% adding fields / filling in defaults
if ~isfield(class, 'type') || isempty(class.type)
    class.type = 'noise'; end

if ~isfield(class, 'amplitudeDv')
    class.amplitudeDv = 0; end

if ~isfield(class, 'amplitudeSlope')
    class.amplitudeSlope = 0; end

if ~isfield(class, 'probability')
    class.probability = 1; end

if ~isfield(class, 'probabilitySlope')
    class.probabilitySlope = 0; end

class = orderfields(class);

% checking values
if ~ismember(class.color, {'white', 'pink', 'brown', 'blue', 'purple', ...
        'white-unif', 'pink-unif', 'brown-unif', 'blue-unif', 'purple-unif'})
    error('SEREEGA:noise_check_class:unknownFieldValue', 'an unknown noise color is indicated in the given noise class variable'); end

if verLessThan('dsp', '8.6')
    warning(['your DSP version is lower than 8.6 (MATLAB R2014a); ' ...
             'during simulation, noise color settings will be ignored;' ...
             'all gaussian noise will be white noise using randn()']); end
    
end
