function playMovie3(out,mask,writeMov)

if writeMov == 1
      mkdir('tmpDir9');
end
clear x
close all

h = figure;
[~,~,sZ] = size(out.imgDR);
if nargin > 1
    mask = mask;
else
    mask = ones(100,100);
end
blur3 = bsxfun(@times,out.blur3,mask);

if isfield(out,'irLicks') 
    rLicks = out.irLicks;
    lLicks = out.ilLicks;
else
    rLicks = zeros(1,sZ);
    lLicks = zeros(1,sZ);
end    

if isfield(out,{'rTrial','lTrial'})
    rTrial = out.rTrial;
    lTrial = out.lTrial;
else 
    rTrial = 0;
    lTrial = 0;
end

if isfield(out,'APint')
    APint = out.APint;
else
    APint = [0,0];
end

for x = 1:1:sZ
%     if ishandle(h) == 1
        subplot(1,2,1), imagesc(out.imgD1(:,:,x)), caxis([0 8000]), colormap('parula'), title('Base'), axis off square
        colorbar('hide')
        subplot(1,2,2), imagesc(blur3(:,:,x).*100), caxis([0 0.5]), title('Ratiometric'), axis off square, hold on
        c = colorbar('SouthOutside');
        c.Label.String = 'deltaR/R0 (%)';
        newLabel = [num2str((x-49)*20) ' ms'];
        text('units','pixels','position',[5 5],'fontsize',18,'string',newLabel,'Color','r')
         % Plot Licks on the video as well
%         if rLicks(x) == 1 
%             plot(10,10,'r.','MarkerSize',50)
%         elseif lLicks(x) == 1
%             plot(10,10,'b.','MarkerSize',50)
%         else
%             plot(10,10,'w.','MarkerSize',50)
%         end
               
        % Plot AP interval
%         if x >= APint(1)*200 && x<=APint(2)*200
%             if rTrial == 1
%                 plot(20,10,'r.','MarkerSize',50)
%             else
%                 plot(20,10,'b.','MarkerSize',50)
%             end
%         else
%             plot(40,10,'w.','MarkerSize',50)
%         end
        
        hold off
        
      

% Pause is needed for the figure to update


    drawnow
    
% And save the image for every processed frame
    print('-f1','-dtiff',strcat('tmpDir9','/af',num2str(x),'.tiff'));
%     close(h);


%         if (190 < x) && (x < 220)
%             pause(0.1)
%         else
%             pause(0.0001)
%         end
        

end
%         pause(0.001)
%     else
%         break
%     end



disp(['Writing output video from analyzed frames: ''' 'VSFP_Opto_SNr3' '''']);
imageNames = dir(fullfile('tmpDir9','af*.tiff'));
imageNames = {imageNames.name}';
imageStrings = regexp([imageNames{:}],'(\d*)','match');
imageNumbers = str2double(imageStrings);
[~,sortedIndices] = sort(imageNumbers);
sortedImageNames = imageNames(sortedIndices);
outputVideo = VideoWriter('VSFP_Opto_SNr3');
outputVideo.FrameRate = 20;
open(outputVideo);
for ii = 1:length(sortedImageNames)
    img = imread(fullfile('tmpDir9',sortedImageNames{ii}));
    writeVideo(outputVideo,img);
end
close(outputVideo);

end

