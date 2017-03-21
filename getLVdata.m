function lvData = getLVdata(fDate,fNum,mouseID)

[NUM,TXT,RAW] = xlsread(['/Volumes/SD_0016/DJ_Lab/' mouseID '_' fDate '_2016.xlsx']);
imgTrials = NUM(:,1); 
loc = find(imgTrials == str2double(fNum));
fileName = [TXT{loc+1,5} '_nh.txt'];
i = NUM(loc, 4);

da = load(['/Volumes/SD_0016/lv_data/' mouseID '/' fileName]);

if da(end,1) == 0 
    da(end,:) = [];
end

tDist = da(:,3); % distance
tSpeed = da(:,2); % speed
tTime = da(:,4); % 
tTime = tTime - tTime(1);
Trials = da(:,1);
Lick1 = da(:,5);
Lick2 = da(:,6);
iTime = 0:5:1024*5;
acc = 0.5;
rTime = round(tTime*100/acc)*acc*10;

X = struct('trial',[]);

% Create indexes for each trial
% 1 is pre
% 2 is sample
% 3 is response
% 4 is reward 
% 5 is inter-trial delay
iStr = num2str(i);
idx1 = find(da(:,1)>= i & da(:,1)<i+0.2);
idx2 = find(da(:,1)>i+0.1 & da(:,1)<i+0.3);
idx3 = find(da(:,1)>i+0.2 & da(:,1)<i+0.4);
idx4 = find(da(:,1)>i+0.3 & da(:,1)<i+0.5);
idx5 = find(da(:,1)>i+0.4 & da(:,1)<i+0.6);
total = find(da(:,1)>= i & da(:,1)<i+0.6);

index = total;
t0 = rTime(idx1(1));
t1 = rTime(idx1)-t0;
t2 = rTime(idx2)-t0;
t3 = rTime(idx3)-t0;
% t4 = rTime(idx4)-t0;


rTime2 = rTime(index);
rTime3 = rTime2 - rTime2(1);
lvData.Lick1 = Lick1(index);
lvData.Lick2 = Lick2(index);

lvData.iTime = iTime;
lvData.rTime = rTime3;
lvData.sampleStart = t2(1)./5;
lvData.ResponseStart = t3(end)./5;
lvData.GoCue = t3(1)./5;
ResponseLicksL = idx3.*Lick1(idx3);
ResponseLicksL(ResponseLicksL==0) = [];
ResponseLicksR = idx3.*Lick2(idx3);
ResponseLicksR(ResponseLicksR==0) = [];
if ResponseLicksL > 0
    lvData.ResponseLickL = (rTime(ResponseLicksL(1))-t0)./5;
else
    lvData.ResponseLickL = 0;
end
if ResponseLicksR > 0
    lvData.ResponseLickR = (rTime(ResponseLicksR(1))-t0)./5;
else
    lvData.ResponseLickR = 0;
end

% lvData.Lick

% RewardTime2 = t4;
% RewTime0 = RewardTime(1);
% RewardTime2 = RewardTime - RewTime0;
% lick2_0 = 
