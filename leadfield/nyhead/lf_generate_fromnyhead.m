% lf = lf_generate_fromnyhead(varargin)
%
%       Generates a leadfield based on the New York Head (ICBM-NY),
%       containing the electrodes indicated.
%       
%       Assumes you have the NY Head leadfield in MATLAB format in the
%       path. As of 2017-04-21, this is available at 
%       http://www.parralab.org/nyhead/sa_nyhead.mat
%       
%       NY Head publication:
%           Huang, Y., Parra, L. C., & Haufe, S. (2016). The New York Head:
%           precise standardized volume conductor model for EEG source
%           localization and tES targeting. NeuroImage, 140, 150-162.
%
%       The New York Head (ICBM-NY) is copyright (C) 2015 Yu Huang (Andy),
%       Lucas C. Parra and Stefan Haufe and licensed under GNU GPL 3.
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
%       >> lf = lf_generate_fromnyhead('labels', {'Fz', 'Cz', 'Pz'});
%       >> plot_headmodel(lf, 'labels', 1, 'style', 'boundary');
% 
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2022-11-24 lrk
%   - Added atlas support from the updated sa_nyhead.mat
% 2021-01-06 lrk
%   - Added support for output of lf_prune_nyheadfile
%   - Added lf.atlas
% 2018-11-08 lrk
%   - Now continues with empty labels if montage not found
% 2017-08-10 lrk
%   - Added channel montage argument
% 2017-06-21 lrk
%   - Excluded fiducials from default channel set
% 2017-04-21 First version

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

function lf = lf_generate_fromnyhead(varargin)

% parsing input
p = inputParser;

addParameter(p, 'labels', {}, @iscell);
addParameter(p, 'montage', '', @ischar);

parse(p, varargin{:})

labels = p.Results.labels;
montage = p.Results.montage;

% loading the NY Head leadfield
if exist('sa_nyhead_sereegareduced.mat')
    % loading reduced-size version if available, see lf_prune_nyheadfile
    load('sa_nyhead_sereegareduced.mat', 'sa');
elseif exist('sa_nyhead.mat') ~= 2
    error('SEREEGA:lf_generate_fromnyhead:fileNotFound', 'Could not find ICBM-NY leadfield file (sa_nyhead.mat) in the path.\nMake sure you have obtained the file, and that MATLAB can find it.\nIt should be available at https://parralab.org/nyhead')
else
    load('sa_nyhead.mat', 'sa');
end

if ~isempty(montage)
    % taking channel labels from indicated montage
    labels = utl_get_montage(montage);
end

if isempty(labels)
    % taking all available EEG electrodes, i.e., excluding fiducials
    labels = setdiff(sa.clab_electrodes, {'RPA', 'LPA', 'Nz'});
end

% obtaining indices of indicated electrodes
[~, chanidx] = ismember(labels, sa.clab_electrodes);
if any(~chanidx)
    missingchans = find(~chanidx);
    warning('\nElectrode %s not available', labels{missingchans});
    chanidx(missingchans) = [];
end

% preparing output
lf = struct();
lf.leadfield = sa.cortex75K.V_fem(chanidx,:,:);
lf.orientation = sa.cortex75K.normals;
lf.pos = sa.cortex75K.vc;
lf.chanlocs = readlocs('chanlocs-nyhead231.elp');
lf.chanlocs = lf.chanlocs(chanidx);
if isfield(sa, 'HO_labels') && isfield(sa.cortex75K, 'in_HO')
    lf.atlas = strcat('Brain', {' '}, sa.HO_labels(sa.cortex75K.in_HO));
    lf.atlas = utl_sanitize_atlas(lf.atlas);
else
    warning('No atlas found; defaulting to Brain_CorticalSurface.\nThere is a newer version of the NY Head that includes an atlas.\nIt should be available at https://parralab.org/nyhead', '');
    lf.atlas = repmat({'Brain_CorticalSurface'}, size(lf.pos, 1), 1);
end

end