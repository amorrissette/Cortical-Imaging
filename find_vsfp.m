function [fpath, fstr, pathName] = find_vsfp(fileName)

%%%%%%%%%%%%%%%%%%
%
%   function to find vsfp data that may be saved in various directories
%   Called within functions:
%       -readCMOS6.m
%
%%%%%%%%%%%%%%%%%%

%% Begin Search For VSFP Files 

% Get date from filename
fDate = (fileName(10:12));
paths = {['/Volumes/PC_MAC/DJlab/vsfp_imaging/VSFP_' fDate '_2015/'],...
    ['/Volumes/djlab/RawData/rhett/VSFP3_' fDate '_2015/']};

% First hard-drive, then attempt server, then error
x = 1;
while x < length(paths)+1
    try
        fpath = [paths{x} fileName];
% Attempy to read the file
        fid=fopen(fpath,'r','b');    
        fstr=fread(fid,'int8=>char')';
    catch
        warning('Unable to find file in first directory') 
        x = x + 1;
    end
    y = x;
    x = length(paths) + 1;
end
pathName = paths{y};
% Attempy to read the file again
fclose(fid);

