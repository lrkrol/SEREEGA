% signal = noise_generate_signal_fromclass(class, epochs, varargin)
%
%       Takes a noise activation class, determines single parameters given
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
%       >> noise = struct('color', 'brown', 'amplitude', .1);
%       >> noise = utl_check_class(noise, 'type', 'noise');
%       >> signal = noise_generate_signal_fromclass(noise, epochs);
% 
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2017-08-10 lrk
%   - Added colored uniform noise (using third-party generator).
% 2017-07-06 lrk
%   - Added uniform white noise and changed DSP syntax for backwards
%     compatibility
% 2017-06-15 lrk
%   - Switched to DSP to generate colored noise
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

function signal = noise_generate_signal_fromclass(class, epochs, varargin)

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

samples = floor(epochs.srate * epochs.length/1000);

% checking probability
if ~baseonly && rand() > class.probability + class.probabilitySlope * epochNumber / epochs.n
    % returning flatline
    signal = zeros(1, samples);
else
    
    if strncmp(class.color(end-3:end), 'unif', 4)
        % uniform colored noise
        switch class.color(1:end-5)
            case 'white'
                signal = rand(1, samples) - .5;
            case 'pink'
                signal = noise_generate_signal_coloreduniform(samples, 1, 1);
            case 'brown'
                signal = noise_generate_signal_coloreduniform(samples, 1, 2);
            case 'blue'
                signal = noise_generate_signal_coloreduniform(samples, 1, -1);
            case 'purple'
                signal = noise_generate_signal_coloreduniform(samples, 1, -2);
        end
    else
        % gaussian colored noise
        if verLessThan('dsp', '8.6')
            warning(['your DSP version is lower than 8.6 (MATLAB R2014a); ' ...
                     'ignoring noise color settings; generating white noise using randn()']); 
             signal = randn(1, samples);
        else
            switch class.color
                case 'white'
                    cn = dsp.ColoredNoise(0, samples);
                case 'pink'
                    cn = dsp.ColoredNoise(1, samples);
                case 'brown'
                    cn = dsp.ColoredNoise(2, samples);
                case 'blue'
                    cn = dsp.ColoredNoise(-1, samples);
                case 'purple'
                    cn = dsp.ColoredNoise(-2, samples);
            end
            signal = step(cn)';
        end
    end
    
    % centering around 0
    signal = signal - mean(signal);
        
    % normalising to have the maximum (or minimum) value be (-)amplitude
    if ~baseonly
        amplitude = utl_apply_dvslopeshift(class.amplitude, class.amplitudeDv, class.amplitudeSlope, epochNumber, epochs.n);
    else 
        amplitude = class.amplitude;
    end
    signal = utl_normalise(signal, amplitude);
    
end

end