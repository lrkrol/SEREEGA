% component = utl_add_signal_tocomponent(signal, component)
%
%       Adds the given signal activation class to the indicated
%       component(s) and returns the updated component variable.
%
% In:
%       signal - single struct, the signal activation class variable
%       component - 1-by-n struct containing the component(s) to which the
%                   signal should be added
%
% Out:  
%       component - the updated component(s)
% 
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2017-12-12 First version

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

function component = utl_add_signal_tocomponent(signal, component)

for c = 1:length(component)
    component(c).signal = [component(c).signal, {signal}];
end

end