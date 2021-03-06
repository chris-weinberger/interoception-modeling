function tstats=dynamical_pc_model(psychstates,graphics)
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

global gwmat gstartstate ginstates gpriormean gpriorvar gnoise typetest;

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

%% Initialize values used in interoceptive inference
u       = 0.7;
sigma_u = 0.1;
v_p     = 2; %can't be zero - dF/dphi vanishes always if phi is zero
sigma_p = 1;
phi     = v_p;
dt      = 0.01;
dur     = 6;
steps   = round(dur/momentum);
epsilon_p = 0;
epsilon_u = 0;
                  
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
   case 'wellregulated'
   case 'useglobals'
    wmat=gwmat; startstate=gstartstate; instates=ginstates; type = typetest; sigma_u=gnoise; v_p=gpriormean; sigma_p = gpriorvar;
  end
end

tstats.wmat=wmat;

%% Initialize matrix used in interoceptive inference

interoceptive_data = zeros(6,timelimit);

interoceptive_data(1,1) = phi;
interoceptive_data(2,1) = epsilon_p;
interoceptive_data(3,1) = epsilon_u;
interoceptive_data(4,1) = sigma_p;
interoceptive_data(5,1) = sigma_u;
interoceptive_data(6,1) = v_p;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Show the network's behavior
% healthy matrix
if graphics, figure(1); clf; end
for instate=1:size(instates,1)
    percept=squeeze(3.*momentum.*instates(instate,:));
    noisevec=noisemag.*(randn(1,length(percept))-.5);
    invec(1,:)=startstate(instate,:);
    for time=1:timelimit-1
        u = invec(time,1);
        % interoceptive prediction occurs in the insula
        interoceptive_data(:,time+1) = interoceptive_update(interoceptive_data(:,time), time, momentum, u);
        % get the current phi prediction generated from
        % interoceptive_update
        phi = interoceptive_data(1,time);
        % this prediction of bodily signal affects amygdala, PFC
        intero_excitation = [0, phi/3, phi/3, 0];
            
        firstcrit = (time < stimtime/4);
        secondcrit = (time > stimtime/2) && (time < 3* stimtime/4);
        if (firstcrit || secondcrit) && (strcmp(type,'criticism'))
            criticism = [0.1 0 0 0]; 
            invec(time+1,:)=slimit(decvec+noisevec+percept+(1-momentum).*invec(time,:)+(momentum.*((wmat'*invec(time,:)'))') + momentum.*intero_excitation + criticism);
        elseif time<stimtime
            invec(time+1,:)=slimit(decvec+noisevec+percept+(1-momentum).*invec(time,:)+(momentum.*((wmat'*invec(time,:)'))') + momentum.*intero_excitation);
        else
            invec(time+1,:)=slimit(decvec+noisevec+(1-momentum).*invec(time,:)+(momentum.*((wmat'*invec(time,:)'))') + momentum.*intero_excitation);
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
end

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
end

end

function time_data=interoceptive_update(time_data, t, dt, u)
    phi = time_data(1);
    epsilon_p = time_data(2);
    epsilon_u = time_data(3);
    sigma_p = time_data(4);
    sigma_u = time_data(5);
    v_p = time_data(6);
    
    % here we run a mini simulation that allows the insula to converge on
    % the most likely value for the incoming data.
    % Then, we update the time_data matrix at the next timestep with all
    % the values that were converged to at the end of the mini sim
    
    num_steps = 75;
    converge_data = zeros(6,num_steps);
    
    for currtime=1:(num_steps-1)
        phi=phi + dt * (epsilon_u * 2 * phi - epsilon_p);
        converge_data(1,currtime+1) = phi;
        
        epsilon_p = epsilon_p + dt * epsilon_p_dot(phi, v_p, sigma_p, epsilon_p);
        converge_data(2,currtime+1) = epsilon_p;
        
        epsilon_u = epsilon_u + dt * epsilon_u_dot(u, phi, sigma_u, epsilon_u);
        converge_data(3,currtime+1) = epsilon_u;
        
        sigma_p = sigma_p + dt * sigma_p_dot(epsilon_p, sigma_p);
        converge_data(4,currtime+1) = sigma_p;
    
        sigma_u = sigma_u + dt * sigma_u_dot(epsilon_u, sigma_u);
        converge_data(5,currtime+1) = sigma_u;
    
        v_p = v_p + dt * v_p_dot(epsilon_p);
        converge_data(6,currtime+1) = v_p;
    end
    
    % Finally, update the next timestep in time_data with the most recent values from converge_data
    return_array = zeros(6,1);
    return_array(1) = converge_data(1,num_steps-1);
    return_array(2) = converge_data(2,num_steps-1);
    return_array(3) = converge_data(3,num_steps-1);
    return_array(4) = converge_data(4,num_steps-1);
    return_array(5) = converge_data(5,num_steps-1);
    return_array(6) = converge_data(6,num_steps-1);
    time_data = return_array;
end

% simple functions used for bayesian prediction
function ret=g(phi)
ret = phi^2;
end

function ret=epsilon_p_dot(phi, v_p, sigma, epsilon_p)
ret = phi - v_p - (sigma * epsilon_p);
end

function ret=epsilon_u_dot(u, phi, sigma, epsilon_u)
ret = u - g(phi) - (sigma * epsilon_u);
end

function ret=v_p_dot(epsilon_p)
ret = epsilon_p;
end

function ret=sigma_p_dot(epsilon_p, sigma_p)
ret = (1.0/2.0) * (epsilon_p^2 - (1/sigma_p));
end

function ret=sigma_u_dot(epsilon_u, sigma_u)
ret = (1.0/2.0) * (epsilon_u^2 - (1/sigma_u));
end
