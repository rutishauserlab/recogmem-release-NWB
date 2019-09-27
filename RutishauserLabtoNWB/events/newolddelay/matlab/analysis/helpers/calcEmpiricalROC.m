%
%calculates, for NEW/OLD discrimination on the 1-6 scale (1-sure NEW, 6 sure OLD),
%the TP/FP for each confidence level. the output of this function can be used to
%calculate cummulative ROCs
%
%mode: 1, all confidence ratings seperate (1-6). 2, collapse to 1-3
%recogState: ground truth. 0-new, 1-old
%responses: response on 1-6 scale
%
%returns: typeCounters has one column per confidence rating. each row is TP/FN/TN/FP, in this order
%
%
%urut/oct06
function typeCounters = calcEmpiricalROC(mode, recogState, responses)

%== compute the number of TP/FN/TN/FP trials for each confidence rating
typeCounters=[];

if mode==1
    %-- collapsed response over 1-3 scale
    for k=1:3
        indsOLD = find( responses == 6 - k + 1 );
        indsNEW = find( responses == k  );

        nTP = length( find( recogState(indsOLD)==1 ) );
        nFN = length( find( recogState(indsNEW)==1 ) );
        nTN = length( find( recogState(indsNEW)==0 ) );
        nFP = length( find( recogState(indsOLD)==0 ) );

        typeCounters(:,k) = [nTP nFN nTN nFP]';
    end
end

if mode==2
    %-- response over entire 1-6 scale, from the perspective of _OLD_
    for k=1:6

        %to which was the response OLD at this level
        if k<=3
            %1,2,3 -> 6,5,4
            inds = find( responses == 6 - k + 1 );
        else
            %4,5,6 -> is 3,2,1
            inds = find( responses == 6 - k + 1 );
        end

        %indsNEW = find( responses == k  );

        nTP = length( find( recogState(inds)==1 ) );

        nFN=0;
        nTN=0;
        %nFN = length( find( recogState(indsNEW)==1 ) );
        %nTN = length( find( recogState(indsNEW)==0 ) );

        nFP = length( find( recogState(inds)==0 ) );

        typeCounters(:,k) = [nTP nFN nTN nFP]';
    end
end


