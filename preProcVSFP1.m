function [imgs, time] = preProcVSFP1(fDate, fNum)

% Preprocessing for VSFP imaging data (Dual Camera Acquisition) 
% 
% Usage:
%   [imgs, time] = preProcVSFP(fDate, fNum)
%
% 7/16/2015 - Much faster Version 2.0

%% Doing initial loading and stuff
if isnumeric(fNum) == 1
    fStr = num2str(fNum);
else fStr = fNum;
end
if length(fStr) < 3
    fStr = ['0' fStr];
end 
imgD = readCMOS6(['VSFP_01A0' num2str(fDate) '-' fStr '_A.rsh']);
imgA = readCMOS6(['VSFP_01A0' num2str(fDate) '-' fStr '_B.rsh']);

% Start timer
tic 

% Dimensions of the loaded files?
if isequal(size(imgD),size(imgA)) == 1
    [sX, sY, sZ] = size(imgD); 
    sXY = sX*sY;
else
    error('Donor and Acceptor Files must be the same size')
end

% Reshape data into 2-dimensions for quicker processing
imgD2d = reshape(imgD,[sXY,sZ]);
imgA2d = reshape(imgA,[sXY,sZ]);

% How many frames are in each sequence (for me usually 2048)
numFrames = sZ;

% Time array (sampling at 5 msec = 0.005 sec)
time = (1:numFrames).*0.005; % array in seconds

% Number of frames to use for baseline average
avgingFr = 200;

% Create stucture for output and version control
imgs = struct('fileNum',[num2str(fDate) '-' num2str(fNum)],'avgFrames',avgingFr,'version','v2.0','date',date);

%% Equalized Ratio to correct for wavelength-dependent loght absorption by hemoglobin

% Sampling freq:
FsImg = 200;

% Calculate standard deviations of Acceptor and Donor channels 
hemfilter = make_ChebII_filter(1, FsImg, [10 15], [10*0.9 15*1.1], 20);
myfilter1 = make_ChebII_filter(2, FsImg, 50, 55, 20);
specfilter = make_ChebII_filter(3, FsImg, 1, 1*0.9, 20);
% Preallocate for speed :)
imgAhem = ones(10000,numFrames);
imgDhem = ones(10000,numFrames);
% stdA = ones(sXY);
% stdD = ones(10000);
% gamma = ones(10000);
% delta = ones(10000);
% imgAe = ones(10000,numFrames);
% imgDe = ones(10000,numFrames);
% imgDiv = ones(10000,numFrames);
% avgAe = ones(10000);
% avgDe = ones(10000);
% avgDiv = ones(10000);
imgDivDemean = ones(10000,numFrames);
imgDivDetrend =  ones(10000,numFrames);
imgDivFilt = ones(10000,numFrames);
% imgDR = ones(10000,numFrames);
% af0 = ones(10000);
% df0 = ones(10000);
% imgAf = ones(10000,numFrames);
% imgDf = ones(10000,numFrames);
% imgDivMax = ones(100,100);
imgSpecFilt = ones(sXY,numFrames);
imgDivNorm = ones(10000,numFrames);
% avgAf = ones(10000);
% avgDf = ones(10000);
% imgDiffA = ones(10000,numFrames);
% imgDiffD = ones(10000,numFrames);
% i = 0;
% figure, hold on
% progbar = waitbar(0, 'Processing Images...');

%% First perform operations outside of cycle:

% Add 500 for normalization correction        
imgA2d = imgA2d + 500;
imgD2d = imgD2d + 500;

% Normalize to deltaF/F0
af0 = mean2(imgA2d(:,1:50));
imgAf = imgA2d.*(100./af0);
%     imgAf(x,y,:) = ((imgA(x,y,:)) - af0(x,y))./af0(x,y); 
df0 = mean2(imgD2d(:,1:50));
imgDf = imgD2d.*(100./df0);
%     imgDf(x,y,:) = ((imgD(x,y,:)) - df0(x,y))./df0(x,y);
        
% Averages of baseline VSFP recordings--first 200 frames (1sec) of data
avgAf = mean(imgAf(1:10000,1:avgingFr),2);
avgDf = mean(imgDf(1:10000,1:avgingFr),2);

%% Cycle through each pixel (100 x 100 window) *This is slow! - remove in future versions*
for xy = 1:sXY
%         i = i+1;
% waitbar(i/(sXY), progbar);
% Status 
if xy == sXY/2
    disp('halway there...')
end

% filter for hemodynamic signal (12-14 hz)
        imgAhem(xy,:) = filtfilt(hemfilter.numer, hemfilter.denom,imgAf(xy,:));
        imgDhem(xy,:) = filtfilt(hemfilter.numer, hemfilter.denom,imgDf(xy,:));
        
