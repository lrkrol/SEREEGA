% signal = ersp_generate_signal_fromclass(class, epochs, epochNumber)
%
%       Takes an ERSP activation class, determines single parameters given
%       the deviations/slopes in the class, and returns a signal generated
%       using those parameters.
%
% In:
%       class - 1x1 struct, the class variable
%       epochs - single epoch configuration struct containing at least
%                sampling rate (srate), epoch length (length), and total
%                number of epochs (n)
%       epochNumber - current epoch number (required for slope calculation)
%
% Out:  
%       signal - row array containing the simulated noise activation signal
%
% Usage example:
%       >> epochs.n = 100; epochs.srate = 500; epochs.length = 1000;
%       >> ersp.frequency = 20; ersp.amplitude = 1; ersp.phase = 0;
%       >> ersp.modulation='pac'; ersp.pacFrequency=2; ersp.pacPhase= -.25;
%       >> signal = ersp_generate_signal_fromclass(ersp, epochs, 1);
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

function signal = ersp_generate_signal_fromclass(class, epochs, epochNumber)

% checking probability
if rand() > class.probability + class.probabilitySlope * epochNumber / epochs.n
    % returning flatline
    signal = zeros(1, floor((epochs.length/1000)*epochs.srate));
else

    % obtaining specific base frequency values
    frequency = utl_apply_dvslope(class.frequency, class.frequencyDv, class.frequencySlope, epochNumber, epochs.n);
    amplitude = utl_apply_dvslope(class.amplitude, class.amplitudeDv, class.amplitudeSlope, epochNumber, epochs.n);
    if ~isempty(class.phase)
        phase = utl_apply_dvslope(class.phase, class.phaseDv, class.phaseSlope, epochNumber, epochs.n);
    else
        phase = class.phase;
    end
    
    if strcmp(class.modulation, 'none')
        % generating signal
        signal = ersp_generate_signal(frequency, amplitude, phase, epochs.srate, epochs.length);
    elseif ismember(class.modulation, {'burst', 'invburst'})
        % obtaining specific burst values
        latency = utl_apply_dvslope(class.burstLatency, class.burstLatencyDv, class.burstLatencySlope, epochNumber, epochs.n);
        width = utl_apply_dvslope(class.burstWidth, class.burstWidthDv, class.burstWidthSlope, epochNumber, epochs.n);
        taper = utl_apply_dvslope(class.burstTaper, class.burstTaperDv, class.burstTaperSlope, epochNumber, epochs.n);
        
        % generating signal
        signal = ersp_generate_signal(frequency, amplitude, phase, epochs.srate, epochs.length, ...
                'modulation', class.modulation, 'burstLatency', latency, 'burstWidth', width, 'burstTaper', taper);
    elseif strcmp(class.modulation, {'pac'})
        % obtaining specific pac values
        pacFrequency = utl_apply_dvslope(class.pacFrequency, class.pacFrequencyDv, class.pacFrequencySlope, epochNumber, epochs.n);
        minAmplitude = utl_apply_dvslope(class.pacMinAmplitude, class.pacMinAmplitudeDv, class.pacMinAmplitudeSlope, epochNumber, epochs.n);
        if ~isempty(class.pacPhase)
            pacPhase = utl_apply_dvslope(class.pacPhase, class.pacPhaseDv, class.pacPhaseSlope, epochNumber, epochs.n);
        else
            pacPhase = class.pacPhase;
        end 
        
        % generating signal
        signal = ersp_generate_signal(frequency, amplitude, phase, epochs.srate, epochs.length, ...
                'modulation', class.modulation, 'pacFrequency', pacFrequency, 'pacPhase', pacPhase, 'pacMinAmplitude', minAmplitude);
    end
    
end

end