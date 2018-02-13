% component = utl_add_signal_tocomponent(signal, component)
%
%       Adds the given signal activation class to the indicated
%       component(s) and returns the updated component variable.
%
% In:
%       signal - single struct containing an activation class, or 1-by-n 
%                struct or cell containing n activation classes. When n=1,
%                the same signal will be added to all components. When n=m,
%                each signal n(i) will be added to component m(i).
%                alternatively, if m=1 and n>1, all signals will be added
%                to the one component.
%       component - 1-by-m struct containing the component(s) to which the
%                   signal(s) should be added
%
% Out:  
%       component - the updated component(s)
% 
%                    Copyright 2017, 2018 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2018-02-13 lrk
%   - Added support for different signal types in cell array
%   - Can now also add multiple signals to a single component
% 2018-01-15 lrk
%   - Added support for component structs that had no signal field yet
% 2018-01-09 lrk
%   - Extended to support multiple signals, one for each component
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

if length(signal) == 1
    % all components get same signal
    for c = 1:length(component)
        if ~isfield(component(c), 'signal')
            component(c).signal = {signal};
        else
            component(c).signal = [component(c).signal, {signal}];
        end
    end
elseif length(signal) == length(component)
    % each component gets one signal
    for c = 1:length(component)
        if ~isfield(component, 'signal')
            if iscell(signal)
                component(c).signal = signal(c);
            else
                component(c).signal = {signal(c)};
            end
        else
            if iscell(signal)
                component(c).signal = [component(c).signal, signal(c)];
            else
                component(c).signal = [component(c).signal, {signal(c)}];
            end
        end
    end
elseif length(signal) > 1 && length(component) == 1
    for s = 1:length(signal)
        if iscell(signal)
            if ~isfield(component, 'signal')
                component.signal = signal(s);
            else
                component.signal = [component.signal, signal(s)];
            end
        else
            if ~isfield(component, 'signal')
                component.signal = {signal(s)};
            else
                component.signal = [component.signal, {signal(s)}];
            end
        end
    end
else
    error('SEREEGA:utl_add_signal_tocomponent:invalidFunctionArguments', 'incompatible number of signals and components');
end

end