% labels = utl_get_montage(montage)
%
%       Returns a cell of predefined channel labels contained in the 
%       indicated electrode montage.
%
% In:
%       montage - name of the montage
%
% Out:
%       labels - cell of channel labels contained in the indicated montage
%
% Usage example:
%       >> labels = utl_get_montage('S64');
%       >> lf = lf_generate_fromnyhead('labels', labels);
% 
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2017-08-10 First version

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

function labels = utl_get_montage(montage)

switch montage
    case 'S64'
        % SEREEGA-64: a selection of 64 EEG channels
        labels = {'Fp1', 'Fp2', 'AF7', 'AF3', 'AFz', 'AF4', 'AF8', ...
                  'F7', 'F5', 'F3', 'F1', 'Fz', 'F2', 'F4', 'F6', 'F8', ...
                  'FT7', 'FC5', 'FC3', 'FC1', 'FCz', 'FC2', 'FC4', ...
                  'FC6', 'FT8', 'T7', 'C5', 'C3', 'C1', 'Cz', 'C2', ...
                  'C4', 'C6', 'T8', 'P9', 'TP7', 'CP5', 'CP3', 'CP1', ...
                  'CPz', 'CP2', 'CP4', 'CP6', 'TP8', 'P10', 'P7', 'P5', ...
                  'P3', 'P1', 'Pz', 'P2', 'P4', 'P6', 'P8', 'PO9', ...
                  'PO7', 'PO3', 'POz', 'PO4', 'PO8', 'PO10', ...
                  'O1', 'Oz', 'O2'};
    otherwise
        warning('montage ''%s'' not found', montage);
        labels = '';
end

end