% [chanlocs, headmidpoint, rotationX, rotationZ, shift] = lf_fix_electrodes_pha(atlas, layout)
%       
%       Fixes the electrode recording such that the electrode grid fits
%       onto the standard head model
%
%       Assumes you have the requested Pediatric Head Atlas directories in
%       your MATLAB path. In particular, it needs the respective 
%       Sensors_*.txt files. 
%       As of 2018-02-05, the Pediatric Head Atlases are available upon 
%       request at https://pedeheadmod.net
%       
%       Pediatric Head Atlas publication:
%           Song, J., Morgan, K., Turovets, S., Li, K., Davey, C.,
%           Govyadinov, P., Tucker, D. M. (2013). Anatomically accurate
%           head models and their derivatives for dense array EEG source
%           localization. Functional Neurology, Rehabilitation, and
%           Ergonomics, 3(2-3), 275-293.
%
% In:
%       atlas - string indicating the atlas to use: '0to2', '4to8', or
%               '8to12'.
%       layout - string indicating which layout (i.e. number of channels)
%                to use: '128', '256', or '2562'. note: '256' is not 
%                available for atlas '0to2'. 
%
% Out: 
%       chanlocs          - the shifted, fixed channel locations to the
%                           given electrode file
%       headmidpoint      - the correct head midpoint, calculated from the
%                           fiducials
%       rotationX         - matrix for the rotation around the X-axis, such
%                           that the ears are on the same line
%       rotationZ         - matrix for the rotation around the Z-axis, such
%                           that the nose direction aligns with the
%                           corresponding axis
%       shift             - the hard-coded method to fit the electrode
%                           grid onto the standard EEGLAB head model
% Usage example:
%       >> [ch, hm, A1, A2, shift] = lf_fix_electrodes_pha('8to18', '2562')
% 
%                    Copyright 2018 Juliane Pawlitzki
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2018-03-22 First version jpaw

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
% along with SEREEGA.  If not, see <http://www.gnu.org/licenses

function [chans, hm, A1, A2, shift] = lf_fix_electrodes_pha(atlas, layout)
%% preparation

if strcmp(layout,'2562')
    layoutchan='generic';
else
    layoutchan=layout;
end
sensorfile = sprintf('Sensors_%s_%s.txt', atlas, layoutchan);
chanlocs = readlocs(sensorfile, 'filetype', 'sfp');

A1=eye(3);

%% shifting the head midpoint: all
%get fiducials
[~, chanidx] = ismember({'FidNz', 'FidT9', 'FidT10'}, {chanlocs.labels});
nas=[chanlocs(chanidx(1)).X, chanlocs(chanidx(1)).Y, chanlocs(chanidx(1)).Z];
lpa=[chanlocs(chanidx(2)).X, chanlocs(chanidx(2)).Y, chanlocs(chanidx(2)).Z];
rpa = [chanlocs(chanidx(3)).X, chanlocs(chanidx(3)).Y, chanlocs(chanidx(3)).Z];

%calculate head midpoint from fiducials
u = lpa-rpa;

e = u(1)*nas(1) + u(2)*nas(2) + u(3)*nas(3);
r = (e-u(1)*lpa(1)-u(2)*lpa(2)-u(3)*lpa(3))/(u(1)^2+u(2)^2+u(3)^2);

%new head midpoint
hm=lpa+r*u;

%shift all coordinates to the head midpoint as new origin
for i=1:length(chanlocs)
   chanlocs(i).X = chanlocs(i).X-hm(1); 
   chanlocs(i).Y = chanlocs(i).Y-hm(2);
   chanlocs(i).Z = chanlocs(i).Z-hm(3);
end

