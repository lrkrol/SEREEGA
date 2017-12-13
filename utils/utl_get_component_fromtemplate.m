% component = utl_get_component_fromtemplate(componentname, leadfield)
%
%       Returns a predefined component by its indicated name.
%
%       Note that, although components in this file are ideally supposed to
%       be generally valid, they may be constructed for different purposes
%       and/or in different contexts and may not behave as desired for your
%       particular purpose. Also note that they may have been designed for
%       different leadfields. In case of odd behaviour, see if e.g. the
%       normaliseLeadfield option of generate_scalpdata makes a difference.
%
%       If you construct a new component for your project that may be of
%       use to others as well, please feel free to extend the list of
%       templates and share it with the project.
%
% In:
%       componentname - string containing the desired component's name
%       leadfield - the leadfield with which the component will be used
%
% Out:  
%       component - the requested component
% 
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2017-12-01 First version

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

function component = utl_get_component_fromtemplate(componentname, leadfield)

switch componentname
    case 'visual_n70_erp'
        % visual evoked potential as per
        % - Pratt, H. (2011). Sensory ERP components. In S. J. Luck & E. S.
        %   Kappenman (Eds.), Oxford handbook of event-related potential 
        %   components (pp. 89–114). New York, NY: Oxford University Press.
        % - Gomez Gonzalez, C. M., Clark, V. P., Fan, S., Luck, S. J., & 
        %   Hillyard, S. A. (1994). Sources of attention-sensitive visual 
        %   event-related potentials. Brain Topography, 7(1), 41–51.
        erp_n70 = struct( ...
            'type', 'erp', ...
            'peakLatency', 70, ...
            'peakWidth', 60, ...
            'peakAmplitude', -7.5, ...
            'peakAmplitudeSlope', 2);
        erp_n70 = utl_check_class(erp_n70);
        erp_n70 = utl_set_dvslope(erp_n70, 'dv', .2);
        
        % projecting centrally from visual cortex
        comp_n70 = struct( ...
            'source', lf_get_source_nearest(leadfield, [0, -70, 0]), ...
            'signal', {{erp_n70}}, ...
            'orientation', [0 -1 0]);
        component = utl_check_component(comp_n70, leadfield);
                
    case 'visual_p100_erp'
        % visual evoked potential as per
        % - Pratt, H. (2011). Sensory ERP components. In S. J. Luck & E. S.
        %   Kappenman (Eds.), Oxford handbook of event-related potential 
        %   components (pp. 89–114). New York, NY: Oxford University Press.
        % - Gomez Gonzalez, C. M., Clark, V. P., Fan, S., Luck, S. J., & 
        %   Hillyard, S. A. (1994). Sources of attention-sensitive visual 
        %   event-related potentials. Brain Topography, 7(1), 41–51.
        erp_p100 = struct( ...
            'type', 'erp', ...
            'peakLatency', 100, ...
            'peakWidth', 60, ...
            'peakAmplitude', -7.5, ...
            'peakAmplitudeSlope', 2);
        erp_p100 = utl_check_class(erp_p100);
        erp_p100 = utl_set_dvslope(erp_p100, 'dv', .2);
        
        % projecting bilaterally from BA 17
        comp_p100 = struct( ...
            'source', {lf_get_source_nearest(leadfield, [-20, -78, -10]), ...  % left
                       lf_get_source_nearest(leadfield, [ 20, -78, -10])}, ... % right
            'signal', {{erp_p100}, {erp_p100}}, ...
            'orientation', {[-.5, .75, 0], [.5, .75, 0]});
        component = utl_check_component(comp_p100, leadfield);
                
    case 'visual_n135_erp'
        % visual evoked potential as per
        % - Pratt, H. (2011). Sensory ERP components. In S. J. Luck & E. S.
        %   Kappenman (Eds.), Oxford handbook of event-related potential 
        %   components (pp. 89–114). New York, NY: Oxford University Press.
        % - Gomez Gonzalez, C. M., Clark, V. P., Fan, S., Luck, S. J., & 
        %   Hillyard, S. A. (1994). Sources of attention-sensitive visual 
        %   event-related potentials. Brain Topography, 7(1), 41–51.
        erp_n135 = struct( ...
            'type', 'erp', ...
            'peakLatency', 135, ...
            'peakWidth', 100, ...
            'peakAmplitude', 10, ...
            'peakAmplitudeSlope', -3);
        erp_n135 = utl_check_class(erp_n135);
        erp_n135 = utl_set_dvslope(erp_n135, 'dv', .2);
        
        % projecting bilaterally from BA 18
        comp_n135 = struct( ...
            'source', {lf_get_source_nearest(leadfield, [-10, -88, 6]), ...    % left
                       lf_get_source_nearest(leadfield, [ 10, -88, 6])}, ...   % right
            'signal', {{erp_n135}, {erp_n135}}, ...
            'orientation', {[.5, .75, .25], [-.5, .75, .25]});
        component = utl_check_component(comp_n135, leadfield);
        
    case 'p300_erp'
        % P300, split into frontal P3a and parietal P3b  as mentioned in
        % - Polich, J. (2007). Updating P300: An integrative theory of P3a
        %    and P3b. Clinical Neurophysiology, 118(10), 2128–2148.
        % dipole locations after 
        % - Debener, S., Makeig, S., Delorme, A., & Engel, A. K. (2005). 
        %   What is novel in the novelty oddball paradigm? Functional 
        %   significance of the novelty P3 event-related potential as 
        %   revealed by independent component analysis. Cognitive Brain 
        %   Research, 22(3), 309–321.
        comp_p3a = utl_get_component_fromtemplate('p3a_erp', leadfield);
        comp_p3b = utl_get_component_fromtemplate('p3b_erp', leadfield);
        component = [comp_p3a, comp_p3b];
        
    case 'p3a_erp'
        % P300, split into frontal P3a and parietal P3b  as mentioned in
        % - Polich, J. (2007). Updating P300: An integrative theory of P3a
        %    and P3b. Clinical Neurophysiology, 118(10), 2128–2148.
        % dipole locations after 
        % - Debener, S., Makeig, S., Delorme, A., & Engel, A. K. (2005). 
        %   What is novel in the novelty oddball paradigm? Functional 
        %   significance of the novelty P3 event-related potential as 
        %   revealed by independent component analysis. Cognitive Brain 
        %   Research, 22(3), 309–321.
        % 50% slope simulating fatigue
        erp_p3a = struct( ...
            'type', 'erp', ...
            'peakLatency', 300, ...
            'peakWidth', 400, ...
            'peakAmplitude', 10, ...
            'peakAmplitudeSlope', -5);
        erp_p3a = utl_check_class(erp_p3a);
        erp_p3a = utl_set_dvslope(erp_p3a, 'dv', .2);
        
        comp_p3a = struct( ...
            'source', {lf_get_source_nearest(leadfield, [0, 5, 20])}, ...
            'signal', {{erp_p3a}}, ...
            'orientation', {[0 .5 1]});
        component = utl_check_component(comp_p3a, leadfield);
        
    case 'p3b_erp'
        % P300, split into frontal P3a and parietal P3b  as mentioned in
        % - Polich, J. (2007). Updating P300: An integrative theory of P3a
        %    and P3b. Clinical Neurophysiology, 118(10), 2128–2148.
        % dipole locations after 
        % - Debener, S., Makeig, S., Delorme, A., & Engel, A. K. (2005). 
        %   What is novel in the novelty oddball paradigm? Functional 
        %   significance of the novelty P3 event-related potential as 
        %   revealed by independent component analysis. Cognitive Brain 
        %   Research, 22(3), 309–321.
        % strong slope simulating habituation
        erp_p3b = struct( ...
            'type', 'erp', ...
            'peakLatency', [400, 500], ...
            'peakWidth', [600, 1000], ...
            'peakAmplitude', [7, 2], ...
            'peakAmplitudeSlope', [-5, -1]);
        erp_p3b = utl_check_class(erp_p3b);
        erp_p3b = utl_set_dvslope(erp_p3b, 'dv', .2);
        
        comp_p3b = struct( ...
            'source', {lf_get_source_nearest(leadfield, [0, -50, 40])}, ...
            'signal', {{erp_p3b}}, ...
            'orientation', {[0 -.5 1]});
        component = utl_check_component(comp_p3b, leadfield);
        
    case 'motorcortex_left_mu_rest_ersp'
        % continuous mu-band activity over left motor cortex
        ersp_mcl_mu = struct( ...
            'type', 'ersp', ...
            'frequency', [8 12], ...
            'amplitude', 3, ...
            'modulation', 'none');
        ersp_mcl_mu = utl_check_class(ersp_mcl_mu);
        ersp_mcl_mu = utl_set_dvslope(ersp_mcl_mu, 'dv', .1);

        comp_mcl = struct( ...
            'source', lf_get_source_nearest(leadfield, [-15, -10, 60]), ...
            'signal', {{ersp_mcl_mu}}, ...
            'orientation', [-1, 0, .5]);
        component = utl_check_component(comp_mcl, leadfield);
        
    case 'motorcortex_left_mu_desynch_ersp'
        % mu-band activity over left motor cortex with a 600 ms desynch
        % starting at 350 ms
        ersp_mcl_mu = struct( ...
            'type', 'ersp', ...
            'frequency', [8 12], ...
            'amplitude', 3, ...
            'modulation', 'invburst', ...
            'modLatency', 650, ...
            'modWidth', 600, ...
            'modTaper', .5, ...
            'modMinAmplitude', .5);
        ersp_mcl_mu = utl_check_class(ersp_mcl_mu);
        ersp_mcl_mu = utl_set_dvslope(ersp_mcl_mu, 'dv', .1);
        ersp_mcl_mu.modLatencyDv = 100;

        comp_mcl = struct( ...
            'source', lf_get_source_nearest(leadfield, [-15, -10, 60]), ...
            'signal', {{ersp_mcl_mu}}, ...
            'orientation', [-1, 0, .5]);
        component = utl_check_component(comp_mcl, leadfield);
        
    case 'motorcortex_right_mu_rest_ersp'
        % continuous mu-band activity over right motor cortex
        ersp_mcr_mu = struct( ...
            'type', 'ersp', ...
            'frequency', [8 12], ...
            'amplitude', 3, ...
            'modulation', 'none');
        ersp_mcr_mu = utl_check_class(ersp_mcr_mu);
        ersp_mcr_mu = utl_set_dvslope(ersp_mcr_mu, 'dv', .1);

        comp_mcr = struct( ...
            'source', lf_get_source_nearest(leadfield, [15, -10, 60]), ...
            'signal', {{ersp_mcr_mu}}, ...
            'orientation', [1, 0, .5]);
        component = utl_check_component(comp_mcr, leadfield);
        
    case 'motorcortex_right_mu_desynch_ersp'
        % mu-band activity over right motor cortex with a 600 ms desynch
        % starting at 350 ms
        ersp_mcr_mu = struct( ...
            'type', 'ersp', ...
            'frequency', [8 12], ...
            'amplitude', 3, ...
            'modulation', 'invburst', ...
            'modLatency', 650, ...
            'modWidth', 600, ...
            'modTaper', .5, ...
            'modMinAmplitude', .5);
        ersp_mcr_mu = utl_check_class(ersp_mcr_mu);
        ersp_mcr_mu = utl_set_dvslope(ersp_mcr_mu, 'dv', .1);
        ersp_mcr_mu.modLatencyDv = 100;

        comp_mcr = struct( ...
            'source', lf_get_source_nearest(leadfield, [15, -10, 60]), ...
            'signal', {{ersp_mcr_mu}}, ...
            'orientation', [1, 0, .5]);
        component = utl_check_component(comp_mcr, leadfield);
        
    otherwise
        error('component ''%s'' not found', componentname);
end

end