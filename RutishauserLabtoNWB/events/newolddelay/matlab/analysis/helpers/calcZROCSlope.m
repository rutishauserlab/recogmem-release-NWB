%
%slope of z-ROC
%
%b -> regression coefficients
%d1/d2 -> distance on x and y axis to origin (see Fig3.3,  MacMillan&creelman book)
%s -> slope
%
function [b, d2, s, da, Rsquare] = calcZROCSlope( typeCounters )

d = calcCumulativeD( typeCounters );
d = d(2:3, 1:end-1); %remove d' value, eliminate last datapoint (is always in right upper corner)

x = d(2,:); %F (z-transformed)
y = d(1,:); %H (z-transformed)


%[B,BINT,R,RINT,STATS]
[b,bint,r,rint,stats]=regress(y', [ones(length(x),1) x' ]);
Rsquare = stats(1);

s=b(2);

%calc d2

d2 = b' * [1 0]';

%Eq 3.4
da = sqrt(2/(1+s^2))*d2;