function vlCorrBatch
files = {'051', '052', '053','054','055','056','057','058','059','060'}%,'024','025','026','027','028','029','030','031'};
% '041','042','042','044','045','046','047','048','049','050','001','031','032','033','034','035','036','037','038','039','040','002','003','004','005','006',{'021', '022', '023','024','025','026','027','028','029','030',
temp = ns_open_file('/Volumes/PC_MAC/DJlab/ephys/VSFP_Rhett/VSFP2/VSFP2_LFP_718.hdf5');
for i = 1:length(files)
    [imgs, ~] = preProcVSFP1(718,files{i});
    blur5 = spatialAvg(imgs.imgDR,5);
    lfp = preProcLFP('VSFP2_LFP_718.hdf5', str2double(files{i})-4,temp);
    lfpRe = lfp.xResamp';
%     lfpShuff = dataShuff(lfpRe,100);
    C = vlCorr(imgs,lfp);
    [x,y] = find(C == max(max(C)));
%     x = 46;
%     y = 56;
    hold on, plot(y,x,'o')
    % imagesc(C)
    title(['Corr from Trial ' files{i}])
    figure, subplot(4,1,1), plot(lfp.xResamp(1:2000));
    title(['LFP from Trial ' files{i}])
    subplot(4,1,2), plot(squeeze(imgs.imgDR(x,y,1:2000)));
    title(['max Corr imgDR VSFP ' files{i}]);
    [cxy,F] = mscohere(squeeze(blur5(x,y,1:2000)),lfpRe(1:2000),[],[],2^10,200);
%     subplot(6,1,3), plot(F,cxy)
    params.tapers = [7,13];
    params.pad = 0;
    params.Fs = 200;
    [c,~,~,~,~,f] = coherencyc(squeeze(blur3(x,y,1:2000)),lfpRe(1:2000),params);
%     subplot(6,1,4), plot(f,c)
    Ctot = zeros(100,513);
    CcTot = zeros(100,1025);
    for i1 = 1:100
    lfpShuff = dataShuff(lfpRe,200);
    [Cxy,F] = mscohere(squeeze(blur5(x,y,1:2000)),lfpShuff,[],[],2^10,200);
    Ctot(i1,:) = Cxy;
    [C,~,~,~,~,f] = coherencyc(squeeze(blur5(x,y,1:2000)),lfpShuff,params);
    CcTot(i1,:) = C;
    end
    C1mean = mean(Ctot);
    std1 = std(Ctot);
    Ccmean = mean(CcTot);
    std2 = std(CcTot);
    subplot(4,1,3), plot(F,C1mean), hold on, plot(F,C1mean+3.*std1), plot(F,cxy)
    params.tapers = [7,13];
    params.pad = 0;
    params.Fs = 200;
%     [C,~,~,~,~,f] = coherencyc(squeeze(blur5(x,y,1:2000)),lfpShuff,params);
    subplot(4,1,4), plot(f,Ccmean), hold on, plot(f,Ccmean+2.*std2), plot(f, c)
    pause(2)
end



    