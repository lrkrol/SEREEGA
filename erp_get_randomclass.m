
%         .peakLatency:          1-by-n matrix of peak latencies
%         .peakLatencyDv:        1-by-n matrix of peak latency deviations
%         .peakLatencySlope:     1-by-n matrix of peak latency slopes
%         .peakWidth:            1-by-n matrix of peak widths
%         .peakWidthDv:          1-by-n matrix of peak width deviations
%         .peakWidthSlope:       1-by-n matrix of peak width slopes
%         .peakAmplitude:        1-by-n matrix of peak amplitudes
%         .peakAmplitudeDv:      1-by-n matrix of peak amplitude deviations
%         .peakAmplitudeSlope:   1-by-n matrix of peak amplitude slopes
%         .probability:          0-1 scalar indicating probability of
%                                appearance
%         .probabilitySlope:     scalar, slope of the probability

function erp = erp_get_randomclass(numpeaks, latencies, widths, amplitudes, varargin)

% parsing input
p = inputParser;

addRequired(p, 'numpeaks', @isnumeric);
addRequired(p, 'latencies', @isnumeric);
addRequired(p, 'widths', @isnumeric);
addRequired(p, 'amplitudes', @isnumeric);

addParamValue(p, 'latencyDvs', [0 0], @isnumeric);
addParamValue(p, 'latencySlopes', [0 0], @isnumeric);
addParamValue(p, 'widthDvs', [0 0], @isnumeric);
addParamValue(p, 'widthSlopes', [0 0], @isnumeric);
addParamValue(p, 'amplitudeDvs', [0 0], @isnumeric);
addParamValue(p, 'amplitudeSlopes', [0 0], @isnumeric);
addParamValue(p, 'probabilities', 1, @isnumeric);
addParamValue(p, 'probabilitySlopes', [0 0], @isnumeric);
addParamValue(p, 'numClasses', 1, @isnumeric);

parse(p, numpeaks, latencies, widths, amplitudes, varargin{:})

numpeaks = p.Results.numpeaks;
latencies = p.Results.latencies;
widths = p.Results.widths;
amplitudes = p.Results.amplitudes;
latencyDvs = p.Results.latencyDvs;
latencySlopes = p.Results.latencySlopes;
widthDvs = p.Results.widthDvs;
widthSlopes = p.Results.widthSlopes;
amplitudeDvs = p.Results.amplitudeDvs;
amplitudeSlopes = p.Results.amplitudeSlopes;
probabilities = p.Results.probabilities;
probabilitySlopes = p.Results.probabilitySlopes;
numClasses = p.Results.numClasses;

for c = 1:numClasses
    n = randsample(numpeaks, 1);
    erpclass = struct();
    erpclass.peakLatency = randsample(latencies, n);
    erpclass.peakLatencyDv = randsample(latencyDvs, n, 1) .* erpclass.peakLatency;
    erpclass.peakLatencySlope = randsample(latencySlopes, n, 1) .* erpclass.peakLatency;
    erpclass.peakWidth = randsample(widths, n, 1);
    erpclass.peakWidthDv = randsample(widthDvs, n, 1) .* erpclass.peakWidth;
    erpclass.peakWidthSlope = randsample(widthSlopes, n, 1) .* erpclass.peakWidth;
    erpclass.peakAmplitude = randsample(amplitudes, n, 1);
    erpclass.peakAmplitudeDv = randsample(amplitudeDvs, n, 1) .* erpclass.peakAmplitude;
    erpclass.peakAmplitudeSlope = randsample(amplitudeSlopes, n, 1) .* erpclass.peakAmplitude;
    erpclass.probability = randsample(probabilities, 1);
    erpclass.probabilitySlope = randsample(probabilitySlopes, 1) .* erpclass.probability;
    erp(c) = utl_check_class(erpclass, 'type', 'erp');
end

end