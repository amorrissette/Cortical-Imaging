function HRwin = HRfilter(imgD,fDate,fNum,Fs)

%%%%%%%
%
%   Function to find peak HR power and filter out signal around max power
%       Need to find peak beacuse hemodynamic signal may vary depending on
%       anesthesia or awake imaging 
%
%       Usage:
%           out = HRfilter(in)
%
%%%%%%%

%% Locations to grab
ROIs = 0;

if ROIs == 1
    for x = 1:4;
        region = roiSelect(fDate,fNum);
        xLoc(x) = region(1);
        yLoc(x) = region(3);
    end
else
    xLoc = [25,25,75,75];
    yLoc = [25,75,25,75];
end

% pre-allocate vars

[~,~,sZ] = size(imgD);
Df = ones(length(xLoc),sZ);
DfTest = (squeeze(imgD(1,1,:))-imgD(1,1,1))/imgD(1,1,1);
[pxxTest,~] = pwelch(DfTest,[],[],[],Fs);
pxx = ones(length(xLoc),length(pxxTest));
F = ones(1,length(pxxTest));

for x = 1:length(xLoc)
    xL = xLoc(x);
    yL = yLoc(x);
    Df(x,:) = (squeeze(imgD(xL,yL,:))-imgD(xL,yL,1))/imgD(xL,yL,1);
    [pxx(x,:),F] = pwelch(Df(x,:),[],[],[],200);
end

[~,locs,~,p] = findpeaks(mean(pxx));

p(F(locs) < 2.5) = [];
locs(F(locs) < 2.5) = [];
peakLoc = locs((p == max(p)));
HRfreq = F(peakLoc);
HRwin = [HRfreq-2.5,HRfreq+2.5];

