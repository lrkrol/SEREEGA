% component = utl_check_component(component)
%
%       Validates a component. Takes an (incomplete) component variable
%       and validates/completes it, including all indicated signals.
%
% In:
%       component - the component variable with at least the required
%                   fields: source and signal
%       leadfield - the leadfield with which the component will be used
%
% Out:  
%       component - the updated/verified component
%
% Usage example:
%       >> lf = lf_generate_fromnyhead;
%       >> erp.peakLatency = 300; erp.peakWidth = 100; erp.peakAmplitude = 1;
%       >> erp = utl_check_class(erp, 'type', 'erp');
%       >> c.source = [1, 2]; c.signal = {erp};
%       >> c = utl_check_component(c, lf)
% 
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2017-06-14 First version

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

function component = utl_check_component(component, leadfield)

% checking for required variables
if ~isfield(component, 'source'),
    error('no source indicated'); 
elseif ~isfield(component, 'signal'),
    error('no signal indicated');
end

% adding fields / filling in defaults
if ~isfield(component, 'orientation'),
    component.orientation = leadfield.orientation(component.source,:); end

if ~isfield(component, 'orientationDv'),
    component.orientationDv = zeros(size(component.orientation)); end

if any(component.source > size(leadfield.pos, 1)),
    error('indicated source(s) not present in the leadfield'); end

% checking values
if ~all(size(component.orientation) == [numel(component.source), 3]),
    error('number of orientations does not match number of sources'); end

if ~iscell(component.signal),
    error('component signals must be in a cell array'); end

for s = 1:length(component.signal)
    component.signal{s} = utl_check_class(component.signal{s});
end

end
