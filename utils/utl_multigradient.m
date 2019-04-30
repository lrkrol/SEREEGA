% map = multigradient(rgb[, pts, varargin])
%
%       Returns a custom or preset colour map generated from the indicated
%       colours anchored at optional control points (colour stops), with
%       their relative positions intact, and gradients between them. 
%
% In:
%       rgb - n-by-3 matrix of rgb color values
%
% Optional:
%       pts - vector of length n indicating the relative positions of
%             the colour control points corresponding to the given rgb 
%             colours. one control point is necessary for each colour. 
%             exception: when there are two colours in rgb, three control 
%             points can be indicated to represent the middle point. 
%             default: all colours are equally spaced
%       
% Optional (key-value pairs):
%       interp - which color representation to use for interpolation:
%                'rgb' - linear interpolation in RGB space (default)
%                'hsv' - linear interpolation in HSV space
%                'labiso' - linear interpolation in L*a*b* space after
%                           first equalising all L* values by taking their
%                           mean, resulting in an isoluminant colour map.
%                           note that conversion back to RGB may induce
%                           colour clipping due to gamut differences.
%                'mshdiv' - linear interpolation in Kenneth Moreland's Msh
%                           space for diverging colour maps. mshdiv
%                           requires exactly two input colours. when these
%                           are sufficiently distinct, a neutral middle
%                           colour will be automatically inserted.
%                           see: Moreland, K. (2009). "Diverging color maps
%                           for scientific visualization". In Proceedings
%                           of the 5th International Symposium on Visual
%                           Computing. doi: 10.1007/978-3-642-10520-3_9
%       length - the length of the colormap. default: length of the current
%                figure's colormap
%       preset - which preset to use. when this argument is used, the rgb
%                argument is ignored and can be left out. to use the pts
%                argument, use it as a key-value pair
%       reverse - whether or not to reverse the colormap (0|1, default 0)
%
% Out:
%       map - the generated colormap as a length-by-3 matrix of rgb values
%
% Usage example:
%       To create a simple black-red-yellow-white colormap, we would put
%       those colours in that order as the first argument:
%       >> figure; imagesc(sort(rand(100), 'descend')); colorbar;
%       >> rgb = [0 0 0; 1 0 0; 1 1 0; 1 1 1];
%       >> colormap(multigradient(rgb));
%
%       It is possible to change the relative location of the colours by
%       adjusting the relative values of the colour stops, one for each
%       indicated colour:
%       >> pts = [1 5 6 7];
%       >> colormap(multigradient(rgb, pts));
%
%       Many presets are available. Kenneth Moreland suggests using the 
%       following diverging colour map for scientific visualisation:
%       >> colormap(multigradient('preset', 'div.km.BuRd'));
%
%                       Copyright 2018, 2019 Laurens R Krol
%                       lrkrol.com

% 2019-02-07 v1.5.4 lrk
%   - Added preset: div.RdYlGn
% 2019-01-18 v1.5.3 lrk
%   - Updated preset naming convention
%   - Reversed div.cb colours to maintain cold -> warm consistency
%   - Code clean-up
% 2019-01-17 v1.5.0 lrk
%   - Added L*a*b* isoluminant interpolation (labiso)
%   - Added Msh divergent interpolation (mshdiv)
%   - Added preset argument with some initial presets
%   - Added reverse argument
%   - Enabled middle control point for two-colour maps
%   - Switched to semantic versioning; this is v1.5.0
% 2018-07-14 First version

% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

