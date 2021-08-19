% this function will get the auto-correlation of simulated curves from the
% model

function av_auto_corr=model_autocorr
global gwmat gstartstate ginstates;

% where we start
gstartstate=[0  1  0.5  0.5 ; % threat present vigilant int
 	        0  1  0.5  0   ; % threat present vigilant not int
	        0  0  0.5  0.5 ; % threat present not vigilant int
	        0  0  0.5    0 ; % threat present not vigilant not int
            0  1  0.5  0.5 ; % threat absent vigilant int
	        0  1  0.5    0 ; % threat absent vigilant not int
            0  0  0.5  0.5 ; % threat absent not vigilant int
            0  0  0.5    0 ]; % threat absent not vigilant not int
    
% what comes in
ginstates=[.1 0 0 0 ; % threat present vigilant int
	      .1 0 0 0 ; % threat present vigilant not int
	      .1 0 0 0 ; % threat present not vigilant int
	      .1 0 0 0 ; % threat present vigilant
           0 0 0 0 ; % threat present not vigilant not int
	       0 0 0 0 ; % threat absent vigilant int
           0 0 0 0 ; % threat absent not vigilant int
           0 0 0 0 ]; % threat absent not vigilant not int
       
num_trials = 10;

tstats = struct('data', cell(1,num_trials));

for simnum=1:num_trials
   randvals = (rand(4,4)-0.5);
   %clip values between [-1,1]
   gwmat=max(-1,min(1,owmat+randvals)); 
   tstats(simnum)=bada_nn_1999_2('useglobals',0);
   
   model_salience_time_data = tstats(simnum).invec(:,2);
   model_exec_time_data = tstats(simnum).invec(:,3);
   model_interoceptive_time_data = tstats(simnum).invec(:,4);
   
   
   
end

av_auto_corr = 0;
end