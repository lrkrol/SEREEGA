% EEG = pop_sereega_plot_source_location(EEG)
%
%       Pops up a dialog to plot the sources associated with the given EEG
%       dataset.
%
%       The pop_ functions serve only to provide a GUI for some of
%       SEREEGA's functions and are not intended to be used in scripts.
%
% In:
%       EEG - an EEGLAB dataset that includes a SEREEGA lead field in
%             EEG.etc.sereega.leadfield and sources in
%             EEG.etc.sereega.sources.
%
% Out:  
%       EEG - the same EEGLAB dataset 
% 
%                    Copyright 2018 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2021-01-07 lrk
%   - Added atlas support
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

function EEG = pop_sereega_plot_source_location(EEG)

% strjoin is problematically overloaded by a number of EEGLAB toolboxes;
% making sure that we use the correct one
cdorig = cd(fileparts(which('strfun/strjoin')));
joinstring = @strjoin;
cd(cdorig);
userdata.joinstring = joinstring;

% testing if lead field is present
if ~isfield(EEG.etc, 'sereega') || ~isfield(EEG.etc.sereega, 'leadfield') ...
        || isempty(EEG.etc.sereega.leadfield)
    errormsg = 'First add a lead field to the simulation.';
    supergui( 'geomhoriz', { 1 1 1 }, 'uilist', { ...
            { 'style', 'text', 'string', errormsg }, { }, ...
            { 'style', 'pushbutton' , 'string', 'OK', 'callback', 'close(gcbf);'} }, ...
            'title', 'Error');
    return
elseif ~isfield(EEG.etc.sereega, 'components') || isempty(EEG.etc.sereega.components)
    errormsg = 'First add a sources to the simulation.';
    supergui( 'geomhoriz', { 1 1 1 }, 'uilist', { ...
            { 'style', 'text', 'string', errormsg }, { }, ...
            { 'style', 'pushbutton' , 'string', 'OK', 'callback', 'close(gcbf);'} }, ...
            'title', 'Error');
    return
end

% obtaining list of regions, renaming generic ones
[allregions, ~, generic, ~] = lf_get_regions(EEG.etc.sereega.leadfield);
genreglist = cellfun(@(x) sprintf('All_%s*', x), generic, 'UniformOutput', false);
reglist = [{'All'}, genreglist, allregions];

% general callback functions
cbf_get_value = @(tag,property) sprintf('get(findobj(''parent'', gcbf, ''tag'', ''%s''), ''%s'')', tag, property);
cbf_set_value = @(tag,property,value) sprintf('set(findobj(''parent'', gcbf, ''tag'', ''%s''), ''%s'', %s);', tag, property, value);

% callbacks
cb_check2d = cbf_set_value('check3d', 'value', ['~' cbf_get_value('check3d', 'value')]);
cb_check3d = cbf_set_value('check2d', 'value', ['~' cbf_get_value('check2d', 'value')]);
cb_selectregion = [ ...
        '[~, regionselection] = pop_chansel({''' joinstring(reglist, ''',''') '''});' ...
        'if ~isempty(regionselection)' ...
        '    set(findobj(''parent'', gcbf, ''tag'', ''regionedit''), ''string'', regionselection);' ...
        'end'];

% building gui
[~, ~, ~, structout] = inputgui( ...
        'geometry', { 1 1 1 1 1 1 [1 1] 1 [3 1] 1 1 [1 1] [1 1] }, ...
        'geomvert', [1 1 1 1 1 1 1 1 1 1 1 1 1], ...
        'uilist', { ...
                { 'style', 'text', 'string', 'Plot source locations', 'fontweight', 'bold' }, ...
                { }, ...
                { 'style', 'text', 'string', 'This plots all sources in the simulation.' }, ...
                { 'style', 'text', 'string', 'To plot individual sources, go to "Select source' }, ...
                { 'style', 'text', 'string', 'locations" under "Configure components".' }, ...
                { }, ...
                { 'style', 'checkbox', 'string', 'Plot in 2D', 'enable', 'on', 'tag', 'check2d', 'value', 1, 'callback', cb_check2d }, ...
                { 'style', 'checkbox', 'string', 'Plot in 3D', 'enable', 'on', 'tag', 'check3d', 'value', 0, 'callback', cb_check3d }, ...
                { }, ...
                { 'style', 'text', 'string', 'Region(s) to include as context' }, ...
                { 'style', 'pushbutton', 'string', '...', 'callback', cb_selectregion }, ... 
                { 'style', 'edit', 'string', joinstring(reglist(1)), 'tag', 'regionedit' }, ...
                { }, ...
                { 'style', 'text', 'string', 'Shrink factor' }, ...
                { 'style', 'edit', 'string', '0.5', 'tag', 'shrink' }, ...
                { 'style', 'text', 'string', 'Viewpoint' }, ...
                { 'style', 'edit', 'string', '120, 20', 'tag', 'view' }, ...
                }, ... 
        'helpcom', 'pophelp(''plot_source_location'');', 'title', 'Plot source locations');

if ~isempty(structout)
    % user pressed OK
    
    % getting region selection in cell format
    regionselection = textscan(structout.regionedit, '%s');
    regionselection = regionselection{1}';
        
    % adding regex to original labels and undoing the renaming
    generic = cellfun(@(x) sprintf('^%s.*$', x), generic, 'UniformOutput', false);
    allregions = cellfun(@(x) sprintf('^%s$', x), allregions, 'UniformOutput', false);
    regexlist = [{'.*'}, generic, allregions];
    region = cellfun(@(x) regexlist{find(strcmp(x, reglist))}, regionselection, 'UniformOutput', false);
    
    % plotting
    if structout.check2d
        plot_source_location([EEG.etc.sereega.components.source], EEG.etc.sereega.leadfield, 'region', region);
    else
        plot_source_location([EEG.etc.sereega.components.source], EEG.etc.sereega.leadfield, 'mode', '3d', 'shrink', str2num(structout.shrink), 'view', str2num(structout.view), 'region', region);
    end
end

end