% EEG = utl_add_markers_toeeglabdataset(EEG, newmarker, refmarker, rellatency)
%
% In:
%       EEG - epoched dataset in EEGLAB format
%       newmarker - new marker string
%       refmarker - existing marker to use as reference point
%       rellatency - latency in ms relative to refmarker at which to place
%                    the new marker
%
% Out:  
%       EEG - updated dataset in EEGLAB format
%
% Usage example:
%       >> lf = lf_generate_fromnyhead();
%       >> epochs = struct('srate', 512, 'length', 1000, 'prestim', 200,...
%                          'marker', 'originalmarker');
%       >> EEG = utl_create_eeglabdataset(rand(228, 512, 100), epochs, lf);
%       >> EEG = utl_add_markers_toeeglabdataset(EEG, 'newmarker', ...
%                          'originalmarker', 175);
% 
%                    Copyright 2021 Laurens R Krol
%                    Neuroadaptive Human-Computer Interaction
%                    Brandenburg University of Technology

% 2021-03-011 First version

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

function EEG = utl_add_markers_toeeglabdataset(EEG, newmarker, refmarker, rellatency)

numevents = numel(EEG.event);

% finding refmarker latencies and epochs
idx = strcmp(refmarker, {EEG.event.type});
epochs = [EEG.event(idx).epoch];
latencies = [EEG.event(idx).latency];

% adding newmarker events relative to latencies
for e = 1:numel(latencies)
    EEG.event(numevents+e) = importevent( ...
            {newmarker, latencies(e) + rellatency/1000*EEG.srate, 1, epochs(e)}, ...
            [], EEG.srate, ...
            'fields', {'type', 'latency', 'duration', 'epoch'}, ...
            'timeunit', NaN);
end

fprintf('Added %d events.\n', numel(latencies));

% re-sorting events
EEG = eeg_checkset(EEG, 'eventconsistency');
EEG = pop_editeventvals(EEG, 'sort', { 'latency' 0 });

end
