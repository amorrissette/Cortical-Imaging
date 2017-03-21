function out = preProcVSFP4(fDate, fNum, region, avgGain, PCA, blur) 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Preprocessing for VSFP imaging data (Dual Camera Acquisition) 
% 
% Usage:
%   out = preProcVSFP(fDate, fNum, avgGain)
% where: avgGain = 0 or 1 (calculate gain factors from trial avg)
%
% 7/16/2015 - Much faster Version 2.0
% 9/02/2015 - Included "method" for specifiying method of removing HR
% artifact & "stimTrial" specification for removing stim artifact when
% performing PCA
% 10/26/2015 - Script overhaul and simplification, includes option to 
% generate equalization gain factor from trial averages (per conv with T. Knopfel)
% 12/09/2015 - Added compatibility for DIF acquired images through ultima
% dual camera system (critical for ratiometric equalization)
% 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% file prefix
fpre = 'VSFP';
% Convert inputs if needed
if isnumeric(fNum) == 1
    fStr = num2str(fNum);
else fStr = fNum;
end
if length(fStr) == 2
    fStr = ['0' fStr];
elseif length(fStr) < 2
    fStr = ['00' fStr];
end 
fNum = str2double(fStr);
disp(['Processing file ' (fStr) ' ...'])

% Load image files
[imgA, anaA1, anaA2, Astim, pathName] = readCMOS6([fpre '_01A' num2str(fDate) '-' fStr '_B.rsh']);
[imgD] = readCMOS6([fpre '_01A' num2str(fDate) '-' fStr '_A.rsh']);

imgA0 = imgA;
imgD0 = imgD;
%% Check image acquisition method (CDF vs DIF)

if imgA(50,50,1) < 1000
    DIF = 1;
    disp('DIF used to acquire images! Recalculating with base fluoresence...')
% for image A    
    pathA = [pathName fpre '_01A' num2str(fDate) '-' fStr 'A.rsm'];
    fidA = fopen(pathA,'r','n');
    fdataA = fread(fidA,'int16');
    fdataA = reshape(fdataA,128,100);
    baseA = fdataA(21:120,:);
    imgA1 = imgA;
    imgA = bsxfun(@plus,imgA,baseA);
    baseAre = reshape(baseA,[100,100]);
    maskA = baseAre(baseAre<1000);
% for image D    
    pathD = [pathName fpre '_01A' num2str(fDate) '-' fStr 'B.rsm'];
    fidD = fopen(pathD,'r','n');
    fdataD = fread(fidD,'int16');
    fdataD = reshape(fdataD,128,100);
    baseD = fdataD(21:120,:);
    imgD1 = imgD;
    imgD = bsxfun(@plus,imgD,baseD);
    baseDre = reshape(baseD,[100,100]);
    maskD = baseDre(baseDre<1000);
    disp('done!')
else
    DIF = 0;
end

% Dimensions of the loaded files?
if isequal(size(imgD),size(imgA)) == 1
    [sX, sY, sZ] = size(imgD);
    sXY = sX*sY;
else
    error('Donor and Acceptor Files must be the same size')
end

% How many frames are in each sequence (for me usually 2048)
numFrames = sZ;
% Time array (sampling at 5 msec = 0.005 sec)
FsImg = 200; % Sampling Rate (Hz)
time = (1:numFrames).*(1/FsImg); % array in seconds

% Select ROI encompassing entire brain FOV and create masks
if exist('region','var') ~= 1 && exist('PCA','var') == 1
    region = roiSelect(fDate, fStr);
else
    region = [1 100 1 100];
end
motionMask = ones(sX,sY,sZ);
motionMask(region(3):region(4),region(1):region(2),:) = 0;
physMask = zeros(sX,sY,sZ);
physMask(region(3):region(4),region(1):region(2),:) = 1;

% and separate images in to physiological and motion est. components
Dmot = imgD.*motionMask;
Amot = imgA.*motionMask;

Dphys = imgD.*physMask;
Aphys = imgA.*physMask;

% Reshape data into 2-dimensions for quicker processing
% Dmot2d = reshape(Dmot,[sXY, sZ]);
% Amot2d = reshape(Amot,[sXY, sZ]);
% Dphys2d = reshape(Dphys, [sXY, sZ]);
% Aphys2d = reshape(Aphys, [sXY, sZ]);

% Number of frames to use for baseline average --first 200 frames (1sec) of data
avgingFr = 10;

% Create stucture for output and version control
out = struct('fileNum',[num2str(fDate) '-' num2str(fNum)],'version','v3.0','date',date);

