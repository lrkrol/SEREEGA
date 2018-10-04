% isvalidcomponent = utl_isvalidcomponent(c, leadfield)
%
%       Returns true when variable c is identical to the output of
%       utl_check_component(c).
%
% In:
%       c - the variable to be checked, can also be an array
%       leadfield - the leadfield struct with which to verify the variable
%
% Out:  
%       isvalidcomponent - boolean, true when c passes and is identical to
%                          the output of utl_check_component(c); if c is an
%                          array, isvalidcomponent will be of the same size
% 
%                    Copyright 2018 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2018-10-04 First version

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

function isvalidcomponent = utl_isvalidcomponent(c, leadfield)

if numel(c) > 1
    for i = 1:numel(c)
        isvalidcomponent(i) = utl_isvalidcomponent(c(i), leadfield);
    end
else
    try 
        check = utl_check_component(c, leadfield);
        if isequal(c, check)
            isvalidcomponent = true;
        end
    catch ME
        isvalidcomponent = false;
    end
end

end