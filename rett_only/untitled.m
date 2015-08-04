[imgs,time] = preProcVSFP1(718,'0');
blur3 = spatialAvg(imgs.imgDR,3);
blur5 = spatialAvg(imgs.imgDR,5);
avg = vsfpAvg(blur5,8);

figure
subplot(3,1,1), plot(time(600:1000),squeeze(imgs.imgAf(60,20,600:1000)./100-1))
% [PxxA, freqA] = pwelch(squeeze(imgs.imgA(60,20,:)),[],[],2^12,200);
% subplot(3,2,2), plot(freqA,log(PxxA));
subplot(3,1,2), plot(time(600:1000),squeeze(imgs.imgDf(60,20,600:1000)./100-1))
% [PxxD, freqD] = pwelch(squeeze(imgs.imgD(60,20,:)),[],[],2^12,200);
% subplot(3,2,4), plot(freqD,log(PxxD));
subplot(3,1,3), plot(time(600:1000),squeeze(blur5(60,20,600:1000)))
% [PxxDR, freqDR] = pwelch(squeeze(imgs.imgDR(60,20,:)),[],[],2^12,200);
% subplot(3,2,6), plot(freqDR,log(PxxDR));