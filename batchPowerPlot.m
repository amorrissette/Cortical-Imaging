function batchPowerPlot(date, files)


for x = 1:length(files)
    [imgs,~] = preProcVSFP1(date,files(x));
    band = powerPlot(imgs.imgDR);
    betaLow(:,:,x) = band.betaLow_power;
    betaHigh(:,:,x) = band.betaHigh_power;
    gammaLow(:,:,x) = band.gammaLow_power;
    gammaHigh(:,:,x) = band.gammaHigh_power;
    delta(:,:,x) = band.delta_power;
    alpha(:,:,x) = band.alpha_power;
    theta(:,:,x) = band.theta_power;
end

bL_sum = mean(betaLow,3);
figure, imagesc(bL_sum)
title('bL_sum');
bH_sum = mean(betaHigh,3);
figure, imagesc(bH_sum)
title('bH_sum');
gL_sum = mean(gammaLow,3);
figure, imagesc(gL_sum)
title('gL_sum');
gH_sum = mean(gammaHigh,3);
figure, imagesc(gH_sum)
title('gH_sum');
d_sum = mean(delta,3);
figure, imagesc(d_sum)
title('d_sum');
a_sum = mean(alpha,3);
figure, imagesc(a_sum)
title('a_sum');
t_sum = mean(theta,3);
figure, imagesc(t_sum)
title('t_sum');



    