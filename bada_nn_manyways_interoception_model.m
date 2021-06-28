function bada_nn_manyways_interoception_model()


global gwmat gstartstate ginstates;


% where we start
gstartstate=[0 0 0.5 0.5 ; % threat absent not vigilant w int
 	        0 0 0.5 0.5 ; % threat present not vigilant w int
	        0 1 0.5 0.5 ; % threat absent vigilant w int
	        0 1 0.5 0   ; % threat present vigilant w/o int
            0 0 0.5 0   ; % threat absent vigilant w/o int
	        0 0 0.5 0   ]; % threat present vigilant w/o int
    
% what comes in
ginstates= [0 0 0 0 ; % threat absent not vigilant
	      .1 0 0 0 ; % threat present not vigilant
	       0 0 0 0 ; % threat absent vigilant
	      .1 0 0 0 ; % threat present vigilant
           0 0 0 0 ; % threat absent vigilant
	      .1 0 0 0 ]; % threat present vigilant  
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the "well regulated" model
owmat=[  .9        .15        0       0   ;   % external threat
   	     0         .9      .25      .25   ;   % vigilance/salience       % FROM THESE NETWORKS
	  -.25       -.04       .9    -.1   ;   % avoidance/control
         0        .25       .15     .9  ];   % interoception

gwmat=owmat;
tstats=bada_nn_1999_2('useglobals');
timevigilant0=tstats.proptime0(:,2);
timevigilantAUC=tstats.AUC(:,2);
timeinteroceptive0 = tstats.proptime0(:,4);
timeinteroceptiveAUC = tstats.AUC(:,4);
%>> timevigilant0
%    1.0000
%    0.0487
%    0.7711
%         0
%>> timevigilantAUC
%         0
%    0.4319
%    0.0882
%    0.4116
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

num_trials = 100;

%pre-allocate the size of the arrays that will be filled below, reduce
%runtime
svig0=zeros(6,num_trials);
sint0 = zeros(6,num_trials);
svigAUC = zeros(6,num_trials);
sintAUC = zeros(6,num_trials);

% now the full parameter space
for simnum=1:num_trials
  %randvals=(rand(3,3)-.5)./2;
  randvals=(rand(4,4)-.5);
  gwmat=max(0,min(1,owmat+randvals));
  tstats(simnum)=bada_nn_1999_2('useglobals');
  
  %sgvig 0: columns are trials from above simulation, 
  % rows contain proportion of time that vigilance was in each possible
  % state (threat vigilant interoceptive, etc.)
  svig0(:,simnum)=tstats(simnum).proptime0(:,2); 
  
  %sint0, same as above, but interoceptive
  sint0(:,simnum) = tstats(simnum).proptime0(:,4);
  
  svigAUC(:,simnum)=tstats(simnum).AUC(:,2);
  sintAUC(:,simnum)=tstats(simnum).AUC(:,4);
  
  fprintf('.');
  if mod(simnum,20)==0, fprintf('\n'); end
end
fprintf('\n');

save('bada_nn_sims_interoceptive.mat', 'tstats', 'svig0','svigAUC', 'sint0','sintAUC')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% First six subplots of vigilance proportion of time at 0

bincenters=0:.05:1;
figure(2); clf;
subplot(2,3,1);
histogram(svig0(1,:),bincenters); 
h=text(timevigilant0(1),25,'*'); 
set(h,'Color',[1 0 0]);
set(h,'FontSize',14);
title('threat absent not vigilant interoceptive');
xlabel('prop vigilance=0');
ylabel('%');
axis([0 1 0 100]);

subplot(2,3,2);
histogram(svig0(2,:),bincenters); 
h=text(timevigilant0(2),25,'*'); 
set(h,'Color',[1 0 0]);
set(h,'FontSize',14);
title('threat present not vigilant interoceptive');
xlabel('prop vigilance=0');
ylabel('%');
axis([0 1 0 100]);

