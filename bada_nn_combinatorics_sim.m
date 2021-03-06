function bada_nn_combinatorics_sim()


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

%% SIMULATIONS

% In this code, we will run through all possible combinations of values
% in the range [-.5, .5], by increments of 0.1, in all positions of the
% weight matrix except for the diagonal


%Define the starting matrix:
startmat=[.9       -.5      -.5     -.5   ;   % external threat
   	     -.5        .9      -.5     -.5   ;   % vigilance/salience       % FROM THESE NETWORKS
	     -.5       -.5       .9     -.5   ;   % avoidance/control
         -.5       -.5      -.5     .9  ];   % interoception


% There are 4^12 trials total
svig0=zeros(6,16777216);
sint0 = zeros(6,16777216);
svigAUC = zeros(6,16777216);
sintAUC = zeros(6,16777216);

counter=1;

% nested for loops over every iterable entry (skips diagonals)
for r1c2=1:4
    startmat(1,3) = -0.2;
    for r1c3=1:4
        startmat(1,4) = -0.2;
        for r1c4=1:4
            startmat(2,1) = -0.2;
            for r2c1=1:4
                startmat(2,3) = -0.2;
                for r2c3=1:4
                    startmat(2,4) = -0.2;
                    for r2c4=1:4
                        startmat(3,1) = -0.2;
                        for r3c1=1:4
                            startmat(3,2) = -0.2;
                            for r3c2=1:4
                                startmat(3,4) = -0.2;
                                for r3c4=1:4
                                    startmat(4,1) = -0.2;
                                    for r4c1=1:4
                                        startmat(4,2) = -0.2;
                                        for r4c2=1:4
                                            startmat(4,3) = -0.2;
                                            for r4c3=1:4
                                                gwmat=startmat;
                                                tstats(counter)=bada_nn_1999_2('useglobals',0); %do not output graphics

                                                %sgvig 0: columns are trials from above simulation, 
                                                % rows contain proportion of time that vigilance was in each possible
                                                % state (threat vigilant interoceptive, etc.)
                                                svig0(:,counter)=tstats(counter).proptime0(:,2); 

                                                %sint0, same as above, but interoceptive
                                                sint0(:,counter) = tstats(counter).proptime0(:,4);

                                                svigAUC(:,counter)=tstats(counter).AUC(:,2);
                                                sintAUC(:,counter)=tstats(counter).AUC(:,4);

                                                fprintf('.');
                                                counter=counter+1;

                                                % increment current entry in weight matrix
                                                startmat(4,3) = startmat(4,3)+0.1 + ((rand()-.5)/2);
                                            end
                                            fprintf('\n');
                                            startmat(4,2) = startmat(4,2)+0.1 + ((rand()-.5)/2);
                                        end
                                        startmat(4,1) = startmat(4,1)+0.1 + ((rand()-.5)/2);
                                    end
                                    startmat(3,4) = startmat(3,4)+0.1 + ((rand()-.5)/2);
                                end           
                                startmat(3,2) = startmat(3,2)+0.1 + ((rand()-.5)/2);
                            end
                            startmat(3,1) = startmat(3,1)+0.1 + ((rand()-.5)/2);
                        end         
                        startmat(2,4) = startmat(2,4)+0.1 + ((rand()-.5)/2);
                    end  
                    startmat(2,3) = startmat(2,3)+0.1 + ((rand()-.5)/2);
                end                         
                startmat(2,1) = startmat(2,1)+0.1+ ((rand()-.5)/2);
            end                          
            startmat(1,4) = startmat(1,4)+0.1 + ((rand()-.5)/2);
        end                    
        startmat(1,3) = startmat(1,3)+0.1 + ((rand()-.5)/2);
    end
    startmat(1,2) = startmat(1,2)+0.1 + ((rand()-.5)/2);
end    

% for i=1:10
%     fprintf('----------ROW %d---------\n', i);
%     % loop over columns
%     for j=1:10
%         fprintf('----------COLUMN %d---------\n', j);
%         % do not change diagonal value
%         if i~=j
%             while startmat(i,j) < 0.5
%                 gwmat=startmat;
%                 tstats(counter)=bada_nn_1999_2('useglobals');
% 
%                 %sgvig 0: columns are trials from above simulation, 
%                 % rows contain proportion of time that vigilance was in each possible
%                 % state (threat vigilant interoceptive, etc.)
%                 svig0(:,counter)=tstats(counter).proptime0(:,2); 
% 
%                 %sint0, same as above, but interoceptive
%                 sint0(:,counter) = tstats(counter).proptime0(:,4);
% 
%                 svigAUC(:,counter)=tstats(counter).AUC(:,2);
%                 sintAUC(:,counter)=tstats(counter).AUC(:,4);
% 
%                 fprintf('.');
%                 if mod(counter,10)==0, fprintf('\n'); end
%                 counter=counter+1;
%                 
%                 % increment current entry in weight matrix
%                 startmat(i,j) = startmat(i,j)+0.1;
%             end
%         end
%        
%     end
%     fprintf('*-*-*-*-*-*-*-*-*-*\n');
% end

fprintf('\n');

save('bada_nn_combinatoric_sims.mat', 'tstats', 'svig0','svigAUC', 'sint0','sintAUC')


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
