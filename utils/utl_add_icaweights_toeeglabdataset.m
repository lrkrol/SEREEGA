% EEG = utl_add_icaweights_toeeglabdataset(EEG, components, leadfield)
%
%       Adds an ICA decomposition to an EEGLAB dataset, based on the given
%       components and leadfield.
%
% In:
%       EEG - EEGLAB dataset structure with n channels
%       components - 1-by-n struct of SEREEGA components. see
%                    utl_check_component for details.
%       leadfield - the leadfield from which the components' sources are
%                   taken
%
% Out:  
%       EEG - EEGLAB dataset structure with added ICA decomposition
% 
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2017-08-25 First version

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

function EEG = utl_add_icaweights_toeeglabdataset(EEG, components, leadfield)

% adding ICA weights to dataset
[w, winv] = utl_get_icaweights(components, leadfield);
EEG.icasphere = eye(EEG.nbchan);
EEG.icaweights = w;
EEG.icawinv = winv;

end
