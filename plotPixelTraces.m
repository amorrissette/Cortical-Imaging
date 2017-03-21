function plotPixelTraces(img)

trials = 115:1:124;
results = zeros(10000,1026,length(trials));
for tr = 1:length(trials)
    out = preProcVSFP5('0222',num2str(trials(tr)));
    img = out.imgDR;

region = roiSelect((out.fDate),out.fNum);

%imgs = vsfp_data.filtered_output
[sX, sY, sZ] = size(img(region(3):region(4),region(1):region(2),:));

% reshape into 1x10002 array (first two numbers correspond to original
% coordinates
horizData = zeros(sX,sY,sZ+2);
for x = region(1):region(2)
    for y = region(3):region(4)
        horizData(x,y,1:sZ+2) = [x y squeeze(img(x,y,:))'];
    end
end

hImg = reshape(horizData, [sX*sY, 1026]);
[val, ind] = max(hImg(:,3:end),[],2);

% Normalize Data to Max Value 
nImg = [hImg(:,1:2) bsxfun(@rdivide,hImg(:,3:end),val./100)];%./val];

% And Sort Array
[ind2, I] = sort(ind);

sImg = zeros(sX*sY,sZ+2);

for i = 1:length(I)
    sImg(i,:) = nImg(I(i),:);
end
figure, imagesc(sImg,[0,100]);

results(:,:,tr) = nImg;
end

% Create 1x10000 array for each pixel in image


% Normalize activity in each pixel by latency to incraese after lick