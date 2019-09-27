%
%calculate cummulative d' values as well as z-transformed hit/false alarm rates. used to construct empirical ROCs constructed using different
%confidence ratings.
%
%the format of C is described in calcEmpiricalROC.m
%
%statsAll: each column is a confidence level. each row is d', zH, zF, H, F
%
%urut/oct06
function statsAll = calcCumulativeD( C )
statsAll=[];

nOLD=sum(C(1,:));
nNEW=sum(C(4,:));

%cumulative, pp53
for i=1:size(C,2)    
    if i==1
        Ctmp = C(:, 1);
    else
        Ctmp = sum( C(:, 1:i)' )'; 
    end
    
    [d1,zH1,zF1,H,F, se] = calcDPrime( Ctmp , nOLD, nNEW);      
    statsAll(:,i) = [ d1; zH1; zF1; H; F; se ];
end
