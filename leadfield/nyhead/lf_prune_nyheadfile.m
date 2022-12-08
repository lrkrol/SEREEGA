% lf_prune_nyheadfile()
%
%       Generates a smaller leadfield file from the original New York Head
%       (ICBM-NY) file, containing only the information used by SEREEGA.
%       This speeds up loading times. The new file will be called 
%       'sa_nyhead_sereegareduced.mat', written to the same directory where
%       'sa_nyhead.mat' is located. lf_generate_fromnyhead will try
%       to find the reduced file first.
%       
%       Assumes you have the NY Head leadfield in MATLAB format in the
%       path. As of 2021-01-05, this is available at 
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
% In (optional):
%       directory - the directory of sa_nyhead.mat. by default, this script
%                   takes the first instance it finds.
%
% Usage example:
%       >> lf_prune_nyheadfile('C:\SEREEGA\leadfield\nyhead');
% 
%                    Copyright 2021, 2022 Laurens R Krol
%                    Neuroadaptive Human-Computer Interaction
%                    Brandenburg University of Technology

% 2022-11-24 lrk
%   - Added atlas compatibility
% 2021-01-05 First version

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

function lf_prune_nyheadfile(directory)

if nargin == 0
    filepath = which('sa_nyhead.mat');
else
    filepath = which(fullfile(directory, 'sa_nyhead.mat'));
end

if isempty(filepath)
    error('SEREEGA:lf_prune_nyheadfile:fileNotFound', 'Could not find ICBM-NY leadfield file (sa_nyhead.mat) in the path.\nMake sure you have obtained the file, and that MATLAB can find it.\nIt should be available at https://parralab.org/nyhead')
else        
    orig = load('sa_nyhead.mat', 'sa');
    
    sa = struct();
    sa.clab_electrodes = orig.sa.clab_electrodes;
    sa.cortex75K.V_fem = orig.sa.cortex75K.V_fem;
    sa.cortex75K.normals = orig.sa.cortex75K.normals;
    sa.cortex75K.vc = orig.sa.cortex75K.vc;
    
    if isfield(orig.sa, 'HO_labels') && isfield(orig.sa.cortex75K, 'in_HO')
        sa.HO_labels = orig.sa.HO_labels;
        sa.cortex75K.in_HO = orig.sa.cortex75K.in_HO;
    end

    newfilepath = fullfile(fileparts(filepath), 'sa_nyhead_sereegareduced.mat');
    save(newfilepath, 'sa');
    fprintf('Created %s\n', newfilepath);
end

end