subplot(2,3,3);
histogram(svig0(3,:),bincenters); 
h=text(timevigilant0(3),25,'*'); 
set(h,'Color',[1 0 0]);
set(h,'FontSize',14);
title('threat absent vigilant interoceptive');
xlabel('prop vigilance=0');
ylabel('%');
axis([0 1 0 100]);

subplot(2,3,4);
histogram(svig0(4,:),bincenters); 
h=text(timevigilant0(4),25,'*'); 
set(h,'Color',[1 0 0]);
set(h,'FontSize',14);
title('threat present vigilant not interoceptive');
xlabel('prop vigilance=0');
axis([0 1 0 100]);
ylabel('%');

subplot(2,3,5);
histogram(svig0(5,:),bincenters); 
h=text(timevigilant0(5),25,'*'); 
set(h,'Color',[1 0 0]);
set(h,'FontSize',14);
title('threat absent not vigilant not interoceptive');
xlabel('prop vigilance=0');
axis([0 1 0 100]);
ylabel('%');

subplot(2,3,6);
histogram(svig0(6,:),bincenters); 
h=text(timevigilant0(6),25,'*'); 
set(h,'Color',[1 0 0]);
set(h,'FontSize',14);
title('threat present not vigilant not interoceptive');
xlabel('prop vigilance=0');
axis([0 1 0 100]);
ylabel('%');

%% Six subplots of vigilance AUC
bincenters=0:.05:2;
figure(3); clf;
subplot(2,3,1);
histogram(svigAUC(1,:),bincenters); 
h=text(timevigilantAUC(1),25,'*'); 
set(h,'Color',[1 0 0]);
set(h,'FontSize',14);
title('threat absent not vigilant interoceptive');
xlabel('vigilance AUC');
ylabel('%');
axis([0 2 0 60]);

subplot(2,3,2);
histogram(svigAUC(2,:),bincenters); 
h=text(timevigilantAUC(2),25,'*'); 
set(h,'Color',[1 0 0]);
set(h,'FontSize',14);
title('threat present not vigilant interoceptive');
xlabel('vigilance AUC');
ylabel('%');
axis([0 2 0 60]);

subplot(2,3,3);
histogram(svigAUC(3,:),bincenters); 
h=text(timevigilantAUC(3),25,'*'); 
set(h,'Color',[1 0 0]);
set(h,'FontSize',14);
title('threat absent vigilant interoceptive');
xlabel('vigilance AUC');
ylabel('%');
axis([0 2 0 60]);

subplot(2,3,4);
histogram(svigAUC(4,:),bincenters); 
h=text(timevigilantAUC(4),25,'*'); 
set(h,'Color',[1 0 0]);
set(h,'FontSize',14);
title('threat present vigilant not interoceptive');
xlabel('vigilance AUC');
axis([0 2 0 60]);
ylabel('%');

subplot(2,3,5);
histogram(svigAUC(5,:),bincenters); 
h=text(timevigilantAUC(5),25,'*'); 
set(h,'Color',[1 0 0]);
set(h,'FontSize',14);
title('threat absent not vigilant not interoceptive');
xlabel('vigilance AUC');
axis([0 2 0 60]);
ylabel('%');

subplot(2,3,6);
histogram(svigAUC(6,:),bincenters); 
h=text(timevigilantAUC(6),25,'*'); 
set(h,'Color',[1 0 0]);
set(h,'FontSize',14);
title('threat present not vigilant not interoceptivet');
xlabel('vigilance AUC');
axis([0 2 0 60]);
ylabel('%');

%% Six subplots of interoceptive proportion of time at 0

bincenters=0:.05:1;
figure(4); clf;
subplot(2,3,1);
histogram(sint0(1,:),bincenters); 
h=text(timeinteroceptive0(1),25,'*'); 
set(h,'Color',[1 0 0]);
set(h,'FontSize',14);
title('threat absent not vigilant interoceptive');
xlabel('prop interoceptive=0');
ylabel('%');
axis([0 1 0 100]);

