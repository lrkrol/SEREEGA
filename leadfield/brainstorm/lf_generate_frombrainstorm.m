function lf = lf_generate_frombrainstorm(varargin)

% parsing input
p = inputParser;

addParameter(p, 'chanloc', 'channel_GSN_HydroCel_128_E1.mat', @ischar)  %Channel location file name
addParameter(p, 't1', 'subjectimage_T1.mat', @ischar)                   %T1 image for coordinates conversion
addParameter(p, 'headmodel', 'headmodel_vol_duneuro.mat', @ischar)      %Headmodel generated in Brainstorm
addParameter(p, 'scaleUnits', 1, @isnumeric);                          %Scale units from V/A-m to microV/nA-m
addParameter(p, 'useMm', 1, @isnumeric);                                %Convert all lengths from meters to mm

parse(p, varargin{:});

chanloc      = p.Results.chanloc;
t1           = p.Results.t1;
hm           = p.Results.headmodel;
scaleUnits   = p.Results.scaleUnits;
useMm        = p.Results.useMm;

%% Load required data

% Display useful information to user
fprintf('Using channel file: %s \nUsing T1 image file: %s \nUsing Brainstorm headmodel file: %s\n', chanloc, t1, hm);

% Channel location
if ~exist('chanloc', 'var')
     error('SEREEGA:lf_generate_fromnyhead:fileNotFound', ...
         ['Could not find channel location file (%s) in the path.' ...
         '\nMake sure you use the same file you used in Brainstorm to generate the leadfield. ' ...
         '\nAdd it to the same directory as this script'], chanloc)
else
    channels = load(chanloc);
end

% T1 data used in Brainstorm
if ~exist('t1', 'var')
    error('SEREEGA:lf_generate_fromnyhead:fileNotFound', ...
        ['Could not find T1 image file (%s) in the path.' ...
        '\nMake sure you use the same file you used in Brainstorm to generate the leadfield.' ...
        '\nAdd it to the same directory as this script'], t1)
else
    t1Image = load(t1);
end

% Brainstorm head model (leadfield)
if ~exist('hm', 'var')
    error('SEREEGA:lf_generate_fromnyhead:fileNotFound', ...
        ['Could not find headmodel file (%s) in the path.' ...
        '\nMake sure to add the headmodel (leadfield) generated in Brainstorm to the same directory as this script'], hm)
else
    bsLeadField = load(hm);
end
%% Convert from Brainstrom format (2D) to Sereega format (3D)
% First convert the 2D leadfield from Brainstorm into a 3D matrix (XYZ
% coordinates)

fprintf('Converting Brainstrom 2D headmodel to 3D matrix\n');

% Extract X-Y-Z dimensions
xdim = bsLeadField.Gain(:, 1:3:size(bsLeadField.Gain,2)); %X dim is in columns 1-4-7-10-etc...
ydim = bsLeadField.Gain(:, 2:3:size(bsLeadField.Gain,2)); %X dim is in columns 2-5-8-11-etc...
zdim = bsLeadField.Gain(:, 3:3:size(bsLeadField.Gain,2)); %X dim is in columns 3-6-9-12-etc...

% Save in 3D matrix
lf3D = cat(3, xdim, ydim, zdim);

% Scale from Brainstorm V/A-m to microV/nA-m if requested
if scaleUnits 
    fprintf('Converting leadfield from Brainstorm default V/A-m to microV/nA-m\n')
    lf3D = lf3D * 1e-3;
end

%% Convert leadfiled dipole position and orientation to MNI coordinates

fprintf('Converting dipole locations from Brainstorm Subject Coordinate System (SCS) to MNI system\n');

