% EEG = pop_sereega_lf_generate_frompha(EEG)
%
%       Pops up a dialog to serve as GUI for lf_generate_frompha, and add a
%       lead field to the given EEGLAB dataset.
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

function EEG = pop_sereega_lf_generate_frompha(EEG)

% strjoin is problematically overloaded by a number of EEGLAB toolboxes;
% making sure that we use the correct one
cdorig = cd(fileparts(which('strfun/strjoin')));
joinstring = @strjoin;
cd(cdorig);
userdata.joinstring = joinstring;

agegroups = {'0 to 2', '4 to 8', '8 to 18'};

% getting channel labels
alllabels = textscan(sprintf('E%d ', 1:2562), '%s');
alllabels = alllabels{1}';

% setting defaults
userdata.agegroup = 1;
userdata.layout = 1;
userdata.labels = alllabels(1:128);

% getting montages
montages = {sprintf('All %d channels', length(userdata.labels)), 'Custom selection'};
montages = [montages, utl_get_montage('?')];

if isstr(EEG)
    userdata = get(gcbf, 'userdata');
    set(findobj(gcbf, 'tag', 'agegroup'), 'value', userdata.agegroup);
    if userdata.agegroup == 1
        layouts = {'128', '2562'};
    else
        layouts = {'128', '256', '2562'};
    end
    set(findobj(gcbf, 'tag', 'layout'), 'string', layouts);
    set(findobj(gcbf, 'tag', 'layout'), 'value', userdata.layout);
    numchan = str2num(layouts{userdata.layout});
    montages{1} = sprintf('All %d channels', numchan);
    set(findobj(gcbf, 'tag', 'montage'), 'string', montages);
    set(findobj(gcbf, 'tag', 'montage'), 'value', 1);
    userdata.labels = alllabels(1:numchan);
    set(findobj(gcbf, 'tag', 'labeledit'), 'string', joinstring(userdata.labels));
    set(gcf, 'userdata', userdata);
    return
end

% callbacks
cb_agegroup = [ ...
        'userdata = get(gcf, ''userdata'');', ...
        'userdata.agegroup = get(gcbo, ''value'');', ...
        'userdata.layout = 1;', ...
        'set(gcf, ''userdata'', userdata);', ...
        'pop_sereega_lf_generate_frompha(''setuserdata'');'];
cb_layout = [ ...
        'userdata = get(gcf, ''userdata'');', ...
        'userdata.layout = get(gcbo, ''value'');', ...
        'set(gcf, ''userdata'', userdata);', ...
        'pop_sereega_lf_generate_frompha(''setuserdata'');'];
cb_montage = [ ...
        'userdata = get(gcf, ''userdata'');' ...
        'if get(gcbo, ''value'') == 1', ...
        '    set(findobj(''parent'', gcbf, ''tag'', ''labeledit''), ''string'', ''' joinstring(alllabels) ''');' ...
        'elseif get(gcbo, ''value'') == 2', ...
        '    set(findobj(''parent'', gcbf, ''tag'', ''labeledit''), ''string'', '''');' ...
        'else', ...
        '    montage = get(gcbo, ''String'');', ...
        '    montage = montage(get(gcbo, ''value''));', ...
        '    set(findobj(''parent'', gcbf, ''tag'', ''labeledit''), ''string'', userdata.joinstring(utl_get_montage(montage{1})));' ...
        'end'];
cb_select = [ ...
        'userdata = get(gcf, ''userdata'');', ...
        '[~, labelselection] = pop_chansel(userdata.labels);' ...
        'if ~isempty(labelselection)' ...
        '    set(findobj(''parent'', gcbf, ''tag'', ''labeledit''), ''string'', labelselection);' ...
        'end'];

[~, ~, ~, structout] = inputgui( ...
        'geometry', { 1 1 1 1 1 1 1 1 1 1 1 1 [4 1] }, ...
        'geomvert', [1 1 1 3 1 1 3 1 1 1 6 1 1], ...
        'uilist', { ...
                { 'style', 'text', 'string', 'Obtain a lead field from a Pediatric Head Atlas', 'fontweight', 'bold' }, ...
                { }, ...
                { 'style', 'text', 'string', 'Indicate which age group to use' }, ...
                { 'style', 'listbox', 'string', agegroups, 'tag', 'agegroup', 'callback', cb_agegroup }, ...
                { }, ...
                { 'style', 'text', 'string', 'Indicate which channel layout to use' }, ...
                { 'style', 'listbox', 'string', {'128', '2562'}, 'tag', 'layout', 'callback', cb_layout }, ...
                { }, ...
                { 'style', 'text', 'string', 'Indicate which channels to include in the simulation,' }, ...
                { 'style', 'text', 'string', 'using a montage or custom channel selection' }, ...
                { 'style', 'listbox', 'string', montages, 'tag', 'montage', 'callback', cb_montage }, ...
                { }, ...
                { 'style', 'edit', 'string', joinstring(userdata.labels), 'tag', 'labeledit' }, ...
                { 'style', 'pushbutton', 'string', '...', 'callback', cb_select } }, ... 
        'helpcom', 'pophelp(''lf_generate_frompha'');', ...
        'title', 'Lead field: Pediatric Head Atlas', ...
        'userdata', userdata);

if ~isempty(structout)
    % user pressed OK, getting label selection in cell format
    labelselection = textscan(structout.labeledit, '%s');
    labelselection = labelselection{1}';
    
    agegroup = agegroups{structout.agegroup};
    agegroup(isspace(agegroup)) = [];
    if structout.agegroup == 1
        layouts = {'128', '2562'};
    else
        layouts = {'128', '256', '2562'};
    end
    layout = layouts{structout.layout};
            
    % adding lead field to EEG structure
    disp('Generating lead field...');
    EEG.etc.sereega.leadfield = lf_generate_frompha(agegroup, layout, 'labels', labelselection);
    
    % also adding code to generate lead field
    EEG.etc.sereega.leadfieldfunction = sprintf('lf_generate_frompha(''%s'', ''%s'', ''labels'', %s);', agegroup, layout, ['{''' joinstring(labelselection, ''',''') '''}']);
    disp('Done.');
end

end

