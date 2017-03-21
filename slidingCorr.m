function C = slidingCorr(imgs)

% Window Size (1 frame = x ms)
slidWin = 10;

% Downscale Factor (Greatly reduces speed, but lose resolution)
dsFactor = 4;

sZ = imgs.sZ;
sX = imgs.sX/dsFactor;
sY = imgs.sY/dsFactor;
sZ1 = sZ-slidWin;

% trials = [122];
% C1 = ones(100,100,length(trials));
% C2 = ones(100,100,length(trials));
mask = makeMask(imgs);
imgMasked = bsxfun(@times, imgs.blur3, mask);
% imagesc(imgMasked(:,:,100));
imgDRds = imgMasked(1:dsFactor:end,1:dsFactor:end,:);
imgDRre = reshape(imgDRds,[sX*sY,sZ]);

B = (zeros(1,sZ));
C = ones(1,sX*sY);
Cmean = ones(sX,sY);

for x = 1:sX
    x
    for y = 1:sY
        if imgDRds(x,y,end) ~= 0
            for n = 1:(sX*sY)
                C(n) = corr(squeeze(imgDRds(x,y,:)),imgDRre(n,:)');
                if isnan(C(n)) == 1
                    C(n) = 0;
                end
            end
        else
            C = B;
        end
        Cmean(x,y) = mean(C,2);
    end
end

figure
imagesc(Cmean);


