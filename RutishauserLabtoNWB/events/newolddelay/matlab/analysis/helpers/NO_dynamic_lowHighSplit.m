%
% decide split low/high conf dynamically
%
% predeterminedChoice: 0 no, 1/2 yes
%
%urut/CSMC/oct13
function [splitMode, indsTPhigh, indsTPlow, indsFPhigh, ...
    indsFPlow, indsTNhigh, indsTNlow, indsFNhigh, indsFNlow, splitStats] = NO_dynamic_lowHighSplit( groundTruth, behavioralResponse, predeterminedChoice )

respCounts=[];
for k=1:6
    respCounts(k) = length(find(behavioralResponse==k));
end

nrConf1 = respCounts(1)+respCounts(6);
nrConf2 = respCounts(2)+respCounts(5);
nrConf3 = respCounts(3)+respCounts(4);

split1 = nrConf1-(nrConf2+nrConf3);
split2 = (nrConf1+nrConf2)-nrConf3;

splitMode = 0;

[~,splitMode]=min( abs([split1 split2]) );  % which is closer to 0 (more similar proportions

%if split1<=split2
    % 1 vs 2/3 and 6 vs 5/4
%    splitMode=1;
%else
    % 1/2 vs 3, 6/5 vs 4
%    splitMode=2;
%end

splitStats = [split1 split2];

if respCounts(1)==0 || respCounts(6)==0
    splitMode=2;  % if high conf resps empty, use second split to be meaningful
end
if respCounts(2)==0 || respCounts(5)==0
    % in this case splitMode 1/2 are the same, so doesnt matter which is chosen. choose mode 1 to be consistent
    splitMode=1;
end

% if externally forced, disregard dynamic choice
if predeterminedChoice > 0
    splitMode = predeterminedChoice;
end

if splitMode==1
    % 1, (2,3), (4,5), 6;
    
    indsTPhigh = find( groundTruth==1 & behavioralResponse'>=6);   % TP high conf
    indsTPlow = find( groundTruth==1 & (behavioralResponse'==4 | behavioralResponse'==5) );   % TP low conf
    indsFPhigh = find( groundTruth==0 & behavioralResponse'>=6);   % TP high conf
    indsFPlow = find( groundTruth==0 & (behavioralResponse'==4 | behavioralResponse'==5) );   % TP low conf
    
    % 1, (2,3), (4,5), 6;
    indsTNhigh = find( groundTruth==0 & behavioralResponse'<=1);   % TN high conf
    indsTNlow = find( groundTruth==0 & (behavioralResponse'==3 | behavioralResponse'==2) );   % TN low conf
    indsFNhigh = find( groundTruth==1 & behavioralResponse'<=1);   % TN high conf
    indsFNlow = find( groundTruth==1 & (behavioralResponse'==3 | behavioralResponse'==2) );   % TN low conf
else
    % (1,2), 3, 4, (5,6)
    indsTPhigh = find( groundTruth==1 & behavioralResponse'>=5);   % TP high conf
    indsTPlow = find( groundTruth==1 & behavioralResponse'==4);   % TP low conf
    indsFPhigh = find( groundTruth==0 & behavioralResponse'>=5);   % TP high conf
    indsFPlow = find( groundTruth==0 & behavioralResponse'==4);   % TP low conf
    
    %(1,2), 3, 4, (5,6)
    indsTNhigh = find( groundTruth==0 & behavioralResponse'<=2);   % TN high conf
    indsTNlow = find( groundTruth==0 & behavioralResponse'==3);   % TN low conf
    indsFNhigh = find( groundTruth==1 & behavioralResponse'<=2);   % TN high conf
    indsFNlow = find( groundTruth==1 & behavioralResponse'==3);   % TN low conf
end
    