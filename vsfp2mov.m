function vsfp2mov(vsfp_data)

% Writes 3-D VSFP matrix to single temp image files, transfers those files to a
% movie (.avi) and erases temp image files to save space
%
%   Usage: 
%       vsfp2mov(vsfp_data);
%

close all
region = roiSelect(916,140);
z = size(vsfp_data,3);
%vsfp_data = spatialAvg(vsfp_data,3);
% vsfp_roi = zeros(100,100,z);
% for n = 1:z
%      vsfp_roi(1:100,1:100,n) = vsfp_data(1:100,1:100,n).*ROI;
% end
mkdir('tmpDir1');
% [~,Imin] = min(vsfp_roi(:));
% [I1,I2,I3] = ind2sub(size(vsfp_roi),Imin);
% minVal = vsfp_roi(I1,I2,I3);
% vsfp_non_zero = vsfp_data+(-1*minVal);
% [~,Imax] = max(vsfp_roi(:));
% [I1,I2,I3] = ind2sub(size(vsfp_roi),Imax);
% maxVal = vsfp_roi(I1,I2,I3);
% sF = 255/maxVal;
% vsfp_scaled = vsfp_non_zero.*sF;
% vsfp_unit8 = uint8(vsfp_scaled);

for i = 1:z

    data = vsfp_data(region(3):region(4),region(1):region(2),i);
    data_roi = vsfp_data(region(3):region(4),region(1):region(2),i);
    figHandle = figure('Visible','off'); hold on;
    %figHandle = figure; hold on;
    rgbImage = data / max(max(data));
    imshow(rgbImage,'InitialMagnification', 100,'Border','tight');
    colormap(figHandle,parula);
    axis off;
    hold on
    
% Create Label with Frame Info
    newLabel = ['F#' num2str(i)];
    text('units','pixels','position',[0 10],'fontsize',14,'string',newLabel,'Color','r')
        
    drawnow
    
% And save the image for every processed frame
    print('-f1','-dtiff',strcat('tmpDir1','/af',num2str(i),'.tiff'));
        
    close(figHandle);
end

disp(['Writing output video from analyzed frames: ''' 'outputVideoName' '''']);
imageNames = dir(fullfile('tmpDir1','af*.tiff'));
imageNames = {imageNames.name}';
imageStrings = regexp([imageNames{:}],'(\d*)','match');
imageNumbers = str2double(imageStrings);
[~,sortedIndices] = sort(imageNumbers);
sortedImageNames = imageNames(sortedIndices);
outputVideo = VideoWriter('outputVideoName');
outputVideo.FrameRate = 30;
open(outputVideo);
for ii = 1:length(sortedImageNames)
    img = imread(fullfile('tmpDir1',sortedImageNames{ii}));
    writeVideo(outputVideo,img);
end
close(outputVideo);
    