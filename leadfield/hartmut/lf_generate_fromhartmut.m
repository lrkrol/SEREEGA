% lf = lf_generate_fromhartmut(model[, varargin])
%
%       Generates a leadfield based on one of the HArtMuT head models,
%       which includes muscular and ocular sources as well as cortical
%       sources.
%       
%       Assumes you have the required HArtMuT leadfield files in MATLAB
%       format in the path. As of 2022-11-16, these are available at
%       https://github.com/harmening/HArtMuT
%
%       HArtMuT publication:
%           Harmening, N., Klug, M., Gramann, K., & Miklody, D. (2022).
%           HArtMuT - Modeling eye and muscle contributors in neuroelectric
%           imaging. Journal of Neural Engineering. In press. doi:
%           10.1088/1741-2552/aca8ce
%
%       HArtMuT is copyright 2022 Nils Harmening and licensed under GNU GPL
%       3.
%
% In:
%       model - string indicating which HArtMuT model to use. currently
%               supported are: 'mix_Colin27_small', 'NYhead_small'
%
% Optional inputs (key-value pairs):
%       labels - cell of electrode labels to be used. default uses all 231
%                available channels (including fiducials).
%       montage - name of predefined channel montage. see utl_get_montage.
%
% Out:  
%       lf - the leadfield containing the following fields
%            .leadfield   - the leadfield, containing projections in three
%                           directions (xyz) for each source, in a 
%                           nchannels x nsources x 3 matrix
%            .orientation - a default orientation for each soure. for the
%                           New York Head, this gives dipole orientations
%                           perpendicular to the cortical surface
%            .pos         - xyz MNI coordinates of each source
%            .chanlocs    - channel information in EEGLAB format
%            .atlas       - nsources x 1 cell with atlas (region) 
%                           indication for each source
%
% Usage example:
%       >> lf = lf_generate_fromhartmut('NYhead_small');
%       >> plot_headmodel(lf);
% 
%                    Copyright 2022 Laurens R. Krol
%                    Neuroadaptive Human-Computer Interaction
%                    Brandenburg University of Technology

% 2022-11-16 First version

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

function lf = lf_generate_fromhartmut(model, varargin)

% parsing input
p = inputParser;

addRequired(p, 'model', @ischar);

addParameter(p, 'labels', {}, @iscell);
addParameter(p, 'montage', '', @ischar);

parse(p, model, varargin{:})

model = p.Results.model;
labels = p.Results.labels;
montage = p.Results.montage;

% setting files to load
if strcmpi(model, 'NYhead_small')
    hartmutfile = 'HArtMuT_NYhead_small.mat';
elseif strcmpi(model, 'mix_Colin27_small')
    hartmutfile = 'HArtMuT_mix_Colin27_small.mat';
else
    error('SEREEGA:lf_generate_fromhartmut:invalidFunctionArguments', 'Unknown HArtMuT model ''%s''', model);
end

% loading leadfields
if exist(hartmutfile, 'file') ~= 2
    error('SEREEGA:lf_generate_fromhartmut:fileNotFound', ['Could not find HArtMuT leadfield file: ' hartmutfile '\nMake sure you have obtained the file, and that MATLAB can find it.\nIt should be available at https://github.com/harmening/HArtMuT']);
else
    load(hartmutfile, 'HArtMuT');
end

if ~isempty(montage)
    % taking channel labels from indicated montage
    labels = utl_get_montage(montage);
end

if isempty(labels)
    % taking all available EEG electrodes
    labels = HArtMuT.electrodes.label;
    
    if strcmp(model, 'mix_Colin27_small')
        % removing channels with duplicate coordinates
        labels = setdiff(labels, {'T3', 'T4', 'T5', 'T6'});
    end
end

% obtaining indices of indicated electrodes
[~, chanidx] = ismember(labels, HArtMuT.electrodes.label);
if any(~chanidx)
    missingchans = find(~chanidx);
    warning('\nElectrode %s not available', labels{missingchans});
    chanidx(missingchans) = [];
end

% preparing output
lf = struct();
lf.leadfield = cat(2, HArtMuT.cortexmodel.leadfield(chanidx,:,:), HArtMuT.artefactmodel.leadfield(chanidx,:,:));
lf.orientation = cat(1, HArtMuT.cortexmodel.orientation, HArtMuT.artefactmodel.orientation);
lf.pos = cat(1, HArtMuT.cortexmodel.pos, HArtMuT.artefactmodel.pos);
lf.chanlocs = struct( ...
        'type', HArtMuT.electrodes.chantype', ...
        'labels', HArtMuT.electrodes.label', ...
        'X', num2cell( HArtMuT.electrodes.chanpos(:,2)'), ...
        'Y', num2cell(-HArtMuT.electrodes.chanpos(:,1)'), ...
        'Z', num2cell( HArtMuT.electrodes.chanpos(:,3)'));
lf.chanlocs = lf.chanlocs(chanidx);
lf.atlas = cat(1, strcat('Brain_', HArtMuT.cortexmodel.labels), HArtMuT.artefactmodel.labels);
lf.atlas = utl_sanitize_atlas(lf.atlas);

% converting chanlocs to EEGLAB format
lf.nbchan = numel(lf.chanlocs);
lf = pop_chanedit(lf, 'convert', {'cart2all'});
lf = rmfield(lf, {'nbchan', 'chaninfo'});

fprintf('Loaded HArtMuT %s leadfield.\n', model);

end