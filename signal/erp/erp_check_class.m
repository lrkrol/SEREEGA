% class = erp_check_class(class)
%
%       Validates and completes an ERP class structure.
%
%       ERPs are defined by peak latencies, widths, and amplitudes.
%       Additionally, the epoch-to-epoch variability of each of these is
%       indicated using a possible deviation (Dv), and the change over time
%       is indicated using a slope. Finally, a probability can be set for
%       the appearance of the signal as a whole.
%
%       For a peak at 400 ms latency, a width of 100 and a slope of 100, 
%       99.7% (six sigma) of the peak will be between 350 and 450 ms on the 
%       first epoch. On the final epoch, due to the slope, the peak will be 
%       100 ms later, between 450 and 550 ms. A slope of 0 means nothing
%       will change over time (barring any indicated deviations).
%
%       Deviations represent the epoch-to-epoch (trial-to-trial)
%       variability. A deviation of 20 for a peak at 400 ms means that the
%       centre peak latency varies according to a normal distribution,
%       between 380 and 420 ms. A deviation of 0 means all signals will be
%       exactly the same (barring any sloping).
%
%       Deviations apply to each peak indivdiually. The peakLatencyShift
%       works in the same way, but applies to all peaks equally, shifting
%       the entire ERP for each epoch.
%
%       The probability can range from 0 (this ERP signal will never be
%       generated) to 1 (this ERP signal will be generated for every single
%       epoch). 
%
%       A complete ERP class definition includes the following fields:
%
%         .type:                 class type (must be 'erp')
%         .peakLatency:          1-by-n matrix of peak latencies
%         .peakLatencyDv:        1-by-n matrix of peak latency deviations
%         .peakLatencySlope:     1-by-n matrix of peak latency slopes
%         .peakLatencyShift:     value indicating maximum absolute peak 
%                                latency deviation applied equally to all
%                                peaks
%         .peakWidth:            1-by-n matrix of peak widths
%         .peakWidthDv:          1-by-n matrix of peak width deviations
%         .peakWidthSlope:       1-by-n matrix of peak width slopes
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
%       >> erp = struct();
%       >> erp.peakLatency = 200;
%       >> erp.peakWidth = 100;
%       >> erp.peakAmplitude = 1;
%       >> erp = erp_check_class(erp)
% 
%                    Copyright 2017, 2018 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2021-09-27 lrk
%   - updated documentation to reflect 2018-06-04 utl_apply_dvslopeshift change
% 2018-06-04 lrk
%   - Added peakLatencyShift
% 2017-10-19 lrk
%   - Changed the width parameter to mean full width, not half width
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

function class = erp_check_class(class)

% checking for required variables
if ~isfield(class, 'peakLatency')
    error('SEREEGA:erp_check_class:missingField', 'field ''peakLatency'' is missing from given ERP class variable');
elseif ~isfield(class, 'peakWidth')
    error('SEREEGA:erp_check_class:missingField', 'field ''peakWidth'' is missing from given ERP class variable');
elseif ~isfield(class, 'peakAmplitude')
    error('SEREEGA:erp_check_class:missingField', 'field ''peakAmplitude'' is missing from given ERP class variable');
elseif isfield(class, 'type') && ~isempty(class.type) && ~strcmp(class.type, 'erp')
    error('SEREEGA:erp_check_class:incorrectFieldValue', 'indicated type (''%s'') not set to ''erp''', class.type);
elseif isfield(class, 'peakLatencyShift') && numel(class.peakLatencyShift) ~= 1
    error('SEREEGA:erp_check_class:incorrectFieldValue', 'peakLatencyShift must be a single value');
end

% adding fields / filling in defaults
if ~isfield(class, 'type') || isempty(class.type)
    class.type = 'erp'; end

if ~isfield(class, 'peakLatencyDv')
    class.peakLatencyDv = zeros(1, numel(class.peakLatency)); end

if ~isfield(class, 'peakLatencySlope')
    class.peakLatencySlope = zeros(1, numel(class.peakLatency)); end

if ~isfield(class, 'peakLatencyShift')
    class.peakLatencyShift = 0; end

if ~isfield(class, 'peakWidthDv')
    class.peakWidthDv = zeros(1, numel(class.peakLatency)); end

if ~isfield(class, 'peakWidthSlope')
    class.peakWidthSlope = zeros(1, numel(class.peakLatency)); end

if ~isfield(class, 'peakAmplitudeDv')
    class.peakAmplitudeDv = zeros(1, numel(class.peakLatency)); end

if ~isfield(class, 'peakAmplitudeSlope')
    class.peakAmplitudeSlope = zeros(1, numel(class.peakLatency)); end

if ~isfield(class, 'probability')
    class.probability = 1; end

if ~isfield(class, 'probabilitySlope')
    class.probabilitySlope = 0; end

class = orderfields(class);

% checking values
fields = fieldnames(class);
for f = 1:length(fields)
    if ~isrow(class.(fields{f}))
        class.(fields{f}) = class.(fields{f})';
end

if ~isequal(numel(class.peakLatency), numel(class.peakLatencyDv), numel(class.peakLatencySlope), ...
            numel(class.peakWidth), numel(class.peakWidthDv), numel(class.peakWidthSlope), ...
            numel(class.peakAmplitude), numel(class.peakAmplitudeDv), numel(class.peakAmplitudeSlope))
    error('SEREEGA:erp_check_class:incorrectFieldValue', 'all peak* fields must be of the same length'); end
    
if any(class.peakLatency < 0)
    error('SEREEGA:erp_check_class:incorrectFieldValue', 'ERP peak latencies cannot be less than zero'); end

if any(class.peakWidth <= 0)
    error('SEREEGA:erp_check_class:incorrectFieldValue', 'ERP peak widths cannot be zero or less'); end

if any(class.peakWidth - class.peakWidthDv < 1)
    warning('some peak widths may become zero or less due to the indicated deviation; this may lead to unexpected results'); end

end
