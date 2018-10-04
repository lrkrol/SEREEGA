% EEG = pop_sereega_utl_mix_data(EEG)
%
%       Pops up a dialog window that allows you to reorder the epochs in an
%       existing dataset with at least two different event types.
%
%       The pop_ functions serve only to provide a GUI for some of
%       SEREEGA's functions and are not intended to be used in scripts.
%
% In:
%       EEG - an EEGLAB dataset
%
% Out:  
%       EEG - the reordered EEGLAB dataset
% 
%                    Copyright 2018 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2018-05-03 First version

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

function EEG = pop_sereega_utl_reorder_eeglabdataset(EEG)


% testing if lead field is present
if ~isfield(EEG.etc, 'sereega') || ~isfield(EEG.etc.sereega, 'epochs') ...
        || isempty(EEG.etc.sereega.leadfield)
    errormsg = 'First configure the epochs.';
    supergui( 'geomhoriz', { 1 1 1 }, 'uilist', { ...
            { 'style', 'text', 'string', errormsg }, { }, ...
            { 'style', 'pushbutton' , 'string', 'OK', 'callback', 'close(gcbf);'} }, ...
            'title', 'Error');
    return
end

% building gui
[~, ~, ~, structout] = inputgui( ...
        'geometry', { 1 1 1 1 1 1 1 1 1 1 1 1}, ...
        'geomvert', [1 1 1 1 1 1 1 1 1 1 1 1], ...
        'uilist', { ...
                { 'style', 'text', 'string', 'Reorder datasets', 'fontweight', 'bold' }, ...
                { }, ...
                { 'style', 'text', 'string', 'Use this function after merging two or more' }, ...
                { 'style', 'text', 'string', 'datasets with different event markers.' }, ...
                { }, ...
                { 'style', 'text', 'string', '''Random'' shuffles all epochs (e.g. 231322311).' }, ...
                { 'style', 'text', 'string', '''Interleave'' interleaves the epochs, keeping' }, ...
                { 'style', 'text', 'string', 'their internal order intact (e.g.123123123).' }, ...
                { 'style', 'text', 'string', 'Interleaving only works with an equal number' }, ...
                { 'style', 'text', 'string', 'of epochs per event.' }, ...
                { }, ...
                { 'style', 'popupmenu', 'string', 'Random|Interleave', 'tag', 'mode' }, ...
                }, ... 
        'helpcom', 'pophelp(''utl_reorder_eeglabdataset'');', ...
        'title', 'Epoch configuration');

if ~isempty(structout)
    % user pressed OK
    mode = {'random', 'interleave'};        
    EEGreorder = utl_reorder_eeglabdataset(EEG, 'mode', mode{structout.mode});
    
    ALLEEG = evalin('base', 'ALLEEG');
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEGreorder );
    assignin('base', 'ALLEEG', ALLEEG);
    assignin('base', 'EEG', EEG);
    assignin('base', 'CURRENTSET', CURRENTSET);
    eeglab redraw;
end

end

