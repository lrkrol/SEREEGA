% class = arm_check_class(class)
%
%       Validates and completes an ARM (autoregressive model) class
%       structure.
%
%       An ARM class structure can only be used to generate one single,
%       independent time series using an autoregressive model. To simulate
%       interactions between different time series, use
%       arm_get_class_interacting.
%
%       For a single class structure, only the 'order' must initially be 
%       indicated. This validation function will then fill in a random
%       coefficient tensor and other default values.
%
%       A complete ARM class definition includes the following fields:
%
%         .type:                 class type (must be 'arm')
%         .order:                order of the autoregressive model, i.e. 
%                                the number of lags
%         .amplitude:            the maximum absolute amplitude of the signal
%         .amplitudeDv:          maximum amplitude deviation
%         .amplitudeSlope:       amplitude slope
%         .arm:                  the coefficient tensor of the 
%                                autoregressive model
%         .probability:          0-1 scalar indicating probability of
%                                appearance
%         .probabilitySlope:     scalar, slope of the probability
%
% In:
%       class - the class variable as a struct with at least the required
%               fields: 'order' and 'amplitude'
%
% Out:  
%       class - the class variable struct with all fields completed
%
% Usage example:
%       >> arm = struct('order', 10, 'amplitude', 1);
%       >> arm = arm_check_class(arm)
% 
%                    Copyright 2018 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2018-01-15 First version

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

function class = arm_check_class(class)

% checking for required variables
if ~isfield(class, 'order')
    error('SEREEGA:erp_check_class:missingField', 'field ''order'' is missing from given ARM class variable');
elseif ~isfield(class, 'amplitude')
    error('SEREEGA:erp_check_class:missingField', 'field ''amplitude'' is missing from given ARM class variable');
elseif isfield(class, 'type') && ~isempty(class.type) && ~strcmp(class.type, 'arm')
    error('SEREEGA:erp_check_class:incorrectFieldValue', 'indicated type (''%s'') not set to ''arm''', class.type);
end

% adding fields / filling in defaults
if ~isfield(class, 'type') || isempty(class.type)
    class.type = 'arm'; end

if ~isfield(class, 'arm') || isempty(class.arm)
    [~, Arsig, ~, ~, ~] = arm_generate_signal(1, 1, class.order, 0);
    class.arm = Arsig;
end

if ~isfield(class, 'amplitudeDv')
    class.amplitudeDv = 0; end

if ~isfield(class, 'amplitudeSlope')
    class.amplitudeSlope = 0; end

if ~isfield(class, 'probability')
    class.probability = 1; end

if ~isfield(class, 'probabilitySlope')
    class.probabilitySlope = 0; end

class = orderfields(class);

end
