function plot_ROIMovie(input,argin)

%%%%%
%
%   Function that will plot region and also play a movie of the full image
%
%   Usage plot_RegMovie(input)
%       where input is the output structure from preProcVSFP7 function
%
%%%%%
nargin
if nargin > 1
    mask = argin;
else
    mask = ones(100,100);
end

region = roiSelect((input.fDate),input.fNum,input.mouseID);

dataEql = input.blur3(region(3):region(4),region(1):region(2),:);
[sX,sY,sZ] = size(dataEql);
dataReEql = reshape(dataEql,[sX*sY,sZ]);
dataMean = mean(dataReEql,1);
dataMin = min(dataMean);
dataMax = max(dataMean);
h = figure;

for x = 150:1:300
    if ishandle(h) == 1
    hold off
    subplot(1,3,1), imagesc(input.imgD(:,:,x)), caxis([0 8000]), title('Base'), axis off square
    subplot(1,3,1), hold on, rectangle('position',[region(1) region(3) region(2)-region(1)+1 region(4)-region(3)+1],'EdgeColor','r')
    subplot(1,3,2), imagesc(bsxfun(@times,input.blur3(region(3):region(4),region(1):region(2),x),-mask(region(3):region(4),region(1):region(2)))), caxis([-0.01 0.01]), title('Ratiometric'), axis off square
    subplot(1,3,2), rectangle('position',[region(1) region(3) region(2)-region(1)+1 region(4)-region(3)+1],'EdgeColor','r')
    newLabel = [num2str(x*5) ' ms'];
    text('units','pixels','position',[10 5],'fontsize',15,'string',newLabel,'Color','w')
    subplot(1,3,3), plot(dataMean.*-1), hold on, line([x x],[dataMin, dataMax],'Color',[1 0 0]), axis square, title('ROI')
    pause(0.02)
    else 
        break
    end
end