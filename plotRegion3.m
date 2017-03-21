function plotRegion3(out)

nReg = 6;
regions = ones(4,nReg);
times = -0.5:0.005:1.5;
colors = ['r','b','g','k','c','m'];
yLimits = [-0.002, 0.006];
stim = 200;
fDate = out.fDate;
fNum = out.fNum;
mouse = out.mouseID;

for x = 1:nReg
    regions(:,x) = roiSelect(fDate,fNum,mouse);
    region = regions(:,x);
    
    dataAP = out.blur3(region(3):region(4),region(1):region(2),stim-50:stim+200,:);
    [sX,sY,sZ] = size(dataAP);
    dataReAP = reshape(dataAP,[sX*sY,sZ]);
%     dataRePole = reshape(dataPole,[sX*sY,sZ]);
%     dataReLick = reshape(dataLick,[sX*sY,sZ]);
    
%     subplot(nReg,6,x*6-2), plot(times,mean(dataRePole,1),colors(x)), ylim(yLimits);
    subplot(nReg,2,x*2), plot(mean(dataReAP,1),colors(x)), ylim(yLimits);
%     subplot(nReg,6,x*6), plot(times,mean(dataReLick,1),colors(x)), ylim(yLimits);

end

subplot(1,2,1), imagesc(out.imgA(:,:,100)), colormap('gray'), axis off
hold on 

for x = 1:nReg
    rectangle('Curvature', [1 1],'position',[regions(1,x) regions(3,x) regions(2,x)-regions(1,x)+1 regions(4,x)-regions(3,x)+1],'EdgeColor',colors(x),'LineWidth',1.0)
end