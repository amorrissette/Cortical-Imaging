function [cmosData, AnaIn1, AnaIn2, StmTrg, fpath] = readCMOS6(fileName,mouseID)
% purpose: Import CMOS files from the MiCAM Ultima-L system
% input: 
% 
% outputs:
%   cmosData = three-dimensional matrix containing the optical mapping
%       image data 
%   AnaIn1 = vector of the signal recorded from "Analog Input #1"
%   AnaIn2 = vector of the signal recorded from "Analog Input #2"
%   StmTrg = vector of the signal recorded from "Stim/Trig"
% 
% taken with permission from Dr. Igor Efimov's cardiac electrophysiology
% lab at Washington University in St. Louis 
% (Roger Chang via Dr. Vadim Fedorov - 11/29/10)
%
% changes: 
% 4/21/2011: 
%    1) Import Analog and Stimulation/Trigger channels with the cmosData
%    2) Eliminated the filtering algorithim, using filtfilt, previously
%           present
%

%% Read file-list from .rsh file (all of this now performed with find_vsfp.m - AEM 9/2/15)
% Find the path of .rsh (head file)
[fpath, fstr, pathName] = find_vsfp(fileName,mouseID);

% locate the Data-File-List
Dindex = find(fstr == 'D');
for i = 1:length(Dindex)
    if isequal(fstr([Dindex(i):Dindex(i)+13]),'Data-File-List')
        origin = Dindex(i)+14+2; % there are two blank char between each line
        break;
    end
end

% Save the data file paths
len = length(fstr);
N = 1000;  % assume file list < 1000 files
dataPaths = cell(N,1);
pointer = origin;  
while ~isequal(fstr([pointer:pointer+3]),'.rsm')
    pointer = pointer + 1;
end
dataPaths{1,1} = fstr([origin:pointer+3]);
origin = pointer + 4 + 2;
seq = 1;
while origin<len
    seq = seq+1;
    pointer = origin;
    while ~isequal(fstr([pointer:pointer+3]),'.rsd')
        pointer = pointer + 1;
    end
    dataPaths{seq,1} = fstr([origin:pointer+3]);
    origin = pointer+4+2;
end
dataPaths = dataPaths(1:seq);

%% Read CMOS data
% The 'num' variable indicates the number of '*.rsd' files reading from, 
%   which the header '*.rsh' file points to.  
num = length(dataPaths);
cmosData = zeros(100,100,(num-1)*256);
ExcessData = zeros(100, 20, (num-1)*256);
for i = 1:num-1
    fpath = [pathName dataPaths{i+1}];
    fid=fopen(fpath,'r','l');        % use big-endian format
    fdata=fread(fid,'int16')';
    fclose(fid);
    fdata = reshape(fdata,12800,256);
    if i == 1
        fdata(:,1) = fdata(:,2);  % first frame is the absolute signal; frame afterwards are differential.
    end
    for j = 1:size(fdata,2)
        % retrieve the Image Data in the variable cmosData
        oneframe = fdata(:,j);  % one frame at certain time point
        oneframe = reshape(oneframe,128,100);
        oneframe = oneframe(21:120,:);
        cmosData(:,:,j+(i-1)*256) = -oneframe';
        
        % retrieve the Analog and other signals in the variable ExcessData
        excessDataFrame = fdata(:, j);
        excessDataFrame = reshape(excessDataFrame, 128, 100);
        excessDataFrame = excessDataFrame(1:20, :);
        ExcessData(:, :, j+(i-1)*256) = -excessDataFrame';
    end
    clear fdata;
end

% retrieve the Analog and Stm/Trg signal from the variable ExcessData
%   1) The analog signals are in 'columns' 13 and 15 
%       and the Stm/Trg signal is in column 9
%   2) Each value is part of a '4 line group'; therefore need to sample 
%       every fourth value because each value is repeated 4 times.
%    *sampling difference: for every Image Data frame, 
%       there are 20 recorded values from the Analog and Stm/Trg values
%   3) Reshape so that it is a vector instead of groups of '*.rsd' samples
%           original vector size: 20, (num-1)*256
 AnaIn1 = reshape(squeeze(ExcessData(1:4:80, 13, :)), 20*((num-1)*256), 1);
 AnaIn2 = reshape(squeeze(ExcessData(1:4:80, 15, :)), 20*((num-1)*256), 1);
 StmTrg = reshape(squeeze(ExcessData(1:4:80,  9, :)), 20*((num-1)*256), 1);