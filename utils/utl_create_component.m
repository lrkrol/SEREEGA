% component = utl_create_component(sourceIdx, signal, leadfield, varargin)
%
%       Creates components from given source indices, signals, and,
%       optionally, orientations.
%
% In:
%       sourceIdx - 1-by-n array of source indices
%       signal - single struct containing an activation class, or 1-by-m 
%                struct or cell containing n activation classes. When m=1,
%                the same signal will be added to all components. When m=n,
%                each signal m(i) will be added to component n(i). 
%       leadfield - the lead field structure array corresponding to the 
%                   source indices
%
% Optional (key-value pairs):
%       orientation - n-by-3 array indicating source dipole orientations,
%                     one row per component
%
% Out:  
%       component - 1-by-n structure array containing the created
%                   components
%
% Usage example:
%       >> lf = lf_generate_fromnyhead();
%       >> erp = struct('peakLatency', 200, 'peakWidth', 100, ...
%               'peakAmplitude', 1);
%       >> erp = utl_check_class(erp, 'type', 'erp');
%       >> src = lf_get_source_random(lf);
%       >> comp = utl_create_component(src, erp, lf);
% 
%                    Copyright 2018 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2018-02-12 First version

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

function component = utl_create_component(sourceIdx, signal, leadfield, varargin)

% parsing input
p = inputParser;

addRequired(p, 'sourceIdx', @isnumeric);
addRequired(p, 'signal', (@(x) isstruct(x) || iscell(x)));
addRequired(p, 'leadfield', @isstruct);

addParameter(p, 'orientation', [], @isnumeric);

parse(p, sourceIdx, signal, leadfield, varargin{:})

sourceIdx = p.Results.sourceIdx;
signal = p.Results.signal;
leadfield = p.Results.leadfield;
orientation = p.Results.orientation;

component = struct('source', num2cell(sourceIdx));
component = utl_add_signal_tocomponent(signal, component);
if ~isempty(orientation)
    if size(orientation, 1) == numel(component)
        for c = 1:numel(component)
            component(c).orientation = orientation(c,:);
        end
    else
        error('SEREEGA:utl_create_component:invalidFunctionArguments', 'size(orientation) should be numel(sourceIdx)-by-3');
    end
end

component = utl_check_component(component, leadfield);

end