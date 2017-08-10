%% preparations
% make sure that EEGLAB has been started.

% in this tutorial, we will be using the leadfield from ICMB-NY. for that,
% the file sa_nyhead.mat should be in the path. it can be downloaded from 
% http://www.parralab.org/nyhead/sa_nyhead.mat

% the general configuration of the simulated epochs is given as a structrue
% array, and requires the following fields:

epochs.n = 100;             % the number of epochs to simulate
epochs.srate = 1000;        % their sampling rate in Hz
epochs.length = 1000;       % their length in ms

% additionally, for this tutorial we add:

epochs.marker = 'event 1';  % the epochs' time-locking event marker
epochs.prestim = 200;       % pre-stimulus period in ms. note that this
                            % only affects the time indicated in the final
                            % dataset; it is ignored during simulation.
                            % i.e., a simulated latency of 500 ms becomes a 
                            % latency of 300 ms when a prestimulus period 
                            % of 200 ms is later applied.

%% generate a leadfield
% first, obtain a leadfield. this we can do either using FieldTrip, or by
% using (a part of) the ICBM-NY precalculated leadfield.

% we can indicate the electrode locations we want to use by indicating
% their channel labels, or by indicating a predefined electrode montage. 
% for example, to simulate a predefined 64-electrode montage using the
% ICBM-NY head model:

lf = lf_generate_fromnyhead('montage', 'S64');

% or, to only simulate the center line, we can use:

% lf = lf_generate_fromnyhead('labels', {'Fz', 'Cz', 'Pz', 'Oz'})

% when generating the leadfield using FieldTrip, we can also indicate the
% resolution of the source model (i.e. the density of the source grid):

% lf = lf_generate_fromfieldtrip('montage', 'S64', 'resolution', 5);

% this gives us a leadfield with the following channel locations:

plot_chanlocs(lf);

%% pick a source location
% the leadfield contains a number of 'sources' in the brain, i.e. source
% locations plus their projection patterns to the selected electrodes. in
% order to simulate a signal coming from a given source, we first need to
% select that source.

% we can get a random source, and inspect its location:

source = lf_get_source_random(lf);
plot_source_location(source, lf);

% or, if we know the location of a source, we can get the source nearest to
% that location, for example, somewhere in the right visual cortex:

source = lf_get_source_nearest(lf, [20 -85 0]);
plot_source_location(source, lf);

%% orient the source dipole
% the sources in the leadfield are represented by dipoles at specific
% locations. these dipoles can be oriented in space into any direction.
% this is indicated using an [x, y, z] orientation array. along with its 
% location, a dipole's orientation determines how it projects onto the
% scalp. 

% our source's projections onto scalp along the X, Y, and Z axes look like:

plot_source_projection(source, lf, ...
        'orientation', [1 0 0], 'orientedonly', 1);

plot_source_projection(source, lf, ...
        'orientation', [0 1 0], 'orientedonly', 1);

plot_source_projection(source, lf, ...
        'orientation', [0 0 1], 'orientedonly', 1);

% these projections can be linearly combined to get any simulated dipole
% orientation. in the ICBM-NY leadfield, default orientations are included,
% which orient the dipole perpendicular to the cortical surface. if no
% orientation is provided, this default orientation is used.
% fieldtrip-generated leadfields have no meaningful default orientation.

orientation = [1, 1, 0];
plot_source_projection(source, lf, 'orientation', orientation);

plot_source_projection(source, lf);

%% define the signal
% we now have a source's location and its orientation, i.e., we now know
% exactly how this source projects onto the scalp. next, we must determine
% what exactly is to be projected onto the scalp, i.e., the source's
% activation pattern.

% let us consider an event-related potential (ERP). an ERP is defined by
% the latency, width, and amplitude of its peak(s). we store activation
% definitions in "classes", in the form of structure arrays:

erp = struct();
erp.peakLatency = 500;      % in ms, starting at the start of the epoch
erp.peakWidth = 100;        % in ms
erp.peakAmplitude = 1;      % in microV

% the width is one-sided, i.e., the full width of the above peak will be
% between approximately 200 and 400 ms (note that we have defined a
% prestimulus period of 200 ms, which must be subtracted from these
% latencies.)

% this toolbox actually works with more than these three variables for ERP
% definitions. those other variables are not important right now, but they
% are required for the further functioning of this toolbox. to make sure
% the class is properly defined, including all currently missing variables,
% we can use the following function and see the newly added values.
% (alternatively, we could indicate all variables by hand.)

erp = utl_check_class(erp, 'type', 'erp');
erp

% we can now plot what this ERP would look like.

plot_signal_fromclass(erp, epochs);

%% brain components and scalp data
% having defined both a signal (the ERP) and a source location plus
% projection pattern for this signal, we can now combine these
% into a single component. brain components again are represented as
% structure arrays in this toolbox, with separate fields for the 
% component's source location and its activation pattern.

c = struct();
c.source = source;      % obtained from the leadfield, as above
c.signal = {erp};       % ERP class, defined above

c = utl_check_component(c, lf);

% with this, we have all we need to simulate scalp data. scalp data is
% simulated by projecting all components' signal activations through their
% respective sources, and summing all projections together. right now, our
% scalp data contains the activation of only one component, with one single
% and fixed activation pattern coming from one and the same location.

scalpdata = generate_scalpdata(c, lf, epochs);

% we can turn this into a dataset according to the EEGLAB format in order
% to use EEGLAB's analysis tools, for example, to see the scalp projection
% time course of the ERP we just simulated.

