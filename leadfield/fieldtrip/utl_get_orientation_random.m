% orientation = utl_get_orientation_random()
%
%       Returns a random [x, y, z] orientation in the form of a 1-by-3
%       array of doubles between -1 and 1.
%
% Out:  
%       orientation - 1-by-3 array of doubles each between -1 and 1
%
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2017-12-03 First version

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

function orientation = utl_get_orientation_random()

orientation = [rand()*2-1, rand()*2-1, rand()*2-1];

end
