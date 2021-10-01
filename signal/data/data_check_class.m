% class = data_check_class(class)
%
%       Validates and completes a data class structure.
%
%       The 'data' class does not procedurally generate a signal but
%       instead takes it from existing data. To that end, both the data and
%       the index pattern is given as arguments in the data class.
%
%       A complete data class definition includes the following fields:
%
%         .type:                 class type (must be 'data')
%         .data:                 any n-dimensional data variable with one
%                                dimension's size corresponding to the 
%                                number of samples required for one epoch.
%                                note: this is not checked by this
%                                function.
%         .index                 cell array indicating the indexation
%                                pattern. the following variables can be
%                                used: e - current epoch number
%                                      n - maximum epoch number
%                                for example, an index of {'e', ':'}
%                                returns the e-th row for each epoch.
%         .amplitudeType         'relative' or 'absolute', indicating
%                                the behaviour of the 'amplitude' parameter
%         .amplitude             the signal's maximum absolute amplitude
%                                (i.e. the data will be scaled), or its
%                                amplitude relative to the given data (i.e.
%                                data will be multiplied by the amplitude)
%         .amplitudeDv           the amplitude's deviation
%         .amplitudeSlope        the amplitude's slope
%         .probability:          0-1 scalar indicating probability of
%                                appearance
%         .probabilitySlope:     scalar, slope of the probability
%         .note                  string, name/description of class
%
% In:
%       class - the class variable as a struct with at least the required
%               fields: data, index, and amplitude
%
% Out:  
%       class - the class variable struct with all fields completed
%
% Usage example:
%       >> randomdata = randn(100,1000); dataclass = struct();
%       >> dataclass = struct();
%       >> dataclass.data = randomdata; dataclass.index = {'e', ':'};
%       >> dataclass.amplitude = 1;
%       >> dataclass = data_check_class(dataclass);
% 
%                    Copyright 2017, 2018 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2018-05-03 lrk
%   - Added note field
% 2018-03-23 lrk
%   - Added amplitudeType argument
% 2017-10-23 First version

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

function class = data_check_class(class)

% checking for required variables
if ~isfield(class, 'data')
    error('SEREEGA:data_check_class:missingField', 'field ''data'' is missing from given data class variable');
elseif ~isfield(class, 'index')
    error('SEREEGA:data_check_class:missingField', 'field ''index'' is missing from given ERP class variable');
elseif ~isfield(class, 'amplitude')
    error('SEREEGA:data_check_class:missingField', 'field ''amplitude'' is missing from given ERP class variable');
elseif isfield(class, 'type') && ~isempty(class.type) && ~strcmp(class.type, 'data')
    error('SEREEGA:data_check_class:incorrectFieldValue', 'indicated type (''%s'') not set to ''data''', class.type);
end

% adding fields / filling in defaults
if ~isfield(class, 'type') || isempty(class.type)
    class.type = 'data'; end

if ~isfield(class, 'amplitudeType')
    class.amplitudeType = 'absolute';
elseif ~any(strcmp(class.amplitudeType, {'absolute', 'relative'}))
    warning('indicated amplitudeType not recognised; reverting to ''absolute''');
    class.amplitudeType = 'absolute';
end

if ~isfield(class, 'amplitudeDv')
    class.amplitudeDv = 0; end

if ~isfield(class, 'amplitudeSlope')
    class.amplitudeSlope = 0; end

if ~isfield(class, 'probability')
    class.probability = 1; end

if ~isfield(class, 'probabilitySlope')
    class.probabilitySlope = 0; end

if ~isfield(class, 'note')
    class.note = ''; end

class = orderfields(class);

end
