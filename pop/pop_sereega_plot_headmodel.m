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

% 2022-12-02 lrk
%   - Added electrodes argument
% 2021-01-07 lrk
%   - Added atlas support
% 2018-07-16 lrk
%   - Fixed issue where view was not properly converted
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
end

% obtaining list of regions, renaming generic ones
[allregions, ~, generic, ~] = lf_get_regions(EEG.etc.sereega.leadfield);
genreglist = cellfun(@(x) sprintf('All_%s*', x), generic, 'UniformOutput', false);
reglist = [{'All'}, genreglist, allregions];

cb_selectregion = [ ...
        '[~, regionselection] = pop_chansel({''' joinstring(reglist, ''',''') '''});' ...
        'if ~isempty(regionselection)' ...
        '    set(findobj(''parent'', gcbf, ''tag'', ''regionedit''), ''string'', regionselection);' ...
        'end'];

[~, ~, ~, structout] = inputgui( ...
        'geometry', { 1 1 [2 1] 1 1  [1 2] [1 2] 1 [1 2] [1 2] 1 [1 2]}, ...
        'geomvert', [1 1 1 1 1 1 1 1 1 1 1 1], ...
        'uilist', { ...
                { 'style', 'text', 'string', 'Plot head model', 'fontweight', 'bold' }, ...
                { }, ...
                { 'style', 'text', 'string', 'Select the region(s) to plot' }, ...
                { 'style', 'pushbutton', 'string', '...', 'callback', cb_selectregion }, ... 
                { 'style', 'edit', 'string', joinstring(reglist(1)), 'tag', 'regionedit' }, ...
                { }, ...
                { 'style', 'text', 'string', 'Electrodes' }, ...
                { 'style', 'checkbox', 'string', 'Plot electrodes', 'value', 1, 'tag', 'electrodes' }, ...
                { 'style', 'text', 'string', 'Labels' }, ...
                { 'style', 'checkbox', 'string', 'Plot electrode labels', 'value', 1, 'tag', 'labels' }, ...
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
    
    % getting region selection in cell format
    regionselection = textscan(structout.regionedit, '%s');
    regionselection = regionselection{1}';
    
    % adding regex to original labels and undoing the renaming
    generic = cellfun(@(x) sprintf('^%s.*$', x), generic, 'UniformOutput', false);
    allregions = cellfun(@(x) sprintf('^%s$', x), allregions, 'UniformOutput', false);
    regexlist = [{'.*'}, generic, allregions];
    region = cellfun(@(x) regexlist{find(strcmp(x, reglist))}, regionselection, 'UniformOutput', false);
    
    styles = {'scatter', 'boundary'};    
    plot_headmodel(EEG.etc.sereega.leadfield, 'electrodes', structout.electrodes, 'labels', structout.labels, 'style', styles{structout.style}, 'shrink', str2double(structout.shrink), 'view', str2num(structout.view), 'region', region);
end

end