subplot(2,3,2);
histogram(sint0(2,:),bincenters); 
h=text(timeinteroceptive0(2),25,'*'); 
set(h,'Color',[1 0 0]);
set(h,'FontSize',14);
title('threat present not vigilant interoceptive');
xlabel('prop interoceptive=0');
ylabel('%');
axis([0 1 0 100]);

subplot(2,3,3);
histogram(sint0(3,:),bincenters); 
h=text(timeinteroceptive0(3),25,'*'); 
set(h,'Color',[1 0 0]);
set(h,'FontSize',14);
title('threat absent vigilant interoceptive');
xlabel('prop interoceptive=0');
ylabel('%');
axis([0 1 0 100]);

subplot(2,3,4);
histogram(sint0(4,:),bincenters); 
h=text(timeinteroceptive0(4),25,'*'); 
set(h,'Color',[1 0 0]);
set(h,'FontSize',14);
title('threat present vigilant not interoceptive');
xlabel('prop interoceptive=0');
axis([0 1 0 100]);
ylabel('%');

subplot(2,3,5);
histogram(sint0(5,:),bincenters); 
h=text(timeinteroceptive0(5),25,'*'); 
set(h,'Color',[1 0 0]);
set(h,'FontSize',14);
title('threat absent not vigilant not interoceptive');
xlabel('prop interoceptive=0');
axis([0 1 0 100]);
ylabel('%');

subplot(2,3,6);
histogram(sint0(6,:),bincenters); 
h=text(timeinteroceptive0(6),25,'*'); 
set(h,'Color',[1 0 0]);
set(h,'FontSize',14);
title('threat present not vigilant not interoceptive');
xlabel('prop interoceptive=0');
axis([0 1 0 100]);
ylabel('%');

%% Six subplots of interoceptive AUC

bincenters=0:.05:1;
figure(5); clf;
subplot(2,3,1);
histogram(sintAUC(1,:),bincenters); 
h=text(timeinteroceptiveAUC(1),25,'*'); 
set(h,'Color',[1 0 0]);
set(h,'FontSize',14);
title('threat absent not vigilant interoceptive');
xlabel('interoceptive AUC');
ylabel('%');
axis([0 2 0 60]);

subplot(2,3,2);
histogram(sintAUC(2,:),bincenters); 
h=text(timeinteroceptiveAUC(2),25,'*'); 
set(h,'Color',[1 0 0]);
set(h,'FontSize',14);
title('threat present not vigilant interoceptive');
xlabel('interoceptive AUC');
ylabel('%');
axis([0 2 0 60]);

subplot(2,3,3);
histogram(sintAUC(3,:),bincenters); 
h=text(timeinteroceptiveAUC(3),25,'*'); 
set(h,'Color',[1 0 0]);
set(h,'FontSize',14);
title('threat absent vigilant interoceptive');
xlabel('interoceptive AUC');
ylabel('%');
axis([0 2 0 60]);

subplot(2,3,4);
histogram(sintAUC(4,:),bincenters); 
h=text(timeinteroceptiveAUC(4),25,'*'); 
set(h,'Color',[1 0 0]);
set(h,'FontSize',14);
title('threat present vigilant not interoceptive');
xlabel('interoceptive AUC');
axis([0 2 0 60]);
ylabel('%');

subplot(2,3,5);
histogram(sintAUC(5,:),bincenters); 
h=text(timeinteroceptiveAUC(5),25,'*'); 
set(h,'Color',[1 0 0]);
set(h,'FontSize',14);
title('threat absent not vigilant not interoceptive');
xlabel('interoceptive AUC');
axis([0 2 0 60]);
ylabel('%');

subplot(2,3,6);
histogram(sintAUC(6,:),bincenters); 
h=text(timeinteroceptiveAUC(6),25,'*'); 
set(h,'Color',[1 0 0]);
set(h,'FontSize',14);
title('threat present not vigilant not interoceptive');
xlabel('interoceptive AUC');
axis([0 2 0 60]);
ylabel('%');