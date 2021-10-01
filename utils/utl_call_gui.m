% utl_call_gui(popfunction, leadfield)
%
%       Calls a SEREEGA GUI function (i.e. pop_sereega_*.m) without
%       requiring the EEGLAB GUI itself or a SEREEGA dataset to be loaded.
%
%       Note: This only works for GUI dialogs that require only a leadfield
%       to be present, e.g. pop_sereega_sources or
%       pop_sereega_plot_headmodel. Dialogs that require more, such as
%       previously stored source locations or signal classes, will not
%       work.
%
% In:
%       popfunction - string name of the pop_sereega_ function to be called
%       leadfield - the leadfield to be used for this call
%
% Usage example:
%       >> utl_call_gui('sources', lf);
%       >> utl_call_gui('plot_headmodel', lf);
% 
%                    Copyright 2021 Laurens R Krol
%                    Neuroadaptive Human-Computer Interaction
%                    Brandenburg University of Technology

% 2021-10-01 First version

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

function utl_call_gui(popfunction, leadfield)

% creating temporary EEG dataset
EEG.etc.sereega.leadfield = leadfield; %#ok<STRNU>

% amending popfunction to full pop_sereega_*(EEG)
if ~startsWith(popfunction, 'pop_sereega_')
    popfunction = ['pop_sereega_' popfunction];
end
if ~endsWith(popfunction, '(EEG)')
    popfunction = [popfunction '(EEG)'];
end

% calling GUI
eval(popfunction);

end
