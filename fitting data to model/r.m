function [xy,p] = r(x,y,outlier,doprettyprint,dorescaleoutliers,missingvalue)
% computes a zero order correlation
% useage: [r,p]=r(x,y,outlier)
%  where trials with outlier=1 are filtered out

if nargin<3, outlier=0; end
if nargin<4, doprettyprint=0; end
if nargin<5, dorescaleoutliers=0; end
if nargin<6, missingvalue=0; end

if (nargin>2) & (length(outlier)>1)
  indices=find(~outlier);
  x=x(indices); y=y(indices);
end

if missingvalue
  goodinds=find((x~=missingvalue) & (y~=missingvalue));
  x=x(goodinds); y=y(goodinds);
end

if dorescaleoutliers
  x=rescaleoutliers(x,dorescaleoutliers);
  y=rescaleoutliers(y,dorescaleoutliers);
end

xy=corrcoef(x,y);

xy=xy(1,2);

if (nargout>1) | doprettyprint
  df=length(x)-2;
  t=xy./sqrt((1-xy.^2)./df);
  p=tcdf(t,df);
  p=(t>=0).*(1-p)+(t<0).*p;
  %if t>=0, p=1-p; end
  p=2.*p; % makes it 2-tailed
end

if doprettyprint
  if p<.001
    fprintf('r=%.2f, t(%d)=%.2f, p<.001\n',xy,df,t);    
  else
    fprintf('r=%.2f, t(%d)=%.2f, p=%.3f\n',xy,df,t,p);
  end
end


%c = cov(x,y);
%d = diag(c);
%xy = c./sqrt(d*d');
%xy=xy(1,2);
