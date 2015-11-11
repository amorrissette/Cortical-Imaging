function out = preProcVSFP3(fDate, fNum) 

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
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Convert inputs if needed
if isnumeric(fNum) == 1
    fStr = num2str(fNum);
else fStr = fNum;
end
if length(fStr) < 3
    fStr = ['0' fStr];
end 

% Load image files
imgD = readCMOS6(['VSFP_01A0' num2str(fDate) '-' fStr '_A.rsh']);
imgA = readCMOS6(['VSFP_01A0' num2str(fDate) '-' fStr '_B.rsh']);

% get rid of variables we don't need (using clear just to remember what var
% we have from the readCMOS6 function)
% clear(anaD1, anaD2, StmTrgA, StmTrgD, anaA1, anaA2, fpathD, fpathA);

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
region = roiSelect(fDate, fNum);
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
Dmot2d = reshape(Dmot,[sXY, sZ]);
Amot2d = reshape(Amot,[sXY, sZ]);
% Dphys2d = reshape(Dphys, [sXY, sZ]);
% Aphys2d = reshape(Aphys, [sXY, sZ]);

% Number of frames to use for baseline average --first 200 frames (1sec) of data
avgingFr = 1*FsImg;

% Create stucture for output and version control
out = struct('fileNum',[num2str(fDate) '-' num2str(fNum)],'version','v3.0','date',date);

%% Equalized Ratio to correct for wavelength-dependent loght absorption by hemoglobin

% Calculate standard deviations of Acceptor and Donor channels 
hemfilter = make_ChebII_filter(1, FsImg, [10 15], [10*0.9 15*1.1], 20);
HPfilter = make_ChebII_filter(3, FsImg, 5, 5*0.9, 20);

% Preallocate couple variables for speed :)
Ahem2d = ones(sXY,numFrames);
Dhem2d = ones(sXY,numFrames);
imgVoltFilt = ones(sXY,numFrames);
imgDRFilt = ones(sXY,numFrames);

%% First perform operations outside of cycle:
        
% Determine if presence of optogenetic stimulation
slope = diff(squeeze(imgD(50,50,:)));
I = find(abs(slope)>10*std(slope));
if length(I) == 2
    disp('Stimulation trial detected...')
    imgA1 = Aphys;
    imgD1 = Dphys;
    % And set stimulation artifact times to 0
    imgA1(:,:,I(1):I(2)) = 0;
    imgD1(:,:,I(1):I(2)) = 0;
else
    imgA1 = Aphys;
    imgD1 = Dphys;
end

Dphys2d = reshape(imgD1, [sXY, sZ]);
Aphys2d = reshape(imgA1, [sXY, sZ]);

% Add 500 for normalization correction        
An2d = Aphys2d + 500;
Dn2d = Dphys2d + 500;

% Averages of baseline VSFP recordings
Aavg = mean(An2d(1:sXY,1:avgingFr),2);
Davg = mean(Dn2d(1:sXY,1:avgingFr),2);

%% Cycle through each pixel (100 x 100 window) *This is slow! - remove in future versions*
for xy = 1:sXY
    
% filter for hemodynamic signal (12-14 hz)
    Ahem2d(xy,:) = filtfilt(hemfilter.numer, hemfilter.denom,An2d(xy,:));
    Dhem2d(xy,:) = filtfilt(hemfilter.numer, hemfilter.denom,Dn2d(xy,:));
end 

% Standard deviation of filtered signal   
stdA = std(Ahem2d,0,2);
stdD = std(Dhem2d,0,2);    
    
% Implemented in future version...
% if nargin == 3; 
%     fNumbers = input('Enter the first and last files for average gain calculation:   ');
%     fNums = fNumbers(1):1:fNumbers(end);
%     avgGain = gainCalc(fDate,fNums);
%     gamma = avgGain(1);
%     delta = avgGain(2);
% else
% end

% gamma and delta values for each pixel    
gamma = 0.5*(1+((Aavg.*stdD)./(Davg.*stdA)));
delta = 0.5*(1+((Davg.*stdA)./(Aavg.*stdD)));


% Calculate equalized A and D data
imgDiffA = bsxfun(@minus,An2d,Aavg);
imgDiffD = bsxfun(@minus,Dn2d,Davg);

Aeql = bsxfun(@plus,bsxfun(@times,gamma,imgDiffA),Aavg);
Deql = bsxfun(@plus,bsxfun(@times,delta,imgDiffD),Davg);

% Calculate new baseline values for equalized frames
avgAe = mean(Aeql(:,1:avgingFr),2);
avgDe = mean(Deql(:,1:avgingFr),2);        
        
% and gain-corrected rationmetric signal
imgDiv = Aeql ./ Deql;
avgDiv = avgDe ./ avgAe;          
imgDR = bsxfun(@times,imgDiv,avgDiv)-1;

% Motion estimate
%motDiv2d = Amot2d ./ Dmot2d;
%motDiv = reshape(motDiv2d,[sX,sY,sZ]);
mvmtEst = squeeze(mean(mean((Dmot))));

%% Run PCA 
D1d = reshape(imgD1,[sX*sY*sZ,1]);
A1d = reshape(imgA1,[sX*sY*sZ,1]);
imgTotal = [A1d,D1d];

% specify number of componenets = 2
[~,score,~] = pca(imgTotal,'NumComponents', 2);  

imgHem = reshape(score(:,1),[sX,sY,sZ]);
imgVolt = reshape(score(:,2),[sX,sY,sZ]);
imgVolt2d = reshape(score(:,2),[sXY,sZ]);

%% High-Pass Filter Results 
for xy = 1:sXY
    imgVoltFilt(xy,:) = filtfilt(HPfilter.numer, HPfilter.denom, imgVolt2d(xy,:));
    imgDRFilt(xy,:) = filtfilt(HPfilter.numer, HPfilter.denom, imgDR(xy,:));
end

%% Output Variables

out.imgD = imgD;
out.imgA = imgA;
out.fNum = fNum;
out.fDate = fDate;
out.imgHem = imgHem;
out.imgVolt = imgVolt;
out.slope = slope;
out.imgDR = reshape(imgDR,[sX,sY,sZ]);
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
out.stim = I;
out.mvmt = mvmtEst;

end
