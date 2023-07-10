% component = utl_check_component(component, leadfield)
%
%       Validates a component. Takes an (incomplete) component variable
%       and validates/completes it. Also validates/completes all indicated 
%       signals.
%
%       A SEREEGA component is one of the main elements in the forward
%       model, and contains the source location, its orientation, and the
%       activation pattern(s) it produces.
%
%       A full component is defined by the following fields.
%         .source        - row array of source indices in the leadfield, 
%                          giving the component's source location(s). 
%                          if more than one source is indicated, activity
%                          will be projected through each src and summed.
%         .signal        - cell array of activation classes. see e.g.
%                          utl_check_class, erp_check_class, etc.
%         .orientation   - nsources-by-3 matrix containing the source 
%                          dipoles'/dipole's x, y, z orientation(s). if 
%                          left empty, the default value(s) will be taken 
%                          from the leadfield.
%         .orientationDv - nsources-by-3 matrix of allowed deviations for 
%                          each dipole's x, y, z orientation values.
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
%       >> lf = lf_generate_fromnyhead();
%       >> erp = struct('peakLatency', 200, 'peakWidth', 100, ...
%               'peakAmplitude', 1);
%       >> erp = utl_check_class(erp, 'type', 'erp');
%       >> comp = struct('source', 1, 'signal', {{erp}})
%       >> comp = utl_check_component(comp, lf)
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

if numel(component) > 1
    for c = 1:numel(component)
        checkedcomponent(c) = utl_check_component(component(c), leadfield);
    end
    component = checkedcomponent;
else
    % checking for required variables
    if ~isfield(component, 'source') || isempty(component.source)
        error('SEREEGA:utl_check_component:missingFieldValue', 'no source indicated: assign at least one source to each component'); 
    elseif ~isfield(component, 'signal') || isempty(component.signal)
        error('SEREEGA:utl_check_component:missingFieldValue', 'no signal indicated: assign at least one signal to each component');
    end

    % adding fields / filling in defaults
    if ~isfield(component, 'orientation') || isempty(component.orientation)
        component.orientation = leadfield.orientation(component.source,:); end

    if ~isfield(component, 'orientationDv') || isempty(component.orientationDv)
        component.orientationDv = zeros(size(component.orientation)); end

    if any(component.source > size(leadfield.pos, 1))
        error('SEREEGA:utl_check_component:error', 'indicated source(s) not present in the leadfield'); end

    % checking values
    if ~all(size(component.orientation) == [numel(component.source), 3])
        warning('number of orientations does not match number of sources; resetting to defaults'); 
        component.orientation = leadfield.orientation(component.source,:); 
    end

    if ~iscell(component.signal)
        error('SEREEGA:utl_check_component:error', 'component signals must be in a cell array'); end

    % checking signals
    for s = 1:length(component.signal)
        component.signal{s} = utl_check_class(component.signal{s});
    end
end

end
