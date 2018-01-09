% signal = utl_normalise(signal, amplitude)
%
%       Takes a signal and normalises it such that the maximum absolute
%       value of signal is +amplitude, scaling all other values
%       accordingly. 
%
% In:
%       signal - numeric matrix of values to be normalised
%
% Optional:
%       amplitude - the maximum absolute value of the output signal.
%                   default: 1
%
% Out:
%       signal - the normalised/scaled signal
%
%                    Copyright 2018 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2018-01-09 First version

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

function signal = utl_normalise(signal, amplitude)

if nargin < 2
    amplitude = 1;
end

m = max(abs(signal(:)));
if m ~= 0
    signal = signal .* (sign(m) / m) .* amplitude;
end

end