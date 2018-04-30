% class = utl_class2string(class)
%
%       Gateway function to obtain strings from classes.
%
% In:
%       class - a validated class variable as a struct (see the class's 
%               check function, i.e. <classtype>_check_class)
%
% Out:  
%       string - a string describing the class
%
% Usage example:
%       >> erp = struct('peakLatency', 200, 'peakWidth', 100, ...
%               'peakAmplitude', 1);
%       >> erp = utl_check_class(erp, 'type', 'erp');
%       >> erpstr = utl_class2string(erp)
% 
%                    Copyright 2018 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2018-04-30 First version

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

function string = utl_class2string(class)

% calling type-specific class2string function
if ~exist(sprintf('%s_class2string', class.type) , 'file')
    error('SEREEGA:utl_class2string:error', 'cannot find function ''%s_class2string''', class.type, class.type);
else
    class2string = str2func(sprintf('%s_class2string', class.type));
    string = class2string(class);
end

end
