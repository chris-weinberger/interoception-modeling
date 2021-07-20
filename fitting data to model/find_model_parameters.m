% we want to pass in a flattened matrix... ie there are 16 parameters to
% test here. If we want to keep the diagonal on 0.9 then we can pass in 12
% parameters

function ret=find_model_parameters(weights)

global gwmat gstartstate ginstates;

% the "well regulated" model
owmat=[  .9        .15        0       0   ;   % external threat
   	     0         .9      .25      .25   ;   % vigilance/salience       % FROM THESE NETWORKS
	  -.25       -.04       .9    -.1   ;   % avoidance/control
         0        .25       .15     .9  ];   % interoception 

weight = reshape(owmat,1,16);
gwmat=owmat;

ret=fminsearch(@weightsearch, weight);


function ret=weightsearch(weights)

global gwmat gstartstate ginstates;

% where we start -- for now assume all networks start at 0.5
gstartstate=[0  0.5  0.5  0.5 ]; % threat absent vigilant int

% what comes in
ginstates=[0 0 0 0 ]; % threat absent vigilant int

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

convolved_threat_data = conv(model_threat_time_data, hemoir);
convolved_salience_data = conv(model_salience_time_data, hemoir);
convolved_exec_data = conv(model_exec_time_data, hemoir);
convolved_interoceptive_data = conv(model_interoceptive_time_data, hemoir);

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

% Import the data, rmmissing() removes the row of nan's that comes in the
% data
executiverestcontrols = rmmissing(readtable("C:\Users\chris\Documents\interoception-modeling\data\2303_executive_neutral_76_scans.csv", opts));
saliencerestcontrols = rmmissing(readtable("C:\Users\chris\Documents\interoception-modeling\data\2303_salience_neutral_76_scans.csv", opts));
interoceptiverestcontrols = rmmissing(readtable("C:\Users\chris\Documents\interoception-modeling\data\2303_interoceptive_neutral_76_scans.csv", opts));

% examine this data later... some values are negative even though there are
% no negative values in the simulated data. May need to address this
exec_rest_controls = (executiverestcontrols.('brain')-10000)./1000 + 1;
salience_rest_controls = (saliencerestcontrols.('brain')-10000)./1000 + 1;
interoceptive_rest_controls = (interoceptiverestcontrols.('brain')-10000)./1000 + 1;

% interpolate all brain data to be the same scale as simulated data
interpolated_exec_data = resample(exec_rest_controls,length(convolved_exec_data), length(exec_rest_controls));
interpolated_salience_data = resample(salience_rest_controls,length(convolved_exec_data), length(exec_rest_controls));
interpolated_interoceptive_data = resample(interoceptive_rest_controls,length(convolved_exec_data), length(exec_rest_controls));

plot ([interpolated_exec_data convolved_exec_data])
drawnow;

% calculate our loss function
loss = mean(sqrt((convolved_exec_data - interpolated_exec_data).^2 + (convolved_salience_data - interpolated_salience_data).^2 + (convolved_interoceptive_data - interpolated_interoceptive_data).^2));

ret=loss;
if ret < 0.0003, ret = 0; end



% TR -> scan repeat time
% wav -> parameters of response function... use 'canonical' parameters

% specific questions to be answered:
% 1. what is scan repeat time? First argument of spm_hrf
% 2. what should our resamprate be? 100? What does this mean?
% 3. what about onset delay? Is 0.2 okay?

% function ret=findhemoampsust(TR,wav)
% if nargin<2, TR=1; end
% if nargin<1,
%   %wav=spm_hrf(TR, [6,16,1,1,6,0,32]); % original version
%   wav=spm_hrf(TR, [8,16,1,1,6,0,32]); % delayed version
% end
% % uses the fminsearch procedure
% % to find the optimal height and delay to match a known hemodynamic response
% 
% global sinp;
% sinp.wav=wav;
% sinp.TR=TR;
% 
% 
% amp=.2;
% sust=1; % in seconds
% initial = zeros(1,18); %flattened array of starting matrix values
% initial(1) = amp;
% initial(2) = sust;
% 
% ret=fminsearch(@hemomatch,initial)
% 
% function ret=hemomatch(ampsust)
%   global sinp;
%   
%   resamprate=100;
%   onsetdelay=.2;
% 
%   amp=ampsust(1);
%   sust=ampsust(2);
%   
%   weights = ampsust(3:length(ampsust));
% 
%   % get standard hemodynamic response... [6,16,1,1,6,0,32] is
%   % canonical hemodynamic parameters.
%   hemoir=spm_hrf(1./resamprate, [6,16,1,1,6,0,32]); % start out 100 times per second
%   
%   % create pulsetrain vector
%   pulsetrain=zeros(size(hemoir));
%   
%   % fill it with amp, which is 0.2 right now
%   pulsetrain(round(onsetdelay.*resamprate):round(resamprate.*(onsetdelay+sust)))=amp;
%   
%   % convolve the interpolated data(?) with standard hemodynamic response to
%   % get what fMRI data would look like
%   convpulse=conv(pulsetrain,hemoir);
%   convpulse=convpulse(1:length(hemoir));
%   
%   % this is where the interpolation happens?
%   convpulseresamp=resample(convpulse,length(convpulse),length(sinp.wav))';
%   
%   %ret=sin(amp)+sust.^2;
%   
%   % compute the loss function right here
%   ret=mean((convpulseresamp-sinp.wav).^2);
%   
%   if ret<0.00003, ret=0; end
%   
%   fprintf('Amp=%.3f   Sust=%.3f   MSD=%.7f\n',amp,sust,ret);
%   plot([convpulseresamp sinp.wav]);
%   drawnow;