%% Equalized Ratio to correct for wavelength-dependent loght absorption by hemoglobin
% Calculate standard deviations of Acceptor and Donor channels 
hemfilter = make_ChebII_filter(1, FsImg, [10 14], [10*0.9 14*1.1], 20);
HPfilter = make_ChebII_filter(1, FsImg, [0.5 50], [0.5*0.9 50*1.1], 20);
betafilter = make_ChebII_filter(1, FsImg, [15 30], [15*0.9 30*1.1], 20);

% Preallocate couple variables for speed :)
Ahem2d = ones(sXY,numFrames);
Dhem2d = ones(sXY,numFrames);
imgVoltFilt = ones(sXY,numFrames);
imgDRFilt = ones(sXY,numFrames);
beta = ones(sXY,numFrames);
blur3 = [];
imgVolt = [];
imgHem = [];
modI = [];
I = [];
%% First perform operations outside of cycle:
        
% Determine if presence of optogenetic stimulation
[imgA1,imgD1,I] = stimCheck(imgD,Aphys,Dphys,sX,sY);

Dphys2d = reshape(imgD1, [sXY, sZ]);
Aphys2d = reshape(imgA1, [sXY, sZ]);

% Averages of baseline VSFP recordings
Aavg = mean(Aphys2d(1:sXY,1:avgingFr),2);
Davg = mean(Dphys2d(1:sXY,1:avgingFr),2);

%% Cycle through each pixel (100 x 100 window) *This is slow! - remove in future versions*
for xy = 1:sXY
    
% filter for hemodynamic signal (12-14 hz)
    Ahem2d(xy,:) = filtfilt(hemfilter.numer, hemfilter.denom,Aphys2d(xy,:));
    Dhem2d(xy,:) = filtfilt(hemfilter.numer, hemfilter.denom,Dphys2d(xy,:));
end 

% Standard deviation of filtered signal   
stdA = std(Ahem2d,0,2);
stdD = std(Dhem2d,0,2);    

% gamma and delta values for each pixel    
if exist('avgGain','var') == 1
    gamma1 = avgGain(:,:,1).*physMask(:,:,1);
    gamma = reshape(gamma1, [sXY, 1]);
    delta1 = avgGain(:,:,2).*physMask(:,:,1);
    delta = reshape(delta1, [sXY, 1]);
else
    gamma = 0.5*(1+((Aavg.*stdD)./(Davg.*stdA)));
    delta = 0.5*(1+((Davg.*stdA)./(Aavg.*stdD)));
end

% Calculate equalized A and D data
imgDiffA = bsxfun(@minus,Aphys2d,Aavg);
imgDiffD = bsxfun(@minus,Dphys2d,Davg);

Aeql = bsxfun(@plus,bsxfun(@times,gamma,imgDiffA),Aavg);
Deql = bsxfun(@plus,bsxfun(@times,delta,imgDiffD),Davg);

% Calculate new baseline values for equalized frames
avgAe = mean(Aeql(:,1:avgingFr),2);
avgDe = mean(Deql(:,1:avgingFr),2);        
        
% and gain-corrected rationmetric signal
imgDiv = Aeql ./ Deql;
avgDiv = avgDe ./ avgAe;          
imgDR = bsxfun(@times,imgDiv,avgDiv)-1;

% Calculate Modulation Index if there is stimulation
if length(I) > 1
    s1 = I(1);
    foff = mean(imgDR(:,s1-30:s1-10),2);
    fon = mean(imgDR(:,s1+10:s1+30),2);

    modI = reshape(foff - fon ./ (fon + foff),[sX,sY,1]);
end
    
% Motion estimate
%motDiv2d = Amot2d ./ Dmot2d;
%motDiv = reshape(motDiv2d,[sX,sY,sZ]);
mvmtEst = squeeze(mean(mean((Dmot))));

%% Run PCA 
if exist('PCA','var') == 1
    disp('Running PCA ...')
    D1d = reshape(imgD1,[sX*sY*sZ,1]);
    A1d = reshape(imgA1,[sX*sY*sZ,1]);
    imgTotal = [A1d,D1d];

% specify number of componenets = 2
    [~,score,~] = pca(imgTotal,'NumComponents', 2);  

    imgHemRaw = reshape(score(:,1),[sX,sY,sZ]);
    imgVoltRaw = reshape(score(:,2),[sX,sY,sZ]);
    imgVolt2dRaw = reshape(score(:,2),[sXY,sZ]);
    imgHem2dRaw = reshape(score(:,1),[sXY,sZ]);

