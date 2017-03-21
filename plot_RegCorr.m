function plot_RegCorr(vsfp_data)

region = roiSelect((vsfp_data.fDate),vsfp_data.fNum, vsfp_data.mouseID);

dataEql = vsfp_data.blur3(region(3):region(4),region(1):region(2),:);
dataBlur = vsfp_data.blur3;

[sX,sY,sZ] = size(dataEql);

dataReBlur = reshape(dataBlur,[10000,sZ])';
dataReEql = reshape(dataEql,[sX*sY,sZ]);
meanReEql = mean(dataReEql)';
CorrMap = zeros(10000,1);

for x = 1:10000
    CorrMap(x) = corr(dataReBlur(:,x),meanReEql);
end

imagesc(reshape(CorrMap,[100,100])), caxis([0.5 1])