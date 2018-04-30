% class = ersp_class2string(class)
%
%       Returns a string describing an ERSP class's base values.
%
% In:
%       class - a validated ERSP class variable as a struct
%
% Out:  
%       string - a string describing the class
%
% Usage example:
%       >> ersp = struct();
%       >> ersp.frequency = 20; ersp.amplitude = 1;
%       >> ersp.modulation = 'ampmod'; ersp.modFrequency = 1;
%       >> ersp.modPhase = -.25; ersp.modMinRelAmplitude = .1;
%       >> ersp = ersp_check_class(ersp);
%       >> erpstr = ersp_class2string(ersp)
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

function string = ersp_class2string(class)

if numel(class.frequency) == 1
    string = sprintf('ERSP (%.1f) (%.2f) (%s)', class.frequency, class.amplitude, class.modulation);
else
    string = sprintf('ERSP (%.1f-%.1f) (%.2f) (%s)', class.frequency(1), class.frequency(end), class.amplitude, class.modulation);
end

end
