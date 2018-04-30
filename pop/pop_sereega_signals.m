% EEG = pop_sereega_signals(EEG)
%
%       Pops up a dialog window that allows you to add and remove sources
%       from the simulation.
%
%       The pop_ functions serve only to provide a GUI for some of
%       SEREEGA's functions and are not intended to be used in scripts.
%
%       To add sources to the simulation, first use one of the four options
%       provided to find sources in the lead field:
%       - Next to "random", indicate the number of randomly selected
%         sources you wish to inspect;
%       - Next to "nearest to", indicate the coordinates in the brain where
%         you wish to find a source;
%       - Next to "spaced", indicate the number of sources you wish to
%         find, and the minimum distance in mm between them;
%       - Next to "in radius", indicate the location in the brain (or the
%         ID of the source) and the size of the radius in mm.
%       Click "find" to find the source(s). They will show up below under
%       "found location", along with their default orientation. Click
%       "plot" to inspect these values graphically.
%
%       The default orientation can be changed. Next to "orientation", a
%       custom orientation can be indicated and applied by clicking
%       "apply". Alternatively, the default orientation can be restored by
%       clicking "default", a random orientation can be given by clicking
%       "random", or a pseudoperpendicular/pseudotangential orientation by
%       clicking the corresponding buttons.
%
%       When satisfied with the found source location and orientation, it
%       can be added to the simulation by clicking "add source(s)". 
%
%       At the left side of the window, a list indicates the sources
%       currently added to the simulation. Clicking on them sets their
%       values as before, and allows them to be plotted. Click "remove
%       source" to remove a source from the simulation.
%
%       See for details: lf_get_source_random, lf_get_source_nearest,
%       lf_get_source_spaced, lf_get_source_inradius,
%       utl_get_orientation_random,
%       utl_get_orientation_pseudoperpendicular,
%       utl_get_orientation_pseudotangential
%
% In:
%       EEG - an EEGLAB dataset that includes a SEREEGA lead field in
%             EEG.etc.sereega.leadfield
%
% Out:  
%       EEG - the EEGLAB dataset with signals added according to the 
%             actions taken in the dialog
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

function EEG = pop_sereega_signals(EEG)

if ~isfield(EEG.etc, 'sereega') || ~isfield(EEG.etc.sereega, 'signals')
    EEG.etc.sereega.signals = {};
end

% setting userdata
userdata.EEG = EEG;

% generating list of current signals
currentsignallist = {}; ...
for i = 1:numel(EEG.etc.sereega.signals), ...
    currentsignallist = [currentsignallist, {utl_class2string(EEG.etc.sereega.signals{i})}]; ...
end

% general callback functions
cbf_get_userdata = 'userdatafig = gcf; userdata = get(userdatafig, ''userdata'');';
cbf_set_userdata = 'set(userdatafig, ''userdata'', userdata);';
cbf_get_value = @(tag,property) sprintf('get(findobj(''parent'', gcbf, ''tag'', ''%s''), ''%s'')', tag, property);
cbf_set_value = @(tag,property,value) sprintf('set(findobj(''parent'', gcbf, ''tag'', ''%s''), ''%s'', %s);', tag, property, value);
cbf_update_fields = [ ...
        cbf_get_userdata ...
        'currentsignallist = {};' ...
        'for i = 1:numel(userdata.EEG.etc.sereega.signals),' ...
            'currentsignallist = [currentsignallist, {utl_class2string(userdata.EEG.etc.sereega.signals{i})}];' ...
        'end;' ...
        cbf_set_value('currentsignals', 'string', 'currentsignallist'); ...
        ];
    
% callbacks
cb_add_erp = [ ...
        cbf_get_userdata ...
        'userdata.EEG = pop_sereega_adderp(userdata.EEG);' ...
        cbf_set_userdata ...
        cbf_update_fields ...
        ]; 
cb_add_ersp = [ ...
        cbf_get_userdata ...
        'userdata.EEG = pop_sereega_addersp(userdata.EEG);' ...
        cbf_set_userdata ...
        cbf_update_fields ...
        ];
cb_add_noise = [ ...
        cbf_get_userdata ...
        'userdata.EEG = pop_sereega_addnoise(userdata.EEG);' ...
        cbf_set_userdata ...
        cbf_update_fields ...
        ]; 

% geometry
nc = 3; nr = 12;
geom = { ...
        { nc nr [ 0  0]    ...  % current signals text
                [ 2  1] }, ...
                { nc nr [ 0  1]    ...  % listbox
                        [ 2  9] }, ...
                { nc nr [ 0 11]    ...  % plot signal
                        [ 1  1] }, ...
                { nc nr [ 1 11]    ...  % remove signals
                        [ 1  1] }, ...
        { nc nr [ 2  0]    ...  % add sources text
                [ 1  1] }, ...
            { nc nr [ 2  1]    ...  % add ERP
                    [ 1  1] }, ...
            { nc nr [ 2  3]    ...  % add ERSP
                    [ 1  1] }, ...
            { nc nr [ 2  5]    ...  % add noise
                    [ 1  1] }, ...
            { nc nr [ 2  7]    ...  % add ARM
                    [ 1  1] }, ...
            { nc nr [ 2  9]    ...  % add data
                    [ 1  1] }, ...
        };

% building gui
[~, userdata, ~, ~] = inputgui('geom', geom, ...
        'uilist', { ...
                { 'style' 'text' 'string' 'Current signals', 'fontweight', 'bold' } ...
                        { 'style' 'listbox' 'string' currentsignallist, 'tag', 'currentsignals' } ...
                        { 'style' 'pushbutton' 'string' 'Plot'  } ...
                        { 'style' 'pushbutton' 'string' 'Remove'  } ...
                { 'style' 'text' 'string' 'Add new signal', 'fontweight', 'bold' } ...
                        { 'style' 'pushbutton' 'string' 'Add ERP', 'callback', cb_add_erp } ...
                        { 'style' 'pushbutton' 'string' 'Add ERSP', 'callback', cb_add_ersp  } ...
                        { 'style' 'pushbutton' 'string' 'Add noise', 'callback', cb_add_noise } ...
                        { 'style' 'pushbutton' 'string' 'Add ARM'  } ...
                        { 'style' 'pushbutton' 'string' 'Add data'  } ...
                }, ...
                'helpcom', 'pophelp(''pop_sereega_signals'');', ...
                'title', 'Define source activations', ...
                'userdata', userdata);
     
% saving signals
if ~isempty(userdata)
    EEG = userdata.EEG;
end

end
