% signal = ersp_generate_signal(frequency, amplitude, phase, srate, epochLength)
%
%       Returns an frequency-based activation signal generated using the 
%       given base frequency and optional modulation.
%
%       Note: If a tukeywin warning appears, it is most likely due to
%       FieldTrip being in the path, which comes with its own tukeywin
%       version and overrides MATLAB's version. It is recommended to use
%       MATLAB's version.
%
% In:
%       frequency - either a single base frequency in Hz, or a frequency
%                   band in the following form: [low transition start, low 
%                   transition end, high transition start, high transition
%                   end] in Hz. in the latter case, a white noise
%                   signal will be filtered using a FIR filter with the
%                   given band edge frequencies; phase will be ignored.
%       amplitude - maximum amplitude in uV
%       phase - phase of the base frequency, between 0 and 1, or [] for a
%               random phase
%       srate - sampling rate of the produced signal, in Hz
%       epochLength - length of the epoch, in ms
%
% Optional (key-value pairs):
%       modulation - type of modulation to apply; 'none', 'burst',
%                    'invburst' or 'ampmod'. default: 'none'
%       modLatency - latency in ms of the burst centre
%       modWidth - width of the burst in ms
%       modTaper - taper of the burst tukey window, between 0 and 1
%       modFrequency - frequency of the amplitude-modulating signal, in Hz
%       modPhase - phase of the amplitude-modulation frequency
%       modMinRelAmplitude - minimum amplitude of the base signal relative
%                            to the base amplitude
%       modPrestimPeriod - prestimuls period length in ms
%       modPrestimTaper - tapering of the tukey window used to apply a
%                         prestimulus signal attenuation; 0 <= taper < 1
%       modPrestimRelAmplitude - amplitude of the prestimulus signal as a
%                             percentage of the base amplitude
%
% Out:  
%       signal - row array containing the simulated noise activation signal
%
% Usage example:
%       >> plot(ersp_generate_signal(25, 1, [], 500, 1000));
%       >> plot(ersp_generate_signal([8 10 15 17], 1, [], 500, 1000));
% 
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2019-09-18 lrk
%   - Shifted the burst latency one sample to the right since EEG starts 
%     counting at 0, not at 1 (GitHub issue #10)
% 2017-12-30 lrk
%   - Changed bandpass filter method as designfilt was blowing out the
%     signal under certain conditions; thanks to Mahta Mousavi for the 
%     filter design. Now takes four edge frequencies instead of two.
% 2017-11-24 lrk
%   - Renamed 'pac' to 'ampmod' and replaced references accordingly
% 2017-11-22 lrk
%   - Changed normalisation such that the signal is no longer fixed between
%     -ampliude and +amplitude, but that the max absolute signal is
%     +amplitude
%   - Renamed parameters modMinAmplitude and modPrestimAmplitude to 
%     modMinRelAmplitude and modPrestimRelAmplitude for clarity
% 2017-11-08 lrk
%   - Changed width parameter to mean full width, not half width
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
addParameter(p, 'modMinRelAmplitude', 0, @isnumeric);
addParameter(p, 'modPrestimPeriod', 0, @isnumeric);
addParameter(p, 'modPrestimTaper', 0, @isnumeric);
addParameter(p, 'modPrestimRelAmplitude', 0, @isnumeric);

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
modMinRelAmplitude = p.Results.modMinRelAmplitude;
modPrestimPeriod = p.Results.modPrestimPeriod;
modPrestimTaper = p.Results.modPrestimTaper;
modPrestimRelAmplitude = p.Results.modPrestimRelAmplitude;

samples = floor(srate * epochLength/1000);

if isempty(phase), phase = rand(); end

% generating the base signal
if numel(frequency) == 1
    % single frequency
    t = (0:samples-1)/srate;
    signal = sin(phase*2*pi + 2*pi*frequency*t);
elseif numel(frequency) == 4
    % designing filter
    c = kaiserord(frequency, [0 1 0], [0.05 0.01 0.05], srate, 'cell');
    b = fir1(c{:});
    
    % taking initial signal length of five times the filter order, but at
    % least as long as samples
    signal = rand(1, max([samples, 5*length(b)])) - .5;

    % filtering signal
    signal = filter(b, 1, signal);
    
    % removing padding (taking the middle segment)
    signal = signal(floor(length(signal)/2-samples/2)+1:floor(length(signal)/2+samples/2));
end

% normalising such that max absolute amplitude = amplitude
signal = utl_normalise(signal, amplitude);

if ismember(modulation, {'burst', 'invburst'})
    latency = floor((modLatency/1000)*srate) + 1;
    width = floor((modWidth/1000)*srate);
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
        % normalising between modMinRelAmplitude and 1
        win = modMinRelAmplitude + (1-modMinRelAmplitude) .* (win - min(win)) ./ (max(win) - min(win));
    else
        % window is flat; if all-zero, it should be modMinRelAmplitude instead
        if ~win, win = repmat(modMinRelAmplitude, size(win)); end
    end

    % applying modulation
    signal = signal .* win;
elseif strcmp(modulation, 'ampmod')
    % phase-amplitude coupling
    if isempty(modPhase), modPhase = rand(); end

    % generating the modulating signal
    t = (0:samples-1)/srate;
    ms = sin(modPhase*2*pi + 2*pi*modFrequency*t);
    
    % normalising between modMinRelAmplitude and 1
    ms = modMinRelAmplitude + (1-modMinRelAmplitude) .* (ms - min(ms)) ./ (max(ms) - min(ms));
    
    % applying the modulation
    signal = signal .* ms;
    
    % applying prestimulus attenuation
    if modPrestimPeriod
        latency = 0;
        width = (modPrestimPeriod * 1/(1-modPrestimTaper))/1000 * srate;
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

        % normalising between modPrestimRelAmplitude and 1
        win = modPrestimRelAmplitude + (1-modPrestimRelAmplitude) .* (win - min(win)) ./ (max(win) - min(win));
        
        signal = signal .* win;
    end
end
    
end