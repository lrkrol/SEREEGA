% EEG = pop_sereega_lf_generate_fromfieldtrip(EEG)
%
%       Pops up a dialog to serve as GUI for lf_generate_fromfieldtrip, and
%       add a lead field to the given EEGLAB dataset.
%
%       The pop_ functions serve only to provide a GUI for some of
%       SEREEGA's functions and are not intended to be used in scripts.
%
% In:
%       EEG - an EEGLAB dataset
%
% Out:  
%       EEG - the EEGLAB dataset with added lead field depending on the 
%             actions taken in the dialog, at EEG.etc.sereega.leadfield
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

function EEG = pop_sereega_lf_generate_fromfieldtrip(EEG)

% strjoin is problematically overloaded by a number of EEGLAB toolboxes;
% making sure that we use the correct one
cdorig = cd(fileparts(which('strfun/strjoin')));
joinstring = @strjoin;
cd(cdorig);
userdata.joinstring = joinstring;

% reading channel labels
labels = {};
fid = fopen('chanlocs-standard_1005.elp','r'); 
while ~feof(fid)
    line = fgets(fid);
    [i, j] = regexp(line, '(?<=EEG\s+)\w+(?=\s)');
    if ~isempty(i), labels = [labels, {line(i:j)}]; end
end
fclose(fid);
labels = setdiff(labels, {'RPA', 'LPA', 'Nz'});
labels = sort(labels);

% getting montages
montages = {sprintf('All %d channels', length(labels)), 'Custom selection'};
montages = [montages, utl_get_montage('?')];

% callbacks
cb_montage = [ ...
        'userdata = get(gcf, ''userdata'');' ...
        'if get(gcbo, ''value'') == 1', ...
        '    set(findobj(''parent'', gcbf, ''tag'', ''labeledit''), ''string'', ''' joinstring(labels) ''');' ...
        'elseif get(gcbo, ''value'') == 2', ...
        '    set(findobj(''parent'', gcbf, ''tag'', ''labeledit''), ''string'', '''');' ...
        'else', ...
        '    montage = get(gcbo, ''String'');', ...
        '    montage = montage(get(gcbo, ''value''));', ...
        '    set(findobj(''parent'', gcbf, ''tag'', ''labeledit''), ''string'', userdata.joinstring(utl_get_montage(montage{1})));' ...
        'end'];
cb_select = [ ...
        '[~, labelselection] = pop_chansel({''' joinstring(labels, ''',''') '''});' ...
        'if ~isempty(labelselection)' ...
        '    set(findobj(''parent'', gcbf, ''tag'', ''labeledit''), ''string'', labelselection);' ...
        'end'];

[~, ~, ~, structout] = inputgui( ...
        'geometry', { 1 1 1 1 1 1 1 1 1 [4 1] }, ...
        'geomvert', [1 1 1 1 1 1 1 6 1 1], ...
        'uilist', { ...
                { 'style', 'text', 'string', 'Obtain a lead field using FieldTrip', 'fontweight', 'bold' }, ...
                { }, ...
                { 'style', 'text', 'string', 'Indicate the resolution of the grid in mm' }, ...
                { 'style', 'edit', 'string', '10', 'tag', 'resolution' }, ...
                { }, ...
                { 'style', 'text', 'string', 'Indicate which channels to include in the simulation,' }, ...
                { 'style', 'text', 'string', 'using a montage or custom channel selection' }, ...
                { 'style', 'listbox', 'string', montages, 'tag', 'montage', 'callback', cb_montage }, ...
                { }, ...
                { 'style', 'edit', 'string', joinstring(labels), 'tag', 'labeledit' }, ...
                { 'style', 'pushbutton', 'string', '...', 'callback', cb_select } }, ... 
        'helpcom', 'pophelp(''lf_generate_fromfieldtrip'');', ...
        'title', 'Lead field: FieldTrip', ...
        'userdata', userdata);

if ~isempty(structout)
    % user pressed OK, getting label selection in cell format
    labelselection = textscan(structout.labeledit, '%s');
    labelselection = labelselection{1}';
    
    % adding lead field to EEG structure
    disp('Generating lead field...');
    EEG.etc.sereega.leadfield = lf_generate_fromfieldtrip('resolution', str2num(structout.resolution), 'labels', labelselection);
    
    % also adding code to generate lead field
    EEG.etc.sereega.leadfieldfunction = sprintf('lf_generate_fromfieldtrip(''resolution'', %s, ''labels'', %s);', structout.resolution, ['{''' joinstring(labelselection, ''',''') '''}']);
    disp('Done.');
end

end

