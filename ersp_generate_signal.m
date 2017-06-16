% signal = ersp_generate_signal(frequency, amplitude, phase, srate, epochLength)
%
%       Returns an frequency-based activation signal generated using the 
%       given base frequency and optional modulation.
%
% In:
%       frequency - base frequency in Hz
%       amplitude - maximum amplitude in uV
%       phase - phase of the base frequency, between 0 and 1, or [] for a
%               random phase
%       srate - sampling rate of the produced signal, in Hz
%       epochLength - length of the epoch, in ms
%
% Optional (key-value pairs):
%       modulation - type of modulation to apply; 'none', 'burst',
%                    'invburst' or 'pac'
%       burstLatency - latency in ms of the burst centre
%       burstWidth - width of the width in ms (one-sided)
%       burstTaper - taper of the tukey window, between 0 and 1
%       pacFrequency - frequency of the modulating signal, in Hz
%       pacPhase - phase of the modulation frequency
%       pacMinAmplitude - minimum amplitude of the base signal as a
%                         percentage of the base amplitude
%
% Out:  
%       signal - row array containing the simulated noise activation signal
%
% Usage example:
%       >> ersp_generate_signal(25, 1, [], 500, 1000)
% 
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology


% 2017-06-16 First version by Fabien Lotte

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

function signal = ersp_generate_signal(frequency, amplitude, phase, srate, epochLength, varargin)

% parsing input
p = inputParser;

addRequired(p, 'frequency', @isnumeric);
addRequired(p, 'amplitude', @isnumeric);
addRequired(p, 'phase', @isnumeric);
addRequired(p, 'srate', @isnumeric);
addRequired(p, 'epochLength', @isnumeric);

addParamValue(p, 'modulation', 'none', @ischar);
addParamValue(p, 'burstLatency', 0, @isnumeric);
addParamValue(p, 'burstWidth', 0, @isnumeric);
addParamValue(p, 'burstTaper', 0, @isnumeric);
addParamValue(p, 'pacFrequency', 0, @isnumeric);
addParamValue(p, 'pacPhase', 0, @isnumeric);
addParamValue(p, 'pacMinAmplitude', 0, @isnumeric);

parse(p, frequency, amplitude, phase, srate, epochLength, varargin{:})

frequency = p.Results.frequency;
amplitude = p.Results.amplitude;
phase = p.Results.phase;
srate = p.Results.srate;
epochLength = p.Results.epochLength;
modulation = p.Results.modulation;
burstLatency = p.Results.burstLatency;
burstWidth = p.Results.burstWidth;
burstTaper = p.Results.burstTaper;
pacFrequency = p.Results.pacFrequency;
pacPhase = p.Results.pacPhase;
pacMinAmplitude = p.Results.pacMinAmplitude;

samples = floor(srate * epochLength/1000);

if isempty(phase), phase = rand(); end

% generating the base signal
t = 0:samples-1;
signal = sin(phase*2*pi + 2*pi*frequency*(t/srate));

% normalising
signal = amplitude .* (-1 + 2 .* (signal - min(signal)) ./ (max(signal) - min(signal)));


if ismember(modulation, {'burst', 'invburst'})
    latency = floor((burstLatency/1000)*srate);
    width = floor((burstWidth/1000)*srate) * 2;
    taper = burstTaper;
    
    % generating tukey window for burst
    if width < 1; width = 0; end
    win = tukeywin(width, taper)';
    
    % positioning window around latency
    if latency > ceil(width/2)
        win = [zeros(1, latency - ceil(width/2)), win];
    else
        win(1:ceil(width/2)-latency) = [];
    end
    
    % fitting window to signal
    if length(win) > samples
        win(samples+1:length(win)) = [];
    elseif length(win) < samples
        win = [win, zeros(1, samples - length(win))];
    end
    
    if strcmp(modulation, 'invburst')
        win = 1 - win; end

    % applying modulation
    signal = signal .* win;
elseif strcmp(modulation, 'pac')
    % phase-amplitude coupling
    if isempty(pacPhase), pacPhase = rand(); end

    % generating the modulating signal
    ms = sin(pacPhase*2*pi + 2*pi*pacFrequency*(t/srate));
    
    % normalising between pacMinAmplitude and 1
    ms = pacMinAmplitude + (1-pacMinAmplitude) .* (ms - min(ms)) ./ (max(ms) - min(ms));
    
    % applying the modulation
    signal = signal .* ms;
end

end