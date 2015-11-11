function [imgs, time] = preProcVSFP2(fDate, fNum, method, stimTrial)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Preprocessing for VSFP imaging data (Dual Camera Acquisition) 
% 
% Usage:
%   [imgs, time] = preProcVSFP(fDate, fNum, method, stimTrial)
%
% 7/16/2015 - Much faster Version 2.0
% 9/02/2015 - Included "method" for specifiying method of removing HR
% artifact & "stimTrial" specification for removing stim artifact when
% performing PCA
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Doing initial loading and stuff
if isnumeric(fNum) == 1
    fStr = num2str(fNum);
else fStr = fNum;
end
if length(fStr) < 3
    fStr = ['0' fStr];
end 
[imgD, anaD1, anaD2] = readCMOS6(['VSFP_01A0' num2str(fDate) '-' fStr '_A.rsh']);
[imgA, anaA1, anaA2] = readCMOS6(['VSFP_01A0' num2str(fDate) '-' fStr '_B.rsh']);

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
myfilter1 = make_ChebII_filter(3, FsImg, 8, 8*0.9, 20);
% specfilter = make_ChebII_filter(3, FsImg, 1, 1*0.9, 20);
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
% imgDivDemean = ones(10000,numFrames);
% imgDivDetrend =  ones(10000,numFrames);
% imgDivFilt = ones(10000,numFrames);
imgDR = ones(10000,numFrames);
% af0 = ones(10000);
% df0 = ones(10000);
% imgAf = ones(10000,numFrames);
% imgDf = ones(10000,numFrames);
% imgDivMax = ones(100,100);
% imgSpecFilt = ones(sXY,numFrames);
% imgDivNorm = ones(10000,numFrames);
% avgAf = ones(10000);
% avgDf = ones(10000);
% imgDiffA = ones(10000,numFrames);
% imgDiffD = ones(10000,numFrames);
imgVoltFilt = ones(sXY, numFrames);
imgHem = ones(sXY,numFrames);
imgVolt = ones(sXY,numFrames);
% i = 0;
% figure, hold on
% progbar = waitbar(0, 'Processing Images...');

%% First perform operations outside of cycle:

% Averages of baseline VSFP recordings--first 200 frames (1sec) of data
%avgAf = mean(imgA2d(1:10000,1:avgingFr),2);
%avgDf = mean(imgD2d(1:10000,1:avgingFr),2);

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

% Determine presence of stimulation
slope = diff(squeeze(imgD(50,50,:)));
I = find(abs(slope)>10*std(slope));
if length(I) == 2
    imgA1 = imgA;
    imgD1 = imgD;
    imgA1(:,:,I(1):I(2)) = 0;
    imgD1(:,:,I(1):I(2)) = 0;
else
    imgA1 = imgA;
    imgD1 = imgD;
end

%% Cycle through each pixel (100 x 100 window) *This is slow! - remove in future versions*
if strcmp(method,'eql')||strcmp(method,'both') == 1 
    for xy = 1:sXY
% filter for hemodynamic signal (12-14 hz)
        imgAhem(xy,:) = filtfilt(hemfilter.numer, hemfilter.denom,imgA2d(xy,:));
        imgDhem(xy,:) = filtfilt(hemfilter.numer, hemfilter.denom,imgD2d(xy,:));
    end 

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

elseif strcmp(method,'pca')||strcmp(method,'both') == 1
%% Run PCA 
    imgD1d = reshape(imgD1,[sX*sY*sZ,1]);
    imgA1d = reshape(imgA1,[sX*sY*sZ,1]);
    imgTotal = [imgA1d,imgD1d];
% specify number of componenets = 2
    [~,score,~] = pca(imgTotal,'NumComponents', 2);  
    imgHem = reshape(score(:,1),[sX,sY,sZ]);
    imgVolt = reshape(score(:,2),[sX,sY,sZ]);
    imgVolt2d = reshape(score(:,2),[sXY,sZ]);
end

