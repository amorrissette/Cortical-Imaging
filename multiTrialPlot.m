function multiTrialPlot(files, fDate, mouseID)
    

for X = 1:length(files)
    
fNum = files(X);

out = preProcVSFPlight(fDate,fNum,mouseID);
