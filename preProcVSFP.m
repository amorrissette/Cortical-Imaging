function [imgs, time] = preProcVSFP(fDate, fNum)

% Preprocessing for VSFP imaging data (Dual Camera Acquisition) 
% 
% Usage:
%   [imgs, time] = preProcVSFP(fDate, fNum)
%

%% Doing initial loading and stuff
% cd /Volumes/PC_MAC/DJlab/vsfp_imaging/VSFP_713_2015/
imgD = readCMOS6(['VSFP_01A0' num2str(fDate) '-' fNum '_A.rsh']);
imgA = readCMOS6(['VSFP_01A0' num2str(fDate) '-' (fNum) '_B.rsh']);
% cd /Users/AMmacbookpro/GitHub/Cortical-Imaging/
% Start timer
tic 

% Dimensions of the loaded files?
if isequal(size(imgD),size(imgA)) == 1
    [sX, sY, sZ] = size(imgD); 
else
    error('Donor and Acceptor Files must be the same size')
end

% Reshape data into 2-dimensions for quicker processing
imgD2d = reshape(imgD,[sX*sY,sZ]);
imgA2d = reshape(imgA,[sX*sY,sZ]);

% How many frames are in each sequence (for me usually 2048)
[~,~,numFrames] = size(imgA);

% Time array (sampling at 5 msec = 0.005 sec)
time = (1:numFrames).*0.005; % array in seconds

% Number of frames to use for baseline average
avgingFr = 200;

% Create stucture for output and version control
imgs = struct('fileNum',[num2str(fDate) '-' num2str(fNum)],'avgFrames',avgingFr,'version','v1.0','date',date);

%% Equalized Ratio to correct for wavelength-dependent loght absorption by hemoglobin

% Sampling freq:
FsImg = 200;

% Calculate standard deviations of Acceptor and Donor channels 
hemfilter = make_ChebII_filter(1, FsImg, [10 15], [10*0.9 15*1.1], 20);
myfilter1 = make_ChebII_filter(2, FsImg, 80, 80*1.1, 20);
specfilter = make_ChebII_filter(3, FsImg, 1, 1*0.9, 20);
% Preallocate for speed :)
imgAhem = ones(100,100,numFrames);
imgDhem = ones(100,100,numFrames);
stdA = ones(100,100);
stdD = ones(100,100);
gamma = ones(100,100);
delta = ones(100,100);
imgAe = ones(100,100,numFrames);
imgDe = ones(100,100,numFrames);
imgDiv = ones(100,100,numFrames);
avgAe = ones(100,100);
avgDe = ones(100,100);
avgDiv = ones(100,100);
imgDivDemean = ones(100,100,numFrames);
imgDivDetrend =  ones(100,100,numFrames);
imgDivFilt = ones(100,100,numFrames);
imgPreDivFilt = ones(100,100,numFrames);
imgDR = ones(100,100,numFrames);
af0 = ones(100,100);
df0 = ones(100,100);
imgAf = ones(100,100,numFrames);
imgDf = ones(100,100,numFrames);
% imgDivMax = ones(100,100);
imgDivNorm = ones(100,100,numFrames);
avgAf = ones(100,100);
avgDf = ones(100,100);
EPdiff = ones(100,100);
imgDiffA = ones(100,100,numFrames);
imgDiffD = ones(100,100,numFrames);
imgSpecFilt = ones(100,100,numFrames);

% i = 0;
% figure, hold on
% progbar = waitbar(0, 'Processing Images...');

%% First perform operations outside of cycle:

% Add 100 for normalization correction        
imgA = imgA + 500;
imgD = imgD + 500;

% Normalize to deltaF/F0
af0 = mean2(imgA(:,:,1:50));
imgAf = imgA.*(100/af0);
%     imgAf(x,y,:) = ((imgA(x,y,:)) - af0(x,y))./af0(x,y); 
df0 = mean2(imgD(:,:,1:50));
imgDf = imgD.*(100/df0);
%     imgDf(x,y,:) = ((imgD(x,y,:)) - df0(x,y))./df0(x,y);
imgPreDiv = imgAf./imgDf;        

% Averages of baseline VSFP recordings--first 200 frames (1sec) of data
avgAf = mean(imgAf(1:100,1:100,1:avgingFr),3);
avgDf = mean(imgDf(1:100,1:100,1:avgingFr),3);

%% Cycle through each pixel (100 x 100 window) *This is slow! - remove in future versions*
for x = 1:100
    for y = 1:100;
%         i = i+1;
% waitbar(i/(10000), progbar);
% % Status 
if x == 50 && y == 50
    disp('halway there...')
    toc
end

% filter for hemodynamic signal (12-14 hz)
        imgAhem(x,y,:) = filtfilt(hemfilter.numer, hemfilter.denom,imgAf(x,y,:));
        imgDhem(x,y,:) = filtfilt(hemfilter.numer, hemfilter.denom,imgDf(x,y,:));
        
% if x == 30 && y == 55
%         [Pxx, freq] = pwelch(squeeze(imgPreDiv(x,y,:)), [],[],2^12,200);
%         figure, plot(freq, log(Pxx));
%         
%         pause(2)
% end

