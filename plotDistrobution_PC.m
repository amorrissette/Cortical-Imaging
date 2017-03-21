%% For Optogenetics Stimulation Trials
% For use with PC files stored on Dropbox
%



%% Set filepath for location of files
% need to adjust for specific computer  

% for Rhett's computer 
filepath = '/Users/AMmacbookpro/Dropbox/DJ Lab/PC_matlab/';
mouse = 'PC3/';
%%

% Baseline Trained Mice Trials
files = {'PC3_0301_2017_AP2_6',...
    'PC3_0301_2017_AP2_8',...
    'PC3_0301_2017_AP2_7',...
    }

files = {
    'VSFP10_1026_2016_AP2_1',... %good for R and L but slow responses
    'VGAT2_0125_2017_AP2_1',... %good L and R licking behavior (some precense of correct early licking
    'VGAT1_0125_2017_AP2_4',... % Back and forth licking, R latency is about 1s and quite a few L licks at the R onset
    'VGAT2_0125_2017_AP2_2',...
    'VGAT3_0210_2017_AP2_1',...
    'VGAT3_0209_2017_AP2_2',...
    'VGAT3_0208_2017_AP2_4',...
    'VGAT2_0210_2017_AP2_0',...
    'VGAT2_0208_2017_AP2_6',...
    'VGAT2_0207_2017_AP2_0',...
    'VGAT1_0210_2017_AP2_4'}; 

    % R and L are awesome, some early licking for L trials, but none for R trials
    % 'VGAT1_1102_2016_AP1_1',... % DNU - okay for L terrible R performance
    % 'VGAT2_1028_2016_AP1_1',... %DNU - good for L, tons of early R licking, but not great R licking during response
    % 'VGAT2_1103_2016_AP1_1',... %DNU - Terrible R licking 
    % 'VSFP11_1026_2016_AP1_1',... % DNU - L terrible, but R has decent long latency response activity
    % 'VGAT3_1028_2016_AP1_1',... %okay L and R, quite variable response times though...
    % 'VGAT3_1103_2016_AP1_1',... %good for L (only 20 trials), some early licking on R trials to the L spout...
    
% Level 3 expert trials 
files = {
    'VGAT3_0209_2017_AP3_5',...
    'VGAT3_0209_2017_AP3_4',...
    'VGAT3_0209_2017_AP3_3',...
    'VGAT2_0207_2017_AP3_4',...
    'VGAT2_0207_2017_AP3_3',...
    'VGAT2_0207_2017_AP3_2',...
    };
    
% AP above control trials
files = {
   'VGAT1_0210_2017_AP2_6APabove',...
   'VGAT2_0208_2017_AP2_7APabove',...
   'VGAT3_0209_2017_AP2_6APabove',...
   'VGAT3_0210_2017_AP2_4APAbove'}

    % ...'VGAT1_0125_2017_AP2_4'};

% Post SNr Opto Baseline
files = {
    'VGAT1_0125_2017_AP2_4',... % Back and forth licking, R latency is about 1s and quite a few L licks at the R onset
    'VGAT1_0210_2017_AP2_9',...
    'VGAT1_0210_2017_AP2_8',...
    'VGAT2_0210_2017_AP2_5',...
    'VGAT3_0208_2017_AP2_6'}; 
    
% SNr Opto Trials
files = {'VSFP10_1026_2016_AP2_7',...
    'VGAT1_1102_2016_AP1_2',...
    'VGAT2_1028_2016_AP1_2',...
    'VGAT2_1103_2016_AP1_2',...
    'VGAT3_1028_2016_AP1_3',...
    'VGAT3_1103_2016_AP1_2',...
    'VSFP10_1026_2016_AP2_6',...
    'VSFP11_1026_2016_AP1_4',...
    'VGAT2_0125_2017_AP2optoSNr_3',...
    'VGAT2_0125_2017_AP2optoSNr_4',...
    'VGAT1_0210_2017_AP2_5SNrOpto',...
    'VGAT3_0210_2017_AP2_5SNrOpto',...
    };
    
% APAbove SNr Opto During Response Trials
files = {
    'VGAT3_0210_2017_AP2_6APAbove_SNrOpto',...
    'VGAT2_0210_2017_AP2_4APabove_SNrOpto',...
    'VGAT1_0210_2017_AP2_7SNrOpto_APabove',...
    };

% VM Opto Trials
files = {'VGAT2_1103_2016_AP1_3',...
    'VGAT3_1103_2016_AP1_3',...
    'VSFP10_1026_2016_AP2_7'};

% Opto Shutter Control Trials
files = {'VGAT2_0125_2017_AP2optoSNrcontrol_5'};

%% Process Data For regular training conditions (no optogenetic manipulations)

RL = zeros(1,1401,2);
RR = zeros(1,1401,2);

for x = 1:length(files)
fpath = [filepath mouse];
lvInfo = lvTrialInfo(fpath,files{x});

RespLicks = plotTrialLicks(fpath,files{x});

Resp = RespLicks;

Rtrials = lvInfo.rTrials;
Ltrials = lvInfo.lTrials;

Rtrials_noInitFail = Rtrials-(Rtrials.*lvInfo.initFail);
Ltrials_noInitFail = Ltrials-(Ltrials.*lvInfo.initFail);

RespR = Resp(logical(Rtrials_noInitFail),:,:);
RespL = Resp(logical(Ltrials_noInitFail),:,:);

RL = [RL;RespL];
RR = [RR;RespR];

