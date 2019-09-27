% simplified version of bootstrapMeanEqualTest.m (for speed reasons).
% see bootstrapMeanEqualTest.m for details
% this can only do two-sided test (mode=1)
%
% everything is in matrix form in here for speed reasons.
%
%
%urut/april08
%---------------------------------------------------------------------------
function [p,t,tOB] = bootstrapMeanEqualTestSimple(z,y,B)
n=length(z);
m=length(y);

zm=mean(z);
ym=mean(y);

xm=mean([ z y ]);

zt = z-zm+xm;
yt = y-ym+xm;

rInds1=unidrnd(n,n,B);
rInds2=unidrnd(m,m,B);

ztAll = repmat(zt',1,B);
ytAll = repmat(yt',1,B);

zstar=ztAll(rInds1); 
ystar=ytAll(rInds2); 

% zstar = zeros(size(rInds1));
% ystar = zeros(size(rInds2));
% 
% for i=1:B
%    zstar(:,i) = zt(rInds1(:,i));
%    ystar(:,i) = yt(rInds2(:,i));        
% t(i) = abs(mean(zstar(:,i))-mean(ystar(:,1)));
% end

t = abs(mean(zstar)-mean(ystar));

tOB = (mean(z)-mean(y));

p=1;
p = length( find( t >= abs(tOB) ) ) / B;
