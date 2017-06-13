% class = erp_check_class(class)
%
%       Validates and completes an ERP class structure.
%
%       ERPs are defined by peak latencies, widths, and amplitudes.
%       additionally, the variability of each of these is indicated using a
%       possible deviation (Dv), and slope. 
%
%       for a peak at 400 ms with a width of 100 and a slope of 100, 99.7%
%       (six sigma) of the peak will be between 300 and 500 ms on the first
%       epoch. on the final epoch, due to the slope, the peak will be 100
%       ms later, between 400 and 600 ms.
%
%       deviations represent the trial-to-trial variability. a deviation of
%       20 for a peak at 400 ms means that the peak latency varies
%       according to a normal distribution, with 99.7% of peaks being
%       centered between 380 and 420 ms.
%
%       a complete ERP class definition includes the following fields:
%
%         type:                 class type (must be 'erp')
%         peakLatency:          1-by-n matrix of peak latencies
%         peakLatencyDv:        1-by-n matrix of peak latency deviations
%         peakLatencySlope:     1-by-n matrix of peak latency slopes
%         peakWidth:            1-by-n matrix of peak widths
%         peakWidthDv:          1-by-n matrix of peak width deviations
%         peakWidthSlope:       1-by-n matrix of peak width slopes
%         peakAmplitude:        1-by-n matrix of peak amplitudes
%         peakAmplitudeDv:      1-by-n matrix of peak amplitude deviations
%         peakAmplitudeSlope:   1-by-n matrix of peak amplitude slopes
%
% In:
%       class - the class variable as a struct with at least the required
%               fields: peakLatency, peakWidth, and peakAmplitude
%
% Out:  
%       class - the class variable with all fields completed
%
% Usage example:
%       >> erp.peakLatency = 200;
%       >> erp.peakWidth = 100;
%       >> erp.peakAmplitude = 1;
%       >> erp = erp_check_class(erp)
% 
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

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
    error('field peakLatency is missing from given ERP class variable');
elseif ~isfield(class, 'peakWidth')
    error('field peakWidth is missing from given ERP class variable');
elseif ~isfield(class, 'peakAmplitude')
    error('field peakAmplitude is missing from given ERP class variable');
elseif isfield(class, 'type') && ~isempty(class.type) && ~strcmp(class.type, 'erp')
    error('indicated type (''%s'') not set to ''erp''', class.type);
end

% adding fields / filling in defaults
if ~isfield(class, 'type') || isempty(class.type),
    class.type = 'erp'; end

if ~isfield(class, 'peakLatencyDv'),
    class.peakLatencyDv = zeros(1, numel(class.peakLatency)); end

if ~isfield(class, 'peakLatencySlope'),
    class.peakLatencySlope = zeros(1, numel(class.peakLatency)); end

if ~isfield(class, 'peakWidthDv'),
    class.peakWidthDv = zeros(1, numel(class.peakLatency)); end

if ~isfield(class, 'peakWidthSlope'),
    class.peakWidthSlope = zeros(1, numel(class.peakLatency)); end

if ~isfield(class, 'peakAmplitudeDv'),
    class.peakAmplitudeDv = zeros(1, numel(class.peakLatency)); end

if ~isfield(class, 'peakAmplitudeSlope'),
    class.peakAmplitudeSlope = zeros(1, numel(class.peakLatency)); end

class = orderfields(class);

% checking values
fields = fieldnames(class);
for f = 1:length(fields)
    if ~isrow(class.(fields{f})),
        error('field ''%s'' is not a row vector', fields{f}); end
end

if ~isequal(numel(class.peakLatency), numel(class.peakLatencyDv), numel(class.peakLatencySlope), ...
            numel(class.peakWidth), numel(class.peakWidthDv), numel(class.peakWidthSlope), ...
            numel(class.peakAmplitude), numel(class.peakAmplitudeDv), numel(class.peakAmplitudeSlope)),
        error('all peak* fields must be of the same length'); end
    
if any(class.peakLatency < 0),
    error('ERP peak latencies cannot be less than zero'); end

if any(class.peakWidth <= 0),
    error('ERP peak widths cannot be zero or less'); end

end
