function [fpath, fstr, pathName] = find_vsfp(fileName, mouseID)

%%%%%%%%%%%%%%%%%%
%
%   function to find vsfp data that may be saved in various directories
%   Called within functions:
%       -readCMOS6.m
%
%   May need to update paths list to find VSFP files...
%       *also important to note sequence of paths for VC*
%
%%%%%%%%%%%%%%%%%%

%% Begin Search For VSFP Files 

% Get date from filename 
fDate = (fileName(9:12));

% Potential Directories that may hold file of interest
paths = {['/Volumes/My Book/JaegerLab/' mouseID '_' fDate '_2016/'],...
    ['/Volumes/MAC_ONLY/' mouseID '/'],...
    ['/Volumes/SD_0016/DJ_Lab/vsfp_imaging/' mouseID '_' fDate '_2016/'],...
    ['/Volumes/SD_0016/DJ_Lab/vsfp_imaging/' mouseID '_' fDate '_2017/A_B/'],...
    ['~/OneDrive - Emory University/' mouseID '/'],...
    ['~/OneDrive - Emory University/' mouseID '_' fDate '_2016/'],...
    ['~/OneDrive - Emory University/' mouseID '_' fDate '_2017/' mouseID '/'],...
    ['/Volumes/My Book/New Folder/M2_1200Deg_CD1_Left/'],...
    ['/Volumes/My Book/New Folder/M2_FreqSweep_CD1_Left/']};


fids = zeros(1,length(paths)); 
x = 1;
done = 0;

while x < length(paths)+1
    if done == 0
    try
        fpath = [paths{x} fileName];
% Attempt to read the file
        fids(x)=fopen(fpath,'r','b');    
        fstr=fread(fids(x),'int8=>char')';
        if fids(x) > 0
            done = 1;
            disp(['Found file in ' paths{x} 'directory'])
        end
    catch
        %disp(['Unable to find file in ' paths{x} ' directory']) 
        x = x + 1;
    end
    y = x;
    else
        break
    end
end
pathName = paths{y};
% Attempy to read the file again
fclose(fids(y));

