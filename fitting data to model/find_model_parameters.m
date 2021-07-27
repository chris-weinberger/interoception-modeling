% find_model_parameters will open data for a given individual under a
% certain test (stimulus like neutral or criticism) and call weightsearch
% inside of fminsearch to find the optimal model parameters to fit the data

function ret=find_model_parameters(individual, test)
% default is first control patient
if nargin < 1, individual = 2303; end
if nargin < 2, test = 'neutral'; end

% these global variables are used in weightsearch to know which data to
% open
global ind typetest;
ind = individual;
typetest = test;

% these global variables will be used in weightsearch for the current
% individual's brain data

% global exec_data salience_data interoceptive_data;

% ------------------------- RECORDED BRAIN DATA ---------------------------
% interpolate the actual brain data so that simulated and actual vectors
% are the same length

% Specify the options for opening all csv data files
opts = delimitedTextImportOptions("NumVariables", 10);
% range and delimiter
opts.DataLines = [1, Inf];
opts.Delimiter = ",";
% column names and types
opts.VariableNames = ["VarName1", "patientID", "time", "condition1", "scanincondition1", "condition2", "condition3", "ignore", "brain"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double"];
% file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% make sure to change directory to be inside /interoception-modeling

% we must select the correct data to open, based on the global variables
% ind and typetest
if strcmp(typetest, 'neutral') % neutral case
    csv_executive = sprintf('%d_executive_%s_76_scans.csv',ind,typetest);
    filename_executive = fullfile('.','data','neutral_rest_76_scans',csv_executive);
    
    csv_salience = sprintf('%d_salience_forward_%s_76_scans.csv',ind,typetest);
    filename_salience = fullfile('data','neutral_rest_76_scans',csv_salience);
    
    csv_interoceptive = sprintf('%d_interoceptive_forward_%s_76_scans.csv',ind,typetest);
    filename_interoceptive = fullfile('data','neutral_rest_76_scans',csv_interoceptive);
else % criticism case
    csv_executive = sprintf('%d_executive_%s_76_scans.csv',ind,typetest);
    filename_executive = fullfile('.','data','criticism_rest_76_scans',csv_executive);
    
    csv_salience = sprintf('%d_salience_forward_%s_76_scans.csv',ind,typetest);
    filename_salience = fullfile('.','data','criticism_rest_76_scans',csv_salience);
    
    csv_interoceptive = sprintf('%d_interoceptive_forward_%s_76_scans.csv',ind,typetest);
    filename_interoceptive = fullfile('data','criticism_rest_76_scans',csv_interoceptive);
end

% Import the data, rmmissing() removes the row of nan's that comes in the
% data
executiverestcontrols = rmmissing(readtable(filename_executive, opts));
saliencerestcontrols = rmmissing(readtable(filename_salience, opts));
interoceptiverestcontrols = rmmissing(readtable(filename_interoceptive, opts));

% examine this data later... some values are negative even though there are
% no negative values in the simulated data. May need to address this
exec_data = (executiverestcontrols.('brain')-10000)./1000 + 1;
salience_data = (saliencerestcontrols.('brain')-10000)./1000 + 1;
interoceptive_data = (interoceptiverestcontrols.('brain')-10000)./1000 + 1;

plot([exec_data salience_data interoceptive_data])

% start Powell's method with the "well regulated" model
owmat=[  .9        .15        0       0   ;   % external threat
   	     0         .9      .25      .25   ;   % vigilance/salience       % FROM THESE NETWORKS
	  -.25       -.04       .9    -.1   ;   % avoidance/control
         0        .25       .15     .9  ];   % interoception 
     
% initialize correlations and timeseries data in outer function, since they
% will be returned in a struct later
exec_corr=0;
sal_corr=0;
int_corr=0;

convolved_salience_data = zeros(1,60000);
convolved_exec_data = zeros(1,60000);
convolved_interoceptive_data = zeros(1,60000);

interpolated_exec_data = zeros(1,60000);
interpolated_salience_data = zeros(1,60000);
interpolated_interoceptive_data = zeros(1,60000);

     function ret=weightsearch(weights)
         global gwmat gstartstate ginstates;
         
         % where we start -- for now assume all networks start at 0.5
         gstartstate=[0  0.5  0.5  0.5 ]; % threat absent vigilant int
         
         % what comes in
         if strcmp(typetest, 'neutral')
             ginstates=[0 0 0 0 ]; % threat absent vigilant int (neutral)
         else
             ginstates=[0.5 0 0 0 ]; % threat present vigilant int (criticism)
         end
         
         % global weight matrix that will be used in dynamic function
         weight_matrix = reshape(weights, 4, 4);
         gwmat=weight_matrix;
         
         % --------------------------- GET SIMULATED DATA -------------------------
         % run model simulation with current weight matrix to get simulated time data for each
         % brain region
         tstats=bada_nn_1999_2('useglobals',0);
         
         model_salience_time_data = tstats.invec(:,2);
         model_exec_time_data = tstats.invec(:,3);
         model_interoceptive_time_data = tstats.invec(:,4);
         
         % --------------------- CONVOLUTION OF SIMULATED DATA --------------------
         % next we perform convolution on simulated data to make it appear like
         % hemodynamic response
         
         % recording length is 120.24 seconds. Simulated data is 60000 samples, so
         % we have 60000/120.24 = 499.002 samples per second
         resamprate=499.002; %what should this number be?
         % get standard hemodynamic response
         hemoir=spm_hrf(1./resamprate, [6,16,1,1,6,0,32]); % start out 100 times per second
         
         % we fill out all convolved data to be 60000 in length, padded with the
         % last value
         convolved_salience_data = conv(model_salience_time_data, hemoir, 'same');
         % convolved_salience_data(length(convolved_salience_data)+1:60000)=convolved_salience_data(length(convolved_salience_data));
         convolved_exec_data = conv(model_exec_time_data, hemoir, 'same');
         convolved_interoceptive_data = conv(model_interoceptive_time_data, hemoir, 'same');
         
         % ------------------------- RECORDED BRAIN DATA ---------------------------
         % interpolate all brain data from glabal vars to be the same scale as simulated data
         % note that resample() will produce edge effects because it assumes there
         % are 0's at the start and end of the data. To account for this, we:
         % 1. subtract mean from original data (data set now has mean of 0)
         % 2. resample the mean normalized data
         % 3. add the mean to the resampled data
         exec_data_mean_norm = exec_data - mean(exec_data);
         interpolated_exec_data = resample(exec_data_mean_norm, length(convolved_exec_data), length(exec_data_mean_norm)) + mean(exec_data);
         sal_data_mean_norm = salience_data - mean(salience_data);
         interpolated_salience_data = resample(sal_data_mean_norm, length(convolved_salience_data), length(sal_data_mean_norm)) + mean(salience_data);
         int_data_mean_norm = interoceptive_data - mean(interoceptive_data);
         interpolated_interoceptive_data = resample(int_data_mean_norm, length(convolved_salience_data), length(int_data_mean_norm)) + mean(interoceptive_data);
         
         plot ([interpolated_exec_data interpolated_salience_data interpolated_interoceptive_data convolved_exec_data convolved_salience_data convolved_interoceptive_data])
         legend({'fMRI exec', 'fMRI salience', 'fMRI int', 'simulated exec', 'simulated salience', 'simulated int'})
         drawnow;
         
         exec_corr = r(interpolated_exec_data, convolved_exec_data);
         sal_corr = r(interpolated_salience_data, convolved_salience_data);
         int_corr = r(interpolated_interoceptive_data, convolved_interoceptive_data);
         
         % calculate our loss function
         loss = mean(sqrt((convolved_exec_data - interpolated_exec_data).^2 + (convolved_salience_data - interpolated_salience_data).^2 + (convolved_interoceptive_data - interpolated_interoceptive_data).^2));
         if loss < 0.0003, loss = 0; end
         
         ret=loss;
     end

weight = reshape(owmat,1,16);

modelparams=fminsearch(@weightsearch, weight);

%save model parameters, correlations, and timeseries fMRI and simulated
%data to a struct
return_struct.weights = modelparams;
return_struct.exec_corr = exec_corr;
return_struct.sal_corr = sal_corr;
return_struct.int_corr = int_corr;

timeseries.fMRI = [interpolated_salience_data, interpolated_exec_data, interpolated_interoceptive_data];
timeseries.simulation = [convolved_salience_data, convolved_exec_data, convolved_interoceptive_data];
timeseries.labels = {'salience','executive','interoceptive'};
                
return_struct.timeseries = timeseries;

ret = return_struct;
end



