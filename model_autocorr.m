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
       
owmat=[  .9        .15        0       0   ;   % external threat
   	     0         .9      .25      .25   ;   % vigilance/salience       % FROM THESE NETWORKS
	  -.25       -.04       .9    -.1   ;   % avoidance/control
         0        .25       .15     .9  ];   % interoception
     
num_trials = 20;

tstats = struct('data', cell(1,num_trials), 'execautocorr', cell(1,num_trials), 'salautocorr', cell(1,num_trials), 'intautocorr', cell(1,num_trials));

for simnum=1:num_trials
   randvals = (rand(4,4)-0.5);
   %clip values between [-1,1]
   gwmat=max(-1,min(1,owmat+randvals)); 
   tstats(simnum).data=bada_nn_1999_2('useglobals',0);
   
   model_salience_time_data = tstats(simnum).data.invec(:,2);
   model_exec_time_data = tstats(simnum).data.invec(:,3);
   model_interoceptive_time_data = tstats(simnum).data.invec(:,4);
   
   % look at 1 second in the future... 60000 points, with 120 second
   % recording
   tstats(simnum).execautocorr = autocorr(model_exec_time_data,500);
   tstats(simnum).salautocorr = autocorr(model_salience_time_data, 500);
   tstats(simnum).intautocorr = autocorr(model_interoceptive_time_data, 500);
   autocorr(model_exec_time_data, 500)
end

av_auto_corr = tstats;
end