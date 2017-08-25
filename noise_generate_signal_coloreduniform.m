
% This file is part of Simulating Event-Related EEG Activity (SEREEGA),
% but has been taken from another source. 
% Original filename: f_alpha_uniform.m
% Original author: Miroslav Stoyanov, Oak Ridge National Laboratory, 
%                  mkstoyanov@gmail.com. 
% Original source: https://people.sc.fsu.edu/~jburkardt/m_src/cnoise/cnoise.html
% The file has not been modified except for these and the following initial
% comments.

% License for this file:

% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU Lesser General Public License as published 
% by the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU Lesser General Public License for more details.
% 
% You should have received a copy of the GNU Lesser General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

% License for SEREEGA:

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

function [ x ] = noise_generate_signal_coloreduniform( n, range, alpha )

% Purpose:
%     Generates a discrete colored noise vector of size n with power 
%     spectrum distribution of alpha
%     White noise is sampled from Uniform (-range,range) distribution
%
% Usage:
%        [ x ] = f_alpha_uniform( n, range, alpha )
%     
%     n - problem size
%     range - range of the underlying Uniform distribution
%     alpha - resulting colored noise has 1/f^alpha power spectrum



%
%  Generate the coefficients Hk.
%

  hfa = zeros ( 2 * n, 1 );
  hfa(1) = 1.0; 
  for i = 2 : n
    hfa(i) = hfa(i-1) * ( 0.5 * alpha + ( i - 2 ) ) / ( i - 1 );
  end
  hfa(n+1:2*n) = 0.0;
  
%
%  Fill Wk with white noise.
%
  
  wfa = [ -range + 2 * range.* rand( n, 1 ); zeros( n, 1 ); ];
  
%
%  Perform the discrete Fourier transforms of Hk and Wk.
%

  [ fh ] = fft( hfa );
  [ fw ] = fft( wfa );
  
%
%  Multiply the two complex vectors.
%
    fh = fh( 1:n + 1 );
    fw = fw( 1:n + 1 );
      
    fw = fh .* fw;
    
%
%  This scaling is introduced only to match the behavior
%  of the Numerical Recipes code...
%

    fw(1)       = fw(1) / 2;
    fw(end)     = fw(end) / 2;
    
%
%  Take the inverse Fourier transform of the result.
%
  
  fw = [ fw; zeros(n-1,1); ];
  
  x = ifft( fw );
  
  x = 2*real( x(1:n) );
  
%
%  Discard the second half of the inverse Fourier transform.
%

  return
end