function lf = lf_generate_frombrainstorm(varargin)

% parsing input
p = inputParser;

addParameter(p, 'chanloc', 'chanloc_gsn_128.mat', @ischar)          %Channel location file name
addParameter(p, 't1', 'ICBM152_T1_Brainstorm.mat', @ischar)               %T1 image for coordinates conversion
addParameter(p, 'headmodel', 'hm_fem_duneuro_acticap64.mat', @ischar) %Headmodel generated in Brainstorm
addParameter(p, 'scale', 1, @isnumeric);

parse(p, varargin{:});

chanloc = p.Results.chanloc;
t1      = p.Results.t1;
hm      = p.Results.headmodel;
scale   = p.Results.scale;

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
    t1_image = load(t1);
end

% Brainstorm head model (leadfield)
if ~exist('hm', 'var')
    error('SEREEGA:lf_generate_fromnyhead:fileNotFound', ...
        ['Could not find headmodel file (%s) in the path.' ...
        '\nMake sure to add the headmodel (leadfield) generated in Brainstorm to the same directory as this script'], hm)
else
    brainstorm_lf = load(hm);
end
