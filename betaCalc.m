function newOut = betaCalc(out)

%%%%% 
% 
%   This function filters in the beta frequency, finds the peak amplitudes
%   of each period and then spices points between to original sZ
%
%   Depends on preProcVSFP7 being called before
%
%%%%%

disp('Calculating Beta Amplitude')
sXY = out.sX*out.sY;
betafilter = make_ChebII_filter(1, out.Fs, [15 30], [15*0.9 30*1.1], 20);
imgDR2d = reshape(out.imgDR2,[sXY,out.sZ]);
beta = ones(sXY,out.sZ);
betaAmp = ones(sXY,out.sZ);

for xy = 1:sXY
    beta(xy,:) = filtfilt(betafilter.numer, betafilter.denom, imgDR2d(xy,:));
    [maxt,~] = peakdet1(beta(xy,:),0.0001);
    betaAmp(xy,:) = spline(maxt(:,1),maxt(:,2),1:out.sZ);
end

betaRe = reshape(betaAmp,[out.sX,out.sY,out.sZ]);
betaBlur = spatialAvg(betaRe,3);

newOut = out;
newOut.beta = betaRe;
newOut.betaBlur = betaBlur;