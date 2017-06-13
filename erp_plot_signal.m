% h = erp_plot_signal(class, epochs)
%
%       Plots ERP class activation signal. In blue, solid line: the mean 
%       signal as defined. The dotted and dashed lines indicate the
%       signal's variability as per the defined deviations. If a slope has
%       been defined, the red curve indicates the signal (mean and
%       extremes) at the end of the slope (i.e. the final epoch).
%
% In:
%       class - 1x1 struct, the class variable
%       epochs - 1x1 struct, an epoch configuration struct
%
% Out:  
%       h - handle of the generated figure
%
% Usage example:
%       >> epochs.n = 100; epochs.srate = 500; epochs.length = 1000;
%       >> erp.peakLatency = 200; erp.peakWidth = 100; erp.peakAmplitude = 1;
%       >> erp.peakLatencyDv = 25; erp.peakAmplitudeSlope = -.25; erp.peakLatencySlope = 50;
%       >> erp = utl_check_class(erp, 'type', 'erp');
%       >> erp_plot_signal(erp, epochs);
% 
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2017-06-13 First version

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

function class = erp_plot_signal(class, epochs)

x = 1:epochs.length/1000*epochs.srate;
x = x/epochs.srate;

h = figure;
hold on;

% mean
plot(x, erp_generate_signal( ...
        class.peakLatency, ...
        class.peakWidth, ...
        class.peakAmplitude, ...
        epochs.srate, epochs.length), 'b-', 'LineWidth', 2);
    
% min deviation
plot(x, erp_generate_signal( ...
        class.peakLatency - class.peakLatencyDv, ...
        class.peakWidth - class.peakWidthDv, ...
        class.peakAmplitude - class.peakAmplitudeDv, ...
        epochs.srate, epochs.length), 'b:');
    
% max deviation
plot(x, erp_generate_signal( ...
        class.peakLatency + class.peakLatencyDv, ...
        class.peakWidth + class.peakWidthDv, ...
        class.peakAmplitude + class.peakAmplitudeDv, ...
        epochs.srate, epochs.length), 'b--');

if any([class.peakLatencySlope, class.peakWidthSlope, class.peakAmplitudeSlope])
   % with maximum slope applied
        % mean
        plot(x, erp_generate_signal(...
                class.peakLatency + class.peakLatencySlope, ...
                class.peakWidth + class.peakWidthSlope, ...
                class.peakAmplitude + class.peakAmplitudeSlope, ...
                epochs.srate, epochs.length), 'r-', 'LineWidth', 2);
    
        % min deviation
        plot(x, erp_generate_signal( ...
                class.peakLatency + class.peakLatencySlope - class.peakLatencyDv, ...
                class.peakWidth + class.peakWidthSlope - class.peakWidthDv, ...
                class.peakAmplitude + class.peakAmplitudeSlope - class.peakAmplitudeDv, ...
                epochs.srate, epochs.length), 'r:');
    
        % max deviation
        plot(x, erp_generate_signal( ...
                class.peakLatency + class.peakLatencySlope + class.peakLatencyDv, ...
                class.peakWidth + class.peakWidthSlope + class.peakWidthDv, ...
                class.peakAmplitude + class.peakAmplitudeSlope + class.peakAmplitudeDv, ...
                epochs.srate, epochs.length), 'r--');
end

end