%% rotating along the x-axis (ears on same z): not 2562
if (~strcmp(layout,'2562'))
    %set new fiducials, shifted to the new head midpoint
    lpa = [chanlocs(chanidx(2)).Y, chanlocs(chanidx(2)).X, chanlocs(chanidx(2)).Z];
    rpa = [chanlocs(chanidx(3)).Y, chanlocs(chanidx(3)).X, chanlocs(chanidx(3)).Z];

    %determine the direction of shift
    if lpa(3)>rpa(3) 
        shift = 1;              %shift clockwise
    else
        shift = -1;
    end

    l=lpa; r=rpa;
    radl = norm(lpa);           %radius of lpa
    radr = norm(rpa);

    %set z, x
    l(3) = lpa(3)+(rpa(3)-lpa(3))/2;
    r(3) = rpa(3)+(lpa(3)-rpa(3))/2;

    l(1) = sign(lpa(1))*abs(sqrt(radl^2-lpa(2)^2-l(3)^2));
    r(1) = sign(rpa(1))*abs(sqrt(radr^2-rpa(2)^2-r(3)^2));

    %get rotation angles and define rotation matrix
    alpha1 = atan2d(norm(cross(l,lpa)),dot(l,lpa));
    alpha2 = atan2d(norm(cross(r,rpa)),dot(r,rpa));
    alpha=(alpha1+alpha2)/2;

    A1=[cosd(alpha),0,shift*sind(alpha);0,1,0;shift*-sind(alpha),0,cosd(alpha)];

    %rotate all coordinates by alpha, with A
    for i=1:length(chanlocs)
       chan=A1*[chanlocs(i).X; chanlocs(i).Y; chanlocs(i).Z];
       chanlocs(i).X=chan(1);
       chanlocs(i).Y=chan(2);
       chanlocs(i).Z=chan(3);
    end
end

%% rotating along the z-axis (direction of nose)
%set new fiducials, shifted to the new head midpoint
nas=[chanlocs(1).X, chanlocs(1).Y, chanlocs(1).Z];

if strcmp(layout,'2562')||strcmp(atlas, '0to2')
    [~, chanidx] = max([chanlocs.X]);
    nas = [chanlocs(chanidx).X, chanlocs(chanidx).Y, chanlocs(chanidx).Z];
end

alpha=90-atan2d(norm(cross(nas,[0,1,0])),dot(nas,[0,1,0]));
shiftdir=1;
if strcmp(atlas,'8to18')
    shiftdir=-1;
end

A2=[cosd(alpha), shiftdir*-sind(alpha), 0 ;shiftdir*sind(alpha),cosd(alpha), 0; 0,0,1];

%rotate all coordinates by alpha, with A
for i=1:length(chanlocs)
   chan=A2*[chanlocs(i).X; chanlocs(i).Y;chanlocs(i).Z];
   chanlocs(i).X=chan(1);
   chanlocs(i).Y=chan(2);
   chanlocs(i).Z=chan(3);
end

%% shift to the head model in the MNI plot
% brain volume extrema of standard EEGLAB MNI head model around which to
% fit current electrodes
minVal = [-71, -108, -63];
maxVal = [74, 77, 86];

chanX=[chanlocs.X];
chanY=[chanlocs.Y];
chanZ=[chanlocs.Z];

X = [min(chanX); max(chanX)];
Y = [min(chanY); max(chanY)];
Z = [min(chanZ); max(chanZ)];

if (strcmp(atlas,'0to2')&&strcmp(layout,'2562'))||(strcmp(atlas,'4to8')&&strcmp(layout,'2562'))
    % take second maximum instead of first, for datasets with wrong fiducials
    X = [min(chanX(chanX>min(chanX))); max(chanX(chanX<max(chanX)))];
    Y = [min(chanY(chanY>min(chanY))); max(chanY(chanY<max(chanY)))];
    Z = [min(chanZ(chanZ>min(chanZ))); max(chanZ(chanZ<max(chanZ)))];
end

Xshift = (X(2)+X(1))/2+15;

%shift between ears
Yshift = (Y(2)+Y(1))/2;

sf = (Y(2)-Yshift)/maxVal(2);       %scaling factor, obtained from Y

Zshift = -((maxVal(3)*sf)-Z(2));

for i=1:length(chanlocs)
   chanlocs(i).X = chanlocs(i).X-Xshift; 
   chanlocs(i).Y = chanlocs(i).Y-Yshift;
   chanlocs(i).Z = chanlocs(i).Z-Zshift;
end

shift=[Xshift,Yshift,Zshift];

%% completing chanlocs structure
chans = convertlocs(chanlocs, 'cart2all');


end
