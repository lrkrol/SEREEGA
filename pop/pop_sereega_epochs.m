% EEG = pop_sereega_sources(EEG)
%
%       Pops up a dialog window that allows you to set the epoch variables
%       for the simulation.
%
%       The pop_ functions serve only to provide a GUI for some of
%       SEREEGA's functions and are not intended to be used in scripts.
%
% In:
%       EEG - an EEGLAB dataset
%
% Out:  
%       EEG - the EEGLAB dataset with epoch information added to
%             EEG.etc.sereega.epochs.
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

function EEG = pop_sereega_epochs(EEG)

if isfield(EEG.etc, 'sereega') && isfield(EEG.etc.sereega, 'epochs')
    n = EEG.etc.sereega.epochs.n;
    length = EEG.etc.sereega.epochs.length;
    srate = EEG.etc.sereega.epochs.srate;
    marker = EEG.etc.sereega.epochs.marker;
    prestim = EEG.etc.sereega.epochs.prestim;
else
    n = 100;
    length = 1000;
    srate = 1000;
    marker = 'event1';
    prestim = 0;
end

[~, ~, ~, structout] = inputgui( ...
        'geometry', { 1 1 [1 1] [1 1] [1 1] 1 [1 1] [1 1]}, ...
        'geomvert', [1 1 1 1 1 1 1 1], ...
        'uilist', { ...
                { 'style', 'text', 'string', 'Configure epochs', 'fontweight', 'bold' }, ...
                { }, ...
                { 'style', 'text', 'string', 'Number of epochs' }, ...
                { 'style', 'edit', 'string', n, 'tag', 'n' }, ...
                { 'style', 'text', 'string', 'Length (ms)' }, ...
                { 'style', 'edit', 'string', length, 'tag', 'length' }, ...
                { 'style', 'text', 'string', 'Sampling rate (Hz)' }, ...
                { 'style', 'edit', 'string', srate, 'tag', 'srate' }, ...
                { }, ...
                { 'style', 'text', 'string', 'Event marker' }, ...
                { 'style', 'edit', 'string', marker, 'tag', 'marker' }, ...
                { 'style', 'text', 'string', 'Prestimulus period (ms)' }, ...
                { 'style', 'edit', 'string', prestim, 'tag', 'prestim' }, ...
                }, ... 
        'title', 'Epoch configuration');

if ~isempty(structout)
    % user pressed OK
    epochs = struct(...
        'n', str2num(structout.n), ...
        'length', str2num(structout.length), ...
        'srate', str2num(structout.srate), ...
        'marker', structout.marker, ...
        'prestim', str2num(structout.prestim));
    
    EEG.etc.sereega.epochs = epochs;
    
    disp('Configured epochs.');
end

end

