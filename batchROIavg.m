function [data_mean, data] = batchROIavg(date, files)


for x = 1:length(files)
    disp(['processing file ' num2str(x) ' out of ' num2str(length(files)) ' ...'])
    [imgs] = preProcVSFP7(date,files(x));
    if x == 1
        region = roiSelect((imgs.fDate),imgs.fNum);
    end
    dataEql = imgs.blur3(region(3):region(4),region(1):region(2),:);
    [sX,sY,sZ] = size(dataEql);
    dataReEql = reshape(dataEql,[sX*sY,sZ]);
    if x == 1
        data = ones(length(files),sZ);
    end
    data(x,1:sZ) = mean(dataReEql,1);
end

data_mean = mean(data);
data_std = std(data);
figure, plot(data_mean)
hold on 
plot(data_mean+data_std,'b:')
plot(data_mean-data_std,'b:')
title('data avg');



    