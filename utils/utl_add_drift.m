% data = utl_add_drift(data, drift)
%
%       Adds a continuously increasing or decreasing value to the given
%       data in order to simulate drift. Drift is indicated either per
%       epoch or for the entire data set.
%
% In:
%       data - channels-by-samples-by-epochs matrix of data
%       mode - ('perepoch'|'total') whether or not the drift value should
%              be applied per epoch or for the entire dataset
%       drift - the drift to apply to the data
%
% Out:  
%       data - the data with drift added
%
% Usage example:
%       >> drifted = utl_add_drift(randn(32,100), 'total', -5);
%       >> figure; plot(drifted');
% 
%                    Copyright 2018 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2018-04-09 First version

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

function data = utl_add_drift(data, mode, drift)

driftsignal = 1:(size(data, 3)*size(data, 2));
if strcmp(mode, 'perepoch')
    driftsignal = utl_normalise(driftsignal, drift * size(data, 3));
elseif strcmp(mode, 'total')
    driftsignal = utl_normalise(driftsignal, drift);
end
driftsignal = repmat(driftsignal, size(data, 1), 1);
driftsignal = reshape(driftsignal, size(data));

data = data + driftsignal;

end