% This product includes color specifications and designs developed by
% Cynthia Brewer (http://colorbrewer.org/). Those specifications are
% Copyright (c) 2002 Cynthia Brewer, Mark Harrower, and The Pennsylvania 
% State University. Licensed under the Apache License, Version 2.0.

function map = multigradient(rgb, varargin)

p = inputParser;

addOptional(p, 'rgb', @(rgb) (isnumeric(rgb) && size(rgb,2) == 3));
addOptional(p, 'pts', [], @isnumeric);
addParameter(p, 'preset', '', @ischar);
addParameter(p, 'interp', 'rgb', @(interp) any(validatestring(interp,{'rgb', 'hsv', 'labiso', 'mshdiv'})));
addParameter(p, 'length', [], @isnumeric);
addParameter(p, 'reverse', 0, @isnumeric);

parse(p, rgb, varargin{:});
rgb = p.Results.rgb;
pts = p.Results.pts;
preset = p.Results.preset;
interp = p.Results.interp;
length = p.Results.length;
reverse = p.Results.reverse;

if ~isempty(preset), [rgb, interp] = getpreset(preset); end
if isempty(pts), pts = 1:size(rgb,1); end
if isempty(length), length = size(get(gcf,'colormap'),1); end
if reverse, rgb = flipud(rgb); end

% mapping control points to map length
pts = maptorange_local(pts, [min(pts), max(pts)], [1, length]);

if strcmp(interp, 'rgb')
    % interpolating RGB directly
    rgb = insertcontrolpoint(rgb, pts);
    map = interp1(pts, rgb, 1:length);
elseif strcmp(interp, 'hsv')
    % converting to HSV
    hsv = rgb2hsv(rgb);
    
    hsv = insertcontrolpoint(hsv, pts);
    
    % interpolating, converting back
    maphsv = interp1(pts, hsv, 1:length);
    map = hsv2rgb(maphsv);
elseif strcmp(interp, 'labiso')
    % converting to L*a*b*, fixing luminance to mean of given colours
    lab = rgb2lab(rgb);
    lab(:,1) = mean(lab(:,1));
    
    lab = insertcontrolpoint(lab, pts);
        
    % interpolating, converting back to RGB
    maplab = interp1(pts, lab, 1:length);
    map = lab2rgb(maplab);
    map = fixgamut(map);
elseif strcmp(interp, 'mshdiv')
    if size(rgb, 1) ~= 2
        warning('mshdiv interpolation requires exactly two input colours; switching to rgb interpolation');
        rgb = insertcontrolpoint(rgb, pts);
        map = interp1(pts, rgb, 1:length);
    else
        % converting to Msh
        lab = rgb2lab(rgb);
        msh = [rssq(lab')', acos(lab(:,1) ./ rssq(lab')'), atan2(lab(:,3), lab(:,2))];

        % adding neutral middle colour if endpoint colours are sufficiently distinct
        if msh(1,2) > 0.05 && msh(2,2) > 0.05 && acos(dot([cos(msh(1,3)) sin(msh(1,3))],[cos(msh(2,3)) sin(msh(2,3))])) > pi/3
            
            % getting neutral M
            Mmid = max([msh(1,1), msh(2,1), 88]);
            
            % getting neutral h spin, separately for both endpoint colours
            if msh(1,1) < Mmid
                huespin1 = (msh(1,2) * sqrt(Mmid^2 - msh(1,1)^2)) / (msh(1,1) * sin(msh(1,2)));
                if msh(1,3) < -pi/3, huespin1 = -huespin1; end
            else
                huespin1 = 0;
            end

            if msh(2,1) < Mmid
                huespin2 = (msh(2,2) * sqrt(Mmid^2 - msh(2,1)^2)) / (msh(2,1) * sin(msh(2,2)));
                if msh(2,3) < -pi/3, huespin2 = -huespin2; end
            else
                huespin2 = 0;
            end

            % setting four-colour gradient with matching control points:
            % startcol -> neutral(hue.start) | neutral(hue.end) -> endcol
            msh = [msh(1,:); Mmid 0 msh(1,3) + huespin1; Mmid 0 msh(2,3) + huespin2; msh(2,:)];
            if numel(pts) == 2, pts = maptorange_local(1:3, [1 3], [1, length]); end                
            pts = [pts(1), pts(2)-0.00001, pts(2)+0.00001, pts(3)];
        end
        
        msh = insertcontrolpoint(msh, pts);

        % interpolating, converting back to RGB
        mapmsh = interp1(pts, msh, 1:length);
        maplab = [mapmsh(:,1) .* cos(mapmsh(:,2)), mapmsh(:,1) .* sin(mapmsh(:,2)) .* cos(mapmsh(:,3)), mapmsh(:,1) .* sin(mapmsh(:,2)) .* sin(mapmsh(:,3))];
        map = lab2rgb(maplab);        
        map = fixgamut(map);
    end
end

end


function targetvalue = maptorange_local(sourcevalue, sourcerange, targetrange)

% limited local version of maptorange;
% see github.com/lrkrol/maptorange for full functionality

if numel(sourcevalue) > 1
    % recursively calling this function
    for i = 1:length(sourcevalue)
        sourcevalue(i) = maptorange_local(sourcevalue(i), sourcerange, targetrange);
        targetvalue = sourcevalue;
    end
else
    % converting source value into a percentage
    sourcespan = sourcerange(2) - sourcerange(1);
    if sourcespan == 0, error('Zero-length source range'); end
    valuescaled = (sourcevalue - sourcerange(1)) / sourcespan;

    % taking given percentage of target range as target value
    targetspan = targetrange(2) - targetrange(1);
    targetvalue = targetrange(1) + (valuescaled * targetspan);
end

end


function colours = insertcontrolpoint(colours, pts)

% inserting mean middle colour when three control points are indicated for
% a two-colour map

if size(colours,1) == 2 && numel(pts) == 3
    colours = [colours(1,:); mean(colours,1); colours(2,:)];
end

end


function map = fixgamut(map)

% when converting back from L*a*b*, some colours can be beyond the gamut

if any(map(:) < 0) || any(map(:) > 1)
    diffneg = abs(min(map(map < 0)));
    diffpos = max(map(map > 1));
    if max(diffneg, diffpos) > .01
        warning('colour clipping: some interpolated colours are up to %.3f beyond the RGB gamut', max(diffneg,diffpos));
    end
    map(map < 0) = 0;
    map(map > 1) = 1;
end

end


function [rgb, interp] = getpreset(preset)

% (figured I'd move the huge wall of numbers to the back of the script)

% naming convention: type.source.colours.variation, where:
% type: either seq (sequential) or div (diverging); this script is not
%       meant for qualitative colour maps.
% source: if applicable, the source of the colour map, e.g. a person's 
%         initials or an organisation's abbreviation, etc. leave out if no
%         specific source can be identified.
% colours: a description of the colours used in the colour map, from low to
%          high values. use the following abbreviations:
%          Bk = Black
%          Br = Brown
%          Bu = Blue
%          Gn = Green
%          Gy = Grey
%          Or = Orange
%          Pi = Pink
%          Pu = Purple
%          Rd = Red
%          Tn = Tan
%          Tq = Turquoise
%          Wh = White
%          Yl = Yellow
% variation: optional descriptor of the colour map, to be used to
%            distinguish between two or more colour maps that would
%            otherwise have the same name. for example, the div.cb maps
%            come in different variations, characterised by the different
%            number of colours used.

switch preset
    case 'seq.BkWh' % black-white
        rgb = [0 0 0; 1 1 1];
        interp = 'rgb';
    case 'div.GnYlRd' % green-yellow-red RGB
        rgb = [0 .8 0; .9 .9 0; .9 0 0];
        interp = 'rgb';
    case 'div.RdYlGn' % red-yellow-green RGB
        rgb = [.9 0 0; .9 .9 0; 0 .8 0];
        interp = 'rgb';
        
    case 'div.GnRd.iso' % isoluminant green-red
        rgb = [0 .8 0; .8 0 0];
        interp = 'labiso';
    case 'div.BuPi.iso' % isoluminant blue-pink
        rgb = [0 153 191; 192 119 87] / 255;
        interp = 'labiso';
        
    % for colours by Kenneth Moreland, see kennethmoreland.com
    case 'div.km.BuRd' % divergent blue-red, by Kenneth Moreland
        rgb = [0.230, 0.299, 0.754; 0.706, 0.016, 0.150];
        interp = 'mshdiv';
    case 'div.km.PuOr' % divergent purple-orange, by Kenneth Moreland
        rgb = [0.436, 0.308, 0.631; 0.759, 0.334, 0.046];
        interp = 'mshdiv';
    case 'div.km.GnPu' % divergent green-purple, by Kenneth Moreland
        rgb = [0.085, 0.532, 0.201; 0.436, 0.308, 0.631];
        interp = 'mshdiv';
    case 'div.km.BuTn' % divergent blue-tan, by Kenneth Moreland
        rgb = [0.217, 0.525, 0.910; 0.677, 0.492, 0.093];
        interp = 'mshdiv';
    case 'div.km.GnRd' % divergent green-red, by Kenneth Moreland
        rgb = [0.085, 0.532, 0.201; 0.758, 0.214, 0.233];
        interp = 'mshdiv';
        
    % for colours by Cynthia Brewer, see colorbrewer.org
    case 'seq.cb.YlGn.3' % 3-colour sequential YlGn, by Cynthia Brewer
        rgb = [247 252 185; 173 221 142; 49 163 84] / 255;
        interp = 'rgb';
    case 'seq.cb.YlGn.6' % 6-colour sequential YlGn, by Cynthia Brewer
        rgb = [255 255 204; 217 240 163; 173 221 142; 120 198 121; 49 163 84; 0 104 55] / 255;
        interp = 'rgb';
    case 'seq.cb.YlGn.9' % 9-colour sequential YlGn, by Cynthia Brewer
        rgb = [255 255 229; 247 252 185; 217 240 163; 173 221 142; 120 198 121; 65 171 93; 35 132 67; 0 104 55; 0 69 41] / 255;
        interp = 'rgb';
        
    case 'seq.cb.YlGn.Bu3' % 3-colour sequential YlGnBu, by Cynthia Brewer
        rgb = [237 248 177; 127 205 187; 44 127 184] / 255;
        interp = 'rgb';
    case 'seq.cb.YlGn.Bu6' % 6-colour sequential YlGnBu, by Cynthia Brewer
        rgb = [255 255 204; 199 233 180; 127 205 187; 65 182 196; 44 127 184; 37 52 148] / 255;
        interp = 'rgb';
    case 'seq.cb.YlGn.Bu9' % 9-colour sequential YlGnBu, by Cynthia Brewer
        rgb = [255 255 217; 237 248 177; 199 233 180; 127 205 187; 65 182 196; 29 145 192; 34 94 168; 37 52 148; 8 29 88] / 255;
        interp = 'rgb';
        
    case 'seq.cb.PuBuGn.3' % 3-colour sequential PuBuGn, by Cynthia Brewer
        rgb = [236 226 240; 166 189 219; 28 144 153] / 255;
        interp = 'rgb';
    case 'seq.cb.PuBuGn.6' % 6-colour sequential PuBuGn, by Cynthia Brewer
        rgb = [246 239 247; 208 209 230; 166 189 219; 103 169 207; 28 144 153; 1 108 89] / 255;
        interp = 'rgb';
    case 'seq.cb.PuBuGn.9' % 9-colour sequential PuBuGn, by Cynthia Brewer
        rgb = [255 247 251; 236 226 240; 208 209 230; 166 189 219; 103 169 207; 54 144 192; 2 129 138; 1 108 89; 1 70 54] / 255;
        interp = 'rgb';
        
    case 'seq.cb.BuPu.3' % 3-colour sequential BuPu, by Cynthia Brewer
        rgb = [224 236 244; 158 188 218; 136 86 167] / 255;
        interp = 'rgb';
    case 'seq.cb.BuPu.6' % 6-colour sequential BuPu, by Cynthia Brewer
        rgb = [237 248 251; 191 211 230; 158 188 218; 140 150 198; 136 86 167; 129 15 124] / 255;
        interp = 'rgb';
    case 'seq.cb.BuPu.9' % 9-colour sequential BuPu, by Cynthia Brewer
        rgb = [247 252 253; 224 236 244; 191 211 230; 158 188 218; 140 150 198; 140 107 177; 136 65 157; 129 15 124; 77 0 75] / 255;
        interp = 'rgb';
        
    case 'seq.cb.RdPu.3' % 3-colour sequential RdPu, by Cynthia Brewer
        rgb = [253 224 221; 250 159 181; 197 27 138] / 255;
        interp = 'rgb';
    case 'seq.cb.RdPu.6' % 6-colour sequential RdPu, by Cynthia Brewer
        rgb = [254 235 226; 252 197 192; 250 159 181; 247 104 161; 197 27 138; 122 1 119] / 255;
        interp = 'rgb';
    case 'seq.cb.RdPu.9' % 9-colour sequential RdPu, by Cynthia Brewer
        rgb = [255 247 243; 253 224 221; 252 197 192; 250 159 181; 247 104 161; 221 52 151; 174 1 126; 122 1 119; 73 0 106] / 255;
        interp = 'rgb';
        
    case 'seq.cb.OrRd.3' % 3-colour sequential OrRd, by Cynthia Brewer
        rgb = [254 232 200; 253 187 132; 227 74 51] / 255;
        interp = 'rgb';
    case 'seq.cb.OrRd.6' % 6-colour sequential OrRd, by Cynthia Brewer
        rgb = [254 240 217; 253 212 158; 253 187 132; 252 141 89; 227 74 51; 179 0 0] / 255;
        interp = 'rgb';
    case 'seq.cb.OrRd.9' % 9-colour sequential OrRd, by Cynthia Brewer
        rgb = [255 247 236; 254 232 200; 253 212 158; 253 187 132; 252 141 89; 239 101 72; 215 48 31; 179 0 0; 127 0 0] / 255;
        interp = 'rgb';
        
    case 'seq.cb.YlOrBr.3' % 3-colour sequential YlOrBr, by Cynthia Brewer
        rgb = [255 247 188; 254 196 79; 217 95 14] / 255;
        interp = 'rgb';
    case 'seq.cb.YlOrBr.6' % 6-colour sequential YlOrBr, by Cynthia Brewer
        rgb = [255 255 212; 254 227 145; 254 196 79; 254 153 41; 217 95 14; 153 52 4] / 255;
        interp = 'rgb';
    case 'seq.cb.YlOrBr.9' % 9-colour sequential YlOrBr, by Cynthia Brewer
        rgb = [255 255 229; 255 247 188; 254 227 145; 254 196 79; 254 153 41; 236 112 20; 204 76 2; 153 52 4; 102 37 6] / 255;
        interp = 'rgb';
        
    % for diverging colour maps, note that a map with an odd number of 
    % colours will have a explicitly defined neutral middle colour, whereas
    % even-numbered maps will not
    case 'div.cb.PuOr.3' % 3-colour diverging PuOr, by Cynthia Brewer
        rgb = [241 163 64; 247 247 247; 153 142 195] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
    case 'div.cb.PuOr.4' % 4-colour diverging PuOr, by Cynthia Brewer
        rgb = [230 97 1; 253 184 99; 178 171 210; 94 60 153] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
    case 'div.cb.PuOr.6' % 6-colour diverging PuOr, by Cynthia Brewer
        rgb = [179 88 6; 241 163 64; 254 224 182; 216 218 235; 153 142 195; 84 39 136] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
    case 'div.cb.PuOr.7' % 7-colour diverging PuOr, by Cynthia Brewer
        rgb = [179 88 6; 241 163 64; 254 224 182; 247 247 247; 216 218 235; 153 142 195; 84 39 136] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
    case 'div.cb.PuOr.9' % 9-colour diverging PuOr, by Cynthia Brewer
        rgb = [179 88 6; 224 130 20; 253 184 99; 254 224 182; 247 247 247; 216 218 235; 178 171 210; 128 115 172; 84 39 136] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
    case 'div.cb.PuOr.10' % 10-colour diverging PuOr, by Cynthia Brewer
        rgb = [127 59 8; 179 88 6; 224 130 20; 253 184 99; 254 224 182; 216 218 235; 178 171 210; 128 115 172; 84 39 136; 45 0 75] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
        
    case 'div.cb.TqBr.3' % 3-colour diverging TqBr, by Cynthia Brewer
        rgb = [216 179 101; 245 245 245; 90 180 172] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
    case 'div.cb.TqBr.4' % 4-colour diverging TqBr, by Cynthia Brewer
        rgb = [166 97 26; 223 194 125; 128 205 193; 1 133 113] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
    case 'div.cb.TqBr.6' % 6-colour diverging TqBr, by Cynthia Brewer
        rgb = [140 81 10; 216 179 101; 246 232 195; 199 234 229; 90 180 172; 1 102 94] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
    case 'div.cb.TqBr.7' % 7-colour diverging TqBr, by Cynthia Brewer
        rgb = [140 81 10; 216 179 101; 246 232 195; 245 245 245; 199 234 229; 90 180 172; 1 102 94] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
    case 'div.cb.TqBr.9' % 9-colour diverging TqBr, by Cynthia Brewer
        rgb = [140 81 10; 191 129 45; 223 194 125; 246 232 195; 245 245 245; 199 234 229; 128 205 193; 53 151 143; 1 102 94] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
    case 'div.cb.TqBr.10' % 10-colour diverging TqBr, by Cynthia Brewer
        rgb = [84 48 5; 140 81 10; 191 129 45; 223 194 125; 246 232 195; 199 234 229; 128 205 193; 53 151 143; 1 102 94; 0 60 48] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
        
    case 'div.cb.GnPu.3' % 3-colour diverging GnPu, by Cynthia Brewer
        rgb = [175 141 195; 247 247 247; 127 191 123] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
    case 'div.cb.GnPu.4' % 4-colour diverging GnPu, by Cynthia Brewer
        rgb = [123 50 148; 194 165 207; 166 219 160; 0 136 55] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
    case 'div.cb.GnPu.6' % 6-colour diverging GnPu, by Cynthia Brewer
        rgb = [118 42 131; 175 141 195; 231 212 232; 217 240 211; 127 191 123; 27 120 55] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
    case 'div.cb.GnPu.7' % 7-colour diverging GnPu, by Cynthia Brewer
        rgb = [118 42 131; 175 141 195; 231 212 232; 247 247 247; 217 240 211; 127 191 123; 27 120 55] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
    case 'div.cb.GnPu.9' % 9-colour diverging GnPu, by Cynthia Brewer
        rgb = [118 42 131; 153 112 171; 194 165 207; 231 212 232; 247 247 247; 217 240 211; 166 219 160; 90 174 97; 27 120 55] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
    case 'div.cb.GnPu.10' % 10-colour diverging GnPu, by Cynthia Brewer
        rgb = [64 0 75; 118 42 131; 153 112 171; 194 165 207; 231 212 232; 217 240 211; 166 219 160; 90 174 97; 27 120 55; 0 68 27] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
        
    case 'div.cb.GnPi.3' % 3-colour diverging GnPi, by Cynthia Brewer
        rgb = [233 163 201; 247 247 247; 161 215 106] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
    case 'div.cb.GnPi.4' % 4-colour diverging GnPi, by Cynthia Brewer
        rgb = [208 28 139; 241 182 218; 184 225 134; 77 172 38] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
    case 'div.cb.GnPi.6' % 6-colour diverging GnPi, by Cynthia Brewer
        rgb = [197 27 125; 233 163 201; 253 224 239; 230 245 208; 161 215 106; 77 146 33] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
    case 'div.cb.GnPi.7' % 7-colour diverging GnPi, by Cynthia Brewer
        rgb = [197 27 125; 233 163 201; 253 224 239; 247 247 247; 230 245 208; 161 215 106; 77 146 33] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
    case 'div.cb.GnPi.9' % 9-colour diverging GnPi, by Cynthia Brewer
        rgb = [197 27 125; 222 119 174; 241 182 218; 253 224 239; 247 247 247; 230 245 208; 184 225 134; 127 188 65; 77 146 33] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
    case 'div.cb.GnPi.10' % 10-colour diverging GnPi, by Cynthia Brewer
        rgb = [142 1 82; 197 27 125; 222 119 174; 241 182 218; 253 224 239; 230 245 208; 184 225 134; 127 188 65; 77 146 33; 39 100 25] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
        
    case 'div.cb.BuRd.3' % 3-colour diverging BuRd, by Cynthia Brewer
        rgb = [239 138 98; 247 247 247; 103 169 207] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
    case 'div.cb.BuRd.4' % 4-colour diverging BuRd, by Cynthia Brewer
        rgb = [202 0 32; 244 165 130; 146 197 222; 5 113 176] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
    case 'div.cb.BuRd.6' % 6-colour diverging BuRd, by Cynthia Brewer
        rgb = [178 24 43; 239 138 98; 253 219 199; 209 229 240; 103 169 207; 33 102 172] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
    case 'div.cb.BuRd.7' % 7-colour diverging BuRd, by Cynthia Brewer
        rgb = [178 24 43; 239 138 98; 253 219 199; 247 247 247; 209 229 240; 103 169 207; 33 102 172] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
    case 'div.cb.BuRd.9' % 9-colour diverging BuRd, by Cynthia Brewer
        rgb = [178 24 43; 214 96 77; 244 165 130; 253 219 199; 247 247 247; 209 229 240; 146 197 222; 67 147 195; 33 102 172] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
    case 'div.cb.BuRd.10' % 10-colour diverging BuRd, by Cynthia Brewer
        rgb = [103 0 31; 178 24 43; 214 96 77; 244 165 130; 253 219 199; 209 229 240; 146 197 222; 67 147 195; 33 102 172; 5 48 97] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
        
    case 'div.cb.GyRd.3' % 3-colour diverging GyRd, by Cynthia Brewer
        rgb = [239 138 98; 255 255 255; 153 153 153] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
    case 'div.cb.GyRd.4' % 4-colour diverging GyRd, by Cynthia Brewer
        rgb = [202 0 32; 244 165 130; 186 186 186; 64 64 64] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
    case 'div.cb.GyRd.6' % 6-colour diverging GyRd, by Cynthia Brewer
        rgb = [178 24 43; 239 138 98; 253 219 199; 224 224 224; 153 153 153; 77 77 77] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
    case 'div.cb.GyRd.7' % 7-colour diverging GyRd, by Cynthia Brewer
        rgb = [178 24 43; 239 138 98; 253 219 199; 255 255 255; 224 224 224; 153 153 153; 77 77 77] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
    case 'div.cb.GyRd.9' % 9-colour diverging GyRd, by Cynthia Brewer
        rgb = [178 24 43; 214 96 77; 244 165 130; 253 219 199; 255 255 255; 224 224 224; 186 186 186; 135 135 135; 77 77 77] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
    case 'div.cb.GyRd.10' % 10-colour diverging GyRd, by Cynthia Brewer
        rgb = [103 0 31; 178 24 43; 214 96 77; 244 165 130; 253 219 199; 224 224 224; 186 186 186; 135 135 135; 77 77 77; 26 26 26] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
        
    case 'div.cb.BuYlRd.3' % 3-colour diverging BuYlRd, by Cynthia Brewer
        rgb = [252 141 89; 255 255 191; 145 191 219] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
    case 'div.cb.BuYlRd.4' % 4-colour diverging BuYlRd, by Cynthia Brewer
        rgb = [215 25 28; 253 174 97; 171 217 233; 44 123 182] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
    case 'div.cb.BuYlRd.6' % 6-colour diverging BuYlRd, by Cynthia Brewer
        rgb = [215 48 39; 252 141 89; 254 224 144; 224 243 248; 145 191 219; 69 117 180] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
    case 'div.cb.BuYlRd.7' % 7-colour diverging BuYlRd, by Cynthia Brewer
        rgb = [215 48 39; 252 141 89; 254 224 144; 255 255 191; 224 243 248; 145 191 219; 69 117 180] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
    case 'div.cb.BuYlRd.9' % 9-colour diverging BuYlRd, by Cynthia Brewer
        rgb = [215 48 39; 244 109 67; 253 174 97; 254 224 144; 255 255 191; 224 243 248; 171 217 233; 116 173 209; 69 117 180] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
    case 'div.cb.BuYlRd.10' % 10-colour diverging BuYlRd, by Cynthia Brewer
        rgb = [165 0 38; 215 48 39; 244 109 67; 253 174 97; 254 224 144; 224 243 248; 171 217 233; 116 173 209; 69 117 180; 49 54 149] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
        
    case 'div.cb.spectral.3' % 3-colour diverging spectral, by Cynthia Brewer
        rgb = [252 141 89; 255 255 191; 153 213 148] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
    case 'div.cb.spectral.4' % 4-colour diverging spectral, by Cynthia Brewer
        rgb = [215 25 28; 253 174 97; 171 221 164; 43 131 186] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
    case 'div.cb.spectral.6' % 6-colour diverging spectral, by Cynthia Brewer
        rgb = [213 62 79; 252 141 89; 254 224 139; 230 245 152; 153 213 148; 50 136 189] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
    case 'div.cb.spectral.7' % 7-colour diverging spectral, by Cynthia Brewer
        rgb = [213 62 79; 252 141 89; 254 224 139; 255 255 191; 230 245 152; 153 213 148; 50 136 189] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
    case 'div.cb.spectral.9' % 9-colour diverging spectral, by Cynthia Brewer
        rgb = [213 62 79; 244 109 67; 253 174 97; 254 224 139; 255 255 191; 230 245 152; 171 221 164; 102 194 165; 50 136 189] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
    case 'div.cb.spectral.10' % 10-colour diverging spectral, by Cynthia Brewer
        rgb = [158 1 66; 213 62 79; 244 109 67; 253 174 97; 254 224 139; 230 245 152; 171 221 164; 102 194 165; 50 136 189; 94 79 162] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
        
    case 'div.cb.GnYlRd.3' % 3-colour diverging GnYlRd, by Cynthia Brewer
        rgb = [252 141 89; 255 255 191; 145 207 96] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
    case 'div.cb.GnYlRd.4' % 4-colour diverging GnYlRd, by Cynthia Brewer
        rgb = [215 25 28; 253 174 97; 166 217 106; 26 150 65] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
    case 'div.cb.GnYlRd.6' % 6-colour diverging GnYlRd, by Cynthia Brewer
        rgb = [215 48 39; 252 141 89; 254 224 139; 217 239 139; 145 207 96; 26 152 80] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
    case 'div.cb.GnYlRd.7' % 7-colour diverging GnYlRd, by Cynthia Brewer
        rgb = [215 48 39; 252 141 89; 254 224 139; 255 255 191; 217 239 139; 145 207 96; 26 152 80] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
    case 'div.cb.GnYlRd.9' % 9-colour diverging GnYlRd, by Cynthia Brewer
        rgb = [215 48 39; 244 109 67; 253 174 97; 254 224 139; 255 255 191; 217 239 139; 166 217 106; 102 189 99; 26 152 80] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
    case 'div.cb.GnYlRd.10' % 10-colour diverging GnYlRd, by Cynthia Brewer
        rgb = [165 0 38; 215 48 39; 244 109 67; 253 174 97; 254 224 139; 217 239 139; 166 217 106; 102 189 99; 26 152 80; 0 104 55] / 255;
        rgb = flipud(rgb);
        interp = 'rgb';
        
    otherwise
        error('preset ''%s'' not found', preset);
end

end