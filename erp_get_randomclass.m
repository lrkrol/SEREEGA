function erp = erp_get_randomclass(numpeaks, latencies, widths, amplitudes, varargin)

% parsing input
p = inputParser;

addRequired(p, 'numpeaks', @isnumeric);
addRequired(p, 'latencies', @isnumeric);
addRequired(p, 'widths', @isnumeric);
addRequired(p, 'amplitudes', @isnumeric);

addParamValue(p, 'latencyDvs', 0, @isnumeric);
addParamValue(p, 'latencySlopes', 0, @isnumeric);
addParamValue(p, 'widthDvs', 0, @isnumeric);
addParamValue(p, 'widthSlopes', 0, @isnumeric);
addParamValue(p, 'amplitudeDvs', 0, @isnumeric);
addParamValue(p, 'amplitudeSlopes', 0, @isnumeric);
addParamValue(p, 'probabilities', 1, @isnumeric);
addParamValue(p, 'probabilitySlopes', 0, @isnumeric);
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
    n = utl_randsample(numpeaks, 1);
    erpclass = struct();
    erpclass.peakLatency = utl_randsample(latencies, n);
    erpclass.peakLatencyDv = utl_randsample(latencyDvs, n, 1) .* erpclass.peakLatency;
    erpclass.peakLatencySlope = utl_randsample(latencySlopes, n, 1) .* erpclass.peakLatency;
    erpclass.peakWidth = utl_randsample(widths, n, 1);
    erpclass.peakWidthDv = utl_randsample(widthDvs, n, 1) .* erpclass.peakWidth;
    erpclass.peakWidthSlope = utl_randsample(widthSlopes, n, 1) .* erpclass.peakWidth;
    erpclass.peakAmplitude = utl_randsample(amplitudes, n, 1);
    erpclass.peakAmplitudeDv = utl_randsample(amplitudeDvs, n, 1) .* erpclass.peakAmplitude;
    erpclass.peakAmplitudeSlope = utl_randsample(amplitudeSlopes, n, 1) .* erpclass.peakAmplitude;
    erpclass.probability = utl_randsample(probabilities, 1);
    erpclass.probabilitySlope = utl_randsample(probabilitySlopes, 1) .* erpclass.probability;
    erp(c) = utl_check_class(erpclass, 'type', 'erp');
end

end