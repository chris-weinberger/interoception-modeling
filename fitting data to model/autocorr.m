function ar=autocorr(vec,lag)
% returns the lag n autocorrelation
% useage: autocorr(vec,lag)
% note: lag can be either a scaler or a vector of lags to evaluate
% by default, lag = 1
if nargin<2
 lag=1;
end

%aumat=xcorr(vec,vec,lag,'coeff');
%ar=aumat(end);

if length(lag)>1
  for ct=1:length(lag)
    ar(ct)=r(vec(1:end-ct),vec(1+ct:end));
  end
else
  ar=r(vec(1:end-lag),vec(1+lag:end));
end
