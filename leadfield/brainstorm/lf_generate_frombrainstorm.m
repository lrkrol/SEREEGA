function lf = lf_generate_frombrainstorm(varargin)

% parsing input
p = inputParser;

addParameter(p, 'chanloc', 'channel_GSN_HydroCel_128_E1.mat', @ischar)  %Channel location file name
addParameter(p, 't1', 'subjectimage_T1.mat', @ischar)                   %T1 image for coordinates conversion
addParameter(p, 'headmodel', 'headmodel_surf_openmeeg.mat', @ischar)    %Headmodel generated in Brainstorm
addParameter(p, 'tess', [], @ischar)                                  %File of the cortex mat or volume mat
addParameter(p, 'atlasName', [], @ischar)                                   %Name of the specific atlas to use (Cortex file could have more than 1)
addParameter(p, 'scaleUnits', 1, @isnumeric);                           %Scale units from V/A-m to microV/nA-m
addParameter(p, 'useMm', 1, @isnumeric);                                %Convert all lengths from meters to mm
addParameter(p, 'useMNI', 1, @isnumeric);                               %Convert units to MNI coordinates

parse(p, varargin{:});

chanloc      = p.Results.chanloc;
t1           = p.Results.t1;
hm           = p.Results.headmodel;
tess         = p.Results.tess;
atlasName    = p.Results.atlasName;
scaleUnits   = p.Results.scaleUnits;
useMm        = p.Results.useMm;
useMNI       = p.Results.useMNI;

%% Load required data

% Display useful information to user
fprintf('Using channel file: %s \nUsing T1 image file: %s \nUsing Brainstorm headmodel file: %s\n', chanloc, t1, hm);

% Channel location
if ~exist('chanloc', 'var')
     error('SEREEGA:lf_generate_frombrainstorm:fileNotFound', ...
         ['Could not find channel location file (%s) in the path.' ...
         '\nMake sure you use the same file you used in Brainstorm to generate the leadfield. ' ...
         '\nAdd it to the same directory as this script'], chanloc)
else
    channels = readlocs(chanloc);
end

% T1 data used in Brainstorm
if ~exist('t1', 'var')
    error('SEREEGA:lf_generate_frombrainstorm:fileNotFound', ...
        ['Could not find T1 image file (%s) in the path.' ...
        '\nMake sure you use the same file you used in Brainstorm to generate the leadfield.' ...
        '\nAdd it to the same directory as this script'], t1)
else
    t1Image = load(t1);
end

% Brainstorm head model (leadfield)
if ~exist('hm', 'var')
    error('SEREEGA:lf_generate_frombrainstorm:fileNotFound', ...
        ['Could not find headmodel file (%s) in the path.' ...
        '\nMake sure to add the headmodel (leadfield) generated in Brainstorm to the same directory as this script'], hm)
else
    bsLeadField = load(hm);
end

% If an atlas has been specified, try to extract it. Atlas in Brainstorm is
% stored in the cortex file, unless it comes from a deep structure. In the
% latter case it will be stored in the headmodel file. 
if ~isempty(tess) && ~isempty(atlasName)
    
    % First case, the atlas comes from a mixed head model, thus it is
    % sotred in the headmodel file
    if strcmp(tess, 'mixed')
        atlas = atlas_bs_to_cell(bsLeadField.GridAtlas);
   
    % Second case, the atlas comes from a volume or a surface headmodel and
    % it is contained in the surface mat file
    else
        if ~exist('tess','var')
            erorr(['SEREEGA:lf_generate_frombrainstorm:fileNotFound ' ...
                'Could not find the tissue file (%s) containing the atlas in the path. ' ...
                '\nIf you created a volume or surface headmodel, make sure to add the tissue file used ' ...
                '(eg. cortex15000V) to the same directory as this script\n '], tess)
        else
            atlasFile = load(tess, 'Atlas');
            % Extract only the requested atlas by its name
            if any(strcmp({atlasFile.Atlas.Name}, atlasName))
                atlasIdx  = find(strcmp({atlasFile.Atlas.Name}, atlasName));
                atlas     = atlas_bs_to_cell(atlasFile.Atlas(atlasIdx).Scouts);
            else
                error('SEREEGA:lf_generate_frombrainstorm:fileNotFound Could not find atlas %s', atlasName)
            end
        end
    end
end


%% Convert from Brainstrom format (2D) to Sereega format (3D)
% First convert the 2D leadfield from Brainstorm into a 3D matrix (XYZ
% coordinates)

fprintf('Converting Brainstrom 2D headmodel to 3D matrix\n');

