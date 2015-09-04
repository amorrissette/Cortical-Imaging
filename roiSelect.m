function region = roiSelect(date, file)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Loads b/w base image from trial and allows user to draw ROI over image
%   for further analysis
%
%   Usage region = roiSelect(date, file);
%       where the INPUT_FILE is un-processed vsfp data and REGION is X and
%           Y coordinate ranges 
%       
%       REGION output is used for preprocessing in preProcVSFP or vsfp2mov
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all

% Open the .rsm file associated with the VSFP data file, reshape, and crop
path = ['/Volumes/djlab/RawData/rhett/VSFP3_' num2str(date) '_2015/VSFP_01A0' num2str(date) ...
    '-' num2str(file) '.rsm'];

fid = fopen(path,'r','n');
fdata = fread(fid,'int16');
fdata = reshape(fdata, 128, 100);
fdata = fdata(21:120,:);

% Plot figure 
fig = figure;
colormap('gray');
imagesc(fdata');


% Select ROI
rect = getrect(fig);
close all

% Calculate ROI boundaries from rect 
x1 = floor(rect(1));
x2 = x1 + round(rect(3));
y1 = floor(rect(2));
y2 = y1 + round(rect(4));


% Output ROI to variable region
region = [x1,x2,y1,y2];

end


