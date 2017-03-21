function multiMovie(out,files)
mID = out.mouseID;
fDate = out.fDate;

for X = 1:length(files)
    out = preProcVSFP7(fDate,files(X),mID);
    
    