% class = utl_check_class(class, varargin)
%
%       Gateway function to validate classes. Takes an (incomplete) class
%       variable and validates/completes it according to the check
%       function of the given/determined class.
%
% In:
%       class - the class variable as a struct with at least the required
%               fields (see the class's own check function, i.e.
%               <classtype>_check_class)
%
% Optional (key-value pairs):
%       type - the type of the class if not indicated in the class.type
%              field
%
% Out:  
%       class - the updated/verified class variable
%
% Usage example:
%       >> erp = struct('peakLatency', 200, 'peakWidth', 100, ...
%               'peakAmplitude', 1);
%       >> erp = utl_check_class(erp, 'type', 'erp')
% 
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2017-06-13 First version

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

function class = utl_check_class(class, varargin)

% parsing input
p = inputParser;

addRequired(p, 'class', @isstruct);

addParameter(p, 'type', '', @ischar);

parse(p, class, varargin{:})

class = p.Results.class;
type = p.Results.type;
% seeing if type can be determined
if ~isfield(class, 'type') && isempty(type)
    error('SEREEGA:utl_check_class:missingFieldValue', 'cannot determine class type.');
elseif isfield(class, 'type')
    type = class.type;
end

% calling type-specific check function
if ~exist(sprintf('%s_check_class', type) , 'file')
    error('SEREEGA:utl_check_class:error', 'cannot check class ''%s'': cannot find function ''%s_check_class''', type, type);
else
    check_class = str2func(sprintf('%s_check_class', type));
    class = check_class(class);
end

end
