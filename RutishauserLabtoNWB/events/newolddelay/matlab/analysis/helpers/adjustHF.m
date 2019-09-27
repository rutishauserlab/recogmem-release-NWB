%
%adjust hit/false alarm rate for ceiling effects
%%according to Macmillan&Creelman, pp8
%
%urut/nov06
function [H,F] = adjustHF(H,F, nOLD, nNEW)

for i=1:length(H)
    if H(i)==1
        H(i) = 1 - 1/(2*nOLD);
    end
    if F(i)==1
        F(i) = 1 - 1/(2*nNEW);
    end
    if H(i)==0
        H(i) = 1/(2*nOLD);
    end
    if F(i)==0
        F(i) = 1/(2*nNEW);
    end

end