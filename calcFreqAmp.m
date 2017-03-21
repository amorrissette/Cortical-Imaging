function newOut = calcFreqAmp(out,freqRange)

%%%%% 
% 
%   This function filters in the beta frequency, finds the peak amplitudes
%   of each period and then spices points between to original sZ
%
%   Depends on preProcVSFP7 being called before
%
%%%%%

sXY = out.sX*out.sY;
freqfilter = make_ChebII_filter(1, out.Fs, freqRange, [freqRange(1)*0.9 freqRange(2)*1.1], 20);
imgDR2d = reshape(out.imgDR2,[sXY,out.sZ]);
freq = ones(sXY,out.sZ);
freqAmp = ones(sXY,out.sZ);


freq = filtfilt(freqfilter.numer, freqfilter.denom, imgDR2d');
%     [maxt,~] = peakdet1(freq(xy,:),0.0001);
%     freqAmp(xy,:) = spline(maxt(:,1),maxt(:,2),1:out.sZ);

[yupper, ~] = envelope(freq,10,'peak');
freqAmp = yupper;

freqRe = reshape(freqAmp',[out.sX,out.sY,out.sZ]);
freqBlur = spatialAvg(freqRe,3);

newOut = out;
newOut.freq = freqRange;
newOut.freqFilt = freqRe;
newOut.freqFiltBlur = freqBlur;