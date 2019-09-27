%
%produces a gaussian kernel, for use by conv(....)
%sig: sigma (in terms of # datapoints)
%n: nr datapoints (symmetric)
%
%urut/march05
function gaussKernel = getGaussianKernel(sig, n)
k=-n:n;
gaussKernel=1/sqrt(2*pi*sig^2)*exp(-k.^2/sig^2);
gaussKernel=gaussKernel/sum(gaussKernel);
