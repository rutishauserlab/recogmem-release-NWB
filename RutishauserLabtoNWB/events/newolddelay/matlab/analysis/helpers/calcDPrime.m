%
%calc D' (d) as well as z-transformed hit rate and false positive rate (zH, zF respectively).
%
%typeCounters is TP/FN/TN/FP, where positive=OLD
%
%according to Macmillan&Creelman, Eq 1.1, 1.2, 1.5;
%error estimation of d' is: Eq 13.4, 13.5 
%
%urut/sept06
function [d, zH, zF,H,F, se] = calcDPrime(typeCounters, nOLD, nNEW)

%if nOLD==0
%    nOLD = sum(typeCounters(1:2));
%end
%if nNEW==0
%    nNEW = sum(typeCounters(3:4));
%end

H=0;
F=0;

if nOLD>0
    H = typeCounters(1)/nOLD;
end

if nNEW>0
    F = typeCounters(4)/nNEW;
end

%adjust for perfect (1) and 0 (all misses)
%acc to pp8
[H,F] = adjustHF(H,F, nOLD, nNEW);

zH=norminv(H);
zF=norminv(F);

d = zH - zF; 

%Eq 13.4, pp325
Hterm=H*(1-H)/(nOLD*phi(H)^2);
Fterm=F*(1-F)/(nNEW*phi(F)^2);

stdErr = Hterm + Fterm;

se = sqrt(stdErr);

%==
%Eq 13.5, pp325
function p = phi(p)
p=1/sqrt(2*pi)*exp(-1/2*norminv(p)^2);