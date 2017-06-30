function y = utl_randsample(n, k, replace, w)

if n == 0, n = [0 0]; end
if nargin < 3, replace = 1; end
if nargin < 4; w = []; end

y = randsample(n, k, replace, w);

if ~isrow(y), y = y'; end

end