function projection = lf_get_projection(sourceIdx, leadfield, varargin)

% parsing input
p = inputParser;

addRequired(p, 'sourceIdx', @isnumeric);
addRequired(p, 'leadfield', @isstruct);

addParamValue(p, 'orientation', [], @isnumeric);
addParamValue(p, 'normaliseLeadfield', 1, @isnumeric);
addParamValue(p, 'normaliseOrientation', 1, @isnumeric);

parse(p, sourceIdx, leadfield, varargin{:})

leadfield = p.Results.leadfield;
sourceIdx = p.Results.sourceIdx;
orientation = p.Results.orientation;
normaliseLeadfield = p.Results.normaliseLeadfield;
normaliseOrientation = p.Results.normaliseOrientation;

if isempty(orientation)
    orientation = leadfield.orientation(sourceIdx,:);
end

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

% getting oriented projection
projection = [];
projection(:,1) = leadfield(:,1) * orientation(1);
projection(:,2) = leadfield(:,2) * orientation(2);
projection(:,3) = leadfield(:,3) * orientation(3);
projection = mean(projection, 2);

end