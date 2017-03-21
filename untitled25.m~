
%%
% Peter 1200 deg twitch
files = [856:905];

% Peter sweeps
files = fTypes(s1',3)'; % Catch
files = fTypes(s2',3)'; % single pulse at 1 sec
files = fTypes(s3',3); % 
files = fTypes(s4',3);
files = fTypes(s5',3);
files = fTypes(s6',3)'; % Ramp and Hold?


files = [490:500];

% Left AP Awake Trials
files = [362,364,366,370,372] %,376,378,383,384]

% Right AP Awake Trials
files = [363,365,367,368,369,371] %373,374,377,379]

% AP Anesthetized Trials
%files = [150:159]
files = [600:619];
%files = [170:175]
files = [620:639];

%OptoFiles
% files = [420,421,423:429]
files = [410:419]; % 51 trials in each for 8 preproc
files = [400:409]
%420, 421,423:429];

%%
x = 1;
total = zeros(100,100,512,length(files));

for X = files
    out = preProcVSFP7('0316',num2str(files(x)),'VSFP14');
    total(:,:,:,x) = out.blur3;
    if X ~= files(end)
    clear out
    end
    x = x+1;
    
end

mTotal = mean(total,4);

