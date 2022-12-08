% lf = lf_generate_frompha(atlas, layout, varargin)
%
%       Generates a lead field based on a Pediatric Head Atlas (v2),
%       containing the electrodes indicated.
%       
%       This script assumes you have the requested Pediatric Head Atlas
%       directories in your MATLAB path. In particular, it needs the
%       respective LeadFieldMatrix_*, Sensors_*.txt, and Triples_Dipoles_*
%       files. As of 2018-02-05, the Pediatric Head Atlases are available 
%       upon request at https://pedeheadmod.net
%
%       Note that the coordinates given by the original Pediatric Head 
%       Atlases do not correspond to a standard coordinate space. This
%       script calls lf_fix_electrodes_pha to largely correct for this by 
%       rotating and shifting both the electrode and the source coordinates
%       to approximately fit the MNI standard. Since the Atlases are based
%       on real recordings, the corrected models may still not be 
%       entirely symmetrical. You can use the plot_headmodel function to 
%       verify this for yourself. It is particularly visible in the '2562' 
%       layouts, where the electrodes cover the entire head shape. Because
%       of this, and because the pediatric models are of course smaller 
%       than the adult MNI standard, the plot_chanlocs_dipplot and
%       plot_source_location_dipplot functions are not recommended for
%       these models.
%       
%       Pediatric Head Atlas publication:
%           Song, J., Morgan, K., Turovets, S., Li, K., Davey, C.,
%           Govyadinov, P., Tucker, D. M. (2013). Anatomically accurate
%           head models and their derivatives for dense array EEG source
%           localization. Functional Neurology, Rehabilitation, and
%           Ergonomics, 3(2-3), 275-293.
%
%       Parts of this script are based on the files provided in the
%       Pediatric Head Atlas packages, authored by Pavel Govyadinov 
%       (Electrical Geodesics Inc.) and David Hammond (NeuroInformatics
%       Center, University of Oregon).
%
% In:
%       atlas - string indicating the atlas to use: '0to2', '4to8', or
%               '8to18'.
%       layout - string indicating which layout (i.e. number of channels)
%                to use: '128', '256', or '2562'. note: '256' is not 
%                available for atlas '0to2'. 
%
% Optional inputs (key-value pairs):
%       labels - cell of electrode labels to be used. default uses all
%                available channels (including fiducials).
%       montage - name of predefined channel montage. see utl_get_montage.
%
% Out:  
%       lf - the leadfield containing the following fields
%            .leadfield   - the leadfield, containing projections in three
%                           directions (xyz) for each source, in a
%                           nchannels x nsources x 3 matrix
%            .orientation - a default orientation for each soure. these are
%                           not available in the PHA and thus default to 0.
%            .pos         - xyz coordinates of each source (not scaled to
%                           MNI but may be approximate, depending on atlas)
%            .chanlocs    - channel information in EEGLAB format
%            .atlas       - atlas (region) indication for each source; this
%                           is simply 'Brain' until more specific 
%                           information is added
%
% Usage example:
%       >> lf = lf_generate_frompha('8to18', '2562');
%       >> plot_headmodel(lf, 'labels', 0);
% 
%                    Copyright 2018 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2021-01-11 lrk
%   - Added lf.atlas
%   - Added warning about coordinate system changes
% 2018-11-08 lrk
%   - Now continues with empty labels if montage not found
% 2018-03-22 jpaw
%   - Fixed electrode and source coordinates
% 2018-02-05 First version

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

function lf = lf_generate_frompha(varargin)

% parsing input
p = inputParser;

addRequired(p, 'atlas', @ischar);
addRequired(p, 'layout', @ischar);

addParameter(p, 'labels', {}, @iscell);
addParameter(p, 'montage', '', @ischar);

parse(p, varargin{:})

atlas = p.Results.atlas;
layout = p.Results.layout;
labels = p.Results.labels;
montage = p.Results.montage;

% setting file names
if strcmp(layout, '2562')
    % (file names are inconsistent for the 2562 layout)
    leadfieldlayout = 'LargeSensorArray';
    sensorlayout = 'generic';
else
    leadfieldlayout = layout;
    sensorlayout = layout;
end
numchan = str2num(layout);

sensorfile = sprintf('Sensors_%s_%s.txt', atlas, sensorlayout);
dipolesfile = sprintf('Triples_Dipoles_%s', atlas);

if strcmp(atlas, '4to8')
    % (file names are inconsistent for the '4to8' atlas)
    atlasf = '2to8';
else
    atlasf = atlas;
end

leadfieldfile = sprintf('LeadFieldMatrix_%s_%s', atlasf, leadfieldlayout);

if any([exist(sensorfile), exist(dipolesfile), exist(leadfieldfile)] ~= 2)
    error('SEREEGA:lf_generate_frompha:fileNotFound', 'Could not find the indicated Pediatric Head Atlas file(s) in the path.\nMake sure you have spelled the atlas and layout correctly, that you have obtained the files, and that MATLAB can find them.\nThey should be available at https://pedeheadmod.net')
end

% loading transformed electrode positions, removing fiducials and Cz
[chanlocs, hm, A1, A2, shift] = lf_fix_electrodes_pha(atlas, layout);
[~, chanidx] = ismember({'FidNz', 'FidT9', 'FidT10', 'Cz'}, {chanlocs.labels});
chanidx = chanidx(~~chanidx);
chanlocs(chanidx) = [];

if ~isempty(montage)
    % taking channel labels from indicated montage
    labels = utl_get_montage(montage);
end

if isempty(labels)
    % taking all available EEG electrodes
    labels = {chanlocs.labels};
end

% obtaining indices of indicated electrodes
[~, chanidx] = ismember(labels, {chanlocs.labels});
if any(~chanidx)
    missingchans = find(~chanidx);
    warning('\nElectrode %s not available', labels{missingchans});
    chanidx(missingchans) = [];
end
chanlocs = chanlocs(chanidx);

% getting lead field
fid = fopen(leadfieldfile, 'r');
leadfield = fread(fid, 'double', 'b');
fclose(fid);
leadfield = reshape(leadfield, 3, [], numchan);
leadfield = permute(leadfield, [3, 2, 1]);
leadfield = leadfield(chanidx,:,:);

% getting dipoles
fid = fopen(dipolesfile, 'r');
dipoles = fread(fid, 3*size(leadfield,2)+1, 'int32', 0, 'l');
dipoles = dipoles(2:end);
fclose(fid);

% dipole locations must be rotated and shifted the same way as the
% electrodes. since readlocs reads the electrodes with X=Y and Y=-X, we
% first read the dipoles in the same orientation.
pos = [dipoles(2:3:end), -dipoles(1:3:end), dipoles(3:3:end)];
for i=1:length(pos)
    % rotating and shifting dipole to align with fixed electrodes
    pos(i,:) = (A2*A1*transpose(pos(i,:)-hm))-transpose(shift);
    
    % fixing the readlocs-x/y-interchange
    pos(i,:) = [-pos(i,2), pos(i,1), pos(i,3)];
end

warning(sprintf('PHA does not use a standardised coordinate system. SEREEGA has\nshifted and rotated all coordinates into a more convenient, but still nonstandard system'));

% preparing output
lf = struct();
lf.leadfield = leadfield;
lf.orientation = zeros(size(leadfield, 2), 3);
lf.pos = pos;
lf.chanlocs = chanlocs;
lf.atlas = repmat({'Brain'}, size(lf.pos, 1), 1);

end
