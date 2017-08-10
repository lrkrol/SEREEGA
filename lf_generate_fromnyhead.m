% lf = lf_generate_nyhead(varargin)
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
%           localization and tES targeting. NeuroImage, 140, 150–162.
%
%       The New York Head (ICBM-NY) is copyright (C) 2015 Yu Huang (Andy),
%       Lucas C. Parra and Stefan Haufe and licensed under GNU GPL 3.
%
% Optional inputs (key-value pairs):
%       labels - cell of electrode labels to be used. default uses all 231
%                available channels (including fiducials).
%
% Out:  
%       lf - the leadfield containing the following fields
%            .leadfield   - the leadfield, containing projections in three
%                           directions (xyz) for each source
%            .orientation - a default orientation for each soure. for the
%                           New York Head, this gives dipole orientations
%                           perpendicular to the cortical surface
%            .pos         - xyz MNI coordinates of each source
%            .chanlocs    - channel information in EEGLAB format
%
% Usage example:
%       >> lf = lf_generate_fromnyhead('labels', {'Fz', 'Cz', 'Pz'})
% 
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

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

parse(p, varargin{:})

labels = p.Results.labels;

% loading the NY Head leadfield
load('sa_nyhead.mat', 'sa');
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

% preparing leadfield
lf.leadfield = sa.cortex75K.V_fem(chanidx,:,:);
lf.orientation = sa.cortex75K.normals;
lf.pos = sa.cortex75K.vc;
lf.chanlocs = readlocs('chanlocs-nyhead231.elp');
lf.chanlocs = lf.chanlocs(chanidx);
    
end