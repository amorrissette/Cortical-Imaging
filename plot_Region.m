function plot_Region(vsfp_data)

region = roiSelect(str2double(vsfp_data.fDate),vsfp_data.fNum);
dataVolt = vsfp_data.imgVoltFilt(region(3):region(4),region(1):region(2),:);
dataHem = vsfp_data.imgHem(region(3):region(4),region(1):region(2),:);
dataEql = vsfp_data.imgDRFilt(region(3):region(4),region(1):region(2),:);
dataMvmt = vsfp_data.Dmot(region(3):region(4),region(1):region(2),:);
[sX,sY,sZ] = size(dataVolt);
% size(dataEql)
dataReVolt = reshape(dataVolt,[sX*sY,sZ]);
dataReHem = reshape(dataHem,[sX*sY,sZ]);
dataReEql = reshape(dataEql,[sX*sY,sZ]);
dataReMvmt = reshape(dataMvmt,[sX*sY,sZ]);
figure, subplot(2,3,1), plot(dataReHem')
subplot(2,3,4), plot(mean(dataReHem,1));
subplot(2,3,2), plot(dataReVolt');
subplot(2,3,5), plot(mean(dataReVolt,1));
subplot(2,3,3), plot(dataReEql');
subplot(2,3,6), plot(mean(dataReEql,1));
figure, plot(mean(dataReMvmt,1));
Nx = length(mean(dataReVolt,1));
nsc = floor(Nx/10);
nov = floor(nsc/2);
figure, spectrogram(mean(dataReVolt,1),hamming(nsc),nov,max(512),200,'yaxis');
caxis([-20 5])
figure,spectrogram(mean(dataReEql,1),hamming(nsc),nov,max(512),200,'yaxis');
% caxis([-25 25])