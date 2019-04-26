% signal = ersp_generate_signal_fromclass(class, epochs, varargin)
%
%       Takes an ERSP activation class, determines single parameters given
%       the deviations/slopes in the class, and returns a signal generated
%       using those parameters.
%
% In:
%       class - 1x1 struct, the class variable
%       epochs - single epoch configuration struct containing at least
%                sampling rate in Hz (field name 'srate'), epoch length in ms
%                 ('length'), and the total number of epochs ('n')
%
% Optional (key-value pairs):
%       epochNumber - current epoch number. this is required for slope
%                     calculation, but defaults to 1 if not indicated
%       baseonly - whether or not to only generate the base signal, without
%                  any deviations or slopes (1|0, default 0)
%
% Out:  
%       signal - row array containing the simulated noise activation signal
%
% Usage example:
%       >> epochs = struct('n', 100, 'srate', 1000, 'length', 1000);
%       >> ersp = struct('frequency', 20, 'amplitude', 1, 'phase', 0, ...
%       >>      'modulation', 'ampmod', 'modFrequency', 2, ...
%       >>      'modPhase', -.25);
%       >> ersp = utl_check_class(ersp, 'type', 'ersp');
%       >> signal = ersp_generate_signal_fromclass(ersp, epochs);
% 
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2018-06-04 lrk
%   - Added frequencyShift
% 2017-11-24 lrk
%   - Renamed 'pac' to 'ampmod' and replaced references accordingly
% 2017-11-22 lrk
%   - Renamed parameters modMinAmplitude and modPrestimAmplitude to 
%     modMinRelAmplitude and modPrestimRelAmplitude for clarity
% 2017-10-19 lrk
%   - Added broadband base activation
% 2017-07-13 lrk
%   - Fixed bug where modMinRelAmplitude was ignored for burst/invburst
%     baseonly signal
% 2017-06-20 lrk
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

function signal = ersp_generate_signal_fromclass(class, epochs, varargin)

% parsing input
p = inputParser;

addRequired(p, 'class', @isstruct);
addRequired(p, 'epochs', @isstruct);

addParameter(p, 'epochNumber', 1, @isnumeric);
addParameter(p, 'baseonly', 0, @isnumeric);

parse(p, class, epochs, varargin{:})

class = p.Results.class;
epochs = p.Results.epochs;
epochNumber = p.Results.epochNumber;
baseonly = p.Results.baseonly;

if baseonly
    % generating base signal    
    if strcmp(class.modulation, 'none')
        signal = ersp_generate_signal(class.frequency, class.amplitude, class.phase, epochs.srate, epochs.length);
    elseif ismember(class.modulation, {'burst', 'invburst'})
        signal = ersp_generate_signal(class.frequency, class.amplitude, class.phase, epochs.srate, epochs.length, ...
                'modulation', class.modulation, 'modLatency', class.modLatency, 'modWidth', class.modWidth, 'modTaper', class.modTaper, 'modMinRelAmplitude', class.modMinRelAmplitude);
    elseif strcmp(class.modulation, 'ampmod')
        signal = ersp_generate_signal(class.frequency, class.amplitude, class.phase, epochs.srate, epochs.length, ...
                'modulation', class.modulation, 'modFrequency', class.modFrequency, 'modPhase', class.modPhase, 'modMinRelAmplitude', class.modMinRelAmplitude, ...
                'modPrestimPeriod', class.modPrestimPeriod, 'modPrestimTaper', class.modPrestimTaper, 'modPrestimRelAmplitude', class.modPrestimRelAmplitude);
    end
else
    % checking probability
    if rand() > class.probability + class.probabilitySlope * epochNumber / epochs.n
        % returning flatline
        signal = zeros(1, floor((epochs.length/1000)*epochs.srate));
    else

        % obtaining specific base values
        frequency = utl_apply_dvslopeshift(class.frequency, class.frequencyDv, class.frequencySlope, epochNumber, epochs.n, class.frequencyShift);
        amplitude = utl_apply_dvslopeshift(class.amplitude, class.amplitudeDv, class.amplitudeSlope, epochNumber, epochs.n);
                
        if ~isempty(class.phase)
            phase = utl_apply_dvslopeshift(class.phase, class.phaseDv, class.phaseSlope, epochNumber, epochs.n);
        else
            phase = class.phase;
        end

        if strcmp(class.modulation, 'none')
            % generating signal
            signal = ersp_generate_signal(frequency, amplitude, phase, epochs.srate, epochs.length);
        elseif ismember(class.modulation, {'burst', 'invburst'})
            % obtaining specific burst values
            latency = utl_apply_dvslopeshift(class.modLatency, class.modLatencyDv, class.modLatencySlope, epochNumber, epochs.n);
            width = utl_apply_dvslopeshift(class.modWidth, class.modWidthDv, class.modWidthSlope, epochNumber, epochs.n);
            taper = utl_apply_dvslopeshift(class.modTaper, class.modTaperDv, class.modTaperSlope, epochNumber, epochs.n);
            minAmplitude = utl_apply_dvslopeshift(class.modMinRelAmplitude, class.modMinRelAmplitudeDv, class.modMinRelAmplitudeSlope, epochNumber, epochs.n);

            % generating signal
            signal = ersp_generate_signal(frequency, amplitude, phase, epochs.srate, epochs.length, ...
                    'modulation', class.modulation, 'modLatency', latency, 'modWidth', width, 'modTaper', taper, 'modMinRelAmplitude', minAmplitude);
        elseif strcmp(class.modulation, {'ampmod'})
            % obtaining specific amplitude modulation values
            modFrequency = utl_apply_dvslopeshift(class.modFrequency, class.modFrequencyDv, class.modFrequencySlope, epochNumber, epochs.n);
            minAmplitude = utl_apply_dvslopeshift(class.modMinRelAmplitude, class.modMinRelAmplitudeDv, class.modMinRelAmplitudeSlope, epochNumber, epochs.n);
            if ~isempty(class.modPhase)
                modPhase = utl_apply_dvslopeshift(class.modPhase, class.modPhaseDv, class.modPhaseSlope, epochNumber, epochs.n);
            else
                modPhase = class.modPhase;
            end 

            % generating signal
            signal = ersp_generate_signal(frequency, amplitude, phase, epochs.srate, epochs.length, ...
                    'modulation', class.modulation, 'modFrequency', modFrequency, 'modPhase', modPhase, 'modMinRelAmplitude', minAmplitude, ...
                    'modPrestimPeriod', class.modPrestimPeriod, 'modPrestimTaper', class.modPrestimTaper, 'modPrestimRelAmplitude', class.modPrestimRelAmplitude);
        end

    end
end

end