% Extract X-Y-Z dimensions
xdim = bsLeadField.Gain(:, 1:3:size(bsLeadField.Gain,2)); %X dim is in columns 1-4-7-10-etc...
ydim = bsLeadField.Gain(:, 2:3:size(bsLeadField.Gain,2)); %X dim is in columns 2-5-8-11-etc...
zdim = bsLeadField.Gain(:, 3:3:size(bsLeadField.Gain,2)); %X dim is in columns 3-6-9-12-etc...

%% Convert to MNI coordinates if required
if useMNI
    % Save in 3D matrix
    % Note1: that the X-Y-Z dimensions of the leadfield are in the SCS system
    % used by Brainstorm. However, here we will transform everything in the MNI
    % coordinate system. Thus, we need to account for this here too, otherwise
    % the leadfiled will project onto the wrong surface. The SCS system has the
    % X-axis pointing towards the nose and the Y-axis pointing towards LPA. The
    % MNI coordinate system has the X-axis pointing towards RPA and the Y-axis
    % towards the nose. 
    % Note2: The rotation applied here is not the same as the rotation applied
    % to the channels to account for the EEGLAB rotation. In that case, we will
    % go from MNI to EEGLAB. 
    lf3D = cat(3, -ydim, xdim, zdim);


% Convert leadfiled dipole position and orientation to MNI coordinates

    fprintf('Converting dipole locations from Brainstorm Subject Coordinate System (SCS) to MNI system\n');
    
    try
        % Dipoles
        gridLocMNI = cs_convert(t1Image, 'scs', 'mni', bsLeadField.GridLoc);    %Location
    
        % Check if the dipoles are oriented, if not, set their values to 0
        if isempty(bsLeadField.GridOrient)
            gridOriMNI = zeros(size(gridLocMNI));
        else
            % Use the provided perpendicular orientations, but rotate them to
            % account for the switch from SCS to MNI coordinate system (see
            % note above)
            gridOriMNI(:,1) = -bsLeadField.GridOrient(:,2);
            gridOriMNI(:,2) = bsLeadField.GridOrient(:,1);
            gridOriMNI(:,3) = bsLeadField.GridOrient(:,3);
        end
    
    catch ME
        % cs_convert is part of the Brainstorm software - Catch if Brainstorm
        % has not been added to the path
        if (strcmp(ME.identifier, 'MATLAB:UndefinedFunction'))
            msg = ['lf_generate_frombrainstorm: Could not find Brainstorm cs_convert function. \n' ...
                'Remember to add Brainstorm or the function to the path. \n' ...
                'You should find cs_convert.m in [YOURPATH]\brainstorm\brainstorm3\toolbox\anatomy \n' ...
                'You can add just this folder to path with addpath [YOURPATH]\brainstorm\brainstorm3\toolbox\anatomy'];
            causeException = MException('MATLAB:myCode:UndefinedFunction', msg);
            ME = addCause(ME, causeException);
        end
        rethrow(ME)
    end
    
    % Channels
    fprintf('Converting channel location from SCS system to MNI system and readjusting for EEGLAB coordinate rotation (X=Y, Y=-X)\n')
    channelsMNI = channels;
    for ch = 1:length(channels)
        % Convert XYZ EEGLAB coordinates into MNI coordinates. This will rotate
        % the coordinates so that Xmni = -Yeeglab, Ymni = Xeeglab
        xyzMNI = cs_convert(t1Image, 'scs', 'mni', [[channels(ch).X], [channels(ch).Y], [channels(ch).Z]]);
        
        % Reassign the MNI coordinates to the channel structure. SEREEGA
        % expects the channels to be in the EEGLAB fomat, thus we need to
        % rotate them 
        channelsMNI(ch).X = xyzMNI(2);
        channelsMNI(ch).Y = -xyzMNI(1);
        channelsMNI(ch).Z = xyzMNI(3);
    end
    
    % Recompute spherical and besa coordinates 
    channelsMNI = convertlocs(channelsMNI);
    
    % If the fiducials are saved with the other channels, remove them (they are
    % not included in the leadfield)
    fiducials = { 'nz' 'lpa' 'rpa' 'nasion' 'left' 'right' 'nazion' 'fidnz' 'fidt9' 'fidt10' 'cms' 'drl' 'nas' 'lht' 'rht' 'lhj' 'rhj' };
    fiducialIdx = find(ismember(lower({channelsMNI.labels}), fiducials));
    
    if length(fiducialIdx)
        channelsMNI(fiducialIdx) = [];
    end
    
    %% Scale units if requested
    
    % Dipole  and channels (NOTE: the MNI coordinate system shoukd be in mm.
    % However, the cs_convert function returns the results in meters, as this
    % is Brainstorm default). 
    if useMm
        fprintf('Converting dipole and channel location from M to mm')
        % Dipole location
        gridLocMNI = gridLocMNI * 1000;
        
        % Electrode XYZ Location
        for ch = 1:length(channelsMNI)
            channelsMNI(ch).X = channelsMNI(ch).X * 1000;
            channelsMNI(ch).Y = channelsMNI(ch).Y * 1000;
            channelsMNI(ch).Z = channelsMNI(ch).Z * 1000;
        end
        % Recompute spherical and besa coordinates 
        channelsMNI = convertlocs(channelsMNI);
    end
        
    % Leadfield from Brainstorm V/A-m to microV/nA-m
    if scaleUnits 
        fprintf('Converting leadfield from Brainstorm default V/A-m to microV/nA-m\n')
        lf3D = lf3D * 1e-3;
    end

    % Create leadfield structure for sereega
    lf = struct();
    lf.leadfield   = lf3D;
    lf.orientation = gridOriMNI;
    lf.pos         = gridLocMNI;
    lf.chanlocs    = channelsMNI;
    % Add atlas if it exists or add Brain_CorticalSurface to all dipoles
    if exist('atlas', 'var')
        lf.atlas = strcat('Brain', {' '}, atlas);
        %lf.atlas = utl_sanitize_atlas(lf.atlas);
    else
        lf.atlas = repmat({'Brain_CorticalSurface'}, size(lf.pos, 1), 1);
    end

