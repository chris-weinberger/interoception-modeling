% we want to pass in a flattened matrix... ie there are 16 parameters to
% test here. If we want to keep the diagonal on 0.9 then we can pass in 12
% parameters

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
global exec_data salience_data interoceptive_data;

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

%2309_executive_criticism_76_scans.csv

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

% start Powell's method with the "well regulated" model
owmat=[  .9        .15        0       0   ;   % external threat
   	     0         .9      .25      .25   ;   % vigilance/salience       % FROM THESE NETWORKS
	  -.25       -.04       .9    -.1   ;   % avoidance/control
         0        .25       .15     .9  ];   % interoception 

weight = reshape(owmat,1,16);
ret=fminsearch(@weightsearch, weight);


function ret=weightsearch(weights)

global gwmat gstartstate ginstates;
global ind typetest exec_data salience_data interoceptive_data;

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

model_threat_time_data = tstats.invec(:,1);
model_salience_time_data = tstats.invec(:,2);
model_exec_time_data = tstats.invec(:,3);
model_interoceptive_time_data = tstats.invec(:,4);

% --------------------- CONVOLUTION OF SIMULATED DATA --------------------
% next we perform convolution on simulated data to make it appear like
% hemodynamic response
resamprate=100; %what should this number be?
% get standard hemodynamic response
hemoir=spm_hrf(1./resamprate, [6,16,1,1,6,0,32]); % start out 100 times per second

% convolved_threat_data = conv(model_threat_time_data, hemoir);
convolved_salience_data = conv(model_salience_time_data, hemoir);
convolved_exec_data = conv(model_exec_time_data, hemoir);
convolved_interoceptive_data = conv(model_interoceptive_time_data, hemoir);

% ------------------------- RECORDED BRAIN DATA ---------------------------
% interpolate all brain data from glabal vars to be the same scale as simulated data
interpolated_exec_data = resample(exec_data,length(convolved_exec_data), length(exec_data));
interpolated_salience_data = resample(salience_data,length(convolved_exec_data), length(salience_data));
interpolated_interoceptive_data = resample(interoceptive_data,length(convolved_exec_data), length(interoceptive_data));

plot ([interpolated_exec_data convolved_exec_data])
drawnow;

% calculate our loss function
loss = mean(sqrt((convolved_exec_data - interpolated_exec_data).^2 + (convolved_salience_data - interpolated_salience_data).^2 + (convolved_interoceptive_data - interpolated_interoceptive_data).^2));

ret=loss;
if ret < 0.0003, ret = 0; end
