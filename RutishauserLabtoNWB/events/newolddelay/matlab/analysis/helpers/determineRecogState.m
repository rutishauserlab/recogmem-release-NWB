%
%for the NO task
%determines from the ground truth whether a stimulus shown during recognition is old or new.
%
%recogState is 0 if new, 1 if old
%urut/jan07
function recogState = determineRecogState(stimuliRecog, stimuliLearn)

%ground truth - is the stimulus old or not. 0=new,1=old
recogState=zeros(1,length(stimuliRecog));
for i=1:length(stimuliRecog)   
    if length(find(stimuliRecog(i)==stimuliLearn))>=1
        recogState(i)=1;
    end
end
