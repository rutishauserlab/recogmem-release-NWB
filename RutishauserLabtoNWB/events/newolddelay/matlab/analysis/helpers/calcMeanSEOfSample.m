%
%mean/std/se/n of a sample. each column is one sample
%
%sample is expected to be a column. multiple columns are treated independently. (mean/std/se/n of each)
%
%ignorenan: 0 none
%           1 ignore nans if data is an array (treat it as such)
%           2 row-wise nan -- if a row has at least one nan, ignore the row
%
%dim: dimension along which to operate (same as for mean or std)
%
%str_mse returns a string of m/se/n for easy labeling of figures
%
%urut/march08 initial
%urut/april12 added ignorenan flag
%urut/march13 added str_mse return
function [m,s,se,n, valsUsed, str_mse] = calcMeanSEOfSample( sample, ignorenan, dim )
if nargin<2
    ignorenan=0;
end
if nargin<3
    dim=1;
end

switch(ignorenan)
    case 1
       sample = sample ( isfinite(sample) );
    case 2
        keepRows=[];
        for j=1:size(sample,1)
           if sum(isnan(sample(j,:)))==0
               keepRows=[keepRows j];
           end
        end
        sample = sample(keepRows,:);
end
valsUsed = sample;

m=mean(sample,dim);
s=std(sample,0,dim);
n=size(sample,dim);
se=s./sqrt(n);

if dim==1
    str_mse = [num2str(m) '\pm' num2str(se) ' n=' num2str(n)];
else
    str_mse='';
end