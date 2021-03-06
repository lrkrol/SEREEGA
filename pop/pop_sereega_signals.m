% EEG = pop_sereega_signals(EEG)
%
%       Pops up a dialog window that allows you to add and remove signal
%       activation classes to/from the simulation.
%
%       The pop_ functions serve only to provide a GUI for some of
%       SEREEGA's functions and are not intended to be used in scripts.
%
%       To add classes to the simulation, use one of the buttons for each
%       class to the right of the list of current classes, and input the
%       parameters you wish to set. Those indicated by a * in both rows and
%       columns are required fields.
%
%       Once classes have been added, you will see a short description of
%       them in the list. Select one and press "plot" to plot this class's
%       signal, or press "remove" to remove it from the simulation. Note
%       that this does NOT remove it from any components you may have
%       previously assigned it to. That must be done separately.
%
%       See for details: <class>_check_class, where <class> is the type of
%       signal you wish to add, explains all the parameters of that type.
%
% In:
%       EEG - an EEGLAB dataset with epochs configured in
%             EEG.etc.sereega.epochs.
%
% Out:  
%       EEG - the EEGLAB dataset with signals added/removed according to
%             the actions taken in the dialog
% 
%                    Copyright 2018 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2018-05-01 First version

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
cbf_get_value = @(tag,property) sprintf('get(findobj(''parent'', gcbf, ''tag'', ''%s''), ''%s'');', tag, property);
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
cb_add_arm = [ ...
        cbf_get_userdata ...
        'userdata.EEG = pop_sereega_addarm(userdata.EEG);' ...
        cbf_set_userdata ...
        cbf_update_fields ...
        ]; 
cb_add_data = [ ...
        cbf_get_userdata ...
        'userdata.EEG = pop_sereega_adddata(userdata.EEG);' ...
        cbf_set_userdata ...
        cbf_update_fields ...
        ];
cb_plot = [ ...
        cbf_get_userdata ...
        'if ~isfield(userdata.EEG.etc.sereega, ''epochs''),' ...
            'errormsg = ''First configure the epochs.'';' ...
            'supergui( ''geomhoriz'', { 1 1 1 }, ''uilist'', { '...
                    '{ ''style'', ''text'', ''string'', errormsg }, { }, '...
                    '{ ''style'', ''pushbutton'' , ''string'', ''OK'', ''callback'', ''close(gcbf);''} }, '...
                    '''title'', ''Error'');'...
        'end;'...
        'sig = ' cbf_get_value('currentsignals', 'value') ...
        'plot_signal_fromclass(userdata.EEG.etc.sereega.signals{sig}, userdata.EEG.etc.sereega.epochs);' ...
        ];
cb_remove = [ ...
        cbf_get_userdata ...
        'sig = ' cbf_get_value('currentsignals', 'value') ...
        'userdata.EEG.etc.sereega.signals(sig) = [];' ...
        cbf_set_userdata ...
        'if sig > numel(userdata.EEG.etc.sereega.signals),' ...
            cbf_set_value('currentsignals', 'value', '1') ...
        'end;' ...
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
                        { 'style' 'pushbutton' 'string' 'Plot', 'callback', cb_plot } ...
                        { 'style' 'pushbutton' 'string' 'Remove', 'callback', cb_remove } ...
                { 'style' 'text' 'string' 'Add new signal', 'fontweight', 'bold' } ...
                        { 'style' 'pushbutton' 'string' 'Add ERP', 'callback', cb_add_erp } ...
                        { 'style' 'pushbutton' 'string' 'Add ERSP', 'callback', cb_add_ersp } ...
                        { 'style' 'pushbutton' 'string' 'Add noise', 'callback', cb_add_noise } ...
                        { 'style' 'pushbutton' 'string' 'Add ARM', 'callback', cb_add_arm } ...
                        { 'style' 'pushbutton' 'string' 'Add data', 'callback', cb_add_data   } ...
                }, ...
                'helpcom', 'pophelp(''pop_sereega_signals'');', ...
                'title', 'Define source activations', ...
                'userdata', userdata);
     
% saving signals
if ~isempty(userdata)
    EEG = userdata.EEG;
end

fprintf('Number of signals: %d\n', numel([EEG.etc.sereega.signals]));

end
