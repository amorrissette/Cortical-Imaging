function imgOut = makeMask(imgsIn,numMasks)

%%%%%
%
% Function that will generate mask based on level of hemodynamic signal in
% frames from cortical imaging with VSFP Butterfly 1.2
%
%
%   Rhett Morrissette 08.02.2016
%
%%%%%
% 
f1 = figure;
imagesc(imgsIn.baseD), colormap('gray')

if nargin > 1
    nMasks = numMasks;
else
    nMasks = 1;
end

BW = zeros(100,100,numMasks);

for x = 1:nMasks
    h = imfreehand;
    BW(:,:,x) = createMask(h);
    clear h
end 



close(f1)
imgOut = mean(BW,3);
imgOut(imgOut > 0) = 1;

% % 
% % imgMax = imgsIn.stdA < 25;
% % imgMin = imgsIn.stdA > 4.8;
% img2 = bsxfun(@times,imgsIn.stdA,imgsIn.stdA2);
% img2min = img2 > 90;
% % imagesc(img2min)
% img2max = img2 < 400;
% % figure, imagesc(img2max)
% totalMap = (img2min + img2max + img2max2 + img2min2)-3;
% MapBR = totalMap;
% MapBR = bwareaopen(MapBR,20);
% MapBR = imclearborder(totalMap);
% imgOut = MapBR;
% 
% img2min = (sfA) > 0.2;
% img2max = (sfA) < 1;
% 
% img2min2 = sfD > 0.2;
% img2max2 = sfD < 1;