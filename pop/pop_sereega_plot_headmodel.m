% EEG = pop_sereega_plot_headmodel(EEG)
%
%       Pops up a dialog to plot the head model associated with the given
%       EEG dataset.
%
%       The pop_ functions serve only to provide a GUI for some of
%       SEREEGA's functions and are not intended to be used in scripts.
%
% In:
%       EEG - an EEGLAB dataset that includes a SEREEGA lead field in
%             EEG.etc.sereega.leadfield
%
% Out:  
%       EEG - the same EEGLAB dataset 
% 
%                    Copyright 2018 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2018-04-23 First version

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

function EEG = pop_sereega_plot_headmodel(EEG)

if ~isfield(EEG.etc.sereega, 'leadfield') || isempty(EEG.etc.sereega.leadfield)
    error('lead field not available');
end

[~, ~, ~, structout] = inputgui( ...
        'geometry', { 1 1 [1 2] 1 [1 2] [1 2] 1 [1 2]}, ...
        'geomvert', [1 1 1 1 1 1 1 1], ...
        'uilist', { ...
                { 'style', 'text', 'string', 'Plot head model', 'fontweight', 'bold' }, ...
                { }, ...
                { 'style', 'text', 'string', 'Labels' }, ...
                { 'style', 'checkbox', 'string', 'Plot channel labels', 'value', 1, 'tag', 'labels' }, ...
                { }, ...
                { 'style', 'text', 'string', 'Style' }, ...
                { 'style', 'popupmenu', 'string', 'scatter|boundary', 'tag', 'style' }, ...
                { 'style', 'text', 'string', 'Shrink factor' }, ...
                { 'style', 'edit', 'string', '1', 'tag', 'shrink' }, ...
                { }, ...
                { 'style', 'text', 'string', 'Viewpoint' }, ...
                { 'style', 'edit', 'string', '120, 20', 'tag', 'view' }, ...
                }, ... 
        'helpcom', 'pophelp(''plot_headmodel'');', 'title', 'Plot head model');

if ~isempty(structout)
    % user pressed OK
    styles = {'scatter', 'boundary'};    
    plot_headmodel(EEG.etc.sereega.leadfield, 'labels', structout.labels, 'style', styles{structout.style}, 'shrink', str2double(structout.shrink), 'view', str2double(structout.view));
end

end

