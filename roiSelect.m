function region = roiSelect(date, file, mouseID)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Loads b&w base image from trial and allows user to draw ROI over image
%   for further analysis
%
%   Usage region = roiSelect(date, file);
%       where the INPUT_FILE is un-processed vsfp data and REGION is X and
%           Y coordinate ranges 
%       
%       REGION output is used for preprocessing in preProcVSFP or vsfp2mov
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%close all
fpre = 'VSFP';
% Open the .rsm file associated with the VSFP data file, reshape, and crop
[fpre '_01A' num2str(date) '-' file '_B.rsh']
[fpath, fstr, pathName] = find_vsfp([fpre '_01A' num2str(date) '-' file '_B.rsh'],mouseID);
pathName
path = [pathName fpre '_01A' num2str(date) ...
    '-' (file) 'B.rsm'];
path
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
close(fig)

% Calculate ROI boundaries from rect 
x1 = floor(rect(1));
x2 = x1 + round(rect(3));
y1 = floor(rect(2));
y2 = y1 + round(rect(4));


% For single click case create 5x5 square
% if x1 == x2 && y1 == y2
%     x3 = x1-2;
%     x4 = x2+2;
%     y3 = y1-2;
%     y4 = y2+2;
% 
%     region = [x3,x4,y3,y4];
% else
% Output ROI to variable region
    region = [x1,x2,y1,y2];

% end


