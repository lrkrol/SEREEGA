% lf = lf_generate_fieldtrip(varargin)
%
%       Generates a leadfield of a given resolution using FieldTrip,
%       containing the electrodes indicated.
%
%       Note: uses ft_read_sens, which is in FieldTrip's fileio directory.
%
% Optional inputs (key-value pairs):
%       resolution - the resolution of the grid in mm (default: 10)
%       labels - cell of electrode labels to be used. default uses all 346
%                available channels (including fiducials).
%       montage - name of predefined channel montage. see utl_get_montage.
%       plotelecs - whether or not to plot electrodes in FieldTrip, e.g. to
%                   check their alignment to the model (1|0, default 0)
%
% Out:  
%       lf - the leadfield containing the following fields
%            .leadfield   - the leadfield, containing projections in three
%                           directions (xyz) for each source
%            .orientation - a default orientation for each soure. since
%                           FieldTrip does not provide this, it is [1 1 1]
%                           for each source.
%            .pos         - xyz MNI coordinates of each source
%            .chanlocs    - channel information in EEGLAB format
%
% Usage example:
%       >> lf = lf_generate_fromfieldtrip('labels', {'Fz', 'Cz', 'Pz'},
%               'resolution', 5)
% 
%                    Copyright 2015-2017 Fabien Lotte & Laurens R Krol
%
%                    Team Potioc
%                    Inria Bordeaux Sud-Ouest/LaBRI, France
% 
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2017-08-10 lrk
%   - Added channel montage argument
% 2017-04-21 lrk
%   - Complete revision for inclusion in SAREEGA
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
addParameter(p, 'resolution', 10, @isnumeric)
addParameter(p, 'plotelecs', 0, @isnumeric)

parse(p, varargin{:})

labels = p.Results.labels;
montage = p.Results.montage;
resolution = p.Results.resolution;
plotelecs = p.Results.plotelecs;

% loading a standard template head model
load('standard_vol.mat');

% loading channel positions
elec = ft_read_sens('standard_1005.elc');

if ~isempty(montage)
    % taking channel labels from indicated montage
    labels = utl_get_montage(montage);
end

% obtaining indices of indicated electrodes
if ~isempty(labels)
    [~, chanidx] = ismember(labels, elec.label);
    if any(~chanidx)
        missingchans = find(~chanidx);
        warning('\nElectrode %s not available', labels{missingchans});
        chanidx(missingchans) = [];
    end
else
    chanidx = 1:length(elec.label);
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
cfg.inwardshift = -15;
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
leadfield = [];
lfidx = 1;
for i = 1:length(ftlf.leadfield)
    if ftlf.inside(i)
        leadfield(lfidx,:,:) = ftlf.leadfield{i};
        lfidx = lfidx + 1; 
    end
end
leadfield = permute(leadfield, [2 1 3]);

% preparing leadfield
lf.leadfield = leadfield;
lf.orientation = ones(size(leadfield, 2), 3);
lf.pos = ftlf.pos(ftlf.inside,:);
lf.chanlocs = readlocs('chanlocs-standard_1005.elp');
lf.chanlocs = lf.chanlocs(chanidx);

end