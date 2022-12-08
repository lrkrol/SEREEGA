% EEG = pop_sereega_lf_generate_fromhartmut(EEG)
%
%       Pops up a dialog to serve as GUI for lf_generate_fromhartmut, and
%       adds a lead field to the given EEGLAB dataset.
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
%                    Copyright 2022 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2022-11-17 First version

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

function EEG = pop_sereega_lf_generate_fromhartmut(EEG)

% strjoin is problematically overloaded by a number of EEGLAB toolboxes;
% making sure that we use the correct one
cdorig = cd(fileparts(which('strfun/strjoin')));
joinstring = @strjoin;
cd(cdorig);
userdata.joinstring = joinstring;

models = {'mix_Colin27_small', 'NYhead_small'};

% getting channel labels
labels{1} = {};
fid = fopen('chanlocs-hartmut-mix_Colin27_small.xyz', 'r'); 
while ~feof(fid)
    line = fgets(fid);
    [i, j] = regexp(line, '(?<=\s+)\w+(?=\s*$)');
    if ~isempty(i), labels{1} = [labels{1}, {line(i:j)}]; end
end
fclose(fid);
labels{1} = sort(labels{1});

labels{2} = {};
fid = fopen('chanlocs-hartmut-NYhead_small.xyz', 'r'); 
while ~feof(fid)
    line = fgets(fid);
    [i, j] = regexp(line, '(?<=\s+)\w+(?=\s*$)');
    if ~isempty(i), labels{2} = [labels{2}, {line(i:j)}]; end
end
fclose(fid);
labels{2} = sort(labels{2});

% setting defaults
userdata.model = 1;
userdata.labels = labels{userdata.model};

% getting montages
montages = {sprintf('All %d channels', length(userdata.labels)), 'Custom selection'};
montages = [montages, utl_get_montage('?')];

if isstr(EEG)
    userdata = get(gcbf, 'userdata');
    set(findobj(gcbf, 'tag', 'model'), 'value', userdata.model);
    userdata.labels = labels{userdata.model};
    montages{1} = sprintf('All %d channels', length(userdata.labels));
    set(findobj(gcbf, 'tag', 'montage'), 'string', montages);
    set(findobj(gcbf, 'tag', 'montage'), 'value', 1);
    set(findobj(gcbf, 'tag', 'labeledit'), 'string', joinstring(userdata.labels));
    set(gcf, 'userdata', userdata);
    return
end

% callbacks
cb_model = [ ...
        'userdata = get(gcf, ''userdata'');', ...
        'userdata.model = get(gcbo, ''value'');', ...
        'set(gcf, ''userdata'', userdata);', ...
        'pop_sereega_lf_generate_fromhartmut(''setuserdata'');'];
cb_montage = [ ...
        'userdata = get(gcf, ''userdata'');' ...
        'if get(gcbo, ''value'') == 1', ...
        '    set(findobj(''parent'', gcbf, ''tag'', ''labeledit''), ''string'', ''' joinstring(labels{userdata.model}) ''');' ...
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
        'geometry', { 1 1 1 1 1 1 1 1 1 [4 1] }, ...
        'geomvert', [1 1 1 3 1 1 1 6 1 1], ...
        'uilist', { ...
                { 'style', 'text', 'string', 'Obtain a lead field from HArtMuT', 'fontweight', 'bold' }, ...
                { }, ...
                { 'style', 'text', 'string', 'Indicate which model to use' }, ...
                { 'style', 'listbox', 'string', models, 'tag', 'model', 'callback', cb_model }, ...
                { }, ...
                { 'style', 'text', 'string', 'Indicate which channels to include in the simulation,' }, ...
                { 'style', 'text', 'string', 'using a montage or custom channel selection' }, ...
                { 'style', 'listbox', 'string', montages, 'tag', 'montage', 'callback', cb_montage }, ...
                { }, ...
                { 'style', 'edit', 'string', joinstring(userdata.labels), 'tag', 'labeledit' }, ...
                { 'style', 'pushbutton', 'string', '...', 'callback', cb_select } }, ... 
        'helpcom', 'pophelp(''lf_generate_fromhartmut'');', ...
        'title', 'Lead field: HArtMuT', ...
        'userdata', userdata);

if ~isempty(structout)
    % user pressed OK, getting label selection in cell format
    labelselection = textscan(structout.labeledit, '%s');
    labelselection = labelselection{1}';
    
    model = models{structout.model};
            
    % adding lead field to EEG structure
    disp('Generating lead field...');
    EEG.etc.sereega.leadfield = lf_generate_fromhartmut(model, 'labels', labelselection);
    
    % also adding code to generate lead field
    EEG.etc.sereega.leadfieldfunction = sprintf('lf_generate_fromhartmut(''%s'', ''labels'', %s);', model, ['{''' joinstring(labelselection, ''',''') '''}']);
    disp('Done.');
end

end

