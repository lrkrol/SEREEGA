% version = eegplugin_sereega(fig, try_strings, catch_strings)
%
%       Loader for SEREEGA's EEGLAB plug-in, which provides a number of
%       dialog options in the Tools menu to perform some of SEREEGA's EEG
%       simulation functions.
%
% In:
%       fig - the handle to the EEGLAB window
%       try_strings - "try" strings for menu callbacks
%       catch_strings - "catch" strings for menu callbacks
%
% Out:  
%       version - the version of the plug-in
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

function version = eegplugin_sereega(fig, try_strings, catch_strings)
    
    version = '1.0.0-beta';
    
    % find tools menu
    % ---------------
    menu = findobj(fig, 'tag', 'tools'); 
    % tag can be 
    % 'import data'  -> File > import data menu
    % 'import epoch' -> File > import epoch menu
    % 'import event' -> File > import event menu
    % 'export'       -> File > export
    % 'tools'        -> tools menu
    % 'plot'         -> plot menu
    
    % menu callback commands
    % ----------------------
    cb_epochs = 'EEG = pop_sereega_epochs(EEG);';
    cb_lf_nyhead = 'EEG = pop_sereega_lf_generate_fromnyhead(EEG);';
    cb_lf_pha = 'EEG = pop_sereega_lf_generate_frompha(EEG);';
    cb_lf_fieldtrip = 'EEG = pop_sereega_lf_generate_fromfieldtrip(EEG);';
    cb_comp_sources = 'EEG = pop_sereega_sources(EEG);';
    cb_comp_signals = 'EEG = pop_sereega_signals(EEG);';
    cb_comp_components = 'EEG = pop_sereega_components(EEG);';
    cb_plot_headmodel = 'EEG = pop_sereega_plot_headmodel(EEG);';
    cb_plot_sources = 'EEG = pop_sereega_plot_sources(EEG);';
    cb_plot_components = 'EEG = pop_sereega_plot_component(EEG);';
    cb_misc_lftoggle = 'EEG = pop_sereega_lftoggle(EEG);';
    cb_misc_addica = 'EEG = pop_sereega_utl_add_icaweights_toeeglabdataset(EEG);';
    cb_simulate = 'EEG = pop_sereega_simulate_scalpdata(EEG);';
    
    % create menus
    % ------------
    userdata = 'startup:on';
    menu_root = uimenu(menu, 'label', 'SEREEGA', 'separator', 'on', 'userdata', userdata);
        menu_sim_epochs = uimenu(menu_root, 'label', 'Configure epochs', 'userdata', userdata, 'callback', cb_epochs);
        menu_lf = uimenu(menu_root, 'label', 'Configure lead field');
            menu_lf_nyhead = uimenu(menu_lf, 'label', 'New York Head', 'userdata', userdata, 'callback', cb_lf_nyhead);
            menu_lf_pha = uimenu(menu_lf, 'label', 'Pediatric Head Atlas', 'userdata', userdata, 'callback', cb_lf_pha);
            menu_lf_fieldtrip = uimenu(menu_lf, 'label', 'FieldTrip', 'userdata', userdata, 'callback', cb_lf_fieldtrip);
        menu_comp = uimenu(menu_root, 'label', 'Configure components', 'userdata', userdata);
            menu_comp_sources = uimenu(menu_comp, 'label', 'Select source locations', 'userdata', userdata, 'callback', cb_comp_sources);
            menu_comp_signals = uimenu(menu_comp, 'label', 'Define source activations', 'userdata', userdata, 'callback', cb_comp_signals);
            menu_comp_components = uimenu(menu_comp, 'label', 'Define components', 'userdata', userdata, 'callback', cb_comp_components);
        menu_plot = uimenu(menu_root, 'label', 'Plot', 'userdata', userdata);
            menu_plot_headmodel = uimenu(menu_plot, 'label', 'Head model', 'userdata', userdata, 'callback', cb_plot_headmodel);
            menu_plot_sources = uimenu(menu_plot, 'label', 'Sources', 'userdata', userdata, 'callback', cb_plot_sources);
            menu_plot_components = uimenu(menu_plot, 'label', 'Components', 'userdata', userdata, 'callback', cb_plot_components);
        menu_misc = uimenu(menu_root, 'label', 'Misc', 'userdata', userdata);
            menu_misc_lftoggle = uimenu(menu_misc, 'label', 'Remove/add lead field', 'userdata', userdata, 'callback', cb_misc_lftoggle);
            menu_misc_addica = uimenu(menu_misc, 'label', 'Add ICA decomposition', 'userdata', userdata, 'callback', cb_misc_addica);
        menu_simulate = uimenu(menu_root, 'label', 'Simulate data', 'userdata', userdata, 'callback', cb_simulate);
    
end