for xy = 1:sXY
% %% Detrend and Filter Image Data 
% 
%         imgDivDemean(xy,:) = detrend(imgDR(xy,:),'constant');
%         imgDivDetrend(xy,:) = detrend(imgDivDemean(xy,:),'linear');
%         
% % Normalize Div Signal to max
% %         imgDivMax(x,y) = max(squeeze(imgDivDetrend(x,y,:)));
% %         imgDivNorm(x,y,:) = squeeze(imgDivDetrend(x,y,:))./imgDivMax(x,y);
%         
%Low-pass filter (should be 50 and 70)

    imgVoltFilt(xy,:) = filtfilt(myfilter1.numer, myfilter1.denom, imgVolt2d(xy,:));

% % Filter for Spectrogram (bandpass from 2Hz to 40Hz)
%     imgSpecFilt(xy,:) = filtfilt(specfilter.numer, specfilter.denom, imgDivDetrend(xy,:));     
end

%% Calculate ROI based on presence of hemodynamic signals
% clear i
% imgROI = ones(sX,sY);
% imgStdTotal = std2(stdA);
% imgAvgTotal = mean2(stdA);
% 
% imgROI(stdA < imgAvgTotal+imgStdTotal) = 0;

%% Stick all the important stuff into a structure for easy access
% 
% imgs.imgDivFilt = reshape(imgDivFilt,[sX,sY,sZ]);
% imgs.imgDiv = reshape(imgDiv,[sX,sY,sZ]);
% imgs.avgDiv = reshape(avgDiv,[sX,sY]);
% imgs.imgDR = reshape(imgDR,[sX,sY,sZ]);
% imgs.imgDivDemean = reshape(imgDivDemean,[sX,sY,sZ]);
% imgs.imgDivDetrend = reshape(imgDivDetrend,[sX,sY,sZ]);
% imgs.imgAe = reshape(imgAe,[sX,sY,sZ]);
% imgs.imgDe = reshape(imgDe,[sX,sY,sZ]);
imgs.imgA = reshape(imgA,[sX,sY,sZ]);
imgs.imgD = reshape(imgD,[sX,sY,sZ]);
% imgs.imgAhem = reshape(imgAhem,[sX,sY,sZ]);
% imgs.imgDhem = reshape(imgDhem,[sX,sY,sZ]);
% imgs.imgDivNorm = reshape(imgDivNorm,[sX,sY,sZ]);
% imgs.imgAf = reshape(imgAf,[sX,sY,sZ]);
% imgs.imgDf = reshape(imgDf,[sX,sY,sZ]);
% imgs.avgAf = reshape(avgAf,[sX,sY]);
% imgs.avgDf = reshape(avgDf,[sX,sY]);
% imgs.stdA = reshape(stdA,[sX,sY]);
% imgs.stdD = reshape(stdD,[sX,sY]);
% imgs.gamma = reshape(gamma,[sX,sY]);
% imgs.delta = reshape(delta,[sX,sY]);
% imgs.af0 = af0;
% imgs.df0 = df0; 
% imgs.avgingFr = avgingFr;
% imgs.imgROI = imgROI;
% imgs.imgSpecFilt = reshape(imgSpecFilt,[sX,sY,sZ]);
imgs.fDate = fDate;
imgs.fNum = fNum;
imgs.imgHem = imgHem;
imgs.imgVolt = imgVolt;
imgs.slope = slope;
imgs.imgDR = imgDR;
imgs.imgVoltFilt = reshape(imgVoltFilt,[sX,sY,sZ]);
toc




% Add 500 for normalization correction        
% imgA2d = imgA2d + 500;
% imgD2d = imgD2d + 500;
% 
% % Normalize to deltaF/F0
% %af0 = mean2(imgA2d(:,1:50));
% imgAf = imgA2d;
% %     imgAf(x,y,:) = ((imgA(x,y,:)) - af0(x,y))./af0(x,y); 
% %df0 = mean2(imgD2d(:,1:50));
% imgDf = imgD2d;
% %     imgDf(x,y,:) = ((imgD(x,y,:)) - df0(x,y))./df0(x,y);
        