EEG = utl_create_eeglabdataset(scalpdata, epochs.srate, ...
        'chanlocs', lf.chanlocs, 'xmin', -epochs.prestim/1000, ...
        'marker', epochs.marker);

pop_topoplot(EEG, 1, [100, 200, 250, 300, 350, 400, 500], '', [1 8]);

%% variability
% if we scroll through the data, we see that all 100 epochs we generated
% are exactly the same, having a peak at exactly the indicated 300 ms and a
% width of exactly 100.

pop_eegplot(EEG, 1, 1, 1);

% this is of course unrealistic. we can build in a variability of the
% signal by indicating allowed deviations and slopes. a deviation of 50 ms
% for our peak latency allows this latency to vary +/- 50 ms between
% trials, following a normal distribution.

erp.peakLatencyDv = 50;
erp.peakAmplitudeDv = .2;

c.signal = {erp};
EEG = utl_create_eeglabdataset(generate_scalpdata(c, lf, epochs), ...
        epochs.srate, 'chanlocs', lf.chanlocs, ...
        'xmin', -epochs.prestim/1000, 'marker', epochs.marker);
pop_eegplot(EEG, 1, 1, 1);

% we can also indicate a slope, resulting in a consistent change over time.
% an amplitude of 1 and an amplitude slope of -.75 for example results in
% the signal having an amplitude of 1 in the first epoch, and .25 in the
% last.

erp.peakAmplitudeSlope = -.75;

c.signal = {erp};
EEG = utl_create_eeglabdataset(generate_scalpdata(c, lf, epochs), ...
        epochs.srate, 'chanlocs', lf.chanlocs, ...
        'xmin', -epochs.prestim/1000, 'marker', epochs.marker);

figure; pop_erpimage(EEG,1, [25],[[]],'Pz',10,1,{},[],'' ,'yerplabel','\muV','erp','on','cbar','on','topo', { [25] EEG.chanlocs EEG.chaninfo } );

% after these changes, the possible shape that the ERP can take varies
% significantly. in blue: extreme values for the first epoch; in red:
% extreme values for the last.

plot_signal_fromclass(erp, epochs);

%% noise and multiple signal classes
% for further, random variability, we can add noise to the signal. we do
% this by defining a new activation class containing the noise we want to
% simulate, and simply adding it to the existing component's signals.

noise = struct();
noise.color = 'brown';
noise.amplitude = 1;

noise = utl_check_class(noise, 'type', 'noise');

c.signal = {erp, noise};
EEG = utl_create_eeglabdataset(generate_scalpdata(c, lf, epochs), ...
        epochs.srate, 'chanlocs', lf.chanlocs, ...
        'xmin', -epochs.prestim/1000, 'marker', epochs.marker);
pop_eegplot(EEG, 1, 1, 1);

% when a component's signal activity is simulated, all of its signals are
% simualed separately and summed together before being projected through
% the leadfield. it is thus possible to generate multiple signal activation
% patterns from the same source location using a single component, e.g. in
% order to add noise to an otherwise clean signal.

%% event-related spectral perturbation
% besides ERP and noise classes, one final class of signal activation is
% available by default in this toolbox. this class concerns oscillatory
% activations.

% in its basic form, it is merely a sine wave of a given frequency, 
% amplitude and, optionally, phase.

ersp = struct();
ersp.frequency = 20;
ersp.amplitude = .25;

ersp = utl_check_class(ersp, 'type', 'ersp');

plot_signal_fromclass(ersp, epochs);

% this base frequency can additionally be modulated in different ways.

% frequency burst / event-related synchronisation
% the base oscillatory signal can be modulated such that it appears only as
% a single frequency burst, with a given peak (centre) latency, width, and
% taper.

ersp.modulation = 'burst';
ersp.modLatency = 500;      % centre of the burst, in ms    
ersp.modWidth = 100;        % width (half duration) of the burst, in ms
ersp.modTaper = 0.5;        % taper of the burst

ersp = utl_check_class(ersp, 'type', 'ersp');

plot_signal_fromclass(ersp, epochs);

% inverse frequency burst / event-related desynchronisation
% the inverse of the above; it results in an attenuation in the given
% window. in both cases, it is also possible to set a minimum amplitude,
% in order to restrict the attenuation, which is otherwise 100%. 

ersp.modulation = 'invburst';
ersp.modMinAmplitude = 0.2;

plot_signal_fromclass(ersp, epochs);

% phase-amplitude coupling
% this allows the base signal's amplitude to be modulated according to the
% phase of another. 

ersp.modulation = 'pac';
ersp.modFrequency = 2;
ersp.modPhase = .25;

ersp = utl_check_class(ersp, 'type', 'ersp');

plot_signal_fromclass(ersp, epochs);

% additionally, the phase-amplitude coupling can be attenuated during a
% given baseline period, using a window similar to the one used for
% frequency bursts.

ersp.modPrestimPeriod = epochs.prestim;
ersp.modPrestimTaper = .5;

ersp = utl_check_class(ersp, 'type', 'ersp');

plot_signal_fromclass(ersp, epochs);

% to put that all together again, and see the resulting EEG:

c.signal = {erp, ersp, noise};
EEG = utl_create_eeglabdataset(generate_scalpdata(c, lf, epochs), ...
        epochs.srate, 'chanlocs', lf.chanlocs, ...
        'xmin', -epochs.prestim/1000, 'marker', epochs.marker);
pop_eegplot(EEG, 1, 1, 1);

