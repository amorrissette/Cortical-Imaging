function plotRegion6(out)

times1 = 0.005:0.005:2.56;
yLimits = [-0.005, 0.015]*100;
stim = 200;
stimTime = stim/200;
fDate = out.fDate;
fNum = out.fNum;
mouse = out.mouseID;

maps = bregmaMaps(out);
bregma = maps.bregma;
coords = round(maps.coords);
colors = maps.colors;
lStyles = maps.lStyles;
nReg = length(maps.coords);
regions = ones(4,nReg);
yCoords = (coords(:,2));
xCoords = (coords(:,1));
x = 1
for x = 1:nReg
    xCoord = coords(x,1);
    yCoord = coords(x,2);
    regions(:,x) = [coords(x,2)-5, 10+coords(x,2)-5, coords(x,1)-5, 10+coords(x,1)-5];
    region = regions(:,x);
    
    dataAP = bsxfun(@minus,out.blur3(region(3):region(4),region(1):region(2),:),out.blur3(region(3):region(4),region(1):region(2),1));
    [sX,sY,sZ] = size(dataAP);
    dataReAP = reshape(dataAP,[sX*sY,sZ]);
%     dataRePole = reshape(dataPole,[sX*sY,sZ]);
%     dataReLick = reshape(dataLick,[sX*sY,sZ]);
    
%     subplot(nReg,6,x*6-2), plot(times,mean(dataRePole,1),colors(x)), ylim(yLimits);
   subplot(1,2,2), plot(times1,(mean(dataReAP,1)*100),colors(x),'linestyle',lStyles(x),'linewidth',1), ylim(yLimits);
%     subplot(nReg,6,x*6), plot(times,mean(dataReLick,1),colors(x)), ylim(yLimits);
hold on
end
%line([(stim) (stim)],[yLimits(1) yLimits(2)],'linewidth',2)
p=patch([stimTime stimTime+2 stimTime+2 stimTime],[yLimits(1) yLimits(1) yLimits(2) yLimits(2)],'r');
  set(p,'FaceAlpha',0.1);
  set(p,'EdgeAlpha',0);
  
subplot(1,2,1), imagesc(out.imgA(:,:,100)), colormap('gray'), axis off
hold on 
rectangle('Curvature', [1 1],'position',[bregma(2)-3 bregma(1)-3 6 6],'EdgeColor','w','LineWidth',2.0)
for x = 1:nReg
    rectangle('Curvature', [1 1],'position',[yCoords(x)-5 xCoords(x)-5 10 10],'EdgeColor',colors(x),'LineStyle',lStyles(x),'LineWidth',3.0)
end
% if exist(out.irLicks)
%     licks = find(diff([zeros(9,1);out.irLicks(9:end)]) == 1);
%     lickTimes = times1(licks);
%     subplot(1,2,2), plot(lickTimes,ones(length(licks))*yLimits(2)-0.1,'k.','LineWidth',2.0)
% end