try
    % Dipoles
    gridLocMNI = cs_convert(t1Image, 'scs', 'mni', bsLeadField.GridLoc);    %Location

    % Check if the dipoles are oriented, if not, set their values to 0
    if isempty(bsLeadField.GridOrient)
        gridOriMNI = zeros(size(gridLocMNI));
    else
        gridOriMNI = cs_convert(t1Image, 'scs', 'mni', bsLeadField.GridOrient); 
    end

    %Channels
    bsChannelocMNI = channels; %Channel structure to save MNI coordinates

    for ch=1:size(channels.Channel,2)
    
        xyzChanpos = channels.Channel(ch).Loc;                        %Extract current channel location
        xyzMNI     = cs_convert(t1Image, 'scs', 'mni', xyzChanpos);   %Convert them into MNI coordinates
        bsChannelocMNI.Channel(ch).Loc = xyzMNI';                     %Save them in chan loc MNI struct

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

%% Rotate coordinates
% The MNI coordinate system is rotated by 90 degrees compared to the EEGLAB
% system, which is used by SEREEGA loading channel location and plotting.
% Because of this, we need to rotate the converted dipoles location and
% electrode locations. 
% If we save the chanloc file now, EEGLAB will assume that it is a
% Brainstorm chanloc file, which should use a SCS system. However, we are
% now in the MNI coordinate system, whihc is rotated by 90 degrees compared
% to EEGLAB system
% (https://eeglab.org/tutorials/ConceptsGuide/coordinateSystem.html). Thus,
% we need to rotate channels and dipoles accordingly X=Y and Y=-X

for ch = 1:size(bsChannelocMNI.Channel,2)
   
   % Electrodes
   % Extract values for x and y coordinates
   xchan = bsChannelocMNI.Channel(ch).Loc(1);
   ychan = bsChannelocMNI.Channel(ch).Loc(2);

   % Swap coordinates and rotate
   bsChannelocMNI.Channel(ch).Loc(1) = ychan;
   bsChannelocMNI.Channel(ch).Loc(2) = -xchan;
   
   % Dipoles
   xdip = gridLocMNI(:,1);
   ydip = gridLocMNI(:,2);

   gridLocMNI(:,1) = ydip;
   gridLocMNI(:,2) = -xdip;

   
   lfX = lf3D(:,:,1);
   lfY = lf3D(:,:,2);

   lf3D(:,:,1) = lfY;
   lf3D(:,:,2) = lfX;


end

%% Change all units from meters to mm to match the other leadfields - if 
% requested. We do this before saving the channel file so that EEGLAB will
% load the X-Y-Z coordinates in mm and correctly compute the spherical
% coordinates.

if useMm
    
    % Dipole location
    gridLocMNI = gridLocMNI * 1000;
    
    % Electrode XYZ Location
    for ch = 1:size(bsChannelocMNI.Channel,2)
        bsChannelocMNI.Channel(ch).Loc = bsChannelocMNI.Channel(ch).Loc * 1000;
    end
end
    
%% Save MNI converted channel file in order to open  it with eeglab
fprintf('Saving channel file converted to MNI coordinates\n');
save(strcat(chanloc(1:end-4), '_MNI.mat'), '-struct', 'bsChannelocMNI');

%% Open with eeglab and adjust fields so they can be used by SEREEGA
eeglabChan = readlocs(strcat(chanloc(1:end-4), '_MNI.mat'), 'filetype', 'mat');

% There should not be fiducial channels in the channel structure.
% However, if any are present, find and remove them
fiducials = { 'nz' 'lpa' 'rpa' 'nasion' 'left' 'right' 'nazion' 'fidnz' 'fidt9' 'fidt10' 'cms' 'drl' 'nas' 'lht' 'rht' 'lhj' 'rhj' };
fiducialIdx = find(ismember(lower({eeglabChan.labels}), fiducials));
if length(fiducialIdx)
    eeglabChan(fiducialIdx) = [];
end

% Create leadfield structure for sereega
lf = struct();
lf.leadfield   = lf3D;
lf.orientation = gridOriMNI;
lf.pos         = gridLocMNI;
lf.chanlocs    = eeglabChan;

end










