function doingStuff2

% For single trial analysis of imaging and behavioral data

%%
mouse = 'VSFP12';
fDate = '1102';
lvPath = '~/Desktop/LabViewFiles/VSFP12_1102/';
fNum = '370';

% Load excel file with lv/img sync info
[NUM,~,RAW] = xlsread([lvPath mouse '_' fDate '.xlsx']);
% Load .mat file with lv trial info
X = find(str2double(fNum) == NUM(:,2));
lvData = load([lvPath RAW{X+1,1} '.mat']);
% and extract data row only data for img trial
lvNum = NUM(X,1);
lTrial = NUM(X,3);
rTrial = NUM(X,4);

if lTrial == 1
    disp('Left AP Trial')
elseif rTrial == 1
    disp('Right AP Trial')
else
    disp('Fail AP Trial')
end

sampRate = 200;
Fs = 1/sampRate;

trialData = lvData.dataTRs(lvNum+1,:);
lLicks = trialData{14}.*Fs;
lLicks(lLicks > 0) = 1;
rLicks = trialData{15}.*Fs;
rLicks(rLicks > 0) = 1;
APint = trialData{17};
RewInt = trialData{18};

% Now load imaging file
out = preProcVSFP7(fDate,fNum,mouse);

if length(lLicks) < out.sZ
    ilLicks = [lLicks, zeros(1,out.sZ-length(lLicks))];
    irLicks = [rLicks, zeros(1,out.sZ-length(rLicks))];
else
    ilLicks = lLicks(1:out.sZ);
    irLicks = rLicks(1:out.sZ);
end

out.ilLicks = ilLicks;
out.irLicks = irLicks;
out.APint = APint;
out.lTrial = lTrial;
out.rTrial = rTrial;

%%
out = betaCalc(out);
playBeta_Movie(out)

%%
out = LickAmp(out);
playLick_Movie(out)

%%
mask = makeMask(out,2);

%%
plot([ilLicks, irLicks]/100)

%%
plot_Region(out)

%%
plotRegion7(out)

%%
out = vsfpPCA(out);

%% 
playMovie4(out,mask)

%%
plot_ROIMovie(out)

%%
plotModIndex(out)

%%
plot_RegMovie(out)

%%
