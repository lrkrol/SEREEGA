% lf = lf_generate_fromfieldtrip(varargin)
%
%       Generates a leadfield of a given resolution using FieldTrip,
%       containing the electrodes indicated.
%
%       Note: uses ft_read_sens, which is in FieldTrip's fileio directory.
%
% Optional inputs (key-value pairs):
%       resolution - the resolution of the grid in mm (default: 10)
%       labels - cell of electrode labels to be used. default uses all 343
%                available EEG channels.
%       montage - name of predefined channel montage. see utl_get_montage.
%       chandef - channel definition variable as per ft_read_sens. by
%                 default, the channel definitions contained in the file
%                 standard_1005.elc are used, containing 343 electrodes.
%       plotelecs - whether or not to plot electrodes in FieldTrip, e.g. to
%                   check their alignment to the model (1|0, default 0)
%
% Out:  
%       lf - the leadfield containing the following fields
%            .leadfield   - the leadfield, containing projections in three
%                           directions (xyz) for each source, in a 
%                           nchannels x nsources x 3 matrix
%            .orientation - a default orientation for each soure. since
%                           FieldTrip does not provide this, it is [0 0 0]
%                           for each source.
%            .pos         - xyz MNI coordinates of each source
%            .chanlocs    - channel information in EEGLAB format
%            .atlas       - atlas (region) indication for each source; this
%                           is simply 'Brain' until more specific 
%                           functionality is added
%
% Usage example:
%       >> lf = lf_generate_fromfieldtrip('labels', {'Fz', 'Cz', 'Pz'}, ...
%               'resolution', 5);
%       >> plot_headmodel(lf, 'labels', 0);
% 
%                    Copyright 2015-2017 Fabien Lotte & Laurens R Krol
%
%                    Team Potioc
%                    Inria Bordeaux Sud-Ouest/LaBRI, France
% 
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2021-01-06 lrk
%   - Added lf.atlas
% 2018-11-08 lrk
%   - Now continues with empty labels if montage not found
% 2018-03-26 lrk
%   - Set inwardshift to 0 and improved efficiency
% 2018-01-25 lrk
%   - Removed fiducials from automatically loaded channel labels
% 2017-09-29 lrk
%   - Added manual channel definition argument
% 2017-08-10 lrk
%   - Added channel montage argument
% 2017-04-21 lrk
%   - Complete revision for inclusion in SEREEGA
%   - Changed leadfield structure
% 2016-04-15 lrk
%   - Complete revision
% 2015-11-27 First version by Fabien Lotte

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

function lf  = lf_generate_fromfieldtrip(varargin)

% parsing input
p = inputParser;

addParameter(p, 'labels', {}, @iscell);
addParameter(p, 'montage', '', @ischar);
addParameter(p, 'chandef', [], @isstruct);
addParameter(p, 'resolution', 10, @isnumeric)
addParameter(p, 'plotelecs', 0, @isnumeric)

parse(p, varargin{:})

labels = p.Results.labels;
montage = p.Results.montage;
chandef = p.Results.chandef;
resolution = p.Results.resolution;
plotelecs = p.Results.plotelecs;

% loading a standard template head model
load('headmodel-standard_vol.mat');

% loading channel positions
if isempty(chandef)
    elec = ft_read_sens('chanlocs-standard_1005.elc');
else
    elec = chandef;
end

if ~isempty(montage)
    % taking channel labels from indicated montage
    labels = utl_get_montage(montage);
end

if isempty(labels)
    % taking all available EEG electrodes, i.e., excluding fiducials
    labels = setdiff(elec.label, {'RPA', 'LPA', 'Nz'});
end

% obtaining indices of indicated electrodes
[~, chanidx] = ismember(labels, elec.label);
if any(~chanidx)
    missingchans = find(~chanidx);
    warning('\nElectrode %s not available', labels{missingchans});
    chanidx(missingchans) = [];
end

% keeping only the indicated electrodes
elec.chanpos = elec.chanpos(chanidx,:);
elec.elecpos = elec.elecpos(chanidx,:);
elec.label = elec.label(chanidx);

if plotelecs
    figure; hold on;
    ft_plot_mesh(vol.bnd(1), 'edgecolor', 'none', 'facealpha' ,0.8, 'facecolor', [0.6 0.6 0.8]);
    ft_plot_sens(elec,'style', 'sk');
end

% preparing the source model
cfg = [];
cfg.grid.unit = 'mm';
cfg.grid.resolution = resolution;
cfg.grid.tight = 'yes';
cfg.inwardshift = 0;
cfg.headmodel = vol;
cfg.elec = elec;
template_grid = ft_prepare_sourcemodel(cfg);

% computing the leadfield (forward model)
cfg = [];
cfg.grid.pos = template_grid.pos;
cfg.grid.inside = template_grid.inside;
cfg.headmodel = vol;
cfg.elec = elec;
ftlf = ft_prepare_leadfield(cfg);

% removing sources outside of the head,
% reshaping leadfield
ftlf.leadfield = ftlf.leadfield(~cellfun(@isempty, ftlf.leadfield));
leadfield = zeros(size(ftlf.leadfield{1}, 1), size(ftlf.leadfield, 2), 3);
for i = 1:length(ftlf.leadfield)
    leadfield(:,i,:) = ftlf.leadfield{i};
end

% preparing output
lf = struct();
lf.leadfield = leadfield;
lf.orientation = zeros(size(leadfield, 2), 3);
lf.pos = ftlf.pos(ftlf.inside,:);
lf.chanlocs = readlocs('chanlocs-standard_1005.elp');
lf.chanlocs = lf.chanlocs(chanidx);
lf.atlas = repmat({'Brain'}, size(lf.pos, 1), 1);

end