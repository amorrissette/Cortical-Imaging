
files = {'227', '228', '229','230','231'};

for x = 1:length(output.startTimes)
    tTime = floor(mean(output.endTimes - output.startTimes));
    output.trialTimes(x,:) = (output.startTimes(x):output.startTimes(x)+tTime);
    [imgs, ~] = preProcVSFP1(713,files{x});
    mvmt.xResamp = resample(output.mvmt(output.trialTimes(1,2:end)),1024,155);
    C = ones(100,100,length(output.startTimes));
    for X = 1:100
        for Y = 1:100
            C(X,Y,x) = corr(squeeze(imgs.imgDR(X,Y,1:1024)),mvmt.xResamp');
        end
    end
end
rgbImage = data / max(max(data));
    
for x = 1:length(output.startTimes)
imshow(rgbImage,'InitialMagnification', 100,'Border','tight');


