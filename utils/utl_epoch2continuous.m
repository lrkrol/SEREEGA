% PURPOSE: converts an epoched dataset into a continuous one.
%          Data segments are concatenated using a 'boundary' events.
%
% FORMAT
%
% EEG = epoch2continuous(EEG);
%
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% July 7, 2011
%
% Feedback would be appreciated and credited.
% NOTE: No ICA fields have been tested until this version.
% BUG #1: EEG.epoch.eventlatency cell vs single value. Steven Raaijmakers

function EEG = utl_epoch2continuous(EEG)
if nargin<1
      help epoch2continuous
      return
end
if size(EEG.data, 3) == 1
      error('epoch2continuous() only works for epoched data!')
end
tic;
[xlat, indx]  = unique([EEG.event.latency], 'first');
neegevent  = length(indx);
% new type
typearray  = {EEG.event(indx).type};
% new duration
if isfield(EEG.event, 'duration')
      durarray = {EEG.event(indx).duration};
else
      durarray = num2cell(ones(1,neegevent));
end
if ~isfield(EEG.event, 'urevent') % bug fixed. JLC. Feb 5, 2013
      [EEG.event.urevent] = EEG.event.type;
end
% new urevent
urarray  = {EEG.event(indx).urevent};
nepoch   = EEG.trials;
nepopnts = EEG.pnts;
latsamarray = zeros(1, neegevent);
% new continuous latencies
for i=1:neegevent
      ep  = EEG.event(indx(i)).epoch;
      if iscell(EEG.epoch(ep).eventlatency)
            lat = EEG.epoch(ep).eventlatency{EEG.epoch(ep).event == indx(i)};
      else
            lat = EEG.epoch(ep).eventlatency; % Thanks to Steven Raaijmakers!
      end
      [xxx latsam] =  closest_local(EEG.times, lat);
      latsamarray(i) = latsam + (ep-1)*nepopnts;
end
latsamarray = num2cell(latsamarray); % cell
% new boundaries
latbound    = num2cell(nepopnts:nepopnts:nepopnts*nepoch);
nbound      = length(latbound);
boundarray  = repmat({'boundary'}, 1, nbound);
% concatenates events and boundaries info
typearray   = [typearray boundarray];
latsamarray = [latsamarray latbound];
urarray     = [urarray repmat({0},1,nbound)];
durarray    = [durarray repmat({0},1,nbound)];
neegevent   = length(typearray); % new length
% Builts new EEG
EEG.trials  = 1;
EEG.xmin    = 0;
EEG.data    = reshape(EEG.data , EEG.nbchan,nepoch*nepopnts);
EEG.event   = [];
% Events
[EEG.event(1:neegevent).type    ] = typearray{:};
[EEG.event(1:neegevent).latency ] = latsamarray{:};
[EEG.event(1:neegevent).urevent ] = urarray{:};
[EEG.event(1:neegevent).duration] = durarray{:};
EEG.epoch  = [];
EEG.times  = [];
EEG.epochdescription = {};
EEG.reject = [];
EEG.pnts   = length(EEG.data);
EEG.xmax   = length(EEG.data)/EEG.srate;
% check everything
tproce = toc;
EEG    = eeg_checkset( EEG, 'eventconsistency' );




% Returns the closest value from a list
%
% Syntax
%
%  c      = closest(a,b); returns the closest value c in a for each value in b
% [c,i]   = closest(a,b); returns the index i of the closest value in a for each value in b
% [c,i,d] = closest(a,b); returns the difference d of the closest value in a for each value in b
%
% Example
%
% [cvalue, cindex cdiff] = closest([-8 2 5.5 12 45 20 100],[-15 2.3 10 50])
% 
% cvalue =
% 
%     -8     2    12    45
% 
% 
% cindex =
% 
%      1     2     4     5
% 
% 
% cdiff =
% 
%     7.0000   -0.3000    2.0000   -5.0000
%
%
% Author: Javier Lopez-Calderon
% Davis, CA, March, 2011
function [cvalue, cindex, cdiff] = closest_local(data, target)

error(nargchk(1,2,nargin))
error(nargoutchk(0,3,nargout))
if nargin<2; target = [];end
ntarget = length(target);
[cvalue, cindex, cdiff]   = deal(zeros(1, ntarget));
for i=1:ntarget
      if isnan(target(i)) || isinf(target(i))
            [cvalue(i), cindex(i), cdiff(i)] = deal(NaN);
      else
            [cx, cindex(i)] = min(abs(data-target(i)));
            cvalue(i) = data(cindex(i));
            cdiff(i)  = cvalue(i)-target(i); % data minus target
      end
end