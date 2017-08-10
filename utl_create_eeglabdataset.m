% EEG = utl_create_eeglabdataset(data, srate, varargin)
%
% In:
%       data - channels x samples x epochs matrix of data points
%       srate - the sampling rate of the data
%
% Optional (key-value pairs):
%       chanlocs - an EEGLAB chanlocs structure
%       chanlabels - a cell array of channel labels (ignored when chanlocs
%                    is indicated)
%       xmin - epoch start latency in seconds (for epoched data, relative
%              to the time-locking event at time 0, i.e., should be <= 0)
%              (default 0)
%       marker - string to put at 0 time point for epoched data (default
%                'event')
%
% Out:  
%       EEG - dataset in EEGLAB format
%
% Usage example:
%       >> lf = lf_generate_fromnyhead();
%       >> EEG = utl_create_eeglabdataset(rand(231, 512, 100), 512, ...
%          'chanlocs', lf.chanlocs, 'xmin', -0.2)
% 
%                    Copyright 2015-2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2017-06-14 lrk
%   - Now accepts both chanlocs structure and cell of channel labels
%   - Added markers
%   - Switched to inputParser to parse arguments
%   - Modifications for inclusion in SAREEGA
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

function EEG = utl_create_eeglabdataset(data, srate, varargin)

% parsing input
p = inputParser;

addRequired(p, 'data', @isnumeric);
addRequired(p, 'srate', @isnumeric);

addParameter(p, 'chanlocs', [], @isstruct);
addParameter(p, 'chanlabels', [], @iscell);
addParameter(p, 'xmin', 0, @isnumeric);
addParameter(p, 'marker', 'event', @ischar);

parse(p, data, srate, varargin{:})

data = p.Results.data;
srate = p.Results.srate;
chanlocs = p.Results.chanlocs;
chanlabels = p.Results.chanlabels;
xmin = p.Results.xmin;
marker = p.Results.marker;

% creating required fields and corresponding values where available
EEG = struct(); 
EEG.setname = '';
EEG.filename = '';
EEG.filepath = '';
EEG.nbchan = size(data, 1);
EEG.trials = size(data, 3);
EEG.pnts = size(data, 2);
EEG.srate = srate;
EEG.xmin = xmin;
EEG.xmax = EEG.xmin + (EEG.pnts-1) / EEG.srate;
EEG.data = data;
EEG.icaact = [];
EEG.icawinv = [];
EEG.icaweights = [];
EEG.icasphere = [];

% adding channel info
if ~isempty(chanlocs)
    EEG.chanlocs = chanlocs;
else
    EEG.chanlocs = struct();
    for c = 1:EEG.nbchan
        if ~isempty(chanlabels)
            EEG.chanlocs(c).labels = chanlabels{c};
        else
            EEG.chanlocs(c).labels = num2str(c);
        end
        EEG.chanlocs(c).type = 'EEG';
        EEG.chanlocs(c).X = [];
        EEG.chanlocs(c).Y = [];
        EEG.chanlocs(c).Z = [];
        EEG.chanlocs(c).sph_theta = [];
        EEG.chanlocs(c).sph_phi = [];
        EEG.chanlocs(c).sph_radius = [];
        EEG.chanlocs(c).theta = [];
        EEG.chanlocs(c).radius = [];
        EEG.chanlocs(c).urchan = c;
        EEG.chanlocs(c).ref = '';
    end
end

EEG = eeg_checkset(EEG);
% keyboard
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