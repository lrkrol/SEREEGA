function componentsignal = generate_signal_fromcomponent(component, epochs, varargin)

% parsing input
p = inputParser;

addRequired(p, 'component', @isstruct);
addRequired(p, 'epochs', @isstruct);

addParamValue(p, 'epochNumber', 1, @isnumeric);
addParamValue(p, 'baseonly', 0, @isnumeric);

parse(p, component, epochs, varargin{:})

component = p.Results.component;
epochs = p.Results.epochs;
epochNumber = p.Results.epochNumber;
baseonly = p.Results.baseonly;

signaldata = zeros(numel(component.signal), floor((epochs.length/1000)*epochs.srate));

% for each signal...
for s = 1:numel(component.signal)
    % obtaining signal
    signal = generate_signal_fromclass(component.signal{s}, epochs, 'epochNumber', epochNumber, 'baseonly', baseonly);
    signaldata(s,:) = signal;
end

% combining signals into single component activation
componentsignal = sum(signaldata, 1);
        
end