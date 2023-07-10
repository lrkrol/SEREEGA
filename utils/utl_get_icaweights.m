% [w, winv] = utl_get_icaweights(components, leadfield)
%
%       Returns an ICA weight matrix as well as its inverse, based on the
%       given components and a leadfield. 
%
% In:
%       components - 1-by-n struct of SEREEGA components. see
%                    utl_check_component for details.
%       leadfield - the leadfield from which the components' sources are
%                   taken.
%
% Out:  
%       w - n-by-n ICA weights matrix
%       winv - n-by-n inverse ICA weights matrix
% 
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2017-08-03 First version

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

function [w, winv] = utl_get_icaweights(components, leadfield)

if length(components) ~= length(leadfield.chanlocs)
    warning('different number of components and channels');
end

% generating winv by putting all components' projection patterns in one matrix
winv = zeros(length(leadfield.chanlocs), length(components));
for c = 1:length(components)
    winv(:,c) = lf_get_projection(leadfield, components(c).source, 'orientation', components(c).orientation)';
end

% generating w by inverting winv
w = pinv(winv);

end
