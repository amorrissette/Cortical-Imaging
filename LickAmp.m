function newOut = LickAmp(out)

%%%%% 
% 
%   This function filters in the beta frequency, finds the peak amplitudes
%   of each period and then spices points between to original sZ
%
%   Depends on preProcVSFP7 being called before
%
%%%%%

disp('Calculating Lick Freq Amplitude')
sXY = out.sX*out.sY;
lickfilter = make_ChebII_filter(1, out.Fs, [6 10], [6*0.9 10*1.1], 20);
imgDR2d = reshape(out.imgDR2,[sXY,out.sZ]);
lick = ones(sXY,out.sZ);
lickAmp = ones(sXY,out.sZ);

for xy = 1:sXY
    lick(xy,:) = filtfilt(lickfilter.numer, lickfilter.denom, imgDR2d(xy,:));
    [maxt,~] = peakdet1(lick(xy,:),0.0001);
    lickAmp(xy,:) = spline(maxt(:,1),maxt(:,2),1:out.sZ);
end

lickRe = reshape(lickAmp,[out.sX,out.sY,out.sZ]);
lickBlur = spatialAvg(lickRe,3);

newOut = out;
newOut.lick = lickRe;
newOut.lickBlur = lickBlur;