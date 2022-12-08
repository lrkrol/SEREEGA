% atlas = utl_sanitize_atlas(atlas)
%
%       Takes the cell of strings that is a lead field's atlas, and
%       sanitizes it for compatibility with other functions. The
%       limitations are primarily due to EEGLAB's GUI functions. Currently,
%       the following substitutions happen:
%
%       - Space (' ') becomes underscore ('_')
%       - Apostrophe (') is removed
%
%       Also forces the atlas to be a column, and checks whether each atlas
%       element belongs to (i.e. each string starts with) one of the known
%       categories, i.e. brain, muscle, etc.
%
% In:
%       atlas - cell of strings
%
% Out:
%       atlas - cell of sanitized strings
%
% Usage example:
%       >> atlas = {'Brain Wernicke''s Area', 'Brain Heschl''s Gyrus'};
%       >> atlas = utl_sanitize_atlas(atlas);
% 
%                    Copyright 2022 Laurens R. Krol
%                    Neuroadaptive Human-Computer Interaction
%                    Brandenburg University of Technology

% 2022-11-25 First version

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

function atlas = utl_sanitize_atlas(atlas)

    % forcing column
    if isrow(atlas)
        atlas = atlas';
    end

    % replacing known problematic characters
    atlas = cellfun(@(x) strrep(x, ' ', '_'), atlas, 'UniformOutput', false);
    atlas = cellfun(@(x) strrep(x, '''', ''), atlas, 'UniformOutput', false);
    
    % checking for generic categories
    brainidx = strncmpi(atlas, 'brain', 5);
    muscleidx = strncmpi(atlas, 'muscle', 6);
    eyeidx = strncmpi(atlas, 'eye', 3);
    
    unknowns = numel(atlas) - sum([brainidx; muscleidx; eyeidx]);
    if unknowns > 0
        warning('%d atlas element(s) do not start with generic region categories', unknowns)
    end

end