% Calculate output of PCA as change from baseline as done for ratio eql
    imgHemAvg = mean(imgHem2dRaw(1:sXY,1:avgingFr),2);
    imgVoltAvg = mean(imgVolt2dRaw(1:sXY,1:avgingFr),2);

    imgHem2d = bsxfun(@minus,imgHem2dRaw,imgHemAvg);
    imgVolt2d = bsxfun(@minus,imgVolt2dRaw,imgVoltAvg);

    imgHem = reshape(imgHem2d,[sX,sY,sZ]);
    imgVolt = reshape(imgVolt2d,[sX,sY,sZ]);

    disp('done!')
end

%% High-Pass Filter Results 
disp('filtering ...')
for xy = 1:sXY
    if exist('PCA','var') == 1
        imgVoltFilt(xy,:) = filtfilt(HPfilter.numer, HPfilter.denom, imgVolt2d(xy,:));
    end
    imgDRFilt(xy,:) = filtfilt(HPfilter.numer, HPfilter.denom, imgDR(xy,:));
    beta(xy,:) = filtfilt(betafilter.numer, betafilter.denom, imgDR(xy,:));
end
disp('done!')
%% Spatial Blur VSFP data

if exist('blur','var') == 1
    disp('Spatial Blurring of VSFP data... ')
    blur3 = spatialAvg(reshape(imgDR,[sX,sY,sZ]),3);
end

%% Output Variables

out.imgD = imgD;
out.imgA = imgA;
out.imgA1 = imgA1;
out.imgD1 = imgD1;
out.fNum = fStr;
out.fDate = fDate;
out.imgHem = imgHem;
out.imgVolt = imgVolt;
out.imgDR2 = reshape(imgDR,[sX,sY,sZ]);
out.imgDR = reshape(bsxfun(@minus,imgDR(:,:),imgDR(:,1)),[sX,sY,sZ]);
out.time = time;
out.Dmot = Dmot;
out.Amot = Amot;
out.gamma = gamma;
out.delta = delta;
out.imgVoltFilt = reshape(imgVoltFilt,[sX,sY,sZ]);
out.imgDRFilt = reshape(imgDRFilt,[sX,sY,sZ]);
out.motionMask = motionMask;
out.physMask = physMask;
out.region = region;
out.mvmt = mvmtEst;
out.anaA1 = anaA1;
out.anaA2 = anaA2;
out.stim1 = Astim;
out.DIF = DIF;
out.baseA = baseA;
out.baseD = baseD;
out.blur3 = blur3;
out.beta = reshape(beta,[sX,sY,sZ]);
out.stdA = reshape(stdA,[sX,sY]);
out.stdD = reshape(stdD,[sX,sY]);
out.Aeql = reshape(Aeql,[sX,sY,sZ]);
out.Deql = reshape(Deql,[sX,sY,sZ]);
out.Aavg = reshape(Aavg,[sX,sY]);
out.Davg = reshape(Davg,[sX,sY]);
out.imgA0 = imgA0;
out.imgD0 = imgD0;
% size(maskA)
% out.maskA = reshape(maskA,[sX,sY]);
% out.maskD = reshape(maskD,[sX,sY]);
out.Ahem = reshape(Ahem2d,[sX,sY,sZ]);
out.Dhem = reshape(Dhem2d,[sX,sY,sZ]);
out.avgAe = reshape(avgAe,[sX,sY]);
out.avgDe = reshape(avgDe,[sX,sY]);
out.imgA1 = reshape(imgA1,[sX,sY,sZ]);
out.imgD1 = reshape(imgD1,[sX,sY,sZ]);
out.modI = modI;

end

function [imgA1,imgD1,I] = stimCheck(imgD,Aphys,Dphys,sX,sY)
% Interpolate Line from start of artifact to end and remove

slope = diff(squeeze(imgD(50,50,:)));
I = find(abs(slope)>8*std(slope));
if length(I) >= 2
%     dON = imgD(:,:,I(1))-imgD(:,:,I(1)-1);
%     dOFF = imgD(:,:,I(2)+1)-imgD(:,:,I(2));
%     dmean = abs(dON-dOFF./2);
    I(1) = I(1);
    I(2) = I(1)+200;
    disp('Stimulation trial detected...')
    imgA1 = Aphys;
    imgD1 = Dphys;
    i(1) = I(1)+1;
    i(2) = I(2)-1;
    I(1) = I(1)-3;
    I(2) = I(2)+3;
    Ai3D = bsxfun(@minus,imgA1(:,:,i(1):i(2)),imgA1(:,:,i(1)));
    Di3D = bsxfun(@minus,imgD1(:,:,i(1):i(2)),imgD1(:,:,i(1)));
    
    Ai2D = reshape(Ai3D,[sX*sY,length(i(1):i(2))]);
    Di2D = reshape(Di3D,[sX*sY,length(i(1):i(2))]);
    AiDetrend = detrend(Ai2D,'linear');
    DiDetrend = detrend(Di2D,'linear');
