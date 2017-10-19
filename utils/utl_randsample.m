% Y = utl_randsample(n, k, replace, w)
%
%       Wrapper for MATLAB's randsample function, adjusted to always
%       interpret n as a population, and to always return a row vector.
%
%       See MATLAB's randsample function for additional help.
% 
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2017-07-13 lrk
%   - Changed behaviour such that n is always interpreted as a population
% 2017-07-05 First version

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

function y = utl_randsample(n, k, replace, w)

if numel(n) == 1, n = [n n]; end
if nargin < 3, replace = 1; end
if nargin < 4; w = []; end

y = randsample(n, k, replace, w);

if ~isrow(y), y = y'; end

end