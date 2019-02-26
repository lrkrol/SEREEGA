% EEG = utl_create_eeglabdataset(data, epochs, leadfield, varargin)
%
% In:
%       data - channels x samples x epochs matrix of data points
%       epochs - 1x1 struct, an epoch configuration struct, containing at
%                least the field 'srate' containing the sampling rate in Hz. 
%                optionally, the field 'prestim' is recognised and applied as
%                prestimulus period in ms.
%       leadfield - 1x1 struct, the leadfield with which the component data
%                   was generated
%
% Optional (key-value pairs):
%       marker - string to put at 0 time point for epoched data (default
%                'event'). if indicated and not manually overridden, 
%                epochs.marker is used.
%
% Out:  
%       EEG - dataset in EEGLAB format
%
% Usage example:
%       >> lf = lf_generate_fromnyhead();
%       >> epochs = struct('srate', 512, 'length', 1000, 'prestim', 200);
%       >> EEG = utl_create_eeglabdataset(rand(228, 512, 100), epochs, lf);
% 
%                    Copyright 2015-2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2017-11-24 lrk
%   - Now takes epochs and leadfield structs instead of separate values for
%     srate, chanlocs, prestim, and marker.
% 2017-06-14 lrk
%   - Now accepts both chanlocs structure and cell of channel labels
%   - Added markers
%   - Switched to inputParser to parse arguments
%   - Modifications for inclusion in SEREEGA
% 2015-11-30 First version

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

function EEG = utl_create_eeglabdataset(data, epochs, leadfield, varargin)

% parsing input
p = inputParser;

addRequired(p, 'data', @isnumeric);
addRequired(p, 'epochs', @isstruct);
addRequired(p, 'leadfield', @isstruct);

addParameter(p, 'marker', '', @ischar);

parse(p, data, epochs, leadfield, varargin{:});

data = p.Results.data;
epochs = p.Results.epochs;
leadfield = p.Results.leadfield;
marker = p.Results.marker;

if isempty(marker)
    if isfield(epochs, 'marker') && ~isempty(epochs.marker)
        marker = epochs.marker;
    else
        marker = 'event';
    end
end

if isfield(epochs, 'prestim') && epochs.prestim ~= 0
    % getting value in seconds
    xmin = -epochs.prestim / 1000;
else
    xmin = 0;
end

% creating required fields and corresponding values where available
EEG = eeg_emptyset(); 
EEG.setname = 'SEREEGA dataset';
EEG.nbchan = size(data, 1);
EEG.trials = size(data, 3);
EEG.pnts = size(data, 2);
EEG.srate = epochs.srate;
EEG.xmin = xmin;
EEG.xmax = EEG.xmin + (EEG.pnts-1) / EEG.srate;
EEG.data = data;
EEG.chanlocs = leadfield.chanlocs;

EEG = eeg_checkset(EEG);

if EEG.trials > 1
    % adding markers
    EEG.event = struct('type', {}, 'latency', {}, 'duration', {}, 'epoch', {}, 'init_index', {}, 'init_time', {});
    for e = 1:EEG.trials
        EEG.event(e) = importevent( ...
                {marker, -xmin + (e-1) * EEG.pnts/EEG.srate, 1/EEG.srate, e}, ...
                [], EEG.srate, ...
                'fields', {'type', 'latency', 'duration', 'epoch'});
    end
    
    EEG = eeg_checkset(EEG, 'eventconsistency');
end

end