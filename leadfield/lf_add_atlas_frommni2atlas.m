% leadfield = lf_add_atlas_frommni2atlas(leadfield, atlasselector, varargin)
%
%       Returns the given lead field with regions assigned to each source
%       according to a selected atlas, using mni2atlas from FSL. 
%
%       WARNING: Region labels will be approximate and possibly entirely
%                inaccurate depending on the lead field and atlas used.
%                Make sure to what extent your lead field matches the
%                atlases used.
%
%       Requires the mni2atlas function from the FMRIB Software Library.
%       As of 2021-01-08, this can be downloaded from 
%       https://github.com/dmascali/mni2atlas
%
%       Note that mni2atlas is covered by a different license which, i.a.,
%       does not allow commercial use.
%
%       mni2atlas in turn requires some functions from NIfTI/ANALYZE,
%       which, as of 2021-01-08, can be downloaded from
%       https://mathworks.com/matlabcentral/fileexchange/8797
%       In particular, the required files are load_nii.m, load_nii_hdr.m,
%       load_nii_img.m, and xform_nii.m. 
%
% In:
%       leadfield - the leadfield to which region labels should be added
%       atlasselector - the atlas to be used by mni2atlas. the options are:
%                       1 - Juelich Histological Atlas
%                       2 - Harvard-Oxford Cortical Structural Atlas
%                       3 - Harvard-Oxford Subcortical Structural Atlas
%                       4 - JHU ICBM-DTI-81 White Matter labels
%                       5 - JHU White Matter tractography Atlas
%                       6 - Oxford Thalamic Connectivity Atlas
%                       7 - Cerebellar Atlas in MNI152 after FLIRT
%                       8 - Cerebellar Atlas in MNI152 after FNIRT
%                       9 - MNI Structural Atlas
%
% Optional (key-value pairs):
%       region - cell of strings indicating the current region
%                       labels to be mapped and overwritten
%       unknownlabel - string label for sources that cannot be found in
%                       the atlas, default 'Brain Unknown'. should start
%                       with one of the generic region labels indicated in
%                       lf_get_regions.
%
% Out:
%       leadfield - the leadfield with region labels added to its atlas
%
% Usage example:
%       >> lf = lf_generate_fromnyhead();
%       >> lf = lf_add_atlas_frommni2atlas(lf, 9); % not fully accurate
% 
%                    Copyright 2021, 2022 Laurens R. Krol
%                    Neuroadaptive Human-Computer Interaction
%                    Brandenburg University of Technology

% 2022-12-09 lrk
%   - Switched to nanmean of confidence also in finalconsole output
% 2022-11-25 lrk
%   - Preallocated variables for efficiency
% 2022-11-17 lrk
%   - Switched to inpurParser to parse arguments
%   - Added optional region argument
% 2021-01-08 First version

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

function leadfield = lf_add_atlas_frommni2atlas(leadfield, atlasselector, varargin)

% parsing input
p = inputParser;

addRequired(p, 'leadfield', @isstruct);
addRequired(p, 'atlasselector', @isnumeric);

addParameter(p, 'region', {'.*'}, @iscell);
addParameter(p, 'unknownlabel', 'Brain Unknown', @ischar);

parse(p, leadfield, atlasselector, varargin{:});

leadfield = p.Results.leadfield;
atlasselector = p.Results.atlasselector;
currentregion = p.Results.region;
unknownlabel = p.Results.unknownlabel;

if ~exist('mni2atlas', 'file')
    error('SEREEGA:lf_add_atlas_frommni2atlas:fileNotFound', 'Could not find the mni2atlas function file (mni2atlas.m) in the path.\nMake sure you have obtained the mni2atlas software, and that MATLAB can find it.\nIt should be available at https://github.com/dmascali/mni2atlas')
end

currentregionidx = lf_get_source_all(leadfield, 'region', currentregion);

atlasnames = { ...
    'Juelich Histological Atlas' ...
    'Harvard-Oxford Cortical Structural Atlas' ...
    'Harvard-Oxford Subcortical Structural Atlas' ...
    'JHU ICBM-DTI-81 White Matter labels' ...
    'JHU White Matter tractography Atlas' ...
    'Oxford Thalamic Connectivity Atlas' ...
    'Cerebellar Atlas in MNI152 after FLIRT' ...
    'Cerebellar Atlas in MNI152 after FNIRT' ...
    'MNI Structural Atlas' ...
    };

numsources = numel(currentregionidx);
atlas = cell(numsources, 1);
unknowns = 0;
confidence = nan(numsources, 1);

w = waitbar(0, {sprintf('Atlas: %s', atlasnames{atlasselector}), sprintf('Source 0 of %d', numsources), 'Average confidence: 0.0%%', 'Unkowns: 0 (0.0%%)'}, 'Name', 'Looking up sources');

for s = 1:numsources
    
    idx = currentregionidx(s);
    
    if mod(s, 250) == 0 || s == numsources
        % updating waitbar
        waitbar(s/numsources, w, {sprintf('Atlas: %s', atlasnames{atlasselector}), sprintf('Source %d of %d', s, numsources), sprintf('Average confidence: %.1f%%', nanmean(confidence)), sprintf('%d unkowns (%3.1f%%)', unknowns, unknowns/s*100)});
    end
        
    % getting source region
    sr = mni2atlas(leadfield.pos(idx,:), atlasselector);
    
    if isempty(sr.label)
        % no result; using default
        atlas(s) = {unknownlabel};
        unknowns = unknowns + 1;
    else
        % parsing string; updating confidence and atlas
        sr = strsplit(sr.label{1}, '% ');
        confidence(s) = str2double(sr{1});
        atlas(s) = {['Brain ' sr{2}]};
    end
    
end

atlas = utl_sanitize_atlas(atlas);
leadfield.atlas(currentregionidx) = atlas;
delete(w);

fprintf('Done.\nAtlas: %s\nAverage confidence: %.1f%%\n%d unkowns (%3.1f%%)\n', atlasnames{atlasselector}, nanmean(confidence), unknowns, unknowns/numsources*100);

end