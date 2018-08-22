% [data, db, signal, noise] = utl_mix_data(signal, noise, snr)
%
%       Mixes given signal and noise data matrices to a certain
%       signal-to-noise ratio specification. Note that this will affect the
%       overall amplitude of the data.
%
% In:
%       signal - matrix containing the signal
%       noise - matrix containing the noise, of the same size as signal
%       snr - scalar between 0-1 indicating the desired signal-to-noise
%             ratio, where (approximately)
%             0   = -Inf dB, noise only
%             1/3 = -6 dB
%             1/2 = 0 dB
%             2/3 = +6 dB
%             1   = +Inf dB, signal only; etc.
%
% Out:  
%       data - the data mixed to the given SNR
%       db - the given SNR in dB
%       signal - the orginal signal as scaled by this method
%       noise - the original noise as scaled by this method
%
% Usage example:
%       >> signal = ersp_generate_signal(10, 1, [], 1000, 1000);
%       >> noise = rand(1, 1000) - .5;
%       >> figure; plot(utl_mix_data(signal, noise, .75));
%       >> figure; plot(utl_mix_data(signal, noise, .50));
%       >> figure; plot(utl_mix_data(signal, noise, .25));
% 
%                    Copyright 2018 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2018-03-20 First version

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

function [data, db, signal, noise] = utl_mix_data(signal, noise, snr)

if ~all(size(signal) == size(noise))
    error('SEREEGA:utl_mix_data:invalidFunctionArguments', 'signal and noise matrices must be of the same size');
end

if snr < 0 || snr > 1
    error('SEREEGA:utl_mix_data:invalidFunctionArguments', 'signal-to-noise ratio must be in range 0-1');
end

% resizing to 2D matrix in case of epoched data
originalsize = size(signal);
if size(signal, 3) > 1
    signal = reshape(signal, size(signal, 1), []);
    noise = reshape(noise, size(noise, 1), []);
end

meanamplitude = mean(abs([signal(:); noise(:)]));

% scaling signal and noise, adding together
signal = snr .* signal ./ norm(signal, 'fro');
noise = (1-snr) .* noise ./ norm(noise, 'fro');
data = signal + noise;

% attempting to keep similar overall amplitude;
% returning original signals at same scale
scale = meanamplitude / mean(abs(data(:)));
data = data .* scale;
signal = signal .* scale;
noise = noise .* scale;

if numel(originalsize) > 2
    % reshaping data back to epoched form
    data = reshape(data, originalsize);
    signal = reshape(signal, originalsize);
    noise = reshape(noise, originalsize);
end

% calculating dB value
db = 10 * log10((rms(signal(:)) / rms(noise(:)))^2);

fprintf('SNR %.2f = %.2f dB\n', snr, db);

end
