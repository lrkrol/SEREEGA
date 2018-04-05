% data = utl_add_sensornoise(data, mode, value)
%
%       Adds spatially and temporally uncorrelated uniform white noise of
%       the indicated amplitude to the data. This simulates sensor noise.
%       Note that indicating a specific signal-to-noise ratio will affect
%       the overall amplitude of the data.
%
% In:
%       data - matrix of data
%       mode - ('amplitude'|'snr') whether or not the noise will be added
%              at the given maximum absolute amplitude, or at a given
%              signal-to-noise ratio
%       value - either the maximum absolute amplitude of the noise or the
%               signal-to-noise ratio of the resulting data
%
% Out:  
%       data - the data with sensor noise added
%
% Usage example:
%       >> utl_add_sensornoise(ones(5,5), 'snr', .5)
% 
%                    Copyright 2018 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2018-04-05 First version

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

function data = utl_add_sensornoise(data, mode, value)

if strcmp(mode, 'amplitude')
    % adding random noise to data
    data = data + utl_normalise(rand(size(data))*2-1, value);
elseif strcmp(mode, 'snr')
    % first normalising noise to similar amplitude as data so as not to
    % affect the overall amplitude of the final signal too much --- some
    % effect will however remain even at snr=1
    noise = utl_normalise(rand(size(data))*2-1, max(abs(data(:))));
    data = utl_mix_data(data, noise, value);
else
    error('SEREEGA:utl_add_sensornoise:invalidFunctionArguments', '''mode'' must be either ''amplitude'' or ''snr''');
end

end
