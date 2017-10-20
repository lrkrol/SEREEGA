% signal = ersp_generate_signal(frequency, amplitude, phase, srate, epochLength)
%
%       Returns an frequency-based activation signal generated using the 
%       given base frequency and optional modulation.
%
% In:
%       frequency - either a single base frequency in Hz, or a [low, high]
%                   frequency band. in the latter case, a white noise
%                   signal will be filtered around the given band, as long
%                   as low >= 2 (due to a 2 Hz transition band); phase will
%                   be ignored.
%       amplitude - maximum amplitude in uV
%       phase - phase of the base frequency, between 0 and 1, or [] for a
%               random phase
%       srate - sampling rate of the produced signal, in Hz
%       epochLength - length of the epoch, in ms
%
% Optional (key-value pairs):
%       modulation - type of modulation to apply; 'none', 'burst',
%                    'invburst' or 'mod'
%       modLatency - latency in ms of the burst centre
%       modWidth - width of the burst in ms (one-sided)
%       modTaper - taper of the burst tukey window, between 0 and 1
%       modFrequency - frequency of the pac modulating signal, in Hz
%       modPhase - phase of the pac modulation frequency
%       modMinAmplitude - minimum amplitude of the base signal as a
%                         percentage of the base amplitude
%       modPrestimPeriod - prestimuls period length in ms
%       modPrestimTaper - tapering of the tukey window used to apply a
%                         prestimulus signal attenuation; 0 <= taper < 1
%       modPrestimAmplitude - amplitude of the prestimulus signal as a
%                             percentage of the base amplitude
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

% 2017-10-19 lrk
%   - Added broadband base activation
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

function signal = ersp_generate_signal(frequency, amplitude, phase, srate, epochLength, varargin)

% parsing input
p = inputParser;

addRequired(p, 'frequency', @isnumeric);
addRequired(p, 'amplitude', @isnumeric);
addRequired(p, 'phase', @isnumeric);
addRequired(p, 'srate', @isnumeric);
addRequired(p, 'epochLength', @isnumeric);

addParameter(p, 'modulation', 'none', @ischar);
addParameter(p, 'modLatency', 0, @isnumeric);
addParameter(p, 'modWidth', 0, @isnumeric);
addParameter(p, 'modTaper', 0, @isnumeric);
addParameter(p, 'modFrequency', 0, @isnumeric);
addParameter(p, 'modPhase', 0, @isnumeric);
addParameter(p, 'modMinAmplitude', 0, @isnumeric);
addParameter(p, 'modPrestimPeriod', 0, @isnumeric);
addParameter(p, 'modPrestimTaper', 0, @isnumeric);
addParameter(p, 'modPrestimAmplitude', 0, @isnumeric);

parse(p, frequency, amplitude, phase, srate, epochLength, varargin{:})

frequency = p.Results.frequency;
amplitude = p.Results.amplitude;
phase = p.Results.phase;
srate = p.Results.srate;
epochLength = p.Results.epochLength;
modulation = p.Results.modulation;
modLatency = p.Results.modLatency;
modWidth = p.Results.modWidth;
modTaper = p.Results.modTaper;
modFrequency = p.Results.modFrequency;
modPhase = p.Results.modPhase;
modMinAmplitude = p.Results.modMinAmplitude;
modPrestimPeriod = p.Results.modPrestimPeriod;
modPrestimTaper = p.Results.modPrestimTaper;
modPrestimAmplitude = p.Results.modPrestimAmplitude;

samples = floor(srate * epochLength/1000);

if isempty(phase), phase = rand(); end

% generating the base signal
if numel(frequency) == 1
    % single frequency
    t = (0:samples-1)/srate;
    signal = sin(phase*2*pi + 2*pi*frequency*t);
elseif numel(frequency) == 2
    % bandpass-filtered white noise
    if verLessThan('dsp', '8.6')
        warning(['your DSP version is lower than 8.6 (MATLAB R2014a); ' ...
                 'cannot produce broadband activation, taking mean instead']);
        t = (0:samples-1)/srate;
        frequency = mean(frequency);
        signal = sin(phase*2*pi + 2*pi*frequency*t);
    else
        % base white noise with two-second padding
        signal = rand(1, samples + 2*srate) - .5;
        
        % filtering
        D = designfilt('bandpassiir', ...
                'SampleRate', srate, ...
                'StopbandFrequency1', frequency(1) - 2, ...
                'PassbandFrequency1', frequency(1), ...
                'PassbandFrequency2', frequency(2), ...
                'StopbandFrequency2', frequency(2) + 2, ...
                'DesignMethod', 'butter');
        signal = filtfilt(D, signal);
        
        % removing padding
        signal = signal(srate+1:end-srate);
    end
end

% normalising
signal = amplitude .* (-1 + 2 .* (signal - min(signal)) ./ (max(signal) - min(signal)));

if ismember(modulation, {'burst', 'invburst'})
    latency = floor((modLatency/1000)*srate);
    width = floor((modWidth/1000)*srate) * 2;
    taper = modTaper;
    
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
    
    % inverting in case of inverse burst
    if strcmp(modulation, 'invburst')
        win = 1 - win; end
    
    if max(win) - min(win) ~= 0
        % normalising between modMinAmplitude and 1
        win = modMinAmplitude + (1-modMinAmplitude) .* (win - min(win)) ./ (max(win) - min(win));
    else
        % window is flat; if all-zero, it should be modMinAmplitude instead
        if ~win, win = repmat(modMinAmplitude, size(win)); end
    end

    % applying modulation
    signal = signal .* win;
elseif strcmp(modulation, 'pac')
    % phase-amplitude coupling
    if isempty(modPhase), modPhase = rand(); end

    % generating the modulating signal
    t = (0:samples-1)/srate;
    ms = sin(modPhase*2*pi + 2*pi*modFrequency*t);
    
    % normalising between modMinAmplitude and 1
    ms = modMinAmplitude + (1-modMinAmplitude) .* (ms - min(ms)) ./ (max(ms) - min(ms));
    
    % applying the modulation
    signal = signal .* ms;
    
    % applying prestimulus attenuation
    if modPrestimPeriod
        latency = 0;
        width = (modPrestimPeriod * 1/(1-modPrestimTaper))/1000 * srate * 2;
        taper = modPrestimTaper;

        if width < 1; width = 0; end
        win = tukeywin(width, taper)';

        if latency > ceil(width/2)
            win = [zeros(1, latency - ceil(width/2)), win];
        else
            win(1:ceil(width/2)-latency) = [];
        end

        if length(win) > samples
            win(samples+1:length(win)) = [];
        elseif length(win) < samples
            win = [win, zeros(1, samples - length(win))];
        end

        win = 1 - win;

        % normalising between modPrestimAmplitude and 1
        win = modPrestimAmplitude + (1-modPrestimAmplitude) .* (win - min(win)) ./ (max(win) - min(win));
        
        signal = signal .* win;
    end
end
    
end