% iscomponent = utl_iscomponent(c)
%
%       Returns true when variable c is a struct with all four of the
%       required component fields.
%
%       NOTE: This is to quickly check whether or not a variable is
%       supposed to be a component or not. Passing this does not mean that 
%       the variable can be successfully used for all further processing. 
%       See utl_isvalidcomponent for a function that checks variables
%       using utl_check_component.
%
% In:
%       c - the variable to be checked
%
% Out:  
%       iscomponent - boolean, true when c is a struct with all four of the
%                     required component fields
% 
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2017-12-01 First version

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

function iscomponent = utl_iscomponent(c)

if isstruct(c) && all(isfield(c, {'source', 'signal', 'orientation', 'orientationDv'}))
    iscomponent = true;
else
    iscomponent = false;
end 

end