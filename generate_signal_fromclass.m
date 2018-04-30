% signal = generate_signal_fromclass(class, epochs, varargin)
%
%       Gateway function to generate signals based on a class. Takes a 
%       class variable and calls the corresponding signal generation
%       function.
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
%       >> erp = struct('type', 'erp', 'peakLatency', 200, ...
%       >>      'peakWidth', 100, 'peakAmplitude', 1);
%       >> erp = utl_check_class(erp);
%       >> signal = generate_signal_fromclass(erp, epochs);
% 
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2017-06-14 First version

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

function signal = generate_signal_fromclass(class, epochs, varargin)

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

% calling type-specific generate function
if ~exist(sprintf('%s_generate_signal_fromclass', class.type), 'file')
    error('SEREEGA:generate_signal_fromclass:error', 'no signal generation function found for class type ''%s''', class.type);
else
    class_generate_signal_fromclass = str2func(sprintf('%s_generate_signal_fromclass', class.type));
    signal = class_generate_signal_fromclass(class, epochs, 'epochNumber', epochNumber, 'baseonly', baseonly);
end

end
