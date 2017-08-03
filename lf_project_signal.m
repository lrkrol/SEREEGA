% scalpdata = lf_project_signal(signal, leadfield, sourceIdx, orientation, varargin)
%
%       Projects an activation signal through the indicated leadfield using
%       the indicated source and orientation.
%
% In:
%       signal - 1-by-n array, the activation signal to be projected
%       leadfield - a leadfield struct
%       sourceIdx - source index of the source in the leadfield
%       orientation - [x, y, z] orientation of the source to use
%
% Optional (key-value pairs):
%       normaliseLeadfield - 1|0, whether or not to normalise the
%                            leadfields before  projecting the signal to
%                            have the most extreme value be either 1 or -1,
%                            depending on its sign. default: 0
%       normaliseOrientation - 1|0, as above, except for orientation
%
% Out:
%       scalpdata - channels x samples array of simulated scalp data
%
% Usage example:
%       >> lf = lf_generate_fromnyhead;
%       >> epochs.n = 100; epochs.srate = 500; epochs.length = 1000;
%       >> s.peakLatency = 200; s.peakWidth = 100; s.peakAmplitude = 1;
%       >> s = utl_check_class(s, 'type', 'erp');
%       >> s = erp_generate_signal_fromclass(s, epochs, 1);
%       >> scalpdata = lf_project_signal(s, lf, 1, [1 1 0]);
% 
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2017-08-03 lrk
%   - Switched normalisation defaults to 0
% 2017-06-14 First version

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

function scalpdata = lf_project_signal(signal, leadfield, sourceIdx, orientation, varargin)

% parsing input
p = inputParser;

addRequired(p, 'signal', @isnumeric);
addRequired(p, 'leadfield', @isstruct);
addRequired(p, 'sourceIdx', @isnumeric);
addRequired(p, 'orientation', @isnumeric);

addParamValue(p, 'normaliseLeadfield', 0, @isnumeric);
addParamValue(p, 'normaliseOrientation', 0, @isnumeric);

parse(p, signal, leadfield, sourceIdx, orientation, varargin{:})

signal = p.Results.signal;
leadfield = p.Results.leadfield;
sourceIdx = p.Results.sourceIdx;
orientation = p.Results.orientation;
normaliseLeadfield = p.Results.normaliseLeadfield;
normaliseOrientation = p.Results.normaliseOrientation;

% getting leadfield
leadfield = squeeze(leadfield.leadfield(:,sourceIdx,:));

if normaliseLeadfield
    % normalising to have the maximum (or minimum) value be 1 (or -1)
    [~, i] = max(abs(leadfield(:)));
    leadfield = leadfield .* (sign(leadfield(i)) / leadfield(i));
end

if normaliseOrientation
    % normalising to have the maximum (or minimum) value be 1 (or -1)
    [~, i] = max(abs(orientation(:)));
    orientation = orientation .* (sign(orientation(i)) / orientation(i));
end

scalpdata = leadfield * [signal * orientation(1); ...
                         signal * orientation(2); ...
                         signal * orientation(3)];

end