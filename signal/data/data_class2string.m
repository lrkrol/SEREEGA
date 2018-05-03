% class = data_class2string(class)
%
%       Returns a string describing a data class's base values.
%
% In:
%       class - a validated data class variable as a struct
%
% Out:  
%       string - a string describing the class
%
% Usage example:
%       >> randomdata = randn(100,1000); dataclass = struct();
%       >> dataclass = struct();
%       >> dataclass.data = randomdata; dataclass.index = {'e', ':'};
%       >> dataclass.amplitude = 1; dataclass.note = 'example';
%       >> dataclass = data_check_class(dataclass);
%       >> datastr = data_class2string(dataclass)
% 
%                    Copyright 2018 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2018-05-03 First version

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

function string = data_class2string(class)

string = sprintf('Data (%.2f) (%s) (%s)', class.amplitude, class.amplitudeType, class.note);

end
