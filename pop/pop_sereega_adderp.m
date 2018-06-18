% EEG = pop_sereega_adderp(EEG)
%
%       Pops up a dialog window that allows you to add an ERP class to the
%       simulation.
%
%       The pop_ functions serve only to provide a GUI for some of
%       SEREEGA's functions and are not intended to be used in scripts.
%
% In:
%       EEG - an EEGLAB dataset
%
% Out:  
%       EEG - the EEGLAB dataset with an ERP class added to 
%             EEG.etc.sereega.signals depending on the actions taken in the
%             dialog window
% 
%                    Copyright 2018 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2018-06-17 lrk
%   - Added peakLatencyShift parameter
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

function EEG = pop_sereega_adderp(EEG)

if ~isfield(EEG.etc, 'sereega') || ~isfield(EEG.etc.sereega, 'signals')
    EEG.etc.sereega.signals = {};
end

[~, ~, ~, structout] = inputgui( ...
        'geometry', { 1 1 [1 1 1 1 1] [1 1 1 1 1] [1 1 1 1 1] [1 1 1 1 1] [1 1 1 1 1]}, ...
        'geomvert', [1 1 1 1 1 1 1], ...
        'uilist', { ...
                { 'style', 'text', 'string', 'Add event-related potential', 'fontweight', 'bold' }, ...
                { }, ...
                { 'style', 'text', 'string', 'Parameter', 'fontweight', 'bold' }, ...
                { 'style', 'text', 'string', 'Base value *', 'fontweight', 'bold' }, ...
                { 'style', 'text', 'string', 'Deviation', 'fontweight', 'bold' }, ...
                { 'style', 'text', 'string', 'Slope', 'fontweight', 'bold' }, ...
                { 'style', 'text', 'string', 'Shift', 'fontweight', 'bold' }, ...
                { 'style', 'text', 'string', 'Peak latency *' }, ...
                { 'style', 'edit', 'string', '', 'tag', 'peaklatency' }, ...
                { 'style', 'edit', 'string', '', 'tag', 'peaklatencydv' }, ...
                { 'style', 'edit', 'string', '', 'tag', 'peaklatencyslope' }, ...
                { 'style', 'edit', 'string', '', 'tag', 'peaklatencyshift' }, ...
                { 'style', 'text', 'string', 'Peak width *' }, ...
                { 'style', 'edit', 'string', '', 'tag', 'peakwidth' }, ...
                { 'style', 'edit', 'string', '', 'tag', 'peakwidthdv' }, ...
                { 'style', 'edit', 'string', '', 'tag', 'peakwidthslope' }, ...
                { }, ...
                { 'style', 'text', 'string', 'Peak amplitude *' }, ...
                { 'style', 'edit', 'string', '', 'tag', 'peakamplitude' }, ...
                { 'style', 'edit', 'string', '', 'tag', 'peakamplitudedv' }, ...
                { 'style', 'edit', 'string', '', 'tag', 'peakamplitudeslope' }, ...
                { }, ...
                { 'style', 'text', 'string', 'Probability' }, ...
                { 'style', 'edit', 'string', '', 'tag', 'probability' }, ...
                { }, ...
                { 'style', 'edit', 'string', '', 'tag', 'probabilityslope' }, ...
                { }, ...
                }, ... 
        'helpcom', 'pophelp(''erp_check_class'');', ...
        'title', 'Add ERP');

if ~isempty(structout)
    % user pressed OK
    erp = struct('type', 'erp');
    
    if ~isempty(structout.peaklatency)
        erp.peakLatency = str2num(structout.peaklatency); end
    if ~isempty(structout.peaklatencydv)
        erp.peakLatencyDv = str2num(structout.peaklatencydv); end
    if ~isempty(structout.peaklatencyslope)
        erp.peakLatencySlope = str2num(structout.peaklatencyslope); end
    if ~isempty(structout.peaklatencyshift)
        erp.peakLatencyShift = str2num(structout.peaklatencyshift); end
    if ~isempty(structout.peakwidth)
        erp.peakWidth = str2num(structout.peakwidth); end
    if ~isempty(structout.peakwidthdv)
        erp.peakWidthDv = str2num(structout.peakwidthdv); end
    if ~isempty(structout.peakwidthslope)
        erp.peakWidthSlope = str2num(structout.peakwidthslope); end
    if ~isempty(structout.peakamplitude)
        erp.peakAmplitude = str2num(structout.peakamplitude); end
    if ~isempty(structout.peakamplitudedv)
        erp.peakAmplitudeDv = str2num(structout.peakamplitudedv); end
    if ~isempty(structout.peakamplitudeslope)
        erp.peakAmplitudeSlope = str2num(structout.peakamplitudeslope); end
    if ~isempty(structout.probability)
        erp.probability = str2num(structout.probability); end
    if ~isempty(structout.probabilityslope)
        erp.probabilitySlope = str2num(structout.probabilityslope); end
    
    erp = utl_check_class(erp);
    EEG.etc.sereega.signals = [EEG.etc.sereega.signals, {erp}];
end

end

