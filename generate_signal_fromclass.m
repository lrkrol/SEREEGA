% signal = generate_signal_fromclass(class, epochs, epochNumber)
%
%       Gateway function to generate signals based on a class. Takes a 
%       class variable and calls the corresponding signal generation
%       function.
%
% In:
%       class - 1x1 struct, the class variable
%       epochs - 1x1 struct, an epoch configuration struct
%       epochNumber - current epoch number (required for slope calculation)
%
% Out:  
%       h - handle of the generated figure
%
% Usage example:
%       >> epochs.n = 100; epochs.srate = 500; epochs.length = 1000;
%       >> erp.peakLatency = 200; erp.peakWidth = 100; erp.peakAmplitude = 1;
%       >> erp = utl_check_class(erp, 'type', 'erp');
%       >> signal = generate_signal_fromclass(erp, epochs, 1);
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

function signal = generate_signal_fromclass(class, epochs, epochNumber)

% calling type-specific generate function
if ~exist(sprintf('%s_generate_signal', class.type), 'file')
    error('no signal generation function found for class type ''%s''', class.type);
else
    class_generate_signal_fromclass = str2func(sprintf('%s_generate_signal_fromclass', class.type));
    signal = class_generate_signal_fromclass(class, epochs, epochNumber);
end

end
