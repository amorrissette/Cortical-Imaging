function out = powerPlot(vsfp_data)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Function to calculate power in specific frequency bands across each 
%   pixel in vsfp imaging data
%
%   Usage: out = powerPlot(vsfp_data)
%       where out is the matrix with power 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ROI selection
% region = roiSelect(

%% Specify frequency bands 

band.betaLow = [15, 25];
band.betaHigh = [25, 40];
band.gammaLow = [40, 70];
band.gammaHigh = [70, 99];
band.delta = [0.1, 4];
band.alpha = [8, 12];
band.theta = [4, 8];

% Sampling Frequency
fs = 200;

%% Reshape the vsfp data

[x,y,z] = size(vsfp_data);
vsfpRe = reshape(vsfp_data,x*y,z);

%% Use bandpower to calulate power in specified bands

bandNames = fieldnames(band);
[numBands, ~] = size(fieldnames(band));

for n = 1:numBands
    X = bandpower(vsfpRe', fs, band.(bandNames{n}));
    Xre = reshape(X,[x,y]);
    Xfilt = spatialAvg(Xre,3);
    [X,Y] = find(Xre == max(max(Xfilt)));
    
	band.([bandNames{n} '_power']) = Xfilt;
    figure, hold on, axis off, imagesc(band.([bandNames{n} '_power'])), plot(Y,X,'o')
    
    title(bandNames{n});
end

out = band;
