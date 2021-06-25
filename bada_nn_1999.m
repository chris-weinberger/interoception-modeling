function tstats=bada_nn_1999(psychstates,graphics)
% conceptual model to show why / how we shut down
% conceptual mechanisms
%   we don't like internal or external pain
%   so we are vigilant for external pain until the internal pain of it becomes too much
%      and we shut down internal pain / experience

if nargin<1, psychstates={'wellregulated'}; end
if nargin<2, graphics=1; end

if ~iscell(psychstates)
  psychstates={psychstates};
end

%comment

tstats.psychstates=psychstates;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% initialize the network for healthy and ruminative and BADA people
nodenames={'threat','vigilance','avoidance'};
tstats.nodenames=nodenames;
%over the diagonal is feed forward
% under the diagonal is feed backward
%healthywmat=[ 1        .5        0           ;   % external threat
%              0         1       .5           ;   % Salience/vigilance/rum
%	          -1       -.5        1         ];    % avoidance/control

momentum=.001;
timelimit=60000;
stimtime=60000;
noisemag=0;
%decvec=[0 -.0002 -.0002]; % natural decay in absence of stimuli
decvec=[0 0 0];
%noisemag=0.0001; % tiny noise completely changes the network - adds threat
                  % where there is none

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% states we will model
% where we start
startstate=[0 0 0.5 ; % threat absent not vigilant
 	        0 0 0.5 ; % threat present not vigilant
	        0 1 0.5 ; % threat absent vigilant
	        0 1 0.5 ]; % threat present vigilant

% what comes in
instates= [0  0  0 ; % threat absent not vigilant
	      .1  0  0 ; % threat present not vigilant
	       0 0 0 ; % threat absent vigilant
	      .1 0 0 ]; % threat present vigilant

instatenames={'threat absent not vigilant','threat present not vigilant','threat absent vigilant','threat present vigilant'};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
wthreatthreat=[1 1];
wthreatvigilance=[1 2];
wthreatavoid=[1 3];
wvigilancethreat=[2 1];
wvigilancevigilance=[2 2];
wvigilanceavoid=[2 3];
wavoidthreat=[3 1];
wavoidvigilance=[3 2];
wavoidavoid=[3 3];

wmat=[  .9        .15        0           ;   % external threat
   	     0         .9       .25          ;   % vigilance/salience
	  -.25       -.04        .9         ];   % avoidance/control


for statenum=1:length(psychstates)
  statetouse=psychstates{statenum};
  switch statetouse
   case 'reactive'
    % clearly that is fairly extreme
    % suppose we want sustained low level vigilance, just enough control
    wmat(1,2)=.6; % increase threat-vigilance
   case 'depressed' % low prefrontal inhibition
    wmat(2,3)=.05; % decrease vigilance->avoidance
   case 'ruminative'
    wmat(2,2)=1; % increase autoconnectivity of vigilance
   case 'avoidant'
    wmat(2,3)=.4;
   case 'noisy' % same as reactive but with noise
    noisemag=.00005;
   case 'lowperceive'
    wmat(1,2)=.015;
   case 'lowvigilant'
    wmat(2,2)=.5;
   case 'overcontrol'
    wmat(2,3)=.4;
   case 'wellregulated'
   case 'useglobals'
    global gwmat gstartstate ginstates;
    wmat=gwmat; startstate=gstartstate; instates=ginstates;
  end
end

tstats.wmat=wmat;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Show the network's behavior


% healthy matrix
if graphics, figure(1); clf; end
for instate=1:size(instates,1)
  instate
  percept=squeeze(3.*momentum.*instates(instate,:))
  noisevec=noisemag.*(randn(1,length(percept))-.5);
  invec(1,:)=startstate(instate,:);
  for time=2:timelimit
    if time<stimtime
      invec(time,:)=slimit(decvec+noisevec+percept+(1-momentum).*invec(time-1,:)+(momentum.*((wmat'*invec(time-1,:)'))'));
    else
      invec(time,:)=slimit(decvec+noisevec+(1-momentum).*invec(time-1,:)+(momentum.*((wmat'*invec(time-1,:)'))'));      
    end
  end
  if graphics
    subplot(2,2,instate);
    plotinvec(invec,timelimit);
    title(instatenames{instate});
    allinvecs(instate,:,:)=invec;
  end
  for nodenum=1:size(invec,2)
    tstats.proptime0(instate,nodenum)=length(find(invec(:,nodenum)==0))./size(invec,1);
    tstats.proptime1(instate,nodenum)=length(find(invec(:,nodenum)>1))./size(invec,1);
    tstats.proptime2(instate,nodenum)=length(find(invec(:,nodenum)==2))./size(invec,1);
    tstats.AUC(instate,nodenum)=sum(invec(:,nodenum))./size(invec,1);
  end
end
%legend(nodenames);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% implementing hard limit in which there is a high upper threshold on activation in the model
% and a low limit on negative activation (inhibition). This is neurally feasible as it represents 
% neural systems in which there is a low basal firing rate which can decrease somewhat but once a 
% neuron stops firing there is nowhere lower for it to go

function[logval]=slimit(x,thresh,negthresh) 
if nargin<2, thresh=2; end
if nargin<3, negthresh=0; end % was -.75
  
logval=min(max(x,negthresh),thresh);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function that plots out the network
function plotinvec(net,timelimit)
if nargin<2, timelimit=size(net,2); end
h=plot(net);
set(h,'LineWidth',2.14);
xlabel('time');
ylabel('activation');
hold on
plot([0 timelimit],[1 1],'k:');
axis([0 timelimit -.2 2.2]);