% Standard deviation of filtered signal   
         stdA(x,y) = std(squeeze(imgAhem(x,y,:)));
         % stdA1(x,y) = std(imgAhem(x,y,:),0,3);
         stdD(x,y) = std(squeeze(imgDhem(x,y,:)));    
    
         imgDiffA(x,y,:) = squeeze(imgAf(x,y,:))-avgAf(x,y);
         imgDiffD(x,y,:) = squeeze(imgDf(x,y,:))-avgDf(x,y);

% gamma and delta values for each pixel
         gamma(x,y) = 0.5*(1+(avgAf(x,y).*stdD(x,y)))./(avgDf(x,y).*stdA(x,y));
         delta(x,y) = 0.5*(1+(avgDf(x,y).*stdA(x,y)))./(avgAf(x,y).*stdD(x,y));

% Calculate equalized A and D data
        imgAe(x,y,:) = (gamma(x,y).*imgDiffA(x,y,:))+avgAf(x,y);
        imgDe(x,y,:) = (delta(x,y).*imgDiffD(x,y,:))+avgDf(x,y);


% Calculate new baseline values for equalized frames
        avgAe(x,y) = mean(imgAe(x,y,1:avgingFr),3);
        avgDe(x,y) = mean(imgDe(x,y,1:avgingFr),3);        
        
% and gain-corrected rationmetric signal

        imgDiv(x,y,:) = imgAe(x,y,:) ./ imgDe(x,y,:);
        avgDiv(x,y) = avgDe(x,y) ./ avgAe(x,y);          
        imgDR(x,y,:) = (squeeze(imgDiv(x,y,:)) .* avgDiv(x,y))-1;
        EPdiff(x,y) = abs(imgDiv(x,y,1000)-imgDiv(x,y,1015));
        
%         if x == 30 && y == 55
%             [Pxx, freq] = pwelch(squeeze(imgDR(x,y,:)), [],[],2^12,200);
%             figure, plot(freq, log(Pxx));
%             pause(2)
%         end
        
%         if x == y
%                 plot(time, squeeze(imgDR(x,y,:)));
%end

% Detrend and Filter Image Data 

        imgDivDemean(x,y,:) = detrend(squeeze(imgDR(x,y,:)),'constant');
        imgDivDetrend(x,y,:) = detrend(squeeze(imgDivDemean(x,y,:)),'linear');
        
% Normalize Div Signal to max
%         imgDivMax(x,y) = max(squeeze(imgDivDetrend(x,y,:)));
%         imgDivNorm(x,y,:) = squeeze(imgDivDetrend(x,y,:))./imgDivMax(x,y);
        
% Low-pass filter (should be 50 and 70)
         imgDivFilt(x,y,:) = filtfilt(myfilter1.numer, myfilter1.denom,squeeze(imgDivDetrend(x,y,:)));
         imgDivFilt(x,y,:) = filtfilt(myfilter1.numer, myfilter1.denom,squeeze(imgDivDetrend(x,y,:)));

% Filter for Spectrogram (bandpass from 2Hz to 40Hz)
%         imgSpecFilt(x,y,:) = filtfilt(specfilter.numer, specfilter.denom, squeeze(imgDivDetrend(x,y,:)));
%         imgPreDivFilt(x,y,:) = filtfilt(myfilter1.numer, myfilter1.denom, squeeze(imgPreDiv(x,y,:)));
    end
end
% waitbar(1, progbar, 'Image Processing Done!');
%% Calculate ROI based on presence of hemodynamic signals
clear i
imgROI = ones(100,100);
imgStdTotal = std2(stdA);
imgAvgTotal = mean2(stdA);

imgROI(stdA < imgAvgTotal+imgStdTotal) = 0;
% Xpix = 38:65;
% Ypix = 50:70;
% 
% roiTemp1 = mean(imgData(Xpix,:,:));
%     roiTemp2 = squeeze(roiTemp1(1,:,:));
%     roiTemp3 = mean(roiTemp2(Ypix,:));
%     imageROIavgs(X,:) = roiTemp3(1,1:2000)'; 

%% Stick all the important stuff into a structure for easy access
% 
imgs.imgDivFilt = imgDivFilt;
imgs.imgDiv = imgDiv;
imgs.avgDiv = avgDiv;
imgs.imgDR = imgDR;
imgs.imgDivDemean = imgDivDemean;
imgs.imgDivDetrend = imgDivDetrend;
imgs.imgAe = imgAe;
imgs.imgDe = imgDe;
imgs.imgA = imgA;
imgs.imgD = imgD;
imgs.imgAhem = imgAhem;
imgs.imgDhem = imgDhem;
imgs.imgDivNorm = imgDivNorm;
imgs.imgAf = imgAf;
imgs.imgDf = imgDf;
imgs.avgAf = avgAf;
imgs.avgDf = avgDf;
imgs.stdA = stdA;
imgs.stdD = stdD;
imgs.gamma = gamma;
imgs.delta = delta;
imgs.af0 = af0;
imgs.df0 = df0; 
imgs.avgingFr = avgingFr;
imgs.imgROI = imgROI;
imgs.imgSpecFilt = imgSpecFilt;
imgs.imgPreDivFilt = imgPreDivFilt;
imgs.imgPreDiv = imgPreDiv;
imgs.EPdiff = EPdiff;
% close(progbar);

toc
