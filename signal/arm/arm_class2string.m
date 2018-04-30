% class = arm_class2string(class)
%
%       Returns a string describing an ARM class's base values.
%
% In:
%       class - a validated ARM class variable as a struct
%
% Out:  
%       string - a string describing the class
%
% Usage example:
%       >> arm = struct('order', 10, 'amplitude', 1);
%       >> arm = arm_check_class(arm);
%       >> armstr = arm_class2string(arm)
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

function string = arm_class2string(class)

string = sprintf('ARM (%d) (%d)', class.order, class.amplitude);

end
