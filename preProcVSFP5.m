function out = preProcVSFP5(fDate, fNum, ~) 

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
% 05/13/2016 - When SAVE is turned on (by setting save equal to 1 in bottom
% of the script), preprocessed output will be saved as 'VSFP_Output_
% 07/18/2016 - Modified stim removal function to rescale stimulus shifted signal
% by comparing STD of Hemodynamic signals pre and during stimulation
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Save File ON
saveVar = 1;

% file prefix
fpre = 'VSFP';

% Convert inputs if needed
fStr = num2str(fNum);

if length(fStr) == 2
    fStr = ['0' fStr];
elseif length(fStr) < 2
    fStr = ['00' fStr];
end 
fNum = str2double(fStr);
disp(['Processing file ' (fStr) ' ...'])

% Load image filesExcessData, pathName, StmTrg, fpath
[imgA, anaA1, anaA2, Astim, pathName, StmTrg, fpath] = readCMOS6([fpre '_01A' num2str(fDate) '-' fStr '_B.rsh']);
[imgD] = readCMOS6([fpre '_01A' num2str(fDate) '-' fStr '_A.rsh']);

imgA1 = imgA;
imgD1 = imgD;

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
    imgA = bsxfun(@plus,imgA,baseA);
    baseAre = reshape(baseA,[100,100]);

% for image D    
    pathD = [pathName fpre '_01A' num2str(fDate) '-' fStr 'B.rsm'];
    fidD = fopen(pathD,'r','n');
    fdataD = fread(fidD,'int16');
    fdataD = reshape(fdataD,128,100);
    baseD = fdataD(21:120,:);
    imgD = bsxfun(@plus,imgD,baseD);
    baseDre = reshape(baseD,[100,100]);
    disp('done!')
else
    DIF = 0;
end

% Create Mask of Pixels 
mask = zeros(10000,1);
aRe = reshape(imgA(:,:,1),[10000,1]);
mask((aRe > 1500)) = 1;
mask = reshape(mask,[100,100]);

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
% !This is old from version before but may get added back in future
% version...
if exist('region','var') ~= 1 && exist('PCA','var') == 1
    region = roiSelect(fDate, fStr);
else
    region = [1 100 1 100];
end


physMask = zeros(sX,sY,sZ);
physMask(region(3):region(4),region(1):region(2),:) = 1;

Dphys = imgD.*physMask;
Aphys = imgA.*physMask;


% Number of frames to use for baseline average -- typically first 200 frames (1sec) of data
avgingFr = 200;

% Create stucture for output and version control
out = struct('fileNum',[num2str(fDate) '-' num2str(fNum)],'version','v3.0','date',date);

%% Equalized Ratio to correct for wavelength-dependent loght absorption by hemoglobin
% Calculate standard deviations of Acceptor and Donor channels 

% Can modify filter settings for optimal HR subtraction
hemfilter = make_ChebII_filter(1, FsImg, [10 14], [10*0.9 14*1.1], 20);
HPfilter = make_ChebII_filter(1, FsImg, [0.5 50], [0.5*0.9 50*1.1], 20);
betafilter = make_ChebII_filter(1, FsImg, [15 30], [15*0.9 30*1.1], 20);

% Preallocate couple variables for speed :)
Ahem2d = ones(sXY,numFrames);
Dhem2d = ones(sXY,numFrames);
imgVoltFilt = ones(sXY,numFrames);
imgDRFilt = ones(sXY,numFrames);
imgGAFilt = ones(sXY,numFrames);
imgGDFilt = ones(sXY,numFrames);
beta = ones(sXY,numFrames);
blur3 = [];
imgVolt = [];
imgHem = [];
modI = [];

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

% Calculate normalized F/F0 images * For GCAMP imaging only
imgGA = bsxfun(@ldivide, Aphys2d, Aavg);
imgGD = bsxfun(@ldivide, Dphys2d, Davg);

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
    foff = mean(imgDR(:,s1-30:s1-5),2);
    fon = mean(imgDR(:,s1+5:s1+30),2);

    modI = reshape(foff - fon ./ (fon + foff),[sX,sY,1]);
end

%% Run PCA - Currently Removed in Version 5!
if exist('PCA','var') == 1
    disp('Running PCA ...')
    D1d = reshape(imgD1,[sX*sY*sZ,1]);
    A1d = reshape(imgA1,[sX*sY*sZ,1]);
    imgTotal = [A1d,D1d];

% specify number of componenets = 2
    [~,score,~] = pca(imgTotal,'NumComponents', 2);  

%     imgHemRaw = reshape(score(:,1),[sX,sY,sZ]);
%     imgVoltRaw = reshape(score(:,2),[sX,sY,sZ]);
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
% disp('filtering ...')
% 
% for xy = 1:sXY
%     if exist('PCA','var') == 1
%         imgVoltFilt(xy,:) = filtfilt(HPfilter.numer, HPfilter.denom, imgVolt2d(xy,:));
%     end
%     imgDRFilt(xy,:) = filtfilt(HPfilter.numer, HPfilter.denom, imgDR(xy,:));
%     beta(xy,:) = filtfilt(betafilter.numer, betafilter.denom, imgDR(xy,:));
%     imgGAFilt(xy,:) = filtfilt(HPfilter.numer, HPfilter.denom, imgGA(xy,:));
%     imgGDFilt(xy,:) = filtfilt(HPfilter.numer, HPfilter.denom, imgGD(xy,:));
% end
% 
% disp('done!')

