function C = vlCorr(imgs, lfp)

C = ones(100,100);

for x = 1:100
    for y = 1:100
        C(x,y) = corr(squeeze(imgs.imgDR(x,y,1:2000)),lfp.xResamp(1,1:2000)');
    end
end
figure
imagesc(C);