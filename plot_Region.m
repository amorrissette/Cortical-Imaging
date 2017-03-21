function  results = plot_Region(vsfp_data)

region = roiSelect((vsfp_data.fDate),vsfp_data.fNum, vsfp_data.mouseID);
dataA = vsfp_data.imgGA(region(3):region(4),region(1):region(2),:);
dataD = vsfp_data.imgGD(region(3):region(4),region(1):region(2),:);
% dataVolt = vsfp_data.imgVolt(region(3):region(4),region(1):region(2),:);
% dataHem = vsfp_data.imgHem(region(3):region(4),region(1):region(2),:);
dataEql = vsfp_data.blur3(region(3):region(4),region(1):region(2),:);
% dataMvmt = vsfp_data.Dmot(region(3):region(4),region(1):region(2),:);
[sX,sY,sZ] = size(dataEql);
dataReA = reshape(dataA,[sX*sY,sZ]);
dataReD = reshape(dataD,[sX*sY,sZ]);
% dataReVolt = reshape(dataVolt,[sX*sY,sZ]);
% dataReHem = reshape(dataHem,[sX*sY,sZ]);
dataReEql = reshape(dataEql,[sX*sY,sZ]);
MDATA = mean(dataReEql,1);
% dataReMvmt = reshape(dataMvmt,[sX*sY,sZ]);
figure, subplot(2,3,1), plot(dataReA')
subplot(2,3,4), plot(mean(dataReA,1));

subplot(2,3,2), plot(dataReD');
subplot(2,3,5), plot(mean(dataReD,1));
figure 
subplot(1,2,1), imagesc(vsfp_data.imgA(:,:,100)), colormap('gray'), axis off
hold on, rectangle('position',[region(1) region(3) region(2)-region(1)+1 region(4)-region(3)+1],'EdgeColor','r','linewidth',1)
subplot(1,2,2), plot((MDATA),'linewidth',1);
hold on
% subplot(1,2,2),plot(MDATA+std(dataReEql(:,145:295),1),'c.','linewidth',0.5);
% subplot(1,2,2),plot(MDATA-std(dataReEql(:,145:295),1),'c.','linewidth',0.5);
% 
% figure, plot(mean(dataReMvmt,1));
% % Nx = length(mean(dataReVolt,1));
% nsc = floor(Nx/40);
% nov = floor(nsc/2);
% figure, spectrogram(mean(dataReEql,1),hamming(nsc),nov,max(512),200,'yaxis');
% figure, spectrogram(mean(dataReD,1),hamming(nsc),nov,max(512),200,'yaxis');
% figure, spectrogram(mean(dataReA,1),hamming(nsc),nov,max(512),200,'yaxis');
results.dataReEql = dataReEql;
results.meanEql = mean(dataReEql,1);
% caxis([-20 5])
% figure, [~,F1,T1,P1] = spectrogram(mean(dataReEql,1),hamming(nsc),nov,max(512),200,'yaxis');
% caxis([-25 25])
% spec.F1 = F1;
% spec.T1 = T1;
% spec.P1 = P1;
% spec.data = mean(dataReEql,1);
% spec.regionSize = size(region);
