function output = bregmaMaps(input)

%%%%%
%
%   Generate Maps based on position of bregma in image
%       Each ROI diameter can be set independently
%
%%%%%

%%% Locations 
%   1. M2 (0.25 , 1), (-0.25,1)
%   2. M1 (1 , 1), (-1,1)
%   3. S1BF (3,-1.75), (-3,-1.75)

%   5. V1 (2.5,-4.75), (-2.5,-4.75)
%   6. ptA (1.25,-2.75), (-1.25, -2.75)
%

colors = ['c','c','g','g','b','b','y','y','m','m','r','r'];
lStyles = ['-',':','-',':','-',':','-',':','-',':','-',':'];
fig = figure;
imagesc(input.baseD),colormap('gray')
hold on
[x, y] = getpts(fig);
bregma = round([x,y]);
ROICoords = [1.75,0;-1.75,0;... % 2.75,0.5;-2.75,0.5;...
    1.5,1.75;-1.5,1.75;...
    3,-1.75;-3,-1.75]; %2.5,-3.75;-2.5,-3.75;1.25,-2.75;-1.25,-2.75];
numROIs = length(ROICoords);

xCoords = -ROICoords(:,1).*10+bregma(2);
yCoords = -ROICoords(:,2).*10+bregma(1);

for x = 1:numROIs
    rectangle('Curvature', [1 1],'position',[yCoords(x)-4 xCoords(x)-4 8 8],'EdgeColor',colors(x),'LineStyle',lStyles(x),'LineWidth',2.0)
end
output.bregma = 10*bregma;
output.coords = [xCoords,yCoords];
output.colors = colors;
output.lStyles= lStyles;