%% Use SCS if conversion to MNI was not required
else
    % Switch leadfield gain coordinates to accountf for EEGLAB rotation of
    % the channels
    lf3D    = cat(3, -ydim, xdim, zdim);

    % Switch dipole coordinates to account for EEGLAB rotation of the
    % channels
    gridLoc  = [-bsLeadField.GridLoc(:,2), bsLeadField.GridLoc(:,1), bsLeadField.GridLoc(:,3)];

     % Check if the dipoles are oriented, if not, set their values to 0
        if isempty(bsLeadField.GridOrient)
            gridOri = zeros(size(gridLoc));
        else
            % Use the provided perpendicular orientations and rotate them
            % to account for EEGLAB rotation of the channels
            
            gridOri(:,1) = -bsLeadField.GridOrient(:,2);
            gridOri(:,2) = bsLeadField.GridOrient(:,1);
            gridOri(:,3) = bsLeadField.GridOrient(:,3);
        end

    % If the fiducials are saved with the other channels, remove them (they are
    % not included in the leadfield)
    fiducials = { 'nz' 'lpa' 'rpa' 'nasion' 'left' 'right' 'nazion' 'fidnz' 'fidt9' 'fidt10' 'cms' 'drl' 'nas' 'lht' 'rht' 'lhj' 'rhj' };
    fiducialIdx = find(ismember(lower({channels.labels}), fiducials));
    
    if length(fiducialIdx)
        channels(fiducialIdx) = [];
    end

    % If requested, convert all the measures from m (as provided by
    % Brainstorm) to mm
    if useMm
        fprintf('Converting dipole and channel location from M to mm')
        % Dipole location
        gridLoc = gridLoc * 1000;

        % Electrode XYZ Location
        for ch = 1:length(channels)
            channels(ch).X = channels(ch).X * 1000;
            channels(ch).Y = channels(ch).Y * 1000;
            channels(ch).Z = channels(ch).Z * 1000;
        end
        % Recompute spherical and besa coordinates 
        channels = convertlocs(channels);
    end

    % Leadfield from Brainstorm V/A-m to microV/nA-m
    if scaleUnits 
        fprintf('Converting leadfield from Brainstorm default V/A-m to microV/nA-m\n')
        lf3D = lf3D * 1e-3;
    end

    % Create leadfield structure for sereega
    lf = struct();
    lf.leadfield   = lf3D;
    lf.orientation = gridOri;
    lf.pos         = gridLoc;
    lf.chanlocs    = channels;
    % Add atlas if it exists or add Brain_CorticalSurface to all dipoles
    if exist('atlas', 'var')
        lf.atlas = strcat('Brain', {' '}, atlas);
        %lf.atlas = utl_sanitize_atlas(lf.atlas);
    else
        lf.atlas = repmat({'Brain_CorticalSurface'}, size(lf.pos, 1), 1);
    end
    
end
end


%---Helper functions---%
% Convert the atlas from brainstorm structure to a simple Nsources X 1 cell
function a = atlas_bs_to_cell(brainstormAtlas)
  
    % Find number of labels
    maxIdx = 0;
    for i = 1:length(brainstormAtlas)
        currentMax = max(brainstormAtlas(i).Vertices);
        if currentMax > maxIdx
            maxIdx = currentMax;
        end
    end

    % Initialise cell array for labels
    a = cell(maxIdx, 1);

    % Find what label each dipole Idx has got and store them in order
    for d = 1:maxIdx
        % Find where the current dipole is and store its label
        for l = 1:length(brainstormAtlas)
            if any(brainstormAtlas(l).Vertices == d)
                a{d} = brainstormAtlas(l).Label;
                break
            end
        end
    end

end









