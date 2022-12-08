% lf = lf_add_source(leadfield, position, projection, varargin)
%
%       Adds a single source to a leadfield, defined by the source's given 
%       position, projection patterns, and, optionally, default
%       orientation.
%
% In:
%       leadfield - the leadfield to which the source should be added
%       position - 1-by-3 matrix of source's xyz position, in mm
%       projection - n-by-3 matrix representing the source's projection
%                    patterns, where n equals the number of channels, and
%                    the three columns represent the x, y, and z projection
%                    patterns, respectively
%       region - string naming the source's corresponding atlas region
%
% Optional inputs (key-value pairs):
%       orientation - 1-by-3 matrix containing default xyz source
%                     orientation. default: [0 0 0]
%
% Out:  
%       lf - the leadfield with the new source added
%
% Usage example:
%       >> lf = lf_generate_fromnyhead('labels', {'Fz', 'Cz', 'Pz', 'Oz'});
%       >> lf = lf_add_source(lf, [0 0 0], rand(4,3), 'Brain_NewRegion')
% 
%                    Copyright 2017, 2022 Laurens R. Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology
%                    Neuroadaptive Human-Computer Interaction
%                    Brandenburg University of Technology

% 2022-12-02 lrk
%    - Added region argument
% 2017-09-29 First version

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

function lf = lf_add_source(leadfield, position, projection, region, varargin)

if strcmp(region, 'orientation')
    
    % maintaining backwards compatibility with SEREEGA <= v1.2.2, where
    % the region argument did not exist and could now be confused with the
    % optional orientation argument
    
    warning('No atlas region indicated; defaulting to ''Unknown''');
    
    lf = lf_add_source(leadfield, position, projection, 'Unknown', 'orientation', varargin{1});
    
else
    
    % parsing input
    p = inputParser;

    addRequired(p, 'leadfield', @isstruct);
    addRequired(p, 'position', @isnumeric);
    addRequired(p, 'projection', @isnumeric);
    addRequired(p, 'region', @ischar);

    addOptional(p, 'orientation', [0 0 0], @isnumeric);

    parse(p, leadfield, position, projection, region, varargin{:})

    lf = p.Results.leadfield;
    position = p.Results.position;
    projection = p.Results.projection;
    region = p.Results.region;
    orientation = p.Results.orientation;

    if iscolumn(position), position = position'; end
    if ~all(size(position) == [1, 3])
        error('SEREEGA:lf_add_source:error', 'position variable should be 1-by-3 matrix');
    end

    if ~all(size(projection) == [size(lf.leadfield, 1), 3])
        error('SEREEGA:lf_add_source:error', 'projection variable should be %d-by-3 matrix', size(lf.leadfield, 1));
    end

    if ~isempty(orientation)
        if iscolumn(orientation), orientation = orientation'; end
        if ~all(size(orientation) == [1, 3])
            error('SEREEGA:lf_add_source:error', 'orientation variable should be 1-by-3 matrix');
        end
    end

    % adding source to leadfield
    lf.pos(end+1,:) = position;
    lf.orientation(end+1,:) = orientation;
    lf.leadfield(:,end+1,:) = projection;
    lf.atlas = [lf.atlas; {region}];
    lf.atlas = utl_sanitize_atlas(lf.atlas);

end
    
end