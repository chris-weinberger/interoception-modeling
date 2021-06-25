function bada_nn_manyways()


global gwmat gstartstate ginstates;


% where we start
gstartstate=[0 0 0.5 ; % threat absent not vigilant
 	    0 0 0.5 ; % threat present not vigilant
	    0 1 0.5 ; % threat absent vigilant
	    0 1 0.5 ]; % threat present vigilant

% what comes in
ginstates= [0  0  0 ; % threat absent not vigilant
	  .1  0  0 ; % threat present not vigilant
	   0 0 0 ; % threat absent vigilant
	  .1 0 0 ]; % threat present vigilant

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the "well regulated" model
owmat=[  .9        .15        0           ;   % external threat
	0         .9       .25           ;   % vigilance
	-.25       -.04        .9         ];   % avoidance


gwmat=owmat;
tstats=bada_nn_1999('useglobals');
timevigilant0=tstats.proptime0(:,2);
timevigilantAUC=tstats.AUC(:,2);
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
% now the full parameter space
for simnum=1:100
  %randvals=(rand(3,3)-.5)./2;
  randvals=(rand(3,3)-.5);
  gwmat=max(0,min(1,owmat+randvals));
  tstats(simnum)=bada_nn_1999('useglobals');
  svig0(:,simnum)=tstats(simnum).proptime0(:,2);
  svigAUC(:,simnum)=tstats(simnum).AUC(:,2);
  fprintf('.');
  if mod(simnum,20)==0, fprintf('\n'); end
end
fprintf('\n');

save bada_nn_sims.mat tstats svig0 svigAUC


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

bincenters=0:.05:1;
figure(2); clf;
subplot(2,2,1);
hist(svig0(1,:),bincenters); 
h=text(timevigilant0(1),25,'*'); 
set(h,'Color',[1 0 0]);
set(h,'FontSize',14);
title('threat absent not vigilant');
xlabel('prop vigilance=0');
ylabel('%');
axis([0 1 0 100]);
subplot(2,2,2);
hist(svig0(2,:),bincenters); 
h=text(timevigilant0(2),25,'*'); 
set(h,'Color',[1 0 0]);
set(h,'FontSize',14);
title('threat present not vigilant');
xlabel('prop vigilance=0');
ylabel('%');
axis([0 1 0 100]);
subplot(2,2,3);
hist(svig0(3,:),bincenters); 
h=text(timevigilant0(3),25,'*'); 
set(h,'Color',[1 0 0]);
set(h,'FontSize',14);
title('threat absent vigilant');
xlabel('prop vigilance=0');
ylabel('%');
axis([0 1 0 100]);
subplot(2,2,4);
hist(svig0(4,:),bincenters); 
h=text(timevigilant0(4),25,'*'); 
set(h,'Color',[1 0 0]);
set(h,'FontSize',14);
title('threat present vigilant');
xlabel('prop vigilance=0');
axis([0 1 0 100]);
ylabel('%');


bincenters=0:.05:2;
figure(3); clf;
subplot(2,2,1);
hist(svigAUC(1,:),bincenters); 
h=text(timevigilantAUC(1),25,'*'); 
set(h,'Color',[1 0 0]);
set(h,'FontSize',14);
title('threat absent not vigilant');
xlabel('vigilance AUC');
ylabel('%');
axis([0 2 0 60]);
subplot(2,2,2);
hist(svigAUC(2,:),bincenters); 
h=text(timevigilantAUC(2),25,'*'); 
set(h,'Color',[1 0 0]);
set(h,'FontSize',14);
title('threat present not vigilant');
xlabel('vigilance AUC');
ylabel('%');
axis([0 2 0 60]);
subplot(2,2,3);
hist(svigAUC(3,:),bincenters); 
h=text(timevigilantAUC(3),25,'*'); 
set(h,'Color',[1 0 0]);
set(h,'FontSize',14);
title('threat absent vigilant');
xlabel('vigilance AUC');
ylabel('%');
axis([0 2 0 60]);
subplot(2,2,4);
hist(svigAUC(4,:),bincenters); 
h=text(timevigilantAUC(4),25,'*'); 
set(h,'Color',[1 0 0]);
set(h,'FontSize',14);
title('threat present vigilant');
xlabel('vigilance AUC');
axis([0 2 0 60]);
ylabel('%');
