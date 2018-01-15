% This file has been included in Simulating Event-Related EEG Activity
% (SEREEGA), but has been taken from another source, with the following
% main changes made:
% 2018-01-15 lrk
%   - Removed perc as argument; set to 1
%   - Added sigma as argument and output
%   - Added crude adaptive sigma-finding loop, moving part of the code to 
%     local function 'findsolution'

% License for this file:

% MIT License
% 
% Copyright 2006-2018 Guido Nolte and Stefan Haufe
% 
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
% 
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.

function [data, Arsig, x, lambdamax, sigma] = arm_generate_signal(M, N, P, K, sigma, Arsig)

% M=10;     % number of time series;
% N=1000;   % number of data-points
% P=10;     % order of AR-model (number of lags)
% K=ceil(M^2/10); % number or indices of interactions between time series
% sigma=1;  % scale of random AR-parameters
perc=1;     % percentage of lags that are nonzero for the interaction terms
N0=2500;    % length of ignored start 

% Copyright 2006-2018 Guido Nolte and Stefan Haufe

if length(K) == 1
    % setting random interactions
    inddiag = linspace(1, M^2, M);
    indndiag = setdiff(1:M^2, inddiag);
    per = randperm(length(indndiag));
    indndiag = indndiag(per);
    indndiag = indndiag(1:K);
    ind = [inddiag indndiag];
else
    % setting the indicated interactions (+ the diagonal)
    inddiag = linspace(1, M^2, M);
    ind = unique([inddiag K]);
end

if ~exist('Arsig', 'var')    
    if ~exist('sigma', 'var')
        % finding a sigma where lambdamax is around 1
        sigma = 1;
        trials = 100;
        w = waitbar(0, sprintf('Finding solution at sigma %1.4f', sigma));
        while 1
            for i = 1:trials
                [~, lambdamax(i)] = findsolution(M,P,ind,sigma,perc);
                waitbar(i/trials, w, sprintf('Finding solution at sigma %1.4f', sigma));  
            end
            if mean(lambdamax) > 2
                sigma = sigma * 0.5;      
            elseif mean(lambdamax) > 1
                sigma = sigma * 0.9;
            else
                break
            end
        end
    else
        w = waitbar(0, sprintf('Finding solution at sigma %1.4f', sigma));
    end

    % finding specific solution where lambdamax is between .98 and .95.
    % note: these are more or less arbitrary values. too close to 1 may
    % lead to unstable systems, too close to 0 means the interactions have
    % hardly any effect relative to the random innovations.
    lambdamax = 10;
    while lambdamax > .98 || lambdamax < 0.95
        [Arsig, lambdamax] = findsolution(M,P,ind,sigma,perc);
    end
    
    delete(w);
end

% generating the signal
x=randn(M,N+N0);
y=x;
for i=P+1:N+N0
    yloc=reshape(fliplr(y(:,i-P:i-1)),[],1);
    y(:,i)=Arsig*yloc+x(:,i);
end

% removing start
data=y(:,N0+1:end);
x = x(:, N0+1:end);

end

function [Arsig, lambdamax] = findsolution(M,P,ind,sigma,perc)

Arsig=[];
for k=1:P
    aloc = zeros(M);
    aloc(ind) = double(rand(length(ind), 1) < perc).*randn(length(ind), 1)*sigma;
    Arsig=[Arsig,aloc];
end
E=eye(M*P);AA=[Arsig;E(1:end-M,:)];lambda=eig(AA);lambdamax=max(abs(lambda));
   
end
