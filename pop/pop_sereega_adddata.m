% EEG = pop_sereega_adddata(EEG)
%
%       Pops up a dialog window that allows you to add a data class to the
%       simulation.
%
%       The pop_ functions serve only to provide a GUI for some of
%       SEREEGA's functions and are not intended to be used in scripts.
%
% In:
%       EEG - an EEGLAB dataset
%
% Out:  
%       EEG - the EEGLAB dataset with a data class added to 
%             EEG.etc.sereega.signals depending on the actions taken in the
%             dialog window
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

function EEG = pop_sereega_adddata(EEG)

if ~isfield(EEG.etc, 'sereega') || ~isfield(EEG.etc.sereega, 'signals')
    EEG.etc.sereega.signals = {};
end

[~, ~, ~, structout] = inputgui( ...
        'geometry', { 1 1 [1 1 1 1] [1 1 2] [1 1 2] [1 1 2] 1 [1 1 1 1] [1 1 1 1]}, ...
        'geomvert', [1 1 1 1 1 1 1 1 1], ...
        'uilist', { ...
                { 'style', 'text', 'string', 'Add data', 'fontweight', 'bold' }, ...
                { }, ...
                { 'style', 'text', 'string', 'Parameter', 'fontweight', 'bold' }, ...
                { 'style', 'text', 'string', 'Base value *', 'fontweight', 'bold' }, ...
                { 'style', 'text', 'string', 'Deviation', 'fontweight', 'bold' }, ...
                { 'style', 'text', 'string', 'Slope', 'fontweight', 'bold' }, ...
                { 'style', 'text', 'string', 'Data *' }, ...
                { 'style', 'edit', 'string', 'varname', 'tag', 'data' }, ...
                { }, ...
                { 'style', 'text', 'string', 'Index *' }, ...
                { 'style', 'edit', 'string', '{''e'', '':''}', 'tag', 'index' }, ...
                { }, ...
                { 'style', 'text', 'string', 'Amplitude type *' }, ...
                { 'style', 'popupmenu', 'string', 'absolute|relative', 'tag', 'amplitudeType' }, ...
                { }, ...
                { }, ...
                { 'style', 'text', 'string', 'Amplitude *' }, ...
                { 'style', 'edit', 'string', '', 'tag', 'amplitude' }, ...
                { 'style', 'edit', 'string', '', 'tag', 'amplitudedv' }, ...
                { 'style', 'edit', 'string', '', 'tag', 'amplitudeslope' }, ...
                { 'style', 'text', 'string', 'Probability' }, ...
                { 'style', 'edit', 'string', '', 'tag', 'probability' }, ...
                { }, ...
                { 'style', 'edit', 'string', '', 'tag', 'probabilityslope' }, ...                
                }, ... 
        'helpcom', 'pophelp(''data_check_data'');', ...
        'title', 'Add data');

if ~isempty(structout)
    % user pressed OK
    data = struct('type', 'data');
    
    data.data = evalin('base', structout.data);
    data.index = eval(structout.index);
    
    amplitudeType = {'absolute', 'relative'};
    data.amplitudeType = amplitudeType{structout.amplitudeType};
    
    if ~isempty(structout.amplitude)
        data.amplitude = str2num(structout.amplitude); end
    if ~isempty(structout.amplitudedv)
        data.amplitudeDv = str2num(structout.amplitudedv); end
    if ~isempty(structout.amplitudeslope)
        data.amplitudeSlope = str2num(structout.amplitudeslope); end
    if ~isempty(structout.probability)
        data.probability = str2num(structout.probability); end
    if ~isempty(structout.probabilityslope)
        data.probabilitySlope = str2num(structout.probabilityslope); end
    
    data = utl_check_class(data);
    EEG.etc.sereega.signals = [EEG.etc.sereega.signals, {data}];
end

end
