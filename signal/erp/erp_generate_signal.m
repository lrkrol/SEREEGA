% signal = erp_generate_signal(peakLatency, peakWidth, peakAmplitude, srate, epochLength)
%
%       Returns an ERP-like activation signal generated using the given
%       peak latencies, widths, and amplitudes.
%
% In:
%       peakLatency - 1-by-n matrix containing the peak latencies, in ms
%       peakWidth - 1-by-n matrix containing the peak widths, in ms
%       peakAmplitude - 1-by-n matrix containing the peak amplitudes, in uV
%       srate - sampling rate of the produced signal, in Hz
%       epochLength - length of the epoch, in ms
%
% Out:  
%       signal - row array containing the simulated noise activation signal
%
% Usage example:
%       >> signal = erp_generate_signal([175, 500], [50, 150], ...
%       >>                              [-.25, 1], 500, 1000)
% 
%                    Copyright 2015-2017 Fabien Lotte & Laurens R Krol
%
%                    Team Potioc
%                    Inria Bordeaux Sud-Ouest/LaBRI, France
% 
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2019-09-18 lrk
%   - Shifted peakLatency one sample to the right since EEG starts counting
%     at 0, not at 1 (GitHub issue #10)
% 2017-10-19 lrk
%   - Changed the width parameter to mean full width, not half width
% 2017-06-13 lrk
%   - Complete revision for inclusion in SAREEGA
%   - Width now represents three-sigma interval, not one-sigma
% 2016-04-19 lrk
%   - Complete revision
%   - Added leadfield normalisation
% 2015-11-27 First version by Fabien Lotte

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

function signal = erp_generate_signal(peakLatency, peakWidth, peakAmplitude, srate, epochLength)

% transforming ms into samples
peakLatency = (peakLatency/1000)*srate + 1;
peakWidth = (peakWidth/1000)*srate;
epochLength = floor((epochLength/1000)*srate);

% generating the signal using summed probability density functions
signal = zeros(1,epochLength);
for p = 1:length(peakLatency)
    % generating separate peak
    peak = normpdf(1:epochLength, peakLatency(p), peakWidth(p)/6);
    
    % if not a flatline, normalising because otherwise sum(peak) == 1
    if any(peak), peak = utl_normalise(peak, peakAmplitude(p)); end
    
    % adding peak to signal
    signal = signal + peak;    
end

end