function smiles(array,name)

array2 = array-array(1);
maxA = max(array2);
minA = min(array2);
if maxA > abs(minA)
    dA = maxA;
else
    dA = abs(minA);
end
array3 = array2/dA;


x1=[1 cos(pi/12) cos(pi/6) cos(pi/4) cos(pi/3) cos(5*pi/12) cos(pi/2) -cos(5*pi/12) -cos(pi/3) -cos(pi/4) -cos(pi/6) -cos(pi/12) -1];
l=length(x1);
for i=1:l
    y1(i)=sqrt(1-(x1(i)^2));
end

yr1=-y1;


% xx=0:0.01:1;
% yy = spline(x,y,xx);
% plot(x,y,'o',xx,yy);
% % plot(x,y,xx)


x2=0.02*x1-0.4;
y2=0.02*y1+0.4;
yr2=-y2+0.8;



axis([-2 2 -2 2]);

h = figure;

for X = 1:length(array3)
    if ishandle(h)
    
        x4=[0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4];
        l1=length(x4);

        for i=1:l1
            y4(i)=-1.5*(-(array3(X))*x4(i)^2)-0.45;
        end
        xx = -(array3(X)-1)/2;
        yy = abs(array3(X)-1)/2;

        subplot(1,2,1)
        rectangle('FaceColor',[0.5 1-xx 1-yy],'Curvature', [1 1],'position',[-1 -1 2 2],'EdgeColor','k','linewidth',2), axis('square'), axis('off')
        hold on

        plot(x4,y4,'k-','LineWidth',2)

        x5=-x4;
        plot(x5,y4,'k-','LineWidth',2)

        rectangle('FaceColor',[0 0 0],'Curvature', [1 1],'position',[-0.5 0.2 0.2 0.2],'EdgeColor','k','linewidth',2)
        rectangle('FaceColor',[0 0 0],'Curvature', [1 1],'position',[0.3 0.2 0.2 0.2],'EdgeColor','k','linewidth',2)

        hold off
        pause(0.05)


        subplot(1,2,2),plot(array,'k','linewidth',2)
        hold on, line([(X) (X)],[min(array) max(array)],'linewidth',2), hold off
    else
        break
    end
end