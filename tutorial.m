%% preparations
% make sure that EEGLAB has been started.

% in this tutorial, we will be using the leadfield from ICMB-NY. for that,
% the file sa_nyhead.mat should be in the path. it can be downloaded from 
% http://www.parralab.org/nyhead/sa_nyhead.mat

% the general configuration of the simulated epochs requires:

epochs.n = 100;             % the number of epochs to simulate
epochs.srate = 500;         % their sampling rate in Hz
epochs.length = 1000;       % their length in ms

%% generate a leadfield
% first, obtain a leadfield. this we can do either using FieldTrip, or by
% using (a part of) the ICBM-NY precalculated leadfield.

% we can indicate the electrode locations we want to use by indicating
% their channel labels. for example, to simulate the closest available 
% equivalent of a 64-channel actiCAP cap based on the ICBM-NY head model:

channels = {'Fp1', 'Fp2', 'F7', 'F3', 'Fz', 'F4', 'F8', 'FC5', ...
            'FC1', 'FC2', 'FC6', 'T7', 'C3', 'Cz', 'C4', 'T8', ...
            'P9', 'CP5', 'CP1', 'CP2', 'CP6', 'P10', 'P7', ...
            'P3', 'Pz', 'P4', 'P8', 'PO9', 'O1', 'Oz', 'O2', ...
            'PO10', 'AF7', 'AF3', 'AF4', 'AF8', 'F5', 'F1', ...
            'F2', 'F6', 'FT9', 'FT7', 'FC3', 'FC4', 'FT8', ...
            'FT10', 'C5', 'C1', 'C2', 'C6', 'TP7', 'CP3', ...
            'CPz', 'CP4', 'TP8', 'P5', 'P1', 'P2', 'P6', ...
            'PO7', 'PO3', 'POz', 'PO4', 'PO8'};

lf = lf_generate_fromnyhead('labels', channels);

% when generating the leadfield using FieldTrip, we can also indicate the
% resolution of the source model (i.e. the density of the source grid):

% lf = lf_generate_fromfieldtrip('labels', channels, 'resolution', 5);

% this gives us a leadfield with the following channel locations:

h = plot_chanlocs(lf);
pause; close(h);

%% pick a source location
% the leadfield contains a number of 'sources' in the brain, i.e. source
% locations plus their projection patterns to the selected electrodes. in
% order to simulate a signal coming from a given source, we first need to
% select that source.

% we can get a random source, and inspect its location:

source = lf_get_source_random(lf);
h = plot_source_location(lf, source);
pause; close(h);

% or, if we know the location of a source, we can get the source nearest to
% that location, for example, somewhere in the right visual cortex:

source = lf_get_source_nearest(lf, [20 -85 0]);
h = plot_source_location(lf, source);
pause; close(h);

%% orient the source dipole
% the sources in the leadfield are represented by dipoles at specific
% locations. these dipoles can be oriented in space into any direction.
% this is indicated using an [x, y, z] orientation array. along with its 
% location, a dipole's orientation determines how it projects onto the
% scalp. 

% our source's projections onto scalp along the X, Y, and Z axes look like:

h = plot_source_projection(lf, source, 'orientation', [1 0 0], 'orientedonly', 1);
pause; close(h);
h = plot_source_projection(lf, source, 'orientation', [0 1 0], 'orientedonly', 1);
pause; close(h);
h = plot_source_projection(lf, source, 'orientation', [0 0 1], 'orientedonly', 1);
pause; close(h);

% these projections can be linearly combined to get any simulated dipole
% orientation. in the ICBM-NY leadfield, default orientations are included,
% which orient the dipole perpendicular to the cortical surface. if no
% orientation is provided, this default orientation is used.
% fieldtrip-generated leadfields have no meaningful default orientation.

orientation = [1, 1, 0];
h = plot_source_projection(lf, source, 'orientation', orientation);
pause; close(h);

h = plot_source_projection(lf, source);
pause; close(h);

%% simulate data
% we now have a source's location and its orientation, i.e., we now know
% exactly how this source projects onto the scalp. next, we must determine
% what exactly is to be projected onto the scalp, i.e., the source's
% activation pattern.

% let us consider an event-related potential (ERP). an ERP is defined by
% the latency, width, and amplitude of its peak(s). we store EEG activation
% definitions in "classes", in the form of structure arrays:

erp.peakLatency = 300;      % in ms
erp.peakWidth = 100;        % in ms
erp.peakAmplitude = 1;      % in mV

% the width is one-sided, i.e., the full width of the above peak will be
% between apprximately 200 and 400 ms.

% this toolbox actually works with more than these three variables for ERP
% definitions. those other variables are not important right now, but they
% are required for the further functioning of this toolbox. to make sure
% the class is properly defined, including all currently missing variables,
% we can use the following function and see the newly added values.
% (alternatively, we could indicate all variables by hand.)

erp = utl_check_class(erp, 'type', 'erp');
erp

% we can now plot what this ERP would look like.

plot_signal(erp, epochs);

%% brain components