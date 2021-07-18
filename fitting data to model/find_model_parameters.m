% we want to pass in a flattened matrix... ie there are 16 parameters to
% test here. If we want to keep the diagonal on 0.9 then we can pass in 12
% parameters
% TR -> scan repeat time
% wav -> parameters of response function... use 'canonical' parameters

% specific questions to be answered:
% 1. what is scan repeat time? First argument of spm_hrf
% 2. what should our resamprate be? 100? What does this mean?
% 3. what about onset delay? Is 0.2 okay?

function ret=findhemoampsust(TR,wav)
if nargin<2, TR=1; end
if nargin<1,
  %wav=spm_hrf(TR, [6,16,1,1,6,0,32]); % original version
  wav=spm_hrf(TR, [8,16,1,1,6,0,32]); % delayed version
end
% uses the fminsearch procedure
% to find the optimal height and delay to match a known hemodynamic response

global sinp;
sinp.wav=wav;
sinp.TR=TR;


amp=.2;
sust=1; % in seconds

ret=fminsearch(@hemomatch,[amp sust])

function ret=hemomatch(ampsust)
  global sinp;
  
  resamprate=100;
  onsetdelay=.2;

  amp=ampsust(1);
  sust=ampsust(2);

    
  % get standard hemodynamic response... [6,16,1,1,6,0,32] is
  % canonical hemodynamic parameters.
  hemoir=spm_hrf(1./resamprate, [6,16,1,1,6,0,32]); % start out 100 times per second
  
  % create pulsetrain vector
  pulsetrain=zeros(size(hemoir));
  
  % fill it wil amp, which is 0.2 right now
  pulsetrain(round(onsetdelay.*resamprate):round(resamprate.*(onsetdelay+sust)))=amp;
  
  % convolve the interpolated data with standard hemodynamic response to
  % get what fMRI data would look like
  convpulse=conv(pulsetrain,hemoir);
  convpulse=convpulse(1:length(hemoir));
  
  % this is where the interpolation happens
  convpulseresamp=resample(convpulse,length(convpulse),length(sinp.wav))';
  
  %ret=sin(amp)+sust.^2;
  
  % compute the loss function right here
  ret=mean((convpulseresamp-sinp.wav).^2);
  
  if ret<0.00003, ret=0; end
  
  fprintf('Amp=%.3f   Sust=%.3f   MSD=%.7f\n',amp,sust,ret);
  plot([convpulseresamp sinp.wav]);
  drawnow;