%% Spatial Blur VSFP data - Currently removed in Version 5!
blur = 1;
if exist('blur','var') == 1
    disp('Spatial Blurring of VSFP data... ')
    blur3 = spatialAvg(reshape(imgDR,[sX,sY,sZ]),3);
end

%% Output Variables and Save

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
out.gamma = gamma;
out.delta = delta;
% out.imgVoltFilt = reshape(imgVoltFilt,[sX,sY,sZ]);
% out.imgDRFilt = reshape(imgDRFilt,[sX,sY,sZ]);
out.physMask = physMask;
out.region = region;
out.anaA1 = anaA1;
out.anaA2 = anaA2;
out.stim1 = Astim;
out.DIF = DIF;
out.baseA = baseAre;
out.baseD = baseDre;
out.blur3 = blur3;
out.beta = reshape(beta,[sX,sY,sZ]);
out.stdA = reshape(stdA,[sX,sY]);
out.stdD = reshape(stdD,[sX,sY]);
out.Aeql = reshape(Aeql,[sX,sY,sZ]);
out.Deql = reshape(Deql,[sX,sY,sZ]);
out.Aavg = reshape(Aavg,[sX,sY]);
out.Davg = reshape(Davg,[sX,sY]);
out.Ahem = reshape(Ahem2d,[sX,sY,sZ]);
out.Dhem = reshape(Dhem2d,[sX,sY,sZ]);
out.avgAe = reshape(avgAe,[sX,sY]);
out.avgDe = reshape(avgDe,[sX,sY]);
out.imgA1 = reshape(imgA1,[sX,sY,sZ]);
out.imgD1 = reshape(imgD1,[sX,sY,sZ]);
out.imgGD = reshape(imgGD,[sX,sY,sZ]);
out.imgGA = reshape(imgGA,[sX,sY,sZ]);
% out.imgGAFilt = reshape(imgGDFilt,[sX,sY,sZ]);
% out.imgGDFilt = reshape(imgGAFilt,[sX,sY,sZ]);
out.modI = modI;
out.version = 'PreProcVSFP5';
out.StmTrg = StmTrg;
out.mask = mask;

% if saveVar == 1
%     save(['VSFP_Out_' fStr '_' num2str(fDate) '.mat'],'out');
% end

end



function [imgA1,imgD1,I] = stimCheck(imgD,Aphys,Dphys,sX,sY)
% Interpolate Line from start of artifact to end and remove

slope = diff(squeeze(imgD(50,50,:)));
I = find(abs(slope)>8*std(slope));
if length(I) >= 2
    I(1) = I(1);
    I(2) = I(1)+400;
    disp('Stimulation trial detected...')
    imgA1 = Aphys;
    imgD1 = Dphys;
    i(1) = I(1)+1;
    i(2) = I(2)-1;
    I(1) = I(1)-3;
    I(2) = I(2)+3;
    Ai3D = bsxfun(@minus,imgA1(:,:,i(1):i(2)),imgA1(:,:,i(1)));
    Di3D = bsxfun(@minus,imgD1(:,:,i(1):i(2)),imgD1(:,:,i(1)));
    
    slopeA = ((imgA1(:,:,I(2))-imgA1(:,:,I(1)))./length(I(1):I(2)));
    slopeD = ((imgD1(:,:,I(2))-imgD1(:,:,I(1)))./length(I(1):I(2)));
    slopeA2 = ((imgA1(:,:,i(2))-imgA1(:,:,i(1)))./length(i(1):i(2)));
    slopeD2 = ((imgD1(:,:,i(2))-imgD1(:,:,i(1)))./length(i(1):i(2)));
    time2 = ones(sX,sY,length(i(1):i(2)));

    time = ones(sX,sY,length(I(1):I(2)));
    for n = 1:length(I(1):I(2))
        time(:,:,n) = ones(sX,sY)*(n-1);
    end
    for n2 = 1:length(i(1):i(2))
        time2(:,:,n2) = ones(sX,sY)*(n2-1);
    end

    sxtA = bsxfun(@times,slopeA,time);
    sxtD = bsxfun(@times,slopeD,time);
    sxtA2 = bsxfun(@times,slopeA2,time2);
    sxtD2 = bsxfun(@times,slopeD2,time2);
    
    Di = bsxfun(@minus, Di3D, sxtD2);
    Ai = bsxfun(@minus, Ai3D, sxtA2);

    imgA1(:,:,I(1):I(2)) = bsxfun(@plus, sxtA, imgA1(:,:,I(1)));
    imgD1(:,:,I(1):I(2)) = bsxfun(@plus, sxtD, imgD1(:,:,I(1)));
    imgA1(:,:,i(1):i(2)) = bsxfun(@plus, Ai, imgA1(:,:,i(1):i(2)));
    imgD1(:,:,i(1):i(2)) = bsxfun(@plus, Di, imgD1(:,:,i(1):i(2)));
    
else
    imgA1 = Aphys;
    imgD1 = Dphys;
end

end