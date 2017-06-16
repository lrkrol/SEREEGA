% signal = noise_generate_signal_fromclass(class, epochs, epochNumber)
%
%       Takes a noise activation class, determines single parameters given
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
%       >> noise.color = 'white'; noise.amplitude = 0.1;
%       >> noise = utl_check_class(noise, 'type', 'noise');
%       >> signal = noise_generate_signal_fromclass(noise, epochs, 1);
% 
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

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

function signal = noise_generate_signal_fromclass(class, epochs, epochNumber)

samples = epochs.srate * epochs.length/1000;

if verLessThan('matlab', '8.3')
    warning('your MATLAB version is lower than R2014a; ignoring noise color settings and generating white noise using randn()');
    signal = randn(1,samples);
else
    cn = dsp.ColoredNoise('Color', class.color, 'SamplesPerFrame', samples);
    signal = cn()';
end

% normalising to have the maximum (or minimum) value be (-)amplitude
amplitude = utl_apply_dvslope(class.amplitude, class.amplitudeDv, class.amplitudeSlope, epochNumber, epochs.n);
[~, i] = max(abs(signal(:)));
signal = signal .* (sign(signal(i)) / signal(i)) .* amplitude;

end