%         if x == 50 && y == 50
%         [Pxx, freq] = pwelch(squeeze(imgAhem(x,y,:)), [],[],2^12,200);
%         figure, plot(freq, Pxx);
%         end
end 
toc

% Standard deviation of filtered signal   
stdA = std(imgAhem,0,2);
         % stdA1(x,y) = std(imgAhem(x,y,:),0,3);
stdD = std(imgDhem,0,2);    
    
% gamma and delta values for each pixel
gamma = 0.5*(1+(avgAf.*stdD))./(avgDf.*stdA);
delta = 0.5*(1+(avgDf.*stdA))./(avgAf.*stdD);

% Calculate equalized A and D data
imgDiffA = bsxfun(@minus,imgAf,avgAf);
imgDiffD = bsxfun(@minus,imgDf,avgDf);

imgAe = bsxfun(@plus,bsxfun(@times,gamma,imgDiffA),avgAf);
imgDe = bsxfun(@plus,bsxfun(@times,delta,imgDiffD),avgDf);


% Calculate new baseline values for equalized frames
        avgAe = mean(imgAe(:,1:avgingFr),2);
        avgDe = mean(imgDe(:,1:avgingFr),2);        
        
% and gain-corrected rationmetric signal

        imgDiv = imgAe ./ imgDe;
        avgDiv = avgDe ./ avgAe;          
        imgDR = bsxfun(@times,imgDiv,avgDiv)-1;
        
%         if x == 50 && y == 50
%             [Pxx, freq] = pwelch(squeeze(imgDR(x,y,:)), [],[],2^12,200);
%             figure, plot(freq, log(Pxx));
%         end
        
%         if x == y
%                 plot(time, squeeze(imgDR(x,y,:)));
%end

for xy = 1:sXY
% Detrend and Filter Image Data 

        imgDivDemean(xy,:) = detrend(imgDR(xy,:),'constant');
        imgDivDetrend(xy,:) = detrend(imgDivDemean(xy,:),'linear');
        
% Normalize Div Signal to max
%         imgDivMax(x,y) = max(squeeze(imgDivDetrend(x,y,:)));
%         imgDivNorm(x,y,:) = squeeze(imgDivDetrend(x,y,:))./imgDivMax(x,y);
        
% Low-pass filter (should be 50 and 70)

    imgDivFilt(xy,:) = filtfilt(myfilter1.numer, myfilter1.denom, imgDivDetrend(xy,:));

% Filter for Spectrogram (bandpass from 2Hz to 40Hz)
    imgSpecFilt(xy,:) = filtfilt(specfilter.numer, specfilter.denom, imgDivDetrend(xy,:));     
end

% waitbar(1, progbar, 'Image Processing Done!');
%% Calculate ROI based on presence of hemodynamic signals
clear i
imgROI = ones(sX,sY);
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
imgs.imgDivFilt = reshape(imgDivFilt,[sX,sY,sZ]);
imgs.imgDiv = reshape(imgDiv,[sX,sY,sZ]);
imgs.avgDiv = reshape(avgDiv,[sX,sY]);
imgs.imgDR = reshape(imgDR,[sX,sY,sZ]);
imgs.imgDivDemean = reshape(imgDivDemean,[sX,sY,sZ]);
imgs.imgDivDetrend = reshape(imgDivDetrend,[sX,sY,sZ]);
imgs.imgAe = reshape(imgAe,[sX,sY,sZ]);
imgs.imgDe = reshape(imgDe,[sX,sY,sZ]);
imgs.imgA = reshape(imgA,[sX,sY,sZ]);
imgs.imgD = reshape(imgD,[sX,sY,sZ]);
imgs.imgAhem = reshape(imgAhem,[sX,sY,sZ]);
imgs.imgDhem = reshape(imgDhem,[sX,sY,sZ]);
imgs.imgDivNorm = reshape(imgDivNorm,[sX,sY,sZ]);
imgs.imgAf = reshape(imgAf,[sX,sY,sZ]);
imgs.imgDf = reshape(imgDf,[sX,sY,sZ]);
imgs.avgAf = reshape(avgAf,[sX,sY]);
imgs.avgDf = reshape(avgDf,[sX,sY]);
imgs.stdA = reshape(stdA,[sX,sY]);
imgs.stdD = reshape(stdD,[sX,sY]);
imgs.gamma = reshape(gamma,[sX,sY]);
imgs.delta = reshape(delta,[sX,sY]);
imgs.af0 = af0;
imgs.df0 = df0; 
imgs.avgingFr = avgingFr;
imgs.imgROI = imgROI;
imgs.imgSpecFilt = reshape(imgSpecFilt,[sX,sY,sZ]);
imgs.fDate = fDate;
imgs.fNum = fNum;
% close(progbar);

toc
