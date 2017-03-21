function results = plotBeta(out)

%%%%%%%
%
%   Function to plot beta amplitude over averaged cortical region
%
%   results = plotBeta(out)
%       
%
%%%%%%%

region = roiSelect((out.fDate),out.fNum, out.mouseID);
dataEql = out.betaBlur(region(3):region(4),region(1):region(2),:);
[sX,sY,sZ] = size(dataEql);

dataReEql = reshape(dataEql,[sX*sY,sZ]);
MDATA = mean(dataReEql,1);

figure 
subplot(1,2,1), imagesc(out.imgA(:,:,100)), colormap('gray'), axis off
hold on, rectangle('position',[region(1) region(3) region(2)-region(1)+1 region(4)-region(3)+1],'EdgeColor','r','linewidth',1)
subplot(1,2,2), plot((MDATA),'linewidth',1);

results.dataReEql = dataReEql;
results.meanEql = mean(dataReEql,1);
