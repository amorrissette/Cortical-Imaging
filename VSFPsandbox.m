function [imgs, time] = VSFPsandbox(pctTotal, fDate, fNum, method)

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
%tic 

% Dimensions of the loaded files?
if isequal(size(imgD),size(imgA)) == 1
    [sX, sY, sZ] = size(imgD);
    sXY = sX*sY;
else
    error('Donor and Acceptor Files must be the same size')
end
frmSect = round(pctTotal*sZ);
imgDmod = imgD(:,:,1:frmSect);
imgAmod = imgA(:,:,1:frmSect);
% Reshape data into 2-dimensions for quicker processing
imgD2d = reshape(imgDmod,[sXY,frmSect]);
imgA2d = reshape(imgAmod,[sXY,frmSect]);

% How many frames are in each sequence (for me usually 2048)
numFrames = frmSect;

% Time array (sampling at 5 msec = 0.005 sec)
time = (1:numFrames).*0.005; % array in seconds

% Number of frames to use for baseline average
avgingFr = 20;

% Create stucture for output and version control
imgs = struct('fileNum',[num2str(fDate) '-' num2str(fNum)],'avgFrames',avgingFr,'version','v2.0','date',date);

%% Equalized Ratio to correct for wavelength-dependent loght absorption by hemoglobin

% Sampling freq:
FsImg = 200;

% Calculate standard deviations of Acceptor and Donor channels 
hemfilter = make_ChebII_filter(1, FsImg, [10 15], [10*0.9 15*1.1], 20);

% Preallocate for speed :)
imgAhem = ones(10000,numFrames);
imgDhem = ones(10000,numFrames);

%% First perform operations outside of cycle:

% Averages of baseline VSFP recordings--first 200 frames (1sec) of data
avgAf = mean(imgA2d(1:10000,1:avgingFr),2);
avgDf = mean(imgD2d(1:10000,1:avgingFr),2);

% Determine presence of stimulation
slope = diff(squeeze(imgD(50,50,:)));
I = find(abs(slope)>10*std(slope));
if length(I) == 2
    disp('Outlying Simulus Artifact Found: Setting Stim Out to 0');
    imgA1 = imgA;
    imgD1 = imgD;
    imgA1(:,:,I(1):I(2)) = 0;
    imgD1(:,:,I(1):I(2)) = 0;
else
    imgA1 = imgA;
    imgA1mod = imgA(:,:,1:frmSect);
    imgD1 = imgD;
    imgD1mod = imgD(:,:,1:frmSect);
end

%% Cycle through each pixel (100 x 100 window) *This is slow! - remove in future versions*
if strcmp(method,'eql') == 1 
    for xy = 1:sXY
        
% filter for hemodynamic signal (12-14 hz)
        imgAhem(xy,:) = filtfilt(hemfilter.numer, hemfilter.denom,imgA(xy,:));
        imgDhem(xy,:) = filtfilt(hemfilter.numer, hemfilter.denom,imgD(xy,:));
    end 

% Standard deviation of filtered signal   
    stdA = std(imgAhem,0,2);
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

elseif strcmp(method,'pca') == 1
%% Run PCA 
    imgD1d = reshape(imgD1mod,[sX*sY*frmSect,1]);
    imgA1d = reshape(imgA1mod,[sX*sY*frmSect,1]);
    imgTotal = [imgA1d,imgD1d];
% specify number of componenets = 2
    [~,score,~] = pca(imgTotal,'NumComponents', 2);  
    imgHem = reshape(score(:,1),[sX,sY,frmSect]);
    imgVolt = reshape(score(:,2),[sX,sY,frmSect]);
    
end

%% Stick all the important stuff into a structure for easy access
% 
imgs.imgA = reshape(imgA,[sX,sY,sZ]);
imgs.imgD = reshape(imgD,[sX,sY,sZ]);
imgs.fDate = fDate;
imgs.fNum = fNum;
imgs.imgHem = imgHem;
imgs.imgVolt = imgVolt;
imgs.slope = slope;

%toc
    