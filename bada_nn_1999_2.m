function tstats=bada_nn_1999_2(psychstates,graphics)
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

global gwmat gstartstate ginstates typetest;

tstats.psychstates=psychstates;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% initialize the network for healthy and ruminative and BADA people
nodenames={'threat','vigilance','avoidance','interoceptive'};
tstats.nodenames=nodenames;
% over the diagonal is feed forward
% under the diagonal is feed backward
%healthywmat=[ 1        .5        0        0   ;   % external threat
%              0         1       .5        0   ;   % Salience/vigilance/rum
%	          -1       -.5        1        0   ;   % avoidance/control
%              0        .5        0.3      1  ];   % interoception

momentum=.001;
timelimit=60000;
stimtime=60000;
noisemag=0;
%decvec=[0 -.0002 -.0002 0]; % natural decay in absence of stimuli
decvec=[0 0 0 0];
%noisemag=0.0001; % tiny noise completely changes the network - adds threat
                  % where there is none

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% states we will model

% where we start - there should be eight combinations of possible scenarios
% because we have three different variables: so 2^3 = 8

startstate=[0  1  0.5  0.5 ; % threat present vigilant int
 	        0  1  0.5  0   ; % threat present vigilant not int
	        0  0  0.5  0.5 ; % threat present not vigilant int
	        0  0  0.5    0 ; % threat present not vigilant not int
            0  1  0.5  0.5 ; % threat absent vigilant int
	        0  1  0.5    0 ; % threat absent vigilant not int
            0  0  0.5  0.5 ; % threat absent not vigilant int
            0  0  0.5    0 ]; % threat absent not vigilant not int

instates=[.1 0 0 0 ; % threat present vigilant int
	      .1 0 0 0 ; % threat present vigilant not int
	      .1 0 0 0 ; % threat present not vigilant int
	      .1 0 0 0 ; % threat present vigilant
           0 0 0 0 ; % threat present not vigilant not int
	       0 0 0 0 ; % threat absent vigilant int
           0 0 0 0 ; % threat absent not vigilant int
           0 0 0 0 ]; % threat absent not vigilant not int

% used to denote what type of stimulus user is presented...
% criticism indicates that they will recieve threat at beginning and
% halfway through recording
type = 'standard';

% where we start
% startstate=[0  0  0.5  0.5 ; % threat absent not vigilant w int
%  	        0  0  0.5  0.5 ; % threat present not vigilant w int
% 	        0  1  0.5  0.5 ; % threat absent vigilant w int
% 	        0  1  0.5    0 ; % threat present vigilant w/o int
%             0  0  0.5    0 ; % threat absent vigilant w/o int
% 	        0  0  0.5    0 ]; % threat present vigilant w/o int

% what comes in
% instates= [0 0 0 0 ; % threat absent not vigilant
% 	      .1 0 0 0 ; % threat present not vigilant
% 	       0 0 0 0 ; % threat absent vigilant
% 	      .1 0 0 0 ; % threat present vigilant
%            0 0 0 0 ; % threat absent vigilant
% 	      .1 0 0 0 ]; % threat present vigilant


instatenames={'threat present vigilant interoceptive','threat present vigilant not interoceptive','threat present not vigilant interoceptive','threat present not vigilant not interoceptive', 'threat absent vigilant interoceptive', 'threat absent vigilant not interoceptive','threat absent not vigilant interoceptive', 'threat absent not vigilant not interoceptive'};
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
        % TO THESE NETWORKS
wmat=[  .9        .15        0       0   ;   % external threat
   	     0         .9      .25      .25   ;   % vigilance/salience       % FROM THESE NETWORKS
	  -.25       -.04       .9    -.1   ;   % avoidance/control
         0        .25       .15     .9  ];   % interoception

% wmat = [3.70145616563835,0.136906283054430,0.0115174868162189,-0.0294855359910754;
% -0.00988584731411681,-1.71513363284323,5.19167529558525,6.51258811638633;
% -0.0539579351498396,0.430802569672914,-9.33536831616034,1.29183903769569;
% 0.0267840673917464,1.68446897618756,2.38239390778934,-4.37898982259990];

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
    wmat=gwmat; startstate=gstartstate; instates=ginstates; type = typetest;
  end
end

tstats.wmat=wmat;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Show the network's behavior


% healthy matrix
if graphics, figure(1); clf; end
for instate=1:size(instates,1)
  percept=squeeze(3.*momentum.*instates(instate,:));
  noisevec=noisemag.*(randn(1,length(percept))-.5);
  invec(1,:)=startstate(instate,:);
  for time=2:timelimit
    if time==(stimtime/2) && (strcmp(type,'criticism'))
        criticism = [0.1 0 0 0];
        disp(slimit(decvec+noisevec+percept+(1-momentum).*invec(time-1,:)+(momentum.*((wmat'*invec(time-1,:)'))')))
        disp(slimit(decvec+noisevec+percept+(1-momentum).*invec(time-1,:)+(momentum.*((wmat'*invec(time-1,:)'))') + momentum.*criticism))
        invec(time,:)=slimit(decvec+noisevec+percept+(1-momentum).*invec(time-1,:)+(momentum.*((wmat'*invec(time-1,:)'))') + momentum.*criticism);
    elseif time<stimtime
      invec(time,:)=slimit(decvec+noisevec+percept+(1-momentum).*invec(time-1,:)+(momentum.*((wmat'*invec(time-1,:)'))'));
    else
      invec(time,:)=slimit(decvec+noisevec+(1-momentum).*invec(time-1,:)+(momentum.*((wmat'*invec(time-1,:)'))'));
    end
  end
  if graphics
    subplot(2,4,instate);
    plotinvec(invec,timelimit);
    title(instatenames{instate});
    allinvecs(instate,:,:)=invec;
  end
  % rows of proptime are the different possible states('no threat vigilant
  % interoceptive', etc.). Columns are each network (executive, interoceptive, etc) 
  for nodenum=1:size(invec,2)
    tstats.proptime0(instate,nodenum)=length(find(invec(:,nodenum)==0))./size(invec,1); %proportion of time in 0
    tstats.proptime1(instate,nodenum)=length(find(invec(:,nodenum)>1))./size(invec,1); % proportion of time in 1
    tstats.proptime2(instate,nodenum)=length(find(invec(:,nodenum)==2))./size(invec,1); % proportion of time at 2
    tstats.AUC(instate,nodenum)=sum(invec(:,nodenum))./size(invec,1);
  end
  
end
%legend(nodenames);
tstats.invec=invec;
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