disp(filename)
disp('Correct  of Failed L Trials: ')
disp('

end

%% Generate Figures For 

tvals = -3:0.005:4;

figure,hold on
ax = gca;
ax.FontSize = 14;
ax.YLabel.String = 'P(Lick)';
ax.YLabel.FontSize = 16;
ax.XLabel.String = 'time (s)';
ax.XLabel.FontSize = 16;
area(tvals,(mean(RR(:,:,1))),'FaceAlpha',1, 'EdgeAlpha',0,'FaceColor','b')
area(tvals,(mean(RR(:,:,2))),'FaceAlpha',0.8, 'EdgeAlpha',0,'FaceColor','r')
line([0,0],[0,0.3],'LineStyle','--','LineWidth',2,'Color','k')

figure, hold on
ax = gca;
ax.FontSize = 14;
ax.YLabel.String = 'P(Lick)';
ax.YLabel.FontSize = 16;
ax.XLabel.String = 'time (s)';
ax.XLabel.FontSize = 16;
area(tvals,(mean(RL(:,:,1))),'FaceAlpha',1, 'EdgeAlpha',0,'FaceColor','b')
area(tvals,(mean(RL(:,:,2))),'FaceAlpha',0.8, 'EdgeAlpha',0,'FaceColor','r')
line([0,0],[0,0.3],'LineStyle','--','LineWidth',2,'Color','k')


%%
%%%%
%%%
%
%
%%%
%%%%

%% Process Data For Optogenetic Stimulation Trials

RL = zeros(1,1401,2);
RR = zeros(1,1401,2);
RLo = zeros(1,1401,2);
RRo = zeros(1,1401,2);

for x = 1:length(files)
    
fpath = [filepath mouse];
lvInfo = lvTrialInfo(fpath,files{x});
initFails = lvInfo.initFail;
init = initFails(1:2:end);
initOpto = initFails(2:2:end);

[~,RespLicks] = plotTrialLicks2(files{x});
RespOpto = RespLicks(2:2:end,:,:);
Resp = RespLicks(1:2:end,:,:);

RtrialsOpto = lvInfo.rTrials(2:2:end)-initOpto>0;
RespROpto = RespOpto(RtrialsOpto,:,:);
Rtrials = lvInfo.rTrials(1:2:end)-init>0;
RespR = Resp(Rtrials,:,:);

LtrialsOpto = lvInfo.lTrials(2:2:end)-initOpto>0;
RespLOpto = RespOpto(LtrialsOpto,:,:);
Ltrials = lvInfo.lTrials(1:2:end)-init>0;
RespL = Resp(Ltrials,:,:);

RL = [RL;RespL];
RR = [RR;RespR];
RLo = [RLo;RespLOpto];
RRo = [RRo;RespROpto];

end


%% Plot Data For Optogenetic Stimulation Trials
tvals = -3:0.005:4;

figure,hold on
ax = gca;
ax.FontSize = 14;
ax.YLabel.String = 'P(Lick)';
ax.YLabel.FontSize = 16;
ax.XLabel.String = 'time (s)';
ax.XLabel.FontSize = 16;
p=patch([-0.5 0.5 0.5 -0.5],[0 0 0.3 0.3],'y');
set(p,'FaceAlpha',0.5,'EdgeAlpha',0);
area(tvals,(mean(RRo(:,:,1))),'FaceAlpha',1, 'EdgeAlpha',0,'FaceColor','b')
area(tvals,(mean(RRo(:,:,2))),'FaceAlpha',0.8, 'EdgeAlpha',0,'FaceColor','r')
line([0,0],[0,0.30],'LineStyle','--','LineWidth',2,'Color','k')

figure, hold on
ax = gca;
ax.FontSize = 14;
ax.YLabel.String = 'P(Lick)';
ax.YLabel.FontSize = 16;
ax.XLabel.String = 'time (s)';
ax.XLabel.FontSize = 16;
p=patch([-0.5 0.5 0.5 -0.5],[0 0 0.3 0.3],'y');
set(p,'FaceAlpha',0.5,'EdgeAlpha',0);
area(tvals,mean(RLo(:,:,1)),'FaceAlpha',1, 'EdgeAlpha',0,'FaceColor','b')
area(tvals,mean(RLo(:,:,2)),'FaceAlpha',0.8, 'EdgeAlpha',0,'FaceColor','r')
line([0,0],[0,0.30],'LineStyle','--','LineWidth',2,'Color','k')

%% Plot Data For Baseline "Catch" Trials In Between Optogenetic Stimulation

tvals = -3:0.005:4;

figure,hold on
ax = gca;
ax.FontSize = 14;
ax.YLabel.String = 'P(Lick)';
ax.YLabel.FontSize = 16;
ax.XLabel.String = 'time (s)';
ax.XLabel.FontSize = 16;
area(tvals,(mean(RR(:,:,1))),'FaceAlpha',1, 'EdgeAlpha',0,'FaceColor','b')
area(tvals,(mean(RR(:,:,2))),'FaceAlpha',0.8, 'EdgeAlpha',0,'FaceColor','r')
line([0,0],[0,0.30],'LineStyle','--','LineWidth',2,'Color','k')

figure, hold on
ax = gca;
ax.FontSize = 14;
ax.YLabel.String = 'P(Lick)';
ax.YLabel.FontSize = 16;
ax.XLabel.String = 'time (s)';
ax.XLabel.FontSize = 16;
area(tvals,(mean(RL(:,:,1))),'FaceAlpha',1, 'EdgeAlpha',0,'FaceColor','b')
area(tvals,(mean(RL(:,:,2))),'FaceAlpha',0.8, 'EdgeAlpha',0,'FaceColor','r')
line([0,0],[0,0.30],'LineStyle','--','LineWidth',2,'Color','k')



