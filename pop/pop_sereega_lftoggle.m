% EEG = pop_sereega_lftoggle(EEG)
%
%       Pops up a dialog to remove a lead field from the EEGLAB dataset, or
%       to re-generate and add one that was removed previously. This is
%       done to save space in the dataset.
%
%       The pop_ functions serve only to provide a GUI for some of
%       SEREEGA's functions and are not intended to be used in scripts.
%
% In:
%       EEG - an EEGLAB dataset that includes a SEREEGA lead field in
%             EEG.etc.sereega.leadfield, or a lead field generation
%             function in EEG.etc.sereega.leadfieldfunction
%
% Out:  
%       EEG - the EEGLAB dataset with lead field removed or added depending
%             on the actions taken in the dialog, at/from
%             EEG.etc.sereega.leadfield
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

function EEG = pop_sereega_lftoggle(EEG)

if ~isfield(EEG.etc, 'sereega') || (~isfield(EEG.etc.sereega, 'leadfield') && ~isfield(EEG.etc.sereega, 'leadfieldfunction'))
    errormsg = 'Found neither a lead field nor a lead field function.';
    supergui( 'geomhoriz', { 1 1 1 }, 'uilist', { ...
            { 'style', 'text', 'string', errormsg }, { }, ...
            { 'style', 'pushbutton' , 'string', 'OK', 'callback', 'close(gcbf);'} }, ...
            'title', 'Error');
    return
end

cb_button_remove = [ ...
        'EEG.etc.sereega = rmfield(EEG.etc.sereega, ''leadfield'');', ...
        'close(gcbf);', ...
        'disp(''Removed lead field.'');'];
cb_button_regenerate = [ ...
        'disp(''Generating lead field...'');', ...
        'eval([''EEG.etc.sereega.leadfield = '' EEG.etc.sereega.leadfieldfunction]);', ...
        'close(gcbf);', ...
        'disp(''Done.'');'];

if isfield(EEG.etc.sereega, 'leadfieldfunction')
    if isfield(EEG.etc.sereega, 'leadfield')
        buttontext = 'Remove lead field';
        buttoncallback = cb_button_remove;
    elseif ~isfield(EEG.etc.sereega, 'leadfield') || isempty(EEG.etc.sereega.leadfield)
        buttontext = 'Re-generate lead field';
        buttoncallback = cb_button_regenerate;
    end
else
    error('lead field re-generation code not available');
end

supergui( ...
        'geomhoriz', { 1 1 1 1 1 1 1 1 1 1 1 }, ...
        'geomvert', [1 1 1 1 1 1 1 1 1 1 1], ...
        'uilist', { ...
                { 'style', 'text', 'string', 'Remove/add lead field', 'fontweight', 'bold' }, ...
                { }, ...
                { 'style', 'text', 'string', 'A lead field can take up hundreds of megabytes' }, ...
                { 'style', 'text', 'string', 'and does not need to be saved with each simulated' }, ...
                { 'style', 'text', 'string', 'data set, as it can be re-generated when needed.' }, ...
                { }, ...
                { 'style', 'text', 'string', 'Press the below button to remove an included lead' }, ...
                { 'style', 'text', 'string', 'field before saving the data set, or to re-generate' }, ...
                { 'style', 'text', 'string', 'a lead field that was removed.' }, ...
                { }, ...
                { 'style', 'pushbutton', 'string', buttontext, 'callback', buttoncallback }, ...
                }, ... 
        'title', 'Lead field inclusion');

end

