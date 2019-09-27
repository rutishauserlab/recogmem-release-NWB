%
%bootstrapped statistical test for null hypothesis of equal mean
%
%z,y: samples for the 2 groups. for this to work, the mean of z must be
%bigger than the mean of y (if onesided)
%
%
%B: # of bootstraps to make
%mode: 1=twosided, 2=onesided (z > y is required)
%
%according to effros&... chapter 16, Algorithm 16.2
%
%t: null distribution as estimated
%tOB: observed mean difference
%
%
%urut/march05
%---------------------------------------------------------------------------
function [p, t,tOB] = bootstrapMeanEqualTest(z,y,B,mode,varCorrection)
if nargin==3
	mode=1;
end
if nargin<5
    varCorrection = 0; %=1 --> correct for unequal variances
end

%disp(['bootstrap mode: ' num2str(mode)]);
rng('shuffle');
n=length(z);
m=length(y);

zm=mean(z);
ym=mean(y);

if isrow(z) && isrow(y),
    xm=mean([ z y ]);
end

if iscolumn(z) && iscolumn(y),
    xm = mean([z;y]);
end



zt = z-zm+xm;
yt = y-ym+xm;


rInds1=unidrnd(n,n,B);
rInds2=unidrnd(m,m,B);

t=zeros(1,B);
for i=1:B
    
    
    divv=0;
    
    
    if varCorrection==1
        %loop here because (very unlikely) the variance of both sets could be 0,which would result in a div 0 error. not sure whether this is theoretically correct.
        tries=0;
        while divv==0 && tries<10
            %rInds1=unidrnd(n,n,2);
            %rInds2=unidrnd(m,m,2);

            zstar = zt(rInds1(:,i));
            ystar = yt(rInds2(:,i));

            divv=sqrt( std(zstar)^2 /n + std(ystar)^2/m );
            
            tries=tries+1; %so we don't hang here
        end
    else
        %rInds1X=unidrnd(n,n,2);
        %rInds2X=unidrnd(m,m,2);

        zstar = zt(rInds1(:,i));
        ystar = yt(rInds2(:,i));        
        divv=1;   % --> equal variance assumption
    end

    if mode==1 
    	t(i) = abs(mean(zstar)-mean(ystar))/divv ;
    else
        t(i) = mean(zstar)-mean(ystar)/divv;
    end
end

if varCorrection==1
    tOB = (mean(z)-mean(y))/sqrt(std(z)^2/n+std(y)^2/m);
else
    tOB = (mean(z)-mean(y));
end

p=1;
if mode==1
	p = length( find( t >= abs(tOB) ) ) / B;
else
	p = length( find( t >= (tOB) ) ) / B;
end
