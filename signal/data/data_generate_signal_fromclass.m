% signal = data_generate_signal_fromclass(class, epochs, varargin)
%
%       Takes a data activation class, determines single parameters given
%       the deviations/slopes in the class, and returns a signal extracted
%       from the class' data.
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
%                  any deviations or slopes (1|0, default 0). in this
%                  case, the base signal is the first possible epoch.
%
% Out:  
%       signal - row array containing the simulated noise activation signal
%
% Usage example:
%       >> epochs = struct('n', 100, 'srate', 500, 'length', 2000);
%       >> randomdata = randn(100,1000); dataclass = struct();
%       >> dataclass = struct();
%       >> dataclass.data = randomdata; dataclass.index = {'e', ':'};
%       >> dataclass.amplitude = 1;
%       >> dataclass = utl_check_class(dataclass, 'type', 'data');
%       >> signal = data_generate_signal_fromclass(dataclass, epochs, ... 
%       >>          'epochNumber', 5);
% 
%                    Copyright 2017, 2018 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2018-03-23 lrk
%   - Added amplitudeType argument
% 2017-10-24 First version

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

function signal = data_generate_signal_fromclass(class, epochs, varargin)

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

nsamples = floor((epochs.length/1000)*epochs.srate);

if baseonly
    % evaluating indexing cell, obtaining data for first epoch
    e = 1; n = epochs.n;
    for i = 1:length(class.index)
        if ischar(class.index{i}) && ~strcmp(class.index{i}, ':')
            class.index{i} = eval(class.index{i});
        end
    end
    signal = class.data(class.index{:});
else        
    % checking probability
    if rand() > class.probability + class.probabilitySlope * epochNumber / epochs.n
        % returning flatline
        signal = zeros(1, nsamples);
    else
        % evaluating indexing cell, obtaining data
        e = epochNumber; n = epochs.n;
        for i = 1:length(class.index)
            if ischar(class.index{i}) && ~strcmp(class.index{i}, ':')
                class.index{i} = eval(class.index{i});
            end
        end
        signal = class.data(class.index{:});
    end
end

% scaling data to indicated (variable) amplitude
amplitude = utl_apply_dvslopeshift(class.amplitude, class.amplitudeDv, class.amplitudeSlope, epochNumber, epochs.n);
if strcmp(class.amplitudeType, 'absolute')
    signal = utl_normalise(signal, amplitude);
elseif strcmp(class.amplitudeType, 'relative')
    signal = signal .* amplitude;
end

% ensuring row vector
if iscolumn(signal), signal = signal'; end

end