%     Ai = reshape(AiDetrend,[sX,sY,length(i(1):i(2))]);
%     Di = reshape(DiDetrend,[sX,sY,length(i(1):i(2))]);

    slopeA = ((imgA1(:,:,I(2))-imgA1(:,:,I(1)))./length(I(1):I(2)));
    slopeD = ((imgD1(:,:,I(2))-imgD1(:,:,I(1)))./length(I(1):I(2)));
    slopeA2 = ((imgA1(:,:,i(2))-imgA1(:,:,i(1)))./length(i(1):i(2)));
    slopeD2 = ((imgD1(:,:,i(2))-imgD1(:,:,i(1)))./length(i(1):i(2)));
    time2 = ones(sX,sY,length(i(1):i(2)));
%     size(time2)
    time = ones(sX,sY,length(I(1):I(2)));
    for n = 1:length(I(1):I(2))
        time(:,:,n) = ones(sX,sY)*(n-1);
    end
    for n2 = 1:length(i(1):i(2))
        time2(:,:,n2) = ones(sX,sY)*(n2-1);
    end
%     figure, plot((DiDetrend(500,:)));
    sxtA = bsxfun(@times,slopeA,time);
    sxtD = bsxfun(@times,slopeD,time);
    sxtA2 = bsxfun(@times,slopeA2,time2);
    sxtD2 = bsxfun(@times,slopeD2,time2);
    
%     size(Di3D)
%     size(sxtD2)
%     size(slopeA2)
    Di = bsxfun(@minus, Di3D, sxtD2);
    Ai = bsxfun(@minus, Ai3D, sxtA2);
%     figure, plot(squeeze(Di(40,40,:)));
%     hold on, plot(squeeze(Ai(40,40,:)));
    imgA1(:,:,I(1):I(2)) = bsxfun(@plus, sxtA, imgA1(:,:,I(1)));
    imgD1(:,:,I(1):I(2)) = bsxfun(@plus, sxtD, imgD1(:,:,I(1)));
    imgA1(:,:,i(1):i(2)) = bsxfun(@plus, Ai, imgA1(:,:,i(1):i(2)));
    imgD1(:,:,i(1):i(2)) = bsxfun(@plus, Di, imgD1(:,:,i(1):i(2)));
else
    imgA1 = Aphys;
    imgD1 = Dphys;
end

end

% Removed for version 4 - do not need to adjust raw image files
% % Add 500 for normalization correction        
% An2d = Aphys2d+5000;
% Dn2d = Dphys2d+5000;
% (:,:,(5:end-4))
% function [imgA1,imgD1,dON,dOFF,dmean] = stimCheck(imgD,Aphys,Dphys,sX,sY)

% slope = diff(squeeze(imgD(50,50,:)));
% I = find(abs(slope)>15*std(slope));
% if length(I) == 2
%     dON = imgD(:,:,I(1))-imgD(:,:,I(1)-1);
%     dOFF = imgD(:,:,I(2)+1)-imgD(:,:,I(2));
%     dmean = abs(dON-dOFF./2);
%     disp('Stimulation trial detected...')
%     imgA1 = Aphys;
%     imgD1 = Dphys;
%     % And set stimulation artifact times to 0
%     %imgA1(:,:,I(1):I(2)) = bsxfun(@plus,imgA1(:,:,I(1):I(2)),slopeMean);
%     imgD1(:,:,I(1):I(2)) = bsxfun(@plus,dmean,imgD1(:,:,(I(1):I(2))));
% else
%     imgA1 = Aphys;
%     imgD1 = Dphys;
% end

%     imgA1(:,:,I(1):I(2)) = ((imgA1(:,:,I(2))-imgA1(:,:,I(1))/length(I(1):I(2))))*I(1):I(2)-I(1)+imgA1(:,:,I(1));
%     imgD1(:,:,I(1):I(2)) = ((imgD1(:,:,I(2))-imgD1(:,:,I(1))/length(I(1):I(2))))*I(1):I(2)-I(1)+imgD1(:,:,I(1));
    %     imgA1(:,:,I(1):I(2)) = bsxfun(@times,imgA1(:,:,I(1):I(2)),zeros(sX,sY,length(I(1):I(2))));
%     imgD1(:,:,I(1):I(2)) = bsxfun(@times,imgD1(:,:,I(1):I(2)),zeros(sX,sY,length(I(1):I(2))));