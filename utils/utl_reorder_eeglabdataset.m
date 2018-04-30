% EEG = utl_reorder_eeglabdataset(EEG, varargin)
%
%       Reorders the epochs in an EEGLAB dataset, either randomly or by
%       interleaving. For example, a dataset in which three separate
%       simulations are merged, the ordering of epochs may be 111222333.
%       Random reordering would randomise the order of these epochs (e.g., 
%       231322311). Interleaving would result in a reordering pattern of
%       123123123, and would leave the internal order of each simulation
%       intact (e.g. slope effects).
%
% In:
%       EEG - epoched EEGLAB dataset structure with no other events than
%             the time-locking events
%
% Optional (key-value pairs):
%       mode - 'random' to fully randomise all epochs (e.g., 231322311),
%              'interleave' to interleave all epochs while keeping the 
%              existing order within epochs of different events
%              (123123123). Interleaving only works with an equal number of
%              epochs per event type. (default: 'random')
%
% Out:  
%       EEG - reordered EEGLAB dataset structure
%
% Usage example:
%       >> leadfield = lf_generate_fromnyhead('montage', 'S64');
%       >> EEG1 = utl_create_eeglabdataset(rand(64, 512, 100), epochs, ...
%                 leadfield, 'marker', 'event1');
%       >> EEG2 = utl_create_eeglabdataset(rand(64, 512, 100), epochs, ...
%                 leadfield, 'marker', 'event2');
%       >> EEG = utl_reorder_eeglabdataset(pop_mergeset(EEG1, EEG2));
% 
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2017-08-02 First version

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

function EEG = utl_reorder_eeglabdataset(EEG, varargin)

% parsing input
p = inputParser;

addRequired(p, 'EEG', @isstruct);

addParameter(p, 'mode', 'random', @ischar);

parse(p, EEG, varargin{:})

EEG = p.Results.EEG;
mode = p.Results.mode;

types = {EEG.event.type};

if strcmp(mode, 'random')
    % setting random order
    order = randperm(EEG.trials);
elseif strcmp(mode, 'interleave')
    % interleaving epochs of different event types
    eventtypes = unique({EEG.event.type});
    for i = 1:length(eventtypes)
        order(i,:) = find(strcmp(eventtypes{i}, {EEG.event.type}));
    end
    order = order(:)';
end

% reordering epoch data and event type labels
EEG.data = EEG.data(:,:,order);
[EEG.event.type] = types{order};

EEG.setname = 'SEREEGA reordered dataset';

end