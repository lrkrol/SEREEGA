% orientation = utl_get_orientation_random(numsources)
%
%       Returns a random [x, y, z] orientation in the form of a 1-by-3
%       array of doubles between -1 and 1.
%
% Optional:
%       numsources - the number of sources (default: 1)
%
% Out:  
%       orientation - numsources-by-3 array of doubles normalised to have
%                     the maximum absolute value be 1
%
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2018-04-26 lrk
%   - Added numsources argument
%   - Normalised output
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

function orientation = utl_get_orientation_random(numsources)

if ~exist('numsources', 'var'), numsources = 1; end

orientation = rand(numsources,3)*2-1;

for i = 1:size(orientation, 1)
    orientation(i,:) = utl_normalise(orientation(i,